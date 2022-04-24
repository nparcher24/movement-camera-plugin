////
////  CameraClass.swift
////  Temp Camera
////
////  Created by Nicholas Parrish on 5/19/21.
////
//
import Foundation
import SwiftUI
import UIKit
import AVFoundation
import CoreVideo
import MLKitCommon
import MLKitVision
import MLKitPoseDetectionCommon
import MLKitPoseDetectionAccurate




//@available(iOS 13.0, *)
class CameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var lineColor: String = "#ffffff"
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoOutput = AVCaptureVideoDataOutput()
    var poseDetector: PoseDetector?
    var exerciseController: ExerciseController?
//    var inFrame: ExerciseView.InFrameStatus = .outOfFrame
    
    lazy var annotationOverlayView: UIView = {
//        precondition(previewLayer?.isPreviewing != nil)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    convenience init(lineColor: String) {
        self.init()
        self.lineColor = lineColor
    }
    
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    private enum Constant {
        static let alertControllerTitle = "Vision Detectors"
        static let alertControllerMessage = "Select a detector"
        static let cancelActionTitleText = "Cancel"
        static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
        static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
        static let noResultsMessage = "No Results"
        static let localModelFile = (name: "bird", type: "tflite")
        static let labelConfidenceThreshold = 0.75
        static let smallDotRadius: CGFloat = 8.0
        static let lineWidth: CGFloat = 3.0
        static let originalScale: CGFloat = 1.0
        static let padding: CGFloat = 10.0
        static let resultsLabelHeight: CGFloat = 200.0
        static let resultsLabelLines = 5
        static let imageLabelResultFrameX = 0.4
        static let imageLabelResultFrameY = 0.1
        static let imageLabelResultFrameWidth = 0.5
        static let imageLabelResultFrameHeight = 0.8
        static let segmentationMaskAlpha: CGFloat = 0.5
    }
    
    func prepare(completionHandler: @escaping (Error?) -> Void){
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
            
            self.frontCamera = camera
            
            try camera?.lockForConfiguration()
            camera?.unlockForConfiguration()
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            captureSession.beginConfiguration()
            
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), captureSession.canAddInput(videoDeviceInput) else {return}
            
            captureSession.addInput(videoDeviceInput)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            //Google style
            videoOutput.videoSettings = [
                (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
            ]
            let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
            videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
            
            guard captureSession.canAddOutput(videoOutput) else {return}
            captureSession.addOutput(videoOutput)
            captureSession.sessionPreset = .medium
            
            //Nick Style
            //            videoOutput.setSampleBufferDelegate(self, queue: .main)
            captureSession.commitConfiguration()
            
            
            //Configure Pose Detector
            let options = AccuratePoseDetectorOptions()
            //            let options = PoseDetectorOptions()
            options.detectorMode = .stream
            
            poseDetector = PoseDetector.poseDetector(options: options)
            
            
            captureSession.startRunning()
            
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
            }
            
            catch {
                DispatchQueue.main.async{
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func stopCaptureSession() {
        captureSession?.stopRunning()

        if let inputs = captureSession?.inputs as? [AVCaptureDeviceInput] {
        for input in inputs {
            captureSession?.removeInput(input)
        }
      }
    }
    
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
                
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        self.previewLayer?.backgroundColor = CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(self.previewLayer!, at: 0)
//        view.backgroundColor = UIColor.red
        self.previewLayer?.frame = view.frame
        
        updateVideoOrientation()
    }
    
    func updateVideoOrientation() {
            assert(Thread.isMainThread) // UIApplication.statusBarOrientation requires the main thread.

            let videoOrientation: AVCaptureVideoOrientation
            switch UIDevice.current.orientation {
            case .portrait:
//                print("Portrait")
                videoOrientation = .portrait
            case .landscapeLeft:
//                print("Land Left")
                videoOrientation = .landscapeRight
            case .landscapeRight:
//                print("Land Right")
                videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
//                print("Upside Down")
                videoOrientation = .portraitUpsideDown
            case .faceUp, .faceDown, .unknown:
//                print("Fallthrough")
                fallthrough
            @unknown default:
                if #available(iOS 13.0, *) {
                    if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                        switch interfaceOrientation {
                        case .portrait:
                            //                        print("Portrait 2")
                            videoOrientation = .portrait
                        case .landscapeLeft:
                            //                        print("Land Left 2")
                            videoOrientation = .landscapeLeft
                        case .landscapeRight:
                            //                        print("Land Right 2")
                            videoOrientation = .landscapeRight
                        case .portraitUpsideDown:
                            //                        print("Upside Down 2")
                            videoOrientation = .portraitUpsideDown
                        case .unknown:
                            fallthrough
                        @unknown default:
                            //                        print("Unkown Unknown")
                            videoOrientation = .portrait
                        }
                    } else {
                        print("ERROR in Orientation")
                        videoOrientation = .portrait
                    }
                } else {
                    // Fallback on earlier versions
                    videoOrientation = .landscapeLeft
                }
            }

            previewLayer?.connection?.videoOrientation = videoOrientation
        }
    

    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //Process the image
        let image = VisionImage(buffer: sampleBuffer)
