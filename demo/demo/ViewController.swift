//
//  ViewController.swift
//  demo
//
//  Created by Phil on 2020/8/24.
//  Copyright © 2020 Phil. All rights reserved.
//

import UIKit
import IRUserResizableView_swift

class ViewController: UIViewController, IRUserResizableViewDelegate, UIGestureRecognizerDelegate {
    
    var currentlyEditingView: IRUserResizableView?
    var lastEditedView: IRUserResizableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appFrame = UIScreen.main.bounds
        self.view = UIView.init(frame: appFrame);
        self.view.backgroundColor = .green;
        
        // (1) Create a user resizable view with a simple red background content view.
        let gripFrame = CGRect.init(x: 50, y: 50, width: 200, height: 150)
        let userResizableView = IRUserResizableView.init(frame: gripFrame)
        let contentView = UIView.init(frame: gripFrame);
        contentView.backgroundColor = .red;
        userResizableView.contentView = contentView;
        userResizableView.delegate = self;
        userResizableView.showEditingHandles()
        currentlyEditingView = userResizableView;
        lastEditedView = userResizableView;
        self.view.addSubview(userResizableView)
        
        // (2) Create a second resizable view with a UIImageView as the content.
        let imageFrame = CGRect.init(x: 50, y: 200, width: 200, height: 200)
        let imageResizableView = IRUserResizableView.init(frame: imageFrame)
        let imageView = UIImageView.init(image: UIImage.init(named: "milky_way.jpg"))
        imageResizableView.contentView = imageView;
        imageResizableView.delegate = self;
        self.view.addSubview(imageResizableView)
        
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(hideEditingHandles))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer);
    }

    @objc func hideEditingHandles() {
        // We only want the gesture recognizer to end the editing session on the last
        // edited view. We wouldn't want to dismiss an editing session in progress.
        lastEditedView?.hideEditingHandles()
    }
    
    func userResizableViewDidBeginEditing(userResizableView: IRUserResizableView) {
        currentlyEditingView?.hideEditingHandles()
        currentlyEditingView = userResizableView
    }
    
    func userResizableViewDidEndEditing(userResizableView: IRUserResizableView) {
        lastEditedView = userResizableView
    }
}

