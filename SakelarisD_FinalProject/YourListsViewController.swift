//
//  YourListsViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
import EventKit
class YourListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
   
    var list: ListObject!
    var listItem: ItemObject?

    // setting up stored core data if there is any
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<ListObject>!
    //
    func initializeFetchedResultsController() {
        let request: NSFetchRequest<ListObject> = ListObject.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "listName", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // Table containing the list of lists
    @IBOutlet weak var YourListsTable: UITableView!
    
    // Button to add a new list (takes user to "AddNewListViewController" view)
    @IBAction func AddNewListBTN(_ sender: Any) {
        let addNewListViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewListViewController") as! AddNewListViewController
        // push AddNewListViewController onto the nav stack
        self.navigationController?.pushViewController(addNewListViewController, animated: true)
    }
    // set up for table containing the list of lists:
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    // begin operation on specific cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        // long tap gesture for editing?
        configureCell(cell, at: indexPath)
        return cell
    }
    // configures prototype cell/s for the list/s
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = list.listName
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.backgroundColor = UIColor.systemTeal
        cell.backgroundColor = UIColor.systemTeal
        cell.contentView.backgroundColor = UIColor.systemTeal
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
    }
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        let listViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.list = list
        self.navigationController?.pushViewController(listViewController, animated: true)
    }
    // NSFetchedResultsControllerDelegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        YourListsTable.reloadData()
    }
    /// Delete Functionality for Lists
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteList(at: indexPath)
        }
    }
    // Calling method to delete a list
    func deleteList(at indexPath: IndexPath) {
        let listToDelete = fetchedResultsController.object(at: indexPath)
        
        // Loop through all the items in the list and delete their corresponding calendar events (if they exist)
        if let items = listToDelete.items as? Set<ItemObject> {
            for item in items {
                if let eventID = item.calendarEventID {
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
            }
        }
        
        // Delete the list itself
        context.delete(listToDelete)
        do {
            try context.save()
        } catch {
            print("Failed to delete list: \(error)")
        }
    }
    
    // VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        YourListsTable.delegate = self
        YourListsTable.dataSource = self
        YourListsTable.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        initializeFetchedResultsController()
    }
}
