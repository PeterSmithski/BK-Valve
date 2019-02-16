//
//  TableViewController.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 14/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import CoreBluetooth

class BTTableViewController: UITableViewController, BluetoothSerialDelegate {
    
    //let btDelegate = BluetoothSerial(delegate: self as! BluetoothSerialDelegate)
    
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    var selectedPeripheral: CBPeripheral?
    var receivedBytes: [UInt8] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btDelegate.delegate = self
        serial = BluetoothSerial(delegate: self)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
                
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Found devices"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BTCell", for: indexPath)

        cell.textLabel?.text = peripherals[indexPath.row].peripheral.name ?? "Devices not found"
        
        // TODO: Insert our logo to shown our devices
        if peripherals[indexPath.row].peripheral.name == "BK-Valve"{
            //cell.imageView.image = UIImage(named: tuwsadzzdjecie.image)
        }
        else{
            //cell.imageView.image = UIImage(named: tuwsadzzdjecie.image)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial.stopScan()
        serial.connectToPeripheral(peripherals[indexPath.row].peripheral)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    // MARK: - BLE funcs
    
    // TODO: Add message box if bluetooth is off
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn{
            messageBox(title: "Bluetooth off", text: "Please turn on bluetooth", btText: "Ok", goToSettings: true)
        }
    }
    // TODO: Add msg box after device disconnects
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        
        for existing in peripherals{
            if existing.peripheral.identifier == peripheral.identifier { return }
        }
        
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort {$0.RSSI < $1.RSSI}
        tableView.reloadData()
    }
    
    func serialDidReceiveBytes(_ bytes: [UInt8]) {
        receivedBytes = bytes
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        
    }
    
    
}
