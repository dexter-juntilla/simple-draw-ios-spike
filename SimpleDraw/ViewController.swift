//
//  ViewController.swift
//  SimpleDraw
//
//  Created by DNA on 1/17/17.
//  Copyright © 2017 DNA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        let signature = FormMDSignature(frame: CGRect.zero)
        signature.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(signature)
        
        let topConstraint = NSLayoutConstraint(item: signature, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: signature, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: signature, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: signature, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)

        topConstraint.isActive = true
        bottomConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true

        self.view.addConstraint(topConstraint)
        self.view.addConstraint(bottomConstraint)
        self.view.addConstraint(leadingConstraint)
        self.view.addConstraint(trailingConstraint)
        
    }

    override func viewDidAppear(_ animated: Bool) {
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
