//
//  ViewController.swift
//  Sense2
//
//  Created by Daniel Hauagge on 2/3/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    
    @IBOutlet weak var accelXLabel: UILabel!
    @IBOutlet weak var accelYLabel: UILabel!
    @IBOutlet weak var accelZLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
        
    var currPoint = CGPointMake(0,0)
    var clearDrawing = false
    
    var red: CGFloat = 1.0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var brush: CGFloat = 10.0
    
    var updateInterval: Double = 1.0 / 60.0 // seconds
    
    func processData() {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
            (motion: CMDeviceMotion?, error: NSError?) in
            
            // Update the labels in the UI
//            self.accelXLabel.text = String(format: "X: %5.2f", arguments: [motion!.userAcceleration.x])
//            self.accelYLabel.text = String(format: "Y: %5.2f", arguments: [motion!.userAcceleration.y])
//            self.accelZLabel.text = String(format: "Z: %5.2f", arguments: [motion!.userAcceleration.z])
            
            self.accelXLabel.text = String(format: "X: %5.2f", arguments: [self.currPoint.x])
            self.accelYLabel.text = String(format: "Y: %5.2f", arguments: [self.currPoint.y])
            self.accelZLabel.text = String(format: "Z: %5.2f", arguments: [self.imageView.frame.size.width])
            
            NSLog("X: %5.2f, Y: %5.2f", self.currPoint.x, self.currPoint.y)
            
            // Update the location of the cursor
            let scale = CGFloat(10)*10
            let fwidth = self.imageView.frame.size.width
            let fheight = self.imageView.frame.size.height

            var nextPoint = CGPointMake(self.currPoint.x, self.currPoint.y)
            
            
            
            if (self.currPoint.x < -(fwidth/2.0)){
                nextPoint = CGPointMake(
                    -(fwidth/2.0) + 2.0,
                    self.currPoint.y + scale * CGFloat(motion!.userAcceleration.y))
                NSLog("X is out on the LEFT of %5.2f",-(fwidth/2.0) + 1.0)
            }
                
            if (self.currPoint.x > (fwidth/2.0)){
                nextPoint = CGPointMake(
                    fwidth/2.0 - 1.0,
                    self.currPoint.y + scale * CGFloat(motion!.userAcceleration.y))
                NSLog("X is out on the RIGHT.")
            
            } else if (self.currPoint.y < -(fheight/2.0)) {
                nextPoint = CGPointMake(
                    self.currPoint.x + scale * -CGFloat(motion!.userAcceleration.x),
                    -(fheight/2.0) + 1.0)
                NSLog("Y is out on the TOP.")

            } else if (self.currPoint.y > (fheight/2.0)){
                nextPoint = CGPointMake(
                    self.currPoint.x + scale * -CGFloat(motion!.userAcceleration.x),
                    fheight/2.0 - 1.0)
                NSLog("Y is out at the BOTTOM.")
            
            } else {
                nextPoint = CGPointMake(
                    self.currPoint.x + scale * -CGFloat(motion!.userAcceleration.x),
                    self.currPoint.y + scale * CGFloat(motion!.userAcceleration.y))
            }
            
            
            // Draw the line
                    self.drawLine(fromPoint: self.currPoint, toPoint: nextPoint)
                    self.currPoint = nextPoint
            
        }
    }
    
    func drawLine(fromPoint a: CGPoint, toPoint b:CGPoint) {
        UIGraphicsBeginImageContext(self.view.frame.size)
        
        let context = UIGraphicsGetCurrentContext()
        
        // If the user hit the clear drawing button, then we do not draw the previous
        // state. This has the effect of erasing the drawing.
        if(!clearDrawing) {
            // Draw prev image into context
            self.imageView.image?.drawInRect(CGRectMake(0, 0,
                self.view.frame.size.width,
                self.view.frame.size.height))
        }
        clearDrawing = false
        
        let origin = CGPointMake(
            self.imageView.frame.origin.x + self.imageView.frame.size.width/2.0,
            self.imageView.frame.origin.y + self.imageView.frame.size.height/2.0
        )
        
        // Draw line
        CGContextMoveToPoint(context, a.x + origin.x, a.y + origin.y)
        CGContextAddLineToPoint(context, b.x + origin.x, b.y + origin.y)
        
        // Set line params
        CGContextSetLineWidth(context, 5.0)
        CGContextSetRGBStrokeColor(context, self.red, self.green, self.blue, 1.0)
        CGContextSetLineCap(context, .Round)
        
        // Render the drawing
        CGContextStrokePath(context)
        
        // Get the newly rendered image into the image view
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()

        // End the graphics context
        UIGraphicsEndImageContext()
    }

    // This function is executed right after the user clicks on the "Settings"
    // button
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settings = segue.destinationViewController as! SettingsViewController
        
        // This is necessary to get the data back from the settings view
        settings.delegate = self
        
        // Send the current color to the settings view
        settings.red = self.red
        settings.green = self.green
        settings.blue = self.blue
    }

    @IBAction func clearButtonPressed(sender: AnyObject) {
        clearDrawing = true
        currPoint = CGPointMake(0, 0)
    }
}

extension ViewController: SettingsViewControllerDelegate {
    // This method is called by the settings view
    func settingsViewControllerFinished(red : CGFloat, green : CGFloat, blue : CGFloat, brush : CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.brush = brush
    }
}


