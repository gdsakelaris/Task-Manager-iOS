////
////  EditListItemViewController.swift
////  SakelarisD_FinalProject
////
////  Created by Daniel Sakelaris on 3/17/23.
////
//
//import UIKit
//
//class EditListItemViewController: UIViewController {
//
//    func didEditListItem(_ listItem: ListItem) {
//            saveContext()
//        }
//
//    var listItem: ItemObject?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //////////////////
//        if let listItem = listItem {
//            NewListItemNameTextField.text = listItem.itemName
//            DueDatePicker.date = listItem.dueDate!
//        }
//
//        // return key
//        //NewListItemNameTextField.delegate = self
//
//        ///////////////////////////////////////////////
//        //DueDatePicker.isHidden = true
//        //DueDateLabel.isHidden = true
//        ////////////////////////////////////////////////
//
//        // dismiss keyboard
//        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
