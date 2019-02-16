//
//  ViewController.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 11/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import UICircularProgressRing
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {
    
    
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    var selectedPeripheral: CBPeripheral?
    var receivedBytes: [UInt8] = []
    var receivedBuffer: [UInt8] = []
    var dataBuffer: [UInt8] = []
    
    @IBOutlet weak var connectedDeviceLabel: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRing!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueField: UITextField!
    
    var sliderValue: Int = 0
    var valueFieldToSlider: Float = 0
    
    let crc16 = CRC16()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let progressRing = UICircularProgressRing()
        //progressRing.maxValue = 300
        //progressRing.ringStyle = .gradient
        self.hideKeyboardWhenTappedAround()
        
        serial = BluetoothSerial(delegate: self)
        
        valueField.delegate = self
        valueField.keyboardType = .asciiCapableNumberPad
        valueField.backgroundColor = UIColor.lightGray
        valueField.textColor = UIColor.white
        valueField.allowsEditingTextAttributes = false
        
        if serial.connectedPeripheral != nil {
            connectedDeviceLabel.text = "Connected to \(String(describing: serial.connectedPeripheral?.name))"
        }
        else{
            connectedDeviceLabel.text = "Not connected"
        }

        }
    
    @IBAction func valueFieldEditingBegin(_ sender: Any) {
        
        //valueField.text = ""
        
    }
    
    
    @IBAction func valueFieldEdited(_ sender: Any) {
        
        if Int(valueField.text ?? String(0)) ?? 0 > 100{
            valueField.text = String(100)
        }
        
        valueFieldToSlider = Float((valueField.text ?? String(0))) ?? 0
        slider.value = (valueFieldToSlider * 255) / 100
        
        sendData(value: UInt8(slider.value))
        
        valueChanged(value: Int(valueField.text ?? String(0)) ?? 0)
        
    }
    
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        valueField.text = String(Int((slider.value/255)*100))
        valueChanged(value: Int((slider.value/255)*100))
        
        print("PGRing maxVal: \(progressRing.maxValue)")
        
        sendData(value: UInt8(slider.value))
    }
    
    
    
    @IBAction func addButton(_ sender: UIButton) {
       
    }
    
    func sendData(value: UInt8){
        dataBuffer.append(0x03)
        dataBuffer.append(0x01)
        dataBuffer.append(value)
        
        let crc = crc16.getCRCResult(by: dataBuffer)
        
        serial.sendBytesToDevice(dataBuffer)
        serial.sendBytesToDevice(crc)
    }
    
    func valueChanged(value: Int){
        progressRing.startProgress(to: UICircularProgressRing.ProgressValue(value), duration: 1.5)
    }
    
    // MARK: And here goes bluetooth again
    
    func serialDidReceiveBytes(_ bytes: [UInt8]) {
        
        receivedBuffer = bytes
        let receivedPotentialData = receivedBuffer.dropLast(2)
        let receivedCRC = receivedBuffer[receivedBuffer.count - 2 ... receivedBuffer.count]
        let calculateCRCFromReceivedData = crc16.getCRCResult(by: Array(receivedPotentialData))
        
        if Array(receivedCRC) == calculateCRCFromReceivedData{          //Comparing the received and calculated CRC
            receivedBytes = Array(receivedPotentialData)
        }
        else{
            print("Crc doesn't match")
        }
    }
    
    func serialDidChangeState() {
        if serial.centralManager.state != .poweredOn{
            messageBox(title: "Bluetooth is off", text: "Please turn on bluetooth", btText: "Cancel", goToSettings: true)
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        if serial.centralManager.state != .poweredOn{
            messageBox(title: "Oops!", text: "Device disconnected :(", btText: "Ok", goToSettings: false)
        }
    }
   
    
    
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



