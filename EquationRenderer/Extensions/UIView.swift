//
//  UIView.swift
//  EquationRenderer
//
//  Created by Amit Chaudhary on 11/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var parentViewController: UIViewController? {
           var parentResponder: UIResponder? = self
           while parentResponder != nil {
               parentResponder = parentResponder?.next
               if let viewController = parentResponder as? UIViewController {
                   return viewController
               }
           }
           return nil
       }
    
    
    
    func anchorView(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, topPadding: CGFloat, leftPadding: CGFloat, bottomPadding: CGFloat, rightPadding: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.autoresizesSubviews = false
        if let top = top {
            
            self.topAnchor.constraint(equalTo: top, constant: topPadding).isActive = true
        }
        
        if let bottom = bottom {
            
            self.bottomAnchor.constraint(equalTo: bottom, constant: -bottomPadding).isActive = true
        }
        
        if let left = left {
            
            self.leftAnchor.constraint(equalTo: left, constant: leftPadding).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -rightPadding).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    
}















