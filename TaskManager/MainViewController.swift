//
//  MainViewController.swift
//  TaskManager
//
//  Created by Wenzhe on 31/1/16.
//  Copyright © 2016 Wenzhe. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var todoB: UIButton!
    @IBOutlet weak var doingB: UIButton!
    @IBOutlet weak var doneB: UIButton!
    @IBOutlet weak var shuffleB: UIButton!
    
    let attrs = [NSStrokeColorAttributeName : UIColor.whiteColor(),
        NSForegroundColorAttributeName  : UIColor(hex: 0x25599a, alpha: 1),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 32)!,
        NSStrokeWidthAttributeName : -3.0]
    
    let attrsS = [NSStrokeColorAttributeName : UIColor.whiteColor(),
        NSForegroundColorAttributeName  : UIColor(hex: 0x25599a, alpha: 1),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 20)!,
        NSStrokeWidthAttributeName : -3.0]
    
    var attributedString = NSMutableAttributedString(string:"")
    
    let secondsInDay : Double = 60*60*24
    var imageShown = false
    let flickr = FlickrClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let todoStr = NSMutableAttributedString(string: "TO DO", attributes: attrs)
        attributedString.appendAttributedString(todoStr)
        todoB.setAttributedTitle(attributedString, forState: .Normal)
        let doingStr = NSMutableAttributedString(string: "DOING", attributes: attrs)
        attributedString = NSMutableAttributedString(string:"")
        attributedString.appendAttributedString(doingStr)
        doingB.setAttributedTitle(attributedString, forState: .Normal)
        let doneStr = NSMutableAttributedString(string: "DONE", attributes: attrs)
        attributedString = NSMutableAttributedString(string:"")
        attributedString.appendAttributedString(doneStr)
        doneB.setAttributedTitle(attributedString, forState: .Normal)
        let shuffleStr = NSMutableAttributedString(string: "Shuffle Photo", attributes: attrsS)
        attributedString = NSMutableAttributedString(string:"")
        attributedString.appendAttributedString(shuffleStr)
        shuffleB.setAttributedTitle(attributedString, forState: .Normal)
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        updateBackgroundImageSet()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let now = NSDate()
        // get new set of interesting photos from flickr if current time is more than 1 day later
        if(flickr.urls == nil
            || now.timeIntervalSince1970 >= flickr.photoDate.timeIntervalSince1970 + secondsInDay){
            updateBackgroundImageSet()
        }else if(imageShown == false){
            randomBackgroudImage()
        }
    }
    
    func updateBackgroundImageSet(){
        if(flickr.requesting){
            return
        }
        ActivityIndicatorView.shared.showProgressView(view)
        flickr.getInterestingPhoto() { image, error  in
            if let myImage = image {
                dispatch_async(dispatch_get_main_queue()) {
                    ActivityIndicatorView.shared.hideProgressView()
                    self.view.backgroundColor = UIColor(patternImage: myImage)
                    self.imageShown = true
                }
            }else if let _ = error{
                self.showAlert("Get background image failed. Please check your internet connection.", vc: self)
            }else {
                self.showAlert("Get background image failed. Please try again.", vc: self)
            }
        }
    }
    
    func randomBackgroudImage(){
        let total = min(100, flickr.totalImage)
        let random = Int(arc4random_uniform(UInt32(total)))
        ActivityIndicatorView.shared.showProgressView(view)
        flickr.getDataFromUrl(NSURL(string:flickr.urls![random])!){ (imageData, response, error) -> Void in
            if let data = imageData {
                dispatch_async(dispatch_get_main_queue()) {
                    ActivityIndicatorView.shared.hideProgressView()
                    let image = UIImage(data: data)
                    self.view.backgroundColor = UIColor(patternImage: image!)
                    self.imageShown = true
                }
            }else if let _ = error{
                self.showAlert("Get background image failed. Please check your internet connection.", vc: self)
            }else {
                self.showAlert("Get background image failed. Please try again.", vc: self)
            }
        }

    }
    
    func showAlert(text: String, vc: UIViewController){
        let alert = UIAlertController(title: "Alert", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            ActivityIndicatorView.shared.hideProgressView()
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        dispatch_async(dispatch_get_main_queue(), {
            vc.presentViewController(alert, animated: true, completion: nil)
        })
    }

    @IBAction func toDoPressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.TODO
        navigationController!.pushViewController(vc, animated: true)
    }

    @IBAction func doingPressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.DOING
        navigationController!.pushViewController(vc, animated: true)
    }
    @IBAction func donePressed(sender: UIButton) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TaskListVC") as! TaskListViewController
        vc.listCategory = Task.DONE
        navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func shufflePressed(sender: AnyObject) {
        if(flickr.urls != nil){
            randomBackgroudImage()
        }else{
            updateBackgroundImageSet()
        }
    }

}

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait, .PortraitUpsideDown]
    }
}

