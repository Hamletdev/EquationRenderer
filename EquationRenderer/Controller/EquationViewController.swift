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
import CoreData

class EquationViewController: UIViewController, UITextFieldDelegate, WMRestAPIDelegate {
    
    // An empty array to hold formulas
    var formulas = [String]()
    // An empty dictionary to hold image cache
    var imageCache = [String: Data]()
    
    let defaults = UserDefaults.standard
    
    //Documents Directory Path
    let dataFilePath = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.appendingPathExtension("Formulas.plist")
    
    //NSManagedObjectContext
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var offlineImages = [CachedImage]()
    
    let wikiHandler = WikimediaRestHandler()
    
    var equationView = EquationView.init(frame: .zero)
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view = equationView
        
        self.equationView.backgroundColor = .white
        self.equationView.clipsToBounds = true
        
        self.equationView.configureViewComponents()
        
        
        
        self.equationView.equationTextField.delegate = self
        wikiHandler.delegate = self
        
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.equationView.equationTextField.filterStrings(defaults.array(forKey: "MathFormulas") as! [String])
        }
        
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
    
    
    //MARK: - Core Data
    func saveRenderedImages() {
        
        do {
            try context.save()
        } catch {
            print("Error during save")
        }
    }
    
    func loadRenderedImages() {
        
        let coreDataRequest: NSFetchRequest<CachedImage> = CachedImage.fetchRequest()
        
        let predicate = NSPredicate(format: "formulaText == %@", self.equationView.equationTextField.text!)
        
        coreDataRequest.predicate = predicate
        do {
            let newOfflineImages = try context.fetch(coreDataRequest)
            
            if newOfflineImages.count > 0 {
                //assign image to uiimageview
                
                let cachedImageData = newOfflineImages[0].imageData
                self.equationView.renderedImage.image = UIImage(data: cachedImageData!)
                self.equationView.loadedFromLabel.text = "IMAGE LOADED FROM CACHE"
                self.equationView.addShareButton.isEnabled = true
            } else {
                
                wikiHandler.getResourceLocation(self.equationView.equationTextField.text!)
                
            }
        } catch  {
            print("Error in reading core data model")
        }
        
    }
    
    
    //MARK: - Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            //
        }) { (UIViewControllerTransitionCoordinatorContext) in
            self.equationView.configureViewComponents()
        }
    }
    
    
}


extension EquationViewController {
    
    //MARK: - WMRestAPIDelegate
    
    func updateUIComponents(_ data: Data) {
        DispatchQueue.main.async() { [weak self] in
            self?.equationView.renderedImage.image = UIImage(data: data)
            self?.equationView.addShareButton.isEnabled = true
            
            self?.equationView.equationTextField.hideResultsList()
            
            let newCachedImage = CachedImage(context: self!.context)
            newCachedImage.formulaText = self!.equationView.equationTextField.text!
            newCachedImage.imageData = data
            self?.offlineImages.append(newCachedImage)
            
            self?.saveRenderedImages()
            
            self!.equationView.loadedFromLabel.text = "IMAGE DOWNLOADED FROM WIKIMEDIA"
            
        }
    }
    
    func throwAlertToUser(_ tag: Int) {
        DispatchQueue.main.async() { [weak self] in
            if tag == 3 {
                //no text detected
                let noTextAlert = UIAlertController(title: "No Formula Text", message: "Please enter a math formula", preferredStyle: UIAlertController.Style.alert)
                noTextAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self!.present(noTextAlert, animated: true, completion: nil)
                return
            }
            else if tag == 1 {
                // incorrect formula
                let wrongFormulaAlert = UIAlertController(title: "Wrong Formula", message: "Please enter a syntactically correct math formula", preferredStyle: UIAlertController.Style.alert)
                wrongFormulaAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self!.present(wrongFormulaAlert, animated: true, completion: nil)
                return
                
            } else if tag == 2 {
                //no internet connection
                let noInternetAlert = UIAlertController(title: "No Internet Connection", message: "Please make sure the device is connected to Internet", preferredStyle: UIAlertController.Style.alert)
                noInternetAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self!.present(noInternetAlert, animated: true, completion: nil)
                return
            }
        }
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text! == "" {
            self.throwAlertToUser(3)
            textField.endEditing(true)
            return true
        }
        
        textField.endEditing(true)
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.formulas = defaults.array(forKey: "MathFormulas") as! [String]
        }
        self.formulas.append((self.equationView.equationTextField.text)!)
        
        self.formulas = (self.uniq(source: self.formulas))
        self.defaults.set((self.formulas), forKey: "MathFormulas")
        
        self.loadRenderedImages()
        
        
        self.equationView.equationTextField.hideResultsList()
        self.equationView.equationTextField.startVisible = false
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.equationView.equationTextField.text! = ""
        if (defaults.array(forKey: "MathFormulas") as? [String]) != nil {
            self.equationView.equationTextField.filterStrings(defaults.array(forKey: "MathFormulas") as! [String])
        }
    }
    
}
