//
//  ViewController.swift
//  VideoProcessing
//
//  Created by Daniel Hauagge on 2/18/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

// Refs:
// - http://stackoverflow.com/questions/9121427/ios-face-detection-issue
// - http://stackoverflow.com/questions/11154585/face-detection-issue-using-cidetector?rq=1

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var startButton: UIButton!

    var session = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer!
    var processedLayer : CALayer!
    
    var isProcessing = false
    
    var frameNo = 0
    
    
    var faceDetector = CIDetector(ofType: CIDetectorTypeFace,
        context: nil,
        options: [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: true
        ])

    override func viewDidLoad() {
        super.viewDidLoad()

        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
        
        
        let x = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0)
        
//        let device = devices.first!
        let device = devices.filter({ $0.position == .Front }).first
        
        let input = try! AVCaptureDeviceInput(device: device)
        
        // try! is similar to
        // do {
        //   input = AVCaptureDeviceInput(device: device)
        // } catch {
        //   assert(false)
        // }
        
        assert(session.canAddInput(input))
        session.addInput(input)
        
        // Output
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)
        ]
        let frameProcessingQueue = dispatch_queue_create("frameprocessing", DISPATCH_QUEUE_SERIAL)
        output.setSampleBufferDelegate(self, queue: frameProcessingQueue)
        output.alwaysDiscardsLateVideoFrames = true
        assert(session.canAddOutput(output))
        session.addOutput(output)
        
        // Preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = self.view.bounds
        previewLayer.hidden = false
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill // *** ??
        self.view.layer.addSublayer(previewLayer)
        
        // Processed layer
        processedLayer = CALayer()
        processedLayer.frame = self.view.bounds
        //processedLayer.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
        processedLayer.hidden = true
        self.view.layer.addSublayer(processedLayer)
        
        // Button setup
        startButton.layer.cornerRadius = startButton.frame.size.width/2
        self.view.bringSubviewToFront(startButton)
        
        session.startRunning()
    }
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        isProcessing = !isProcessing
        
        if(isProcessing) {
            processedLayer.hidden = false
            previewLayer.hidden = true
            startButton.backgroundColor = UIColor.greenColor()
        } else {
            processedLayer.hidden = true
            previewLayer.hidden = false
            startButton.backgroundColor = UIColor.redColor()        }
    }

    func processImageBuffer(imageBuffer : CVImageBufferRef) {
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
    
        var pixel = UnsafeMutablePointer<UInt8>(CVPixelBufferGetBaseAddress(imageBuffer))
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        
        let blueValue = UInt8( 255 * (sin(Double(frameNo)/10) + 1) * 0.5 )
        
        for _ in 0 ..< height {
            var idx = 0
            for _ in 0 ..< width {
                pixel[idx] = blueValue        // B
                //pixel[idx + 1] = 0  // G
                //pixel[idx + 2] = 0  // R
                //pixel[idx + 3] = 0  // A
                idx += 4
            }
            pixel += bytesPerRow
        }
        
        let context = CIContext()
        let ciImage = CIImage(CVImageBuffer: imageBuffer).imageByApplyingOrientation(6)
        let cgImage = context.createCGImage(ciImage, fromRect: ciImage.extent)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.processedLayer.contents = cgImage
        }
    }
    
    func detectFace(imageBuffer : CVImageBufferRef) {
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let image : UIImage = UIImage(named:"scar")!
        
        let ciImage = CIImage(CVImageBuffer: imageBuffer)

        //let faces = faceDetector.featuresInImage(ciImage) as! [CIFaceFeature]
        let faces = faceDetector.featuresInImage(ciImage, options: [CIDetectorImageOrientation: 6]) as! [CIFaceFeature] // ****
    
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        UIGraphicsBeginImageContext(CGSizeMake(CGFloat(width), CGFloat(height)))
        let context = UIGraphicsGetCurrentContext()
        
        UIImage(CIImage: ciImage).drawInRect(CGRectMake(0, 0, CGFloat(width), CGFloat(height)))

        // Draw the actual faces
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 30)

        var T = CGAffineTransformIdentity
        T = CGAffineTransformTranslate(T, 0, +CGFloat(height))
        T = CGAffineTransformScale(T, 1, -1)

        for face in faces {
            let faceRectT = CGRectApplyAffineTransform(face.bounds, T)
            //CGContextStrokeEllipseInRect(context, faceRectT)
            image.drawInRect(faceRectT)
        }
        CGContextStrokePath(context)
        
        // Get back the final drawn image
        let markedFacesImage = UIGraphicsGetImageFromCurrentImageContext()

        // -------------------------
        UIGraphicsEndImageContext()
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0)
        
        let finalImg = hackFixOrientation(markedFacesImage)

        
        dispatch_async(dispatch_get_main_queue()) {
            self.processedLayer.contents = finalImg
        }

    }
    
    func hackFixOrientation(img: UIImage) -> CGImageRef {
        let debug = CIImage(CGImage: img.CGImage!).imageByApplyingOrientation(5)
        let context = CIContext()
        let fixedImg = context.createCGImage(debug, fromRect: debug.extent)
        return fixedImg
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        
        if(isProcessing) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // processImageBuffer(imageBuffer)
            detectFace(imageBuffer)
            
            self.frameNo += 1
        }
    }
}
// =====

