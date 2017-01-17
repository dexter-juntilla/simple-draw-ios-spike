//
//  ViewController.swift
//  SimpleDraw
//
//  Created by DNA on 1/17/17.
//  Copyright © 2017 DNA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    @IBOutlet weak var tempImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLeftPoint = CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.swiped = false
        if let touch = touches.first {
            self.lastPoint = touch.location(in: self.view)
            
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
            let currentPoint = touch.location(in: self.view)
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
        UIGraphicsBeginImageContext(self.view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
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
        self.mainImageView.image = nil
        self.lastPoint = CGPoint(x: 0, y: 0)
        self.topLeftPoint = CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height)
        self.bottomRightPoint = CGPoint(x: 0, y: 0)
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
        
//        if posX - 10 < 0 {
//            posX = 0
//        }
//        else {
//            posX = posX - 10
//            cgwidth = cgwidth + 20
//        }
        posX = posX - 10
        cgwidth = cgwidth + 20
        posY = posY - 20
        cgheight = cgheight + 30
//        if posY - 10 < 0 {
//            posY = 0
//        }
//        else {
//            posY = posY - 20
//            cgheight = cgheight + 30
//        }
        
        let rect: CGRect = CGRect(x: posX ,y: posY, width: cgwidth, height: cgheight)

        print("rect: \(rect)")

        if let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect) {
            let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
            return image
        }
        
        return nil
    }
    
    func rotated() {
        self.mainImageView.image = nil
        self.lastPoint = CGPoint(x: 0, y: 0)
        self.topLeftPoint = CGPoint(x: self.view.frame.size.width, y: self.view.frame.size.height)
        self.bottomRightPoint = CGPoint(x: 0, y: 0)
    }
}
