//
//  ViewController.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/9/23.
//
import UIKit
import CoreData
class ViewController: UIViewController {
    // button to enter into the app (takes user to "YourLists" view)
    @IBAction func EnterBTN(_ sender: Any) {
        let yourListsViewController = self.storyboard?.instantiateViewController(withIdentifier: "YourListsViewController") as! YourListsViewController
        self.navigationController?.pushViewController(yourListsViewController, animated: true)
    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

