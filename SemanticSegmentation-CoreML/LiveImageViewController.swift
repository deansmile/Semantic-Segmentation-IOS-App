//
//  ViewController.swift
//  ImageSegmentation-CoreML
//
//  Created by Doyoung Gwak on 20/07/2019.
//  Edited by Sriram Bhimaraju on 27/01/2022
//  Copyright © 2019 Doyoung Gwak. All rights reserved.
/*
 * In this view controller, the user surveys a scene in real time with
 * their camera, and the app analyzes the objects it sees.
 *
 * Current features in the app:
 *   The app says aloud what it sees in the frame. Based on how high or low the object is in the image frame, the program speaks in a different tone. An object high in the frame will be announced in a high-pitch female tone, while an object low in the frame will be announced in a deep, male tone
 *
 * Potential features to be added:
 *   HRTF spacialization or changing the right-left headphone balance could be used to indicate an object's horizontal placement in the image frame. Additionally, the app should speak only when the image is double-tapped, so the user can customize when they hear auditory feedback.
 *
 * Limitations:
 *   The app speaks in a slightly jarring and monotonous tone.
 */


import UIKit
import Vision
import AVFoundation


class LiveImageViewController: UIViewController, AVSpeechSynthesizerDelegate{
    

    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var drawingView: DrawingSegmentationView!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    
    // MARK: - AV Properties
    var videoCapture: VideoCapture!
    
    // MARK - Core ML model
    // DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)
    // FaceParsing(iOS14+)
    lazy var segmentationModel = {
        return try! DeepLabV3()
    }()

//    11 Pro
//    DeepLabV3        : 37 465 1
//    DeepLabV3FP16    : 40 511 1
//    DeepLabV3Int8LUT : 40 520 1
//
//    XS
//    DeepLabV3        : 135 409 2
//    DeepLabV3FP16    : 136 403 2
//    DeepLabV3Int8LUT : 135 412 2
//
//    X
//    DeepLabV3        : 177 531 1
//    DeepLabV3FP16    : 177 530 1
//    DeepLabV3Int8LUT : 177 517 1
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    var isInferencing = false
    
    // MARK: - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    let maf1 = MovingAverageFilter()
    let maf2 = MovingAverageFilter()
    let maf3 = MovingAverageFilter()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup ml model
        setUpModel()
        
        // setup camera
        setUpCamera()
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    // MARK: - Setup camera
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // UI에 비디오 미리보기 뷰 넣기
                if let previewLayer = self.videoCapture.makePreview() {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
}

// MARK: - VideoCaptureDelegate
extension LiveImageViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoSampleBuffer sampleBuffer: CMSampleBuffer) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        // the captured image from camera is contained on pixelBuffer
        if let pixelBuffer = pixelBuffer, !isInferencing {
            isInferencing = true
            
            // start of measure
            self.👨‍🔧.🎬👏()
            
            // predict!
            predict(with: pixelBuffer)
        }
    }
}

// MARK: - Inference
extension LiveImageViewController {
    // prediction
    func predict(with pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }

    // post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            
            // sriram - new code
            guard let row = segmentationmap.shape[0] as? Int,
                let col = segmentationmap.shape[1] as? Int else {
                    return
            }
            
            let imageFrameCoordinates = StillImageViewController.getImageFrameCoordinates(segmentationmap: segmentationmap, row: row, col: col)
            

            let d = imageFrameCoordinates.d
            let x = imageFrameCoordinates.x
            let y = imageFrameCoordinates.y
            
            print("any value",terminator: Array(repeating: "\n", count: 100).joined())
            var objs = [String]()
            var mults = [Float]()
            
            for (k,v) in d {
                if (k==0) {
                    continue
                }
                
                let objectAndPitchMultiplier = StillImageViewController.getObjectAndPitchMultiplier(k:k, v:v, x:x, y:y, row: row, col: col)
                let obj = objectAndPitchMultiplier.obj
                let mult_val = objectAndPitchMultiplier.mult_val

                objs.append(obj)
                mults.append(mult_val)
                //StillImageViewController.speak(text: obj, multiplier: mult_val)
            }
            
            
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(tapSelector))
            tap.objs = objs
            tap.mults = mults
            tap.numberOfTapsRequired = 2
            view.addGestureRecognizer(tap)
            
            // sriram - existing rendering code
            let segmentationResultMLMultiArray = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
            DispatchQueue.main.async { [weak self] in
                // update result
                self?.drawingView.segmentationmap = segmentationResultMLMultiArray
                
                // end of measure
                self?.👨‍🔧.🎬🤚()
                self?.isInferencing = false
            }
        } else {
            // end of measure
            self.👨‍🔧.🎬🤚()
            isInferencing = false
        }
    }
    
    @objc func tapSelector(sender: CustomTapGestureRecognizer) {
        let cnt = sender.objs.count
        if cnt == 0 {
            StillImageViewController.speak(text: "No Objects Identified", multiplier: 1)
        } else {
            for i in 0...cnt-1 {
                let obj = sender.objs[i]
                let mult = sender.mults[i]
                StillImageViewController.speak(text: obj, multiplier: mult)
            }
        }
    }
}


// MARK: - 📏(Performance Measurement) Delegate
extension LiveImageViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int, objectIndex: Int) {
        self.maf1.append(element: Int(inferenceTime*1000.0))
        self.maf2.append(element: Int(executionTime*1000.0))
        self.maf3.append(element: fps)
        
        self.inferenceLabel.text = "inference: \(self.maf1.averageValue) ms"
        self.etimeLabel.text = "execution: \(self.maf2.averageValue) ms"
        self.fpsLabel.text = "fps: \(self.maf3.averageValue)"
    }
}

class MovingAverageFilter {
    private var arr: [Int] = []
    private let maxCount = 10
    
    public func append(element: Int) {
        arr.append(element)
        if arr.count > maxCount {
            arr.removeFirst()
        }
    }
    
    public var averageValue: Int {
        guard !arr.isEmpty else { return 0 }
        let sum = arr.reduce(0) { $0 + $1 }
        return Int(Double(sum) / Double(arr.count))
    }
}
