//
//  Protocols.swift
//  EquationRenderer
//
//  Created by Amit Chaudhary on 11/25/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

protocol WMRestAPIDelegate {
    func updateUIComponents(_ data: Data)
    func throwAlertToUser(_ tag: Int)
}
