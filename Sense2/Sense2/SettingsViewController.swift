//
//  SettingsViewController.swift
//  Sense2
//
//  Created by Daniel Hauagge on 2/3/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerFinished(red : CGFloat, green : CGFloat, blue : CGFloat, brush: CGFloat)
}

class SettingsViewController: UIViewController {

    var delegate: SettingsViewControllerDelegate?
    
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var brush: CGFloat = 10.0
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var brushSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func redSliderDidChange(sender: UISlider) {
        red = CGFloat(sender.value)
        updateColorView()
    }

    @IBAction func greenSliderDidChange(sender: UISlider) {
        green = CGFloat(sender.value)
        updateColorView()
    }
    
    @IBAction func blueSliderDidChange(sender: UISlider) {
        blue = CGFloat(sender.value)
        updateColorView()
    }
    
    @IBAction func brushSliderDidChange(sender: UISlider) {
        brush = CGFloat(sender.value)
        updateBrushView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.redSlider.value = Float(red)
        self.greenSlider.value = Float(green)
        self.blueSlider.value = Float(blue)
        self.brushSlider.value = Float(brush)
        updateColorView()
        updateBrushView()
    }
    
    func updateBrushView() {
        UIGraphicsBeginImageContext(colorView.frame.size)
        var context = UIGraphicsGetCurrentContext()
        
//        CGContextSetLineCap(context, kCGLineCapRound)
//        CGContextSetLineWidth(context, brush)
//        
//        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0)
//        CGContextMoveToPoint(context, 45.0, 45.0)
//        CGContextAddLineToPoint(context, 45.0, 45.0)
//        CGContextStrokePath(context)
//        colorView.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        UIGraphicsBeginImageContext(colorView.frame.size)
//        context = UIGraphicsGetCurrentContext()
//        
//        CGContextSetLineCap(context, kCGLineCapRound)
//        CGContextSetLineWidth(context, 20)
//        CGContextMoveToPoint(context, 45.0, 45.0)
//        CGContextAddLineToPoint(context, 45.0, 45.0)
//        
//        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, opacity)
//        CGContextStrokePath(context)
//        imageViewOpacity.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    func updateColorView() {
        self.colorView.backgroundColor = UIColor(colorLiteralRed: Float(red),
            green: Float(green), blue: Float(blue), alpha: 1.0)
    }
    
    
    @IBAction func buttonDonePressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
        // If the delegate was set (in our case the main view), then call this method
        // to let the view know what was the final color the user picked
        self.delegate?.settingsViewControllerFinished(red, green: green, blue: blue, brush: brush)
    }
}
//
//class imageViewBrush: UIView {
//    <#properties and methods#>
//}