//        image.orientation = imageOrientation(
//            deviceOrientation: UIDevice.current.orientation,
//            cameraPosition: .front)
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          print("Failed to get image buffer from sample buffer.")
          return
        }
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
//                processImageAsynchronously(image: image, height: imageHeight, width: imageWidth)
        processImageSynchronously(image: image, height: imageHeight, width: imageWidth)


    }
    
    
    func processImageSynchronously(image: VisionImage, height: CGFloat, width: CGFloat) {
        
        var results: [Pose]?
        do {
            results = try poseDetector!.results(in: image)
        } catch let error {
            print("Failed to detect pose with error: \(error.localizedDescription).")
            return
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
            //          print("Pose detector returned no results.")
            return
        }
        
        // Success. Get pose landmarks here.
        //        print("Pose Recognized")
        exerciseController?.handlePose(pose: results!)
        
        DispatchQueue.main.sync {
            // Pose detected. Currently, only single person detection is supported.
            results!.forEach { pose in
                
                let lineColor: UIColor = UIColor.white
                
//                switch self.inFrame {
//                case .inFrame:
//                    lineColor = UIColor.green
//                case .outOfFrame:
//                    lineColor = UIColor.red
//                default:
//                    lineColor = UIColor.yellow
//                }
                
                let poseOverlayView = UIUtilities.createPoseOverlayViewWarriorU(
                    forPose: pose,
                    inViewWithBounds: self.previewLayer!.bounds,
                    lineWidth: Constant.lineWidth,
                    dotRadius: Constant.smallDotRadius,
                    positionTransformationClosure: { (position) -> CGPoint in
                        return self.normalizedPoint(
                            fromVisionPoint: position, width: width, height: height)
                    },
                    color: lineColor
                )
                
                for annotationView in self.annotationOverlayView.subviews {
                    annotationView.removeFromSuperview()
                }
                self.annotationOverlayView.addSubview(poseOverlayView)
            }
        }
    }
    
   
    
    func processImageAsynchronously(image: VisionImage, height: CGFloat, width: CGFloat) {
        poseDetector!.process(image) { detectedPoses, error in
            guard error == nil else {
                // Error.
                print("Error in pose detector")
                return
            }
            guard !detectedPoses!.isEmpty else {
                //                print("Pose not recognized")
                // No pose detected.
                return
            }

            self.exerciseController?.handlePose(pose: detectedPoses!)
            
            let lineColor: UIColor = UIColor.white
            
//            switch self.inFrame {
//            case .inFrame:
//                lineColor = UIColor.green
//            case .outOfFrame:
//                lineColor = UIColor.red
//            default:
//                lineColor = UIColor.yellow
//            }

                // Pose detected. Currently, only single person detection is supported.
                detectedPoses!.forEach { pose in
                    let poseOverlayView = UIUtilities.createPoseOverlayViewWarriorU(
                        forPose: pose,
                        inViewWithBounds: self.previewLayer!.bounds,
                        lineWidth: Constant.lineWidth,
                        dotRadius: Constant.smallDotRadius,
                        positionTransformationClosure: { (position) -> CGPoint in
                            return self.normalizedPoint(
                                fromVisionPoint: position, width: width, height: height)
                        },
                        color: lineColor
                    )
                    for annotationView in self.annotationOverlayView.subviews {
                        annotationView.removeFromSuperview()
                    }
                    self.annotationOverlayView.addSubview(poseOverlayView)
                }
        }
    }
    
    
    
    private func normalizedPoint(
      fromVisionPoint point: VisionPoint,
      width: CGFloat,
      height: CGFloat
    ) -> CGPoint {
      let cgPoint = CGPoint(x: point.x, y: point.y)
      var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
        normalizedPoint = previewLayer?.layerPointConverted(fromCaptureDevicePoint: normalizedPoint) ?? CGPoint(x: 0.0, y: 0.0)
      return normalizedPoint
    }
    
    
}

