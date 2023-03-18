//
//  ListViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//

import UIKit
import CoreData
import EventKit
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate {
    
    // LIST list
    var list: ListObject!
    
    // Table containing the list of list items
    @IBOutlet weak var ListItemsTable: UITableView!
    
    // Label that displays the name of the current list at the top of the view
    @IBOutlet weak var ListNameHeadingLabel: UILabel!
    
    // Button to add a new list item (takes user to "AddNewListItem" view)
    @IBAction func AddNewListItemBTN(_ sender: Any) {
        let addNewListItemViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewListItemViewController") as! AddNewListItemViewController
        addNewListItemViewController.list = list
        self.navigationController?.pushViewController(addNewListItemViewController, animated: true)
    }
    
    // CONTEXT AND FETCHED RESULTS
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<ItemObject>!
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<ItemObject> = ItemObject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "itemName", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "list == %@", list)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    // setting up the table containing the list tasks:
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        // Adds "long press gesture recognizer" to cells - used for editing an existing task
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            cell.addGestureRecognizer(longPressRecognizer)
        configureCell(cell, at: indexPath)
        return cell
    }
    // LONG PRESS GESTURE RECOGNIZER
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            if let cell = gestureRecognizer.view as? UITableViewCell {
                // Get the index path of the cell
                if let indexPath = ListItemsTable.indexPath(for: cell) {
                    // Get the item object for the cell at this index path
                    let item = fetchedResultsController.object(at: indexPath)
                    // Call the EDIT ITEM function on the item being long-tapped
                    editItem(item)
                }
            }
        }
    }
    // Configures appearence, etc. of the prototype cells containing the tasks.
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = item.itemName
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.backgroundColor = UIColor.systemTeal
        cell.backgroundColor = UIColor.systemTeal
        cell.contentView.backgroundColor = UIColor.systemTeal
        cell.accessoryType = item.completed ? .checkmark : .none
    }
    // .completed called on single tap - adds a check mark to task cell's view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        item.completed = !item.completed
        do {
            try context.save()
        } catch {
            print("Failed to toggle item completion status: \(error)")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // NSFetchedResultsControllerDelegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        ListItemsTable.reloadData()
    }
    // .delete EDITINGSTYLE
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(at: indexPath)
        }
    }
    // DELETE ITEM AND CALENDAR EVENT
    func deleteItem(at indexPath: IndexPath) {
        let itemToDelete = fetchedResultsController.object(at: indexPath)
        
        // Delete the corresponding calendar event if it exists
        if let eventID = itemToDelete.calendarEventID {
            let eventStore = EKEventStore()
            let event = eventStore.event(withIdentifier: eventID)
            if let event = event {
                do {
                    try eventStore.remove(event, span: .thisEvent)
                    print("Calendar event deleted")
                } catch {
                    print("Failed to delete calendar event: \(error.localizedDescription)")
                }
            }
        }
        context.delete(itemToDelete)
        do {
            try context.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    // EDIT ITEM
    func editItem(_ listItem: ItemObject) {
        let EditListItemViewController = storyboard?.instantiateViewController(withIdentifier: "AddNewListItemViewController") as! AddNewListItemViewController
        EditListItemViewController.list = list
        EditListItemViewController.listItem = listItem
        self.navigationController?.pushViewController(EditListItemViewController, animated: true)
    }
    // VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        ListItemsTable.delegate = self
        ListItemsTable.dataSource = self
        ListItemsTable.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        ListNameHeadingLabel.text = list.listName
        initializeFetchedResultsController()
    }
}
