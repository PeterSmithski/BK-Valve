//
//  ProfileTableViewController.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 15/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import CoreData


class ProfileTableViewController: UITableViewController {
    


    @IBOutlet var profileTableView2: UITableView!
    
    var profileNames: [NSManagedObject] = []
    var profileName: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.title = "Profiles"
        UITabBar.appearance().barTintColor = UIColor.darkGray
        
        profileTableView2.register(UITableViewCell.self, forCellReuseIdentifier: "profileCell")
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return profileNames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profileName = profileNames[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        }
        
        let angleValueCD = profileName.value(forKeyPath: "angle") as! Int16
        
        
        cell!.textLabel?.text = profileName.value(forKeyPath: "name") as? String
        cell!.detailTextLabel?.text = String("\(angleValueCD)%")
        cell!.detailTextLabel?.textColor = .black
        cell!.backgroundColor = .darkGray
        return cell!
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Profiles"
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        fetchRequest.returnsObjectsAsFaults = false
        
        // MARK: Deleting object and saving changes
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            context.delete(self.profileNames[indexPath.row])
            self.profileNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            do {
                try context.save()
            } catch {
                print("Failed saving on delete")
            }
            tableView.reloadData()
        }
        // MARK: Updating Core Data after editing
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            
            if self.profileNames.count > 0{
                for result in self.profileNames{
                    if let desiredName = result.value(forKey: "name") as? String, let desiredAngle = result.value(forKeyPath: "angle") as? Int16{
                        if desiredName == self.profileNames[indexPath.row].value(forKey: "name") as? String && desiredAngle == self.profileNames[indexPath.row].value(forKeyPath: "angle") as? Int16 {
                            
                            let alert = UIAlertController(title: "Edit Your profile", message: "Type in new profile parameters", preferredStyle: .alert)
                            
                            alert.addTextField(configurationHandler: { (textField) in
                                textField.text = desiredName
                            })
                            
                            alert.addTextField(configurationHandler: { (textField) in
                                textField.text = String(desiredAngle)
                                textField.keyboardType = .asciiCapableNumberPad
                            })
                            
                            alert.addAction(UIAlertAction(title: "Ready!", style: .default, handler: { [weak alert] (_) in
                                let nameField = alert?.textFields![0]
                                let angleField = alert?.textFields![1]
                                
                                if(angleField!.text == nil || Int(angleField!.text!)! < 0){
                                    angleField!.text = "0"
                                }
                                else if(Int(angleField!.text!)! > 100){
                                    angleField!.text = "100"
                                }
                                
                                result.setValue(nameField?.text ?? "", forKey: "name")
                                result.setValue(Int(angleField?.text ?? "0"), forKey: "angle")
                                
                                do {
                                    try context.save()
                                    tableView.reloadData()
                                } catch{
                                    print("Couldn't save the edit")
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                            
                            self.present(alert,animated: true, completion: nil)
                            
                        }
                    }
                }
            }
            
            do{
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
        
        return [delete, edit]
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = UIColor.lightGray
            view.textLabel?.textColor = UIColor.black
        }
    }
    
    
    
    // MARK: Fetching from Core Data
    func fetchData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Profile")
        
        do {
            profileNames = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
