import Foundation
import Capacitor
//import SwiftUI
import CoreMotion
//
//  ExerciseController.swift
//  WarriorU Fitness Test
//
//  Created by Nicholas Parrish on 5/25/21.
//

import SwiftUI
import AVKit
import MLKitCommon
import MLKitVision
import MLKitPoseDetectionCommon
import MLKitPoseDetectionAccurate

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

//@available(iOS 13.0, *)
@objc(MCameraPlugin)
public class MCameraPlugin: CAPPlugin {
    private let implementation = MCamera()
    private let exerciseController = ExerciseController(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), delegate: nil)


    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.echo(value)
        ])
    }
    
    @objc func showCamera(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            
            self.exerciseController.previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            
            self.exerciseController.exerciseDelegate = self
            
            let testView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            testView.backgroundColor = UIColor.red
            self.webView?.superview?.addSubview(testView)
            
//            self.webView?.superview?.addSubview(self.exerciseController.view)

            
            self.webView?.superview?.bringSubviewToFront(self.webView!)
            self.webView?.backgroundColor = UIColor.clear

            
//            print(hexStringFromColor(color: (self.webView?.subviews[0].scrollView.backgroundColor)!))
            
            
        }
        
        call.resolve()
    }
    
    @objc func updateUI(_ call: CAPPluginCall) {
        let goodReps = call.getInt("goodReps") ?? 0
        let time = call.getInt("time") ?? 0
        let badReps = call.getInt("badReps") ?? 0
        implementation.updateUI(goodReps: goodReps, badReps: badReps, time: time)
//        print("Good Reps: " + goodReps + ", Bad Reps: " + badReps + ", Time: " + time)
    }
}

func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    print(hexString)
    return hexString
 }

extension MCameraPlugin: ExerciseControllerDelegate {
    
    func graphEmitted(pose: Pose) {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(pose.landmarks)
            let ds = String(data: data, encoding: .utf8)
            self.notifyListeners("posedetected", data: ["data": ds as Any]);
        } catch {
            print(error)
        }
         
        
        
    }
}

extension Vision3DPoint: Encodable {
    enum CodingKeys: String, CodingKey {
        case x
        case y
        case z
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
}


extension PoseLandmark: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case position
        case inFrameLikelihood
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(position, forKey: .position)
        try container.encode(inFrameLikelihood, forKey: .inFrameLikelihood)
    }
    
}




protocol ExerciseControllerDelegate {
    func graphEmitted(pose: Pose)
//    func inFrameChanged(inFrameStatus: ExerciseView.InFrameStatus)
}


final class ExerciseController: UIViewController {
    
    var exerciseDelegate: ExerciseControllerDelegate?
    
    var time: Int = 0
    var goodReps: Int = 0
    var badReps: Int = 0
    var cameraController: CameraController?
    var previewView: UIView!
    var motion = CMMotionManager()
    var frame: CGRect?
    
    var started = false
    
    
    let inFrameThreshold: Float? = 0.8
    let intermdeiatBufferCount: Int = 3
    
    
    
    convenience init(frame: CGRect, delegate: ExerciseControllerDelegate?) {
        self.init()
        
        self.frame = frame
        self.exerciseDelegate = delegate
        self.cameraController = CameraController()
//        print("Exercise is \(String(describing: self.exercise?.name))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.cameraController?.stopCaptureSession()
        self.motion.stopDeviceMotionUpdates()
        self.cameraController = nil

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
//        previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        
        previewView.contentMode = UIView.ContentMode.scaleAspectFill
        view.addSubview(previewView)
        //        previewView.layer.insertSublayer(layer, at: 0)
        
        cameraController?.prepare {(error) in
            if let error = error {
                print(error)
            }
            try? self.cameraController?.displayPreview(on: self.previewView)
        }
        
        //Declare the exercisecontroller for messaging
        cameraController?.exerciseController = self
        
        //Start the devices accelerometer measuring the device angle
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 0.5
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        }
        
        //Add the lines view as a subview
        previewView.addSubview(cameraController!.annotationOverlayView)
        
        
    }
    
    func handlePose(pose: [Pose]) {
        self.exerciseDelegate?.graphEmitted(pose: pose[0])
    }
}


//@available(iOS 13.0, *)
extension ExerciseController : UIViewControllerRepresentable {
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.cameraController?.previewLayer?.frame = view.bounds
        self.cameraController?.updateVideoOrientation()
    }
    
    public typealias UIViewControllerType = ExerciseController
    
    @available(iOS 13.0, *)
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ExerciseController>) -> ExerciseController {
        return ExerciseController(frame: self.frame!, delegate: self.exerciseDelegate)
//        return ExerciseController()
    }
    
    @available(iOS 13.0, *)
    public func updateUIViewController(_ uiViewController: ExerciseController, context: UIViewControllerRepresentableContext<ExerciseController>) {
        
    }
}



