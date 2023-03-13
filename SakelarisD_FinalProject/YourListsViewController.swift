//
//  YourListsViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
class YourListsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    // Table containing the list of lists
    @IBOutlet weak var YourListsTable: UITableView!
    // Button to add a new list (takes user to "AddNewList" view)
    @IBAction func AddNewListBTN(_ sender: Any) {
        let addNewListViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNewListViewController") as! AddNewListViewController
        self.navigationController?.pushViewController(addNewListViewController, animated: true)
    }
//
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
//
    // "Table containing the list of lists."
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = list.listName
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = fetchedResultsController.object(at: indexPath)
        let listViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        // error below
        listViewController.list = list
        self.navigationController?.pushViewController(listViewController, animated: true)
    }
//
    // NSFetchedResultsControllerDelegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        YourListsTable.reloadData()
    }
// Delete Functionality for Lists
//
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteList(at: indexPath)
        }
    }
//
    func deleteList(at indexPath: IndexPath) {
        let listToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(listToDelete)
        do {
            try context.save()
        } catch {
            print("Failed to delete list: \(error)")
        }
    }
//
// End
    override func viewDidLoad() {
        super.viewDidLoad()
        YourListsTable.delegate = self
        YourListsTable.dataSource = self
        YourListsTable.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        initializeFetchedResultsController()
    }
}



// Invalid Outlets:

// @IBOutlet weak var ListNameLabel: UILabel!

// // Cell within "YourListsTable" table
// @IBOutlet weak var YourListsTableCell: UITableViewCell!
// Label within each "YourListsTableCell" that displays the name of the list
