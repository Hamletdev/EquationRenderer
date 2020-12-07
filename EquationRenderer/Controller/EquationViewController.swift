//
//  EquationViewController.swift
//  EquationRenderer
//
//  Created by Amit Chaudhary on 11/16/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import SearchTextField

class EquationViewController: UIViewController, UITextFieldDelegate {
    
    // An empty array to hold formulas
    var formulas = [String]()
    // An empty dictionary to hold image cache
    var imageCache = [String: Data]()
    
    let defaults = UserDefaults.standard
    
    // UI Components
    let logoContainerView: UIView = {
        let logoView = UIView()
        let logoLabel = UILabel()
        //logoLabel.text = "robart Math Renderer"
        let attributedTitle = NSMutableAttributedString(string: "Wiki", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.black])
        attributedTitle.append(NSMutableAttributedString(string: "media", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.systemBlue]))
        attributedTitle.append(NSMutableAttributedString(string: "  Formula Renderer", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20.0), NSAttributedString.Key.foregroundColor : UIColor.white]))
        logoLabel.attributedText = attributedTitle
        
        logoView.addSubview(logoLabel)
        logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor).isActive = true
        logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor, constant: 10).isActive = true
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
        return textField
    }()
    
    var renderedImage: UIImageView = {
        let renderedIV = UIImageView()
        renderedIV.contentMode = .scaleAspectFit
        renderedIV.clipsToBounds = false
        renderedIV.backgroundColor = UIColor.init(red: 43/255, green: 158/255, blue: 252/255, alpha: 0.25)
        // renderedIV.image = #imageLiteral(resourceName: "RenderedIMV")
        return renderedIV
    }()
    
    let addShareButton : UIButton = {
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.systemGreen, for: .normal)
        shareButton.backgroundColor = UIColor.init(red: 25/255, green: 204/255, blue: 203/255, alpha: 0.2)
        shareButton.layer.cornerRadius = 5
        shareButton.isEnabled = false
        shareButton.addTarget(self, action: #selector(shareRenderedImage), for: .touchUpInside)
        return shareButton
    }()
    
    let loadedFromLabel: UILabel = {
        let logoLabel = UILabel()
        //        logoLabel.text = "Instagram"
        logoLabel.font = UIFont.systemFont(ofSize: 11.0)
        logoLabel.textColor = UIColor.init(red: 185/255.0, green: 142/255.0, blue: 135/255.0, alpha: 1.0)
        logoLabel.textAlignment = .center
        return logoLabel
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        //        let dataFilePath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.appendingPathExtension("Formulas.plist")
        //        print(dataFilePath)
        
        self.view.addSubview(logoContainerView)
        logoContainerView.anchorView(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 0, leftPadding: 0, bottomPadding: 0, rightPadding: 0, width: 0, height: view.frame.size.height * 0.15)
        
        configureViewComponents()
        
        self.equationTextField.delegate = self
        
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.equationTextField.filterStrings(defaults.array(forKey: "MathFormulas") as! [String])
        }
        
    }
    
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [equationTextField, renderedImage, addShareButton, loadedFromLabel])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        self.view.addSubview(stackView)
        stackView.anchorView(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topPadding: 40, leftPadding: 40, bottomPadding: 0, rightPadding: 40, width: 0, height: 240)
    }
    
    
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.formulas = defaults.array(forKey: "MathFormulas") as! [String]
        }
        self.formulas.append((self.equationTextField.text)!)
        
        self.formulas = (self.uniq(source: self.formulas))
        self.defaults.set((self.formulas), forKey: "MathFormulas")
        
        if (defaults.object(forKey: "RenderedImages") as? [String: Data]) != nil {
            self.imageCache = defaults.object(forKey: "RenderedImages") as! [String: Data]
        }
        if let cachedImageData = imageCache[self.equationTextField.text!] {
            self.renderedImage.image = UIImage(data: cachedImageData)
            self.loadedFromLabel.text = "IMAGE LOADED FROM CACHE"
        } else {
            self.getResourceLocation(self.equationTextField.text!)
        }
        
        
        self.equationTextField.hideResultsList()
        self.equationTextField.startVisible = false
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.equationTextField.text! = ""
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.equationTextField.filterStrings(defaults.array(forKey: "MathFormulas") as! [String])
        }
    }
    
    
    //MARK: - Wikimedia REST
    func getResourceLocation(_ equation: String) {
        
        let urlComp = URLComponents(string: "https://wikimedia.org/api/rest_v1/media/math/check/tex")!
        let body = ["q": self.equationTextField.text!]
        
        var request = URLRequest(url: urlComp.url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  // header
        request.setValue("PLEASE_PUT_AN_EMAIL_ID", forHTTPHeaderField: "User-Agent")  // header
        
        //assign a datatask using resume() to get data in JSON Format.
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if(error != nil || data == nil) {
                // TODO: handle error
                
                print(error!)
                return
            }
            
            
            
            if let httpResponse = response as? HTTPURLResponse {
                if let wikiHash = httpResponse.allHeaderFields["x-resource-location"] as? String {
                    
                    //use this wikiHash to make another http request and get image data in png format.
                    
                    let finalURLComp = URLComponents(string: "https://wikimedia.org/api/rest_v1/media/math/render/png/" + wikiHash)!
                    
                    // Download image from finalURLComp.url and assign renderedImageView.image asynchronously on main thread
                    print("Image Download Started")
                    self.getData(from: finalURLComp.url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        print(response?.suggestedFilename ?? finalURLComp.url!.lastPathComponent)
                        print("Download Finished")
                        
                        
                        DispatchQueue.main.async() { [weak self] in
                            self?.renderedImage.image = UIImage(data: data)
                            self?.addShareButton.isEnabled = true
                            
                            self?.equationTextField.hideResultsList()
                            
                            self!.imageCache[self!.equationTextField.text!] = data
                            self?.defaults.set(self?.imageCache, forKey: "RenderedImages")
                            self!.loadedFromLabel.text = "IMAGE DOWNLOADED FROM WIKIMEDIA"
                            
                        }
                    }
                }
            }
            
            
        }
        
        task.resume()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    //MARK: - Share Rendered Image
    @objc func shareRenderedImage() {
        // set up activity view controller
        let imageToShare = [ self.renderedImage.image!]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //MARK: - Array Handling
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    
}
