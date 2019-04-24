//
//  TableViewController.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 14/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import CoreBluetooth

var connectedPeripheral: String = "Not connected"

class BTTableViewController: UITableViewController, BluetoothSerialDelegate {
    
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    var selectedPeripheral: CBPeripheral?
    var receivedBytes: [UInt8] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgView =  UIImageView(frame: self.tableView.frame)
        let img = UIImage(named: "background")
        imgView.image = img
        imgView.frame = CGRect(x: 0, y:0,width: self.tableView.frame.width,height: self.tableView.frame.height)
        imgView.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.tableView.backgroundView = imgView
        
        serial = BluetoothSerial(delegate: self)
        UITabBar.appearance().barTintColor = UIColor.lightGray
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Found devices"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = .none
            view.textLabel?.textColor = UIColor.black
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BTCell", for: indexPath)

        cell.textLabel?.text = peripherals[indexPath.row].peripheral.name ?? "Devices not found"
        
        // TODO: Insert our logo to shown our devices
        if peripherals[indexPath.row].peripheral.name == "BK-Valve"{
            //cell.imageView.image = UIImage(named: img.image)
        }
        else{
            //cell.imageView.image = UIImage(named: img.image)
        }
        
        cell.backgroundColor = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        serial.stopScan()
        serial.connectToPeripheral(peripherals[indexPath.row].peripheral)
        connectedPeripheral = String(peripherals[indexPath.row].peripheral.name!)
    }
    
    // MARK: - BLE funcs
    
    // TODO: Add message box if bluetooth is off
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn{
            messageBox(title: "Bluetooth is off", message: "Please turn on bluetooth", btText: "Ok", goToSettings: true)
        }
        else{
            serial.startScan()
        }
    }
    // TODO: Add msg box after device disconnects
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        messageBox(title: "Disconnected", message: "Device has been disconnected", btText: "Ok")
        connectedPeripheral = "Not connected"
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
