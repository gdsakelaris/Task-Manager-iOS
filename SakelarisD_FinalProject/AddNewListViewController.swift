//
//  AddNewListViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
class AddNewListViewController: UIViewController, UITextFieldDelegate {
    
    // Text field where the user enters the name of their new list
    @IBOutlet weak var NewListNameTextField: UITextField!
    
    // CONTEXT
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Upon tapping, the user will be taken back to the "Your Lists" view, where the new list will be displayed inside of the "YourListsTable"
    // This means that the text entered in the "NewListNameTextField" text field will appear inside a new "ListNameLabel" label within a newly created "YourListsTableCell" cell when the user taps the "SaveNewListBTN" button
    // It should also appear in the "ListNameHeadingLabel" in the new list's view (a new instance of "ListViewController")
    @IBAction func SaveNewListBTN(_ sender: Any) {
        guard let newListName = NewListNameTextField.text, !newListName.isEmpty else {
            // Show an alert if the user didn't enter a name for the new list
            let alert = UIAlertController(title: "Error", message: "Please enter a name for the new list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let newList = ListObject(context: context)
        newList.listName = newListName
        do {
            try context.save()
            navigationController?.popViewController(animated: true)
        } catch {
            // Show an alert if there was an error saving the new list
            let alert = UIAlertController(title: "Error", message: "Failed to save new list.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    // VIEWDIDLOAD
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // dismissal
        NewListNameTextField.delegate = self
        
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
