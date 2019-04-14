//
//  Properties.swift
//  BK-Valve
//
//  Created by Peter Kowalski on 28/02/2019.
//  Copyright © 2019 Peter Kowalski. All rights reserved.
//

import Foundation

class Properties{
    static let sharedInstance = Properties()
    var selectedProfile = String()
    var selectedAngle = Int16()
    var connectedPeripheral = String()
}
