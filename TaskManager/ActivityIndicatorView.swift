//
//  ActivityIndicatorView.swift
//  OnTheMap
//
//  Created by 咩咩 on 15/11/5.
//  Copyright © 2015年 Wenzhe. All rights reserved.
//

import Foundation
import UIKit

public class ActivityIndicatorView {
    
    var containerView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    public class var shared: ActivityIndicatorView {
        struct Static {
            static let instance: ActivityIndicatorView = ActivityIndicatorView()
        }
        return Static.instance
    }
    
    public func showProgressView(view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.color = UIColor(red: 17/256.0, green: 122/256.0, blue: 231/256.0, alpha: 1)
        activityIndicator.center = CGPointMake(containerView.bounds.width / 2, containerView.bounds.height / 2)

        containerView.addSubview(activityIndicator)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    public func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}