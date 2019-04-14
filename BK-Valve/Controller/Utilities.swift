//
//  Utilities.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 15/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    // MARK: Standard alert box
    func messageBox(title: String, message: String, btText: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
    alert.addAction(UIAlertAction(title: btText, style: UIAlertAction.Style.default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Alert box with go to settings function
    func messageBox(title: String, message: String, btText: String, goToSettings: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if goToSettings{
            let settingsAction = UIAlertAction(title: "Settings", style: .default){ (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl){
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
                
            }
            alert.addAction(settingsAction)
        }
        
        alert.addAction(UIAlertAction(title: btText, style: UIAlertAction.Style.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func messageBox(title: String, message: String, btText: String, angleValue: Int){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    
    
        let saveAction = UIAlertAction(title: "Save", style: .default){
            [unowned self] action in
    
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {return}
    
            self.saveData(profileName: nameToSave, angleValue: angleValue) //, angleValue: angleValue
        }
    
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: btText, style: UIAlertAction.Style.default, handler: nil))
    
        self.present(alert, animated: true, completion: nil)
    }
    
    func messageBoxForEdit(title: String, message: String, btText: String) -> String{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: btText, style: UIAlertAction.Style.default, handler: nil))
        
        alert.addTextField()
        
        guard let textField = alert.textFields?.first else {return "nil"}
        
        self.present(alert, animated: true, completion: nil)
        
        return textField.text ?? "nil"
        }
    
    func saveData(profileName: String, angleValue: Int){ //, angleValue: Int
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
    
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)!
        let profile = NSManagedObject(entity: entity, insertInto: managedContext)
    
        //let angle = NSManagedObject(entity: entity, insertInto: managedContext)
    
        profile.setValue(profileName, forKeyPath: "name")
        profile.setValue(angleValue, forKey: "angle")
        //angle.setValue(angleValue, forKeyPath: "angleValue")
        do {
            try managedContext.save()
        } catch let error as NSError{
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
}
