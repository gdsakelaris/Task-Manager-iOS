//
//  AddNewListItemViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//

import UIKit
import CoreData
import UserNotifications
import EventKit

class AddNewListItemViewController: UIViewController, UITextFieldDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var list: ListObject!
    var listItem: ItemObject?
    
    @IBOutlet weak var NewListItemNameTextField: UITextField!
    
    var hasDueDate: Bool = true
    @IBOutlet weak var DueDateSwitch: UISwitch!
    @IBAction func dueDateSwitchValueChanged(_ sender: UISwitch) {
        hasDueDate = sender.isOn
        DueDatePicker.isHidden = !hasDueDate
        DueDateLabel.isHidden = !hasDueDate
    }
    @IBOutlet weak var DueDatePicker: UIDatePicker!
    @IBOutlet weak var DueDateLabel: UILabel!
    @IBAction func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        updateDueDateLabel()
    }
    // UPDATE DUE DATE LABEL
    func updateDueDateLabel() {
        if hasDueDate {
            DueDateLabel.text = "Due Date: " + DateFormatter.localizedString(from: DueDatePicker.date, dateStyle: .medium, timeStyle: .short)
        } else {
            DueDateLabel.text = ""
        }
    }
    
    // ???
    var delegate: UINavigationControllerDelegate?
    
    // Button that when tapped, saves the new list item
    // Upon tapping, the user will be taken back to the "List" view, where the new list item will be displayed inside of the "ListItemsTable"
    // This means that the text entered in the "NewListItemNameTextField" text field will appear inside a new "ListItemNameLabel" label within a newly created "ListItemsTableCell" cell when the user taps the "SaveNewListItemBTN" button
    @IBAction func SaveNewListItemBTN(_ sender: Any) {
        if let itemName = NewListItemNameTextField.text {
            if let listItem = listItem {
                listItem.itemName = itemName
                listItem.list = list
                if hasDueDate {
                    listItem.dueDate = DueDatePicker.date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .short
                    DueDateLabel.text = dateFormatter.string(from: DueDatePicker.date)
                }
                updateCalendarEvent(for: listItem)
                do {
                    try context.save()
                } catch {
                    print("Failed to save new list item: \(error)")
                }
                navigationController?.popViewController(animated: true)
            } else {
                let newItemName = NewListItemNameTextField.text ?? ""
                if newItemName != "" {
                    let newItem = ItemObject(context: context)
                    newItem.itemName = newItemName
                    newItem.completed = false
                    newItem.list = list
                    if hasDueDate {
                        newItem.dueDate = DueDatePicker.date
                        createCalendarEvent(for: newItem)
                        scheduleNotification(for: newItem)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .short
                        DueDateLabel.text = dateFormatter.string(from: DueDatePicker.date)
                    }
                    do {
                        try context.save()
                    } catch {
                        print("Failed to save new list item: \(error)")
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    // CREATE NEW CALENDAR EVENT
    func createCalendarEvent(for item: ItemObject) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted, error == nil {
                let event = EKEvent(eventStore: eventStore)
                event.title = item.itemName ?? "Unknown Task"
                event.startDate = item.dueDate ?? Date()
                event.endDate = item.dueDate ?? Date()
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("Event saved to calendar")
                    // Store the calendar event ID in the ItemObject instance
                    item.calendarEventID = event.eventIdentifier
                    try self.context.save()
                } catch {
                    print("Failed to save event to calendar: \(error.localizedDescription)")
                }
            } else {
                print("Failed to request access to calendar: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    // UPDATE A CALENDAR EVENT
    func updateCalendarEvent(for item: ItemObject) {
        if let eventID = item.calendarEventID {
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { granted, error in
                if granted, error == nil {
                    if let event = eventStore.event(withIdentifier: eventID) {
                        // Update the event with the new title/due date
                        event.title = item.itemName ?? "Unknown Task"
                        event.startDate = item.dueDate ?? Date()
                        event.endDate = item.dueDate ?? Date()
                        //
                        self.scheduleNotification(for: item)
                        
                        // Save the updated event
                        do {
                            try eventStore.save(event, span: .thisEvent)
                            print("Event updated in calendar")
                        } catch {
                            print("Failed to update event in calendar: \(error.localizedDescription)")
                        }
                    }
                } else {
                    print("Failed to request access to calendar: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }
    // DELETE A CALENDAR EVENT
    func deleteCalendarEvent(for item: ItemObject) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted, error == nil {
                // Find the calendar event with the same ID as the list item
                let event = eventStore.event(withIdentifier: item.calendarEventID ?? "")
                if let event = event {
                    do {
                        try eventStore.remove(event, span: .thisEvent)
                        print("Event removed from calendar")
                    } catch {
                        print("Failed to remove event from calendar: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Failed to request access to calendar: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    // SCHEDULE NOTIFICATION
    func scheduleNotification(for item: ItemObject) {
        let content = UNMutableNotificationContent()
        content.title = "Task Due"
        content.body = item.itemName ?? "Unknown Task"
        content.sound = UNNotificationSound.default
        let soundSetting = UNNotificationSound.default
        if soundSetting == .none {
            print("Notification sound is disabled in app settings.")
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(item.objectID)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification for item: \(item.itemName ?? "Unknown Task"), error: \(error)")
            }
        }
    }
    // VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        // dismissal
        NewListItemNameTextField.delegate = self
        
        // edit/update/delete (eud)
        if let listItem = listItem {
            NewListItemNameTextField.text = listItem.itemName
            DueDatePicker.date = listItem.dueDate!
        }
        
        // bogus - fix this
        DueDatePicker.isHidden = true
        DueDateLabel.isHidden = true
        
        // outside keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    // return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
