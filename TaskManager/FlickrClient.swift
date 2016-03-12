//
//  FlickrClient.swift
//  TaskManager
//
//  Created by Wenzhe on 6/3/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import Foundation
import UIKit

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.interestingness.getList"
let API_KEY = "43d4f3aa87f84aed3c27f49468a4c555"
let EXTRAS = "url_m"
let PER_PAGE = "100"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"

class FlickrClient: NSObject{
    
    var session: NSURLSession
    var photoDate : NSDate = NSDate.distantPast()
    var urls : [String]?
    var totalImage = 0
    var requesting = false
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    class func sharedInstance() -> FlickrClient {
        
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)){
        print("getting photo from URL \(url)")
        let task = session.dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
        }
        task.resume()
    }
    
    func getInterestingPhoto(completionHandler: (image: UIImage?, error: NSError?)->Void ) {
        
        requesting = true
        print("requesting new photos")
        
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "per_page": PER_PAGE,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            self.requesting = false
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(image: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandler(image: nil, error: nil)
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(image: nil, error: nil)
                print("No data was returned by the request!")
                return
            }
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                completionHandler(image: nil, error: nil)
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                completionHandler(image: nil, error: nil)
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                completionHandler(image: nil, error: nil)
                print("Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                completionHandler(image: nil, error: nil)
                print("Cannot find key 'photo' in \(photosDictionary)")
                return
            }
            
            self.totalImage = photosArray.count
            
            if photosArray.count > 0 {
                
                var url = [String]()
                for photo in photosArray {
                    guard let imageUrlString = photo["url_m"] as? String else {
                        continue
                    }
                    url.append(imageUrlString)
                }
                
                self.urls = url
                self.photoDate = NSDate()
                let random = Int(arc4random_uniform(UInt32(min(self.totalImage,100))))
                self.getDataFromUrl(NSURL(string:url[random])!){ (imageData, response, error) -> Void in
                    if let data = imageData {
                        dispatch_async(dispatch_get_main_queue()) {
                            let image = UIImage(data: data)
                            completionHandler(image: image, error: nil)
                        }
                    }
                    else{
                        completionHandler(image: nil, error: nil)
                        print("error getting image")
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}