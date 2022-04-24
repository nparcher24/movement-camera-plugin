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

@available(iOS 15.0, *)
@objc(MCameraPlugin)
public class MCameraPlugin: CAPPlugin {
    private let implementation = MCamera()
    private var exerciseController = ExerciseController(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), delegate: nil, lineColor: "#ffffff")
    
    @objc public func stopCamera() {
        self.exerciseController.view.removeFromSuperview()
        self.exerciseController.removeFromParent()
        
    }
    
    @objc func showCamera(_ call: CAPPluginCall) {
        
        guard let lineColor = call.options["lineColor"] as? String else {
            print("No Line Color passed")
            return
          }
        
        self.exerciseController = ExerciseController(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), delegate: nil, lineColor: lineColor)
        
        
        DispatchQueue.main.async {
            self.exerciseController.previewView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            self.exerciseController.exerciseDelegate = self
            self.webView?.superview?.addSubview(self.exerciseController.view)
            self.webView?.isOpaque = false
            self.webView?.backgroundColor = UIColor.clear
            self.webView?.scrollView.backgroundColor = UIColor.clear
            self.webView?.superview?.bringSubviewToFront(self.webView!)
        }
        call.resolve()
    }
}

func hexStringFromColor(color: UIColor) -> String {
    let components = color.cgColor.components
    let r: CGFloat = components?[0] ?? 0.0
    let g: CGFloat = components?[1] ?? 0.0
    let b: CGFloat = components?[2] ?? 0.0

    let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    return hexString
 }

@available(iOS 15.0, *)
extension MCameraPlugin: ExerciseControllerDelegate {

    func graphEmitted(pose: Pose) {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(pose.landmarks)
            
            let ds = String(data: data, encoding: .utf8)
            self.notifyListeners("posedetected", data: ["data": ds as Any]);
//            self.notifyListeners("posedetected", data: ["data": "STOP IT"])
        } catch {
//            print("Error: \(error)")
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
}


final class ExerciseController: UIViewController {

    var lineColor: String = "#ffffff"
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



    convenience init(frame: CGRect, delegate: ExerciseControllerDelegate?, lineColor: String) {
        self.init()
        self.lineColor = lineColor
        self.frame = frame
        self.exerciseDelegate = delegate
        self.cameraController = CameraController(lineColor: lineColor)
        
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

        previewView.contentMode = UIView.ContentMode.scaleAspectFill
        view.addSubview(previewView)

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
        return ExerciseController(frame: self.frame!, delegate: self.exerciseDelegate, lineColor: self.lineColor)
//        return ExerciseController()
    }

    @available(iOS 13.0, *)
    public func updateUIViewController(_ uiViewController: ExerciseController, context: UIViewControllerRepresentableContext<ExerciseController>) {

    }
}



