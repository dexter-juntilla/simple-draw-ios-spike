//
//  FormMDSignature.swift
//  SimpleDraw
//
//  Created by DNA on 1/17/17.
//  Copyright © 2017 DNA. All rights reserved.
//

import UIKit

class FormMDSignature: UIView {
    
    var lastPoint = CGPoint(x: 0, y: 0)
    var topLeftPoint = CGPoint(x: 0, y: 0)
    var bottomRightPoint = CGPoint(x: 0, y: 0)
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 3.0
    var opacity: CGFloat = 1.0
    var swiped = false
    @IBOutlet weak var mainImageView: UIImageView!
    
    let nibName = "FormMDSignature"
    var view : UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetUp()
    }
    
    func xibSetUp() {
        self.view = loadViewFromNib()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        topConstraint.isActive = true
        bottomConstraint.isActive = true
        leadingConstraint.isActive = true
        trailingConstraint.isActive = true
        
        self.addConstraints([topConstraint,
                             bottomConstraint,
                             leadingConstraint,
                             trailingConstraint])
        self.clearCanvas()
    }
    
    func loadViewFromNib() ->UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.swiped = false
        if let touch = touches.first {
            self.lastPoint = touch.location(in: self)
            
            if self.lastPoint.x < self.topLeftPoint.x {
                self.topLeftPoint.x = self.lastPoint.x
            }
            if self.lastPoint.y < self.topLeftPoint.y {
                self.topLeftPoint.y = self.lastPoint.y
            }
            if self.lastPoint.x > self.bottomRightPoint.x {
                self.bottomRightPoint.x = self.lastPoint.x
            }
            if self.lastPoint.y > self.bottomRightPoint.y {
                self.bottomRightPoint.y = self.lastPoint.y
            }
            print("topLeftPoint: \(topLeftPoint)")
            print("bottomRightPoint: \(bottomRightPoint)")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self)
            self.drawLine(from: self.lastPoint, to: currentPoint)
            self.lastPoint = currentPoint
            
            if self.lastPoint.x < self.topLeftPoint.x {
                self.topLeftPoint.x = self.lastPoint.x
            }
            if self.lastPoint.y < self.topLeftPoint.y {
                self.topLeftPoint.y = self.lastPoint.y
            }
            if self.lastPoint.x > self.bottomRightPoint.x {
                self.bottomRightPoint.x = self.lastPoint.x
            }
            if self.lastPoint.y > self.bottomRightPoint.y {
                self.bottomRightPoint.y = self.lastPoint.y
            }
            print("topLeftPoint: \(topLeftPoint)")
            print("bottomRightPoint: \(bottomRightPoint)")
        }
    }
    
    func drawLine(from: CGPoint, to: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        self.mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        context?.move(to: from)
        context?.addLine(to: to)
        
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(self.brushWidth)
        context?.setStrokeColor(red: self.red, green: self.green, blue: self.blue, alpha: self.opacity)
        context?.setBlendMode(.normal)
        
        context?.strokePath()
        
        self.mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        self.mainImageView.alpha = self.opacity
        UIGraphicsEndImageContext()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        self.clearCanvas()
    }
    
    @IBAction func save(_ sender: UIButton) {
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            print("Documents Directory: \(documentsDirectory)")
            return documentsDirectory
        }
        
        UIGraphicsBeginImageContext(CGSize(width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            if let img = self.cropToBounds(image: image) {
                if let data = UIImagePNGRepresentation(img) {
                    let filename = getDocumentsDirectory().appendingPathComponent("temp.png")
                    try? data.write(to: filename)
                }
            }
        }
        
        UIGraphicsEndImageContext()
    }
    
    func cropToBounds(image: UIImage) -> UIImage? {
        let x = self.topLeftPoint.x
        let y = self.topLeftPoint.y
        let width = self.bottomRightPoint.x - x
        let height = self.bottomRightPoint.y - y
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        var posX = x
        var posY = y
        var cgwidth = width
        var cgheight = height
        
        posX = posX - 10
        cgwidth = cgwidth + 20
        posY = posY - 20
        cgheight = cgheight + 30
        
        let rect: CGRect = CGRect(x: posX ,y: posY, width: cgwidth, height: cgheight)
        
        print("rect: \(rect)")
        
        if let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect) {
            let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
            return image
        }
        
        return nil
    }
    
    func rotated() {
        self.clearCanvas()
    }
    
    func clearCanvas() {
        self.mainImageView.image = nil
        self.lastPoint = CGPoint(x: 0, y: 0)
        if self.frame.size.height == 0 || self.frame.size.width == 0 {
            self.topLeftPoint = CGPoint(x: CGFloat(UInt16.max), y: CGFloat(UInt16.max))
        }
        else {
            self.topLeftPoint = CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height)
        }
        self.bottomRightPoint = CGPoint(x: 0, y: 0)
    }
}
