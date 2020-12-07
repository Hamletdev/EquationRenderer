//
//  WikimediaRestHandler.swift
//  EquationRenderer
//
//  Created by Amit Chaudhary on 11/25/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation

class WikimediaRestHandler {
    var delegate: WMRestAPIDelegate?
    
    let deviceReachability = try! Reachability()
    
    
    func getResourceLocation(_ equation: String) {
        
        if deviceReachability!.isReachable == false {
            self.delegate?.throwAlertToUser(2)
            return
        }
        
        
        let urlComp = URLComponents(string: wikiBaseURL + "check/tex")!
        let body = ["q": equation]
        
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
                
                return
            }
            
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 400 {
                    
                    //wrong formula
                    self.delegate?.throwAlertToUser(1)
                    return
                }
                
                if let wikiHash = httpResponse.allHeaderFields["x-resource-location"] as? String {
                    
                    //use this wikiHash to make another http request and get image data in png format.
                    
                    let finalURLComp = URLComponents(string: wikiBaseURL + "render/png/" + wikiHash)!
                    
                    // Download image from finalURLComp.url and assign renderedImageView.image asynchronously on main thread
                    print("Image Download Started")
                    self.getData(from: finalURLComp.url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        print(response?.suggestedFilename ?? finalURLComp.url!.lastPathComponent)
                        print("Download Finished")
                        
                        self.delegate?.updateUIComponents(data)
                        
                    }
                }
            }
            
            
        }
        
        task.resume()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
}
