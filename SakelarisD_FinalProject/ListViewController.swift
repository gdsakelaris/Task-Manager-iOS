//
//  ListViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
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
//
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<ItemObject>!
    var list: ListObject!
//// Backspace
//    let navItem = UINavigationItem(title: "ListViewController")
//    self.navigationItem = navItem
//    //
//    let backButton = UIBarButtonItem(title: "Back", style: .plain, target: ListViewController.self, action: #selector(backButtonTapped))
//    navItem.leftBarButtonItem = backButton
//    //
//    @objc func backButtonTapped() {
//        navigationController?.popViewController(animated: true)
//    }
////
//// End
//
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
//
    // "Table containing the list of list items."
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
        configureCell(cell, at: indexPath)
        return cell
    }
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = item.itemName
        cell.accessoryType = item.completed ? .checkmark : .none
    }
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
//
    // NSFetchedResultsControllerDelegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        ListItemsTable.reloadData()
    }
// Delete Functionality for Items
//
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(at: indexPath)
        }
    }
//
    func deleteItem(at indexPath: IndexPath) {
        let itemToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(itemToDelete)
        do {
            try context.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
//
// End
    override func viewDidLoad() {
        super.viewDidLoad()
        ListItemsTable.delegate = self
        ListItemsTable.dataSource = self
        ListItemsTable.register(UITableViewCell.self, forCellReuseIdentifier: "itemCell")
        ListNameHeadingLabel.text = list.listName
        initializeFetchedResultsController()
    }
}
