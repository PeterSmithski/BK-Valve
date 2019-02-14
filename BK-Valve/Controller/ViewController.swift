//
//  ViewController.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 11/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var progressRing: UICircularProgressRing!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var valueField: UITextField!
    
    var sliderValue: Int = 0
    
    var valueFieldToSlider: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let progressRing = UICircularProgressRing()
        //progressRing.maxValue = 300
        //progressRing.ringStyle = .gradient
        self.hideKeyboardWhenTappedAround()
        
        valueField.delegate = self
        valueField.keyboardType = .asciiCapableNumberPad
        }
    
    @IBAction func valueFieldEditingBegin(_ sender: Any) {
        
        valueField.text = ""
        
    }
    
    
    @IBAction func valueFieldEdited(_ sender: Any) {
        
        if Int(valueField.text ?? String(0)) ?? 0 > 100{
            valueField.text = String(100)
        }
        
        valueFieldToSlider = Float((valueField.text ?? String(0))) ?? 0
        
        slider.value = (valueFieldToSlider * 255) / 100
        
        valueChanged(value: Int(valueField.text ?? String(0)) ?? 0)
    }
    
    
    
    @IBAction func sliderChanged(_ sender: Any) {
        valueField.text = String(Int((slider.value/255)*100))
        print("PGRing maxVal: \(progressRing.maxValue)")
        valueChanged(value: Int((slider.value/255)*100))
    }
    
    
    
    @IBAction func addButton(_ sender: UIButton) {
       
    }
    
    
    
    func valueChanged(value: Int){
        progressRing.startProgress(to: UICircularProgressRing.ProgressValue(value), duration: 1.5)
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
