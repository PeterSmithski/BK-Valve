//
//  Utilities.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 15/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import UIKit

extension UIViewController {
func messageBox(title: String, text: String, btText: String, goToSettings: Bool){
    let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
    
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
}
