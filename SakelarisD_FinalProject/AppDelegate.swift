//
//  AppDelegate.swift
//  SakelarisD_FinalProject
//
//  Created by Daniel Sakelaris on 3/11/23.
//

import UIKit
import CoreData
import UserNotifications
import EventKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // create an EventStore object
    let eventStore = EKEventStore()
    
    // Override point for customization after application launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // requests permission to send notifications, only prints if fails to receive it
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Failed to request authorization for notifications: \(error)")
            }
        }
        
        // Requests access to the user's calendar
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                print("Failed to request access to calendar: \(error)")
            } else if granted {
                print("Access to calendar granted")
            } else {
                print("Access to calendar denied")
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    

    /// Core Data

    // The persistent container for the application.
    lazy var persistentContainer: NSPersistentContainer = {
        // Loads any previously saved application data into a new container
        let container = NSPersistentContainer(name: "SakelarisD_FinalProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // check for fatal errors
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // Saves the core data
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

