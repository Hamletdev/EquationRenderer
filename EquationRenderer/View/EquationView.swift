//
//  EquationView.swift
//  EquationRenderer
//
//  Created by Amit Chaudhary on 11/25/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import SearchTextField

class EquationView: UIView {
    
    let logoContainerView: UIView = {
        let logoView = UIView()
        let logoLabel = UILabel()
       
        let attributedTitle = NSMutableAttributedString(string: "Wiki", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor : UIColor.black])
        attributedTitle.append(NSMutableAttributedString(string: "media", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]))
        attributedTitle.append(NSMutableAttributedString(string: "  Formula Renderer", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22.0), NSAttributedString.Key.foregroundColor : UIColor.white]))
        logoLabel.attributedText = attributedTitle
        
        logoView.addSubview(logoLabel)
        logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor).isActive = true
        logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor, constant: 14).isActive = true
        logoLabel.anchorView(top: nil, left: nil, bottom: nil, right: nil, topPadding: 0.0, leftPadding: 0.0, bottomPadding: 0.0, rightPadding: 0.0, width: 0.0, height: logoLabel.font.lineHeight)
        logoView.backgroundColor = .systemTeal
        
        return logoView
    }()
    
    let equationTextField: SearchTextField = {
        let textField = SearchTextField()
        textField.backgroundColor = UIColor.init(displayP3Red: 52.0/255.0, green: 83.0/255.0, blue: 149.0/255.0, alpha: 0.28)
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Equation", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        textField.returnKeyType = .go
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }()
    
    var renderedImage: UIImageView = {
        let renderedIV = UIImageView()
        renderedIV.contentMode = .scaleAspectFit
        renderedIV.clipsToBounds = false
        renderedIV.backgroundColor = UIColor.init(red: 43/255, green: 158/255, blue: 252/255, alpha: 0.25)
        return renderedIV
    }()
    
    let addShareButton : UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Share Image", for: .normal)
        shareButton.setTitleColor(.systemGreen, for: .normal)
        shareButton.setTitleColor(.lightGray, for: .disabled)
        shareButton.backgroundColor = UIColor.init(red: 25/255, green: 204/255, blue: 203/255, alpha: 0.2)
        shareButton.layer.cornerRadius = 5
        shareButton.isEnabled = false
        shareButton.addTarget(self, action: #selector(shareRenderedImage), for: .touchUpInside)
        return shareButton
    }()
    
    let loadedFromLabel: UILabel = {
        let logoLabel = UILabel()
        logoLabel.font = UIFont.systemFont(ofSize: 12.0)
        logoLabel.textColor = UIColor.init(red: 185/255.0, green: 142/255.0, blue: 135/255.0, alpha: 1.0)
        logoLabel.textAlignment = .center
        return logoLabel
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViewComponents() {
        
        if ((self.traitCollection.horizontalSizeClass == .compact) && (self.traitCollection.verticalSizeClass == .regular)) || (self.traitCollection.horizontalSizeClass == .regular) && (self.traitCollection.verticalSizeClass == .regular) {
            
            
            let stackView1 = UIStackView(arrangedSubviews: [logoContainerView])
            stackView1.distribution = .fillEqually
            self.addSubview(stackView1)
            stackView1.anchorView(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 80)
            
            
            let stackView = UIStackView(arrangedSubviews: [equationTextField, renderedImage, addShareButton, loadedFromLabel])
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.distribution = .fillEqually
            
            self.addSubview(stackView)
            stackView.anchorView(top: stackView1.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 40, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 280)
        }
            
        else if ((self.traitCollection.horizontalSizeClass == .compact) && (self.traitCollection.verticalSizeClass == .compact)) || ((self.traitCollection.horizontalSizeClass == .regular) && (self.traitCollection.verticalSizeClass == .compact)) {
            
            //logo
            let stackView1 = UIStackView(arrangedSubviews: [logoContainerView])
            stackView1.distribution = .fillEqually
            self.addSubview(stackView1)
            stackView1.anchorView(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: 60)
            
            
            let stackViewTop = UIStackView(arrangedSubviews: [equationTextField, renderedImage])
            stackViewTop.axis = .horizontal
            stackViewTop.spacing = 20
            stackViewTop.distribution = .fillEqually
            
            
            let stackViewBottom = UIStackView(arrangedSubviews: [addShareButton, loadedFromLabel])
            stackViewBottom.axis = .vertical
            stackViewBottom.spacing = 10
            stackViewBottom.distribution = .fillEqually
            stackViewBottom.alignment = .center
            addShareButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 140).isActive = true
            
            
            let stackView = UIStackView(arrangedSubviews: [stackViewTop, stackViewBottom])
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.distribution = .fillProportionally
            
            self.addSubview(stackView)
            stackView.anchorView(top: stackView1.bottomAnchor, left: self.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.safeAreaLayoutGuide.rightAnchor, topPadding: 20, leftPadding: 20, bottomPadding: 0, rightPadding: 20, width: 0, height: 180)
            
        }
        
    }
    
    
    //MARK: - Share Rendered Image
    @objc func shareRenderedImage() {
        // set up activity view controller
        let imageToShare = [ self.renderedImage.image!]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self
        
        // present the view controller
        self.parentViewController!.present(activityViewController, animated: true, completion: nil)
        
    }
    
}
