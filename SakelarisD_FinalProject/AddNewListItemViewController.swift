//
//  AddNewListItemViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
class AddNewListItemViewController: UIViewController, UITextFieldDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var list: ListObject!
    //
    // Text field where the user enters the name of their new list item
    @IBOutlet weak var NewListItemNameTextField: UITextField!
    
    
    //    @IBAction func NewListItemNameTextField(_ sender: Any) {
    //    }
    
    
    // Button that when tapped, saves the new list item
    // Upon tapping, the user will be taken back to the "List" view, where the new list item will be displayed inside of the "ListItemsTable"
    // This means that the text entered in the "NewListItemNameTextField" text field will appear inside a new "ListItemNameLabel" label within a newly created "ListItemsTableCell" cell when the user taps the "SaveNewListItemBTN" button
    @IBAction func SaveNewListItemBTN(_ sender: Any) {
        let newItemName = NewListItemNameTextField.text ?? ""
        if newItemName != "" {
            let newItem = ItemObject(context: context)
            newItem.itemName = newItemName
            newItem.completed = false
            newItem.list = list
            do {
                try context.save()
            } catch {
                print("Failed to save new list item: \(error)")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // return key
        NewListItemNameTextField.delegate = self
        
        // dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
//
    // return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
