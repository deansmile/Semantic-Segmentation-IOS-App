//
//  LiveMetalCameraViewController.swift
//  SemanticSegmentation-CoreML
//
//  Created by Doyoung Gwak on 2020/11/16.
//  Copyright © 2020 Doyoung Gwak. All rights reserved.
//

//Giles10added
class CustomPressGestureRecognizer: UILongPressGestureRecognizer {
    //var obj_name: String = ""
    //var mult_val: Float = 0.0
    
    var objs = [String]()
    var mults = [Float]()
    var x_vals = [Double]()
    var objSize = [Double]()
}

import UIKit
import Vision
import AVFoundation

var sound1str:String! = "1"
var sound1pan:Float! = 0.0
var sound1vol:Float! = 0.0
var sound1obj:Int! = 1

var sound2str:String! = "2"
var sound2pan:Float! = 0.0
var sound2vol:Float! = 0.0
var sound2obj:Int! = 2

var sound3str:String! = "3"
var sound3pan:Float! = 0.0
var sound3vol:Float! = 0.0
var sound3obj:Int! = 3

var sound4str:String! = "4"
var sound4pan:Float! = 0.0
var sound4vol:Float! = 0.0
var sound4obj:Int! = 4

var sound5str:String! = "5"
var sound5pan:Float! = 0.0
var sound5vol:Float! = 0.0
var sound5obj:Int! = 5

var sound6str:String! = "6"
var sound6pan:Float! = 0.0
var sound6vol:Float! = 0.0
var sound6obj:Int! = 6

var sound7str:String! = "7"
var sound7pan:Float! = 0.0
var sound7vol:Float! = 0.0
var sound7obj:Int! = 7

var sound8str:String! = "8"
var sound8pan:Float! = 0.0
var sound8vol:Float! = 0.0
var sound8obj:Int! = 8

var sound9str:String! = "9"
var sound9pan:Float! = 0.0
var sound9vol:Float! = 0.0
var sound9obj:Int! = 9

var sound10str:String! = "10"
var sound10pan:Float! = 0.0
var sound10vol:Float! = 0.0
var sound10obj:Int! = 10

var sound11str:String! = "11"
var sound11pan:Float! = 0.0
var sound11vol:Float! = 0.0
var sound11obj:Int! = 11

var sound12str:String! = "12"
var sound12pan:Float! = 0.0
var sound12vol:Float! = 0.0
var sound12obj:Int! = 12

var sound13str:String! = "13"
var sound13pan:Float! = 0.0
var sound13vol:Float! = 0.0
var sound13obj:Int! = 13

var sound14str:String! = "14"
var sound14pan:Float! = 0.0
var sound14vol:Float! = 0.0
var sound14obj:Int! = 14

var sound15str:String! = "15"
var sound15pan:Float! = 0.0
var sound15vol:Float! = 0.0
var sound15obj:Int! = 15

var sound16str:String! = "16"
var sound16pan:Float! = 0.0
var sound16vol:Float! = 0.0
var sound16obj:Int! = 16

var sound17str:String! = "17"
var sound17pan:Float! = 0.0
var sound17vol:Float! = 0.0
var sound17obj:Int! = 17

var sound18str:String! = "18"
var sound18pan:Float! = 0.0
var sound18vol:Float! = 0.0
var sound18obj:Int! = 18

var sound19str:String! = "19"
var sound19pan:Float! = 0.0
var sound19vol:Float! = 0.0
var sound19obj:Int! = 19

var sound20str:String! = "20"
var sound20pan:Float! = 0.0
var sound20vol:Float! = 0.0
var sound20obj:Int! = 20

var drumStr = "drum"
var drumPan:Float! = 0.0
var drumVol:Float! = 1.0

var rtPersonDetectorStr:String! = "5piano"
var rtPersonDetectorPan:Float! = 0.0
var rtPersonDetectorVol:Float! = 0.0


var player1: AVAudioPlayer!
var player2: AVAudioPlayer!
var player3: AVAudioPlayer!
var player4: AVAudioPlayer!
var player5: AVAudioPlayer!
var player6: AVAudioPlayer!
var player7: AVAudioPlayer!
var player8: AVAudioPlayer!
var player9: AVAudioPlayer!
var player10: AVAudioPlayer!

var player11: AVAudioPlayer!
var player12: AVAudioPlayer!
var player13: AVAudioPlayer!
var player14: AVAudioPlayer!
var player15: AVAudioPlayer!
var player16: AVAudioPlayer!
var player17: AVAudioPlayer!
var player18: AVAudioPlayer!
var player19: AVAudioPlayer!
var player20: AVAudioPlayer!

var drumPlayer: AVAudioPlayer!

//Dean live updating of objects
var centerObj=""

var rtPersonDetector: AVAudioPlayer!

class LiveMetalCameraViewController: UIViewController, AVSpeechSynthesizerDelegate {
    
    
    
    // MARK: - UI Properties
    @IBOutlet weak var metalVideoPreview: MetalVideoView!
    @IBOutlet weak var drawingView: DrawingSegmentationView!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    var cameraTextureGenerater = CameraTextureGenerater()
    var multitargetSegmentationTextureGenerater = MultitargetSegmentationTextureGenerater()
    var overlayingTexturesGenerater = OverlayingTexturesGenerater()
    
    var cameraTexture: Texture?
    var segmentationTexture: Texture?
    
    let synthesizer = AVSpeechSynthesizer() // Speech
    var speechDelayTimer: Timer? // Makes sure that it doesn't speak too fast.
    
    
    // MARK: - AV Properties
    var videoCapture: VideoCapture!
    
    // MARK - Core ML model
    /// DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)
    /// - labels: ["background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow", "diningtable", "dog", "horse", "motorbike", "person", "pottedplant", "sheep", "sofa", "train", "tv"]
    /// - number of labels: 21
    /// FaceParsing(iOS14+)
    /// - labels:  ["background", "skin", "l_brow", "r_brow", "l_eye", "r_eye", "eye_g", "l_ear", "r_ear", "ear_r", "nose", "mouth", "u_lip", "l_lip", "neck", "neck_l", "cloth", "hair", "hat"]
    /// - number of labels: 19
    lazy var segmentationModel = { return try! DeepLabV3() }()
    let numberOfLabels = 21 // <#if you changed the segmentationModel, you have to change the numberOfLabels#>
    
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
        // 👨‍🔧.delegate = self
    }
    
    override func didReceiveMemoryWarning() { // override
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) { // override
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) { // override
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .centerCrop
        } else {
            fatalError()
        }
    }
    
    // MARK: - Setup camera
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        //Giles5 - change FPS? was 50
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: .hd1280x720) { success in
            
            if success {
                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                self.videoCapture.start()
            }
        }
    }
}

// MARK: - VideoCaptureDelegate
extension LiveMetalCameraViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoSampleBuffer sampleBuffer: CMSampleBuffer) {
        
        // 카메라 프리뷰 텍스쳐
        cameraTexture = cameraTextureGenerater.texture(from: sampleBuffer)
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if !isInferencing {
            isInferencing = true

            // start of measure
            self.👨‍🔧.🎬👏()

            // predict!
            predict(with: pixelBuffer)
        }
    }
}

// MARK: - Inference
extension LiveMetalCameraViewController {
    // prediction
    func predict(with pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    
    
    // post-processing
    // add to still image
    public func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            guard let row = segmentationmap.shape[0] as? Int,
                let col = segmentationmap.shape[1] as? Int else {
                    return
            }
            
            guard let cameraTexture = cameraTexture,
                  let segmentationTexture = multitargetSegmentationTextureGenerater.texture(segmentationmap, row, col, numberOfLabels) else {
                return
            }
            
            // Giles10 could use this and edit to reduce memory consumption
            //Giles10 need to alter the pixel numbers though
//            for counterLR in 1...11 {
//
//            let counterLRfloat = Float(counterLR)
//            let counterLRpan = Float(-1.0+((counterLRfloat-1.0)*0.2))
//
//                let pixelNumber1:Float = 0+((counterLRfloat-1)*51)
//                let pixelNumber1Int = Int(pixelNumber1)
//            sound1 = 1
//            sound1str = String(sound1)
//            sound1pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber1Int]) >= 1) {
//                    sound1vol = 1.0
//                }
//                else
//                {
//                    sound1vol = 0.0
//                }
//
//                let pixelNumber2:Float = 28728+((counterLRfloat-1)*51)
//                let pixelNumber2Int = Int(pixelNumber2)
//            sound2 = 2
//            sound2str = String(sound2)
//            sound2pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber2Int]) >= 1) {
//                    sound2vol = 1.0
//                }
//                else
//                {
//                    sound2vol = 0.0
//                }
//
//                let pixelNumber3:Float = 57456+((counterLRfloat-1)*51)
//                let pixelNumber3Int = Int(pixelNumber3)
//            sound3 = 3
//            sound3str = String(sound3)
//            sound3pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber3Int]) >= 1) {
//                    sound3vol = 1.0
//                }
//                else
//                {
//                    sound3vol = 0.0
//                }
//
//                let pixelNumber4:Float = 86184+((counterLRfloat-1)*51)
//                let pixelNumber4Int = Int(pixelNumber4)
//            sound4 = 4
//            sound4str = String(sound4)
//            sound4pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber4Int]) >= 1) {
//                    sound4vol = 1.0
//                }
//                else
//                {
//                    sound4vol = 0.0
//                }
//
//                let pixelNumber5:Float = 114912+((counterLRfloat-1)*51)
//                let pixelNumber5Int = Int(pixelNumber5)
//            sound5 = 5
//            sound5str = String(sound5)
//            sound5pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber5Int]) >= 1) {
//                    sound5vol = 1.0
//                }
//                else
//                {
//                    sound5vol = 0.0
//                }
//
//                //Giles - next values are 143640, 172368, 201096, 229824, 258552
//                let pixelNumber6:Float = 143640+((counterLRfloat-1)*51)
//                let pixelNumber6Int = Int(pixelNumber6)
//            sound6 = 6
//            sound6str = String(sound6)
//            sound6pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber6Int]) >= 1) {
//                    sound6vol = 1.0
//                }
//                else
//                {
//                    sound6vol = 0.0
//                }
//
//                let pixelNumber7:Float = 172368+((counterLRfloat-1)*51)
//                let pixelNumber7Int = Int(pixelNumber7)
//            sound7 = 7
//            sound7str = String(sound7)
//            sound7pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber7Int]) >= 1) {
//                    sound7vol = 1.0
//                }
//                else
//                {
//                    sound7vol = 0.0
//                }
//
//                let pixelNumber8:Float = 201096+((counterLRfloat-1)*51)
//                let pixelNumber8Int = Int(pixelNumber8)
//            sound8 = 8
//            sound8str = String(sound8)
//            sound8pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber8Int]) >= 1) {
//                    sound8vol = 1.0
//                }
//                else
//                {
//                    sound8vol = 0.0
//                }
//
//
//                let pixelNumber9:Float = 229824+((counterLRfloat-1)*51)
//                let pixelNumber9Int = Int(pixelNumber9)
//            sound9 = 9
//            sound9str = String(sound9)
//            sound9pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber9Int]) >= 1) {
//                    sound9vol = 1.0
//                }
//                else
//                {
//                    sound9vol = 0.0
//                }
//
//                let pixelNumber10:Float = 258552+((counterLRfloat-1)*51)
//                let pixelNumber10Int = Int(pixelNumber10)
//            sound10 = 10
//            sound10str = String(sound10)
//            sound10pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber10Int]) >= 1) {
//                    sound10vol = 1.0
//                }
//                else
//                {
//                    sound10vol = 0.0
//                }
//
//            playSound1()
//            playSound2()
//            playSound3()
//            playSound4()
//            playSound5()
//            playSound6()
//            playSound7()
//            playSound8()
//            playSound9()
//            playSound10()
//
//            usleep(150000)
//
//                if counterLR == 11 {
//                    self.player1.stop()
//                    self.player2.stop()
//                    self.player3.stop()
//                    self.player4.stop()
//                    self.player5.stop()
//                    self.player6.stop()
//                    self.player7.stop()
//                    self.player8.stop()
//                    self.player9.stop()
//                    self.player10.stop()
//                    //self.playerCamera.stop()
//                }
//            }
            let imageFrameCoordinates = StillImageViewController.getImageFrameCoordinates(segmentationmap: segmentationmap, row: row, col: col)
            
            let d = imageFrameCoordinates.d
            let x = imageFrameCoordinates.x
            let y = imageFrameCoordinates.y
            // Giles 2a commenting out
//            print("any value",terminator: Array(repeating: "\n", count: 100).joined())
            
            var objs = [String]()
            var mults = [Float]()
            var x_vals = [Double]()
            var objSizes = [Double]()

            //Dean live updating of objects
            let objects=["background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow", "table", "dog", "horse", "motorbike", "person", "plant", "sheep", "sofa", "train", "tv"]
            
            
            for (k,v) in d {
                if (k==0) {
                    continue
                }
                
                // Deep exhibit 3
                let objectAndPitchMultiplier = StillImageViewController.getObjectAndPitchMultiplier(k:k, v:v, x:x, y:y, row: row, col: col)
                let obj = objectAndPitchMultiplier.obj
                let mult_val = objectAndPitchMultiplier.mult_val
                let x_val = objectAndPitchMultiplier.xValue
                let objSize = objectAndPitchMultiplier.sizes

                // Dean live updating of objects - Dean 11/23
//                if (objSize <= 0.3) {
//                    continue
//                }
                
                
                objs.append(obj)
                mults.append(mult_val)
                x_vals.append(x_val)
                objSizes.append(objSize)
                
                //Giles9 - Add real-time spatialized object detector in here
                
//                if objs.contains("Person") {
//
//                    print("YOYO a person is HERE YO")
////                    rtPersonDetectorPan = (Float(truncating: XXX_put_person.Xpos_in_here_XXX))
//                    let wherePerson:Int = objs.firstIndex(of: "Person")!
//                    let panningPerson = x_vals[wherePerson]
//                    let panningPersonFloat = (Float(panningPerson))
//
//                }

                // Giles commented out below and replaced with above
//                let objectAndPitchMultiplier = StillImageViewController.getObjectAndPitchMultiplier(k:k, v:v, x:x, y:y, row: row, col: col)
//                let obj = objectAndPitchMultiplier.obj
//                let mult_val = objectAndPitchMultiplier.mult_val
//
//                objs.append(obj)
//                mults.append(mult_val)
                //StillImageViewController.speak(text: obj, multiplier: mult_val)
            }
            
//            if objs.contains("Person") {
//                print("YOYO a person is HERE YO")
//                let urlPerson = Bundle.main.url(forResource: "5piano", withExtension: "wav")
//                rtPersonDetector = try! AVAudioPlayer(contentsOf: urlPerson!)
//                rtPersonDetector.pan = 0.0
//                rtPersonDetector.volume = 1.0
//                rtPersonDetector.play()
//                usleep(1000000)
//            }
            let cnt=x_vals.count
            print(cnt)
            if (cnt>0) {
                let med=x_vals.sorted(by: <)[cnt / 2]
                var med_ind = 0
                for i in 0...(cnt-1) {
                    if x_vals[i]==med {
                        med_ind=i
                    }
                }
                if (objs[med_ind] != centerObj) {
                    StillImageViewController.speak(text: objs[med_ind], multiplier: 1)
                    centerObj=objs[med_ind]
                }
            }
            //Giles10added
            let press = CustomPressGestureRecognizer(target: self, action: #selector(pressSelector))
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(tapSelector))
            
            // Giles2 - added dispatchqueue - it provided verbal feedback once - it can only speak when NO OBJECTS IDENTIFIED
            // is that because it cannot access tap.objs etc
            
            DispatchQueue.main.async {
                
                press.objs = objs
                press.mults = mults
                press.x_vals = x_vals
                press.objSize = objSizes
                self.view.addGestureRecognizer(press)
                
                tap.numberOfTapsRequired = 2
                tap.objs = objs
                tap.mults = mults
                tap.x_vals = x_vals
                tap.objSize = objSizes
                self.view.addGestureRecognizer(tap)
            }
            
            //Giles10 commented out all the below
//            tap.objs = objs
//            tap.mults = mults
//            tap.x_vals = x_vals
//            // Giles added below
//            tap.objSize = objSizes

            //tap.numberOfTapsRequired = 2
            //view.addGestureRecognizer(tap)
            
            let overlayedTexture = overlayingTexturesGenerater.texture(cameraTexture, segmentationTexture)
            metalVideoPreview.currentTexture = overlayedTexture
            
            DispatchQueue.main.async { [weak self] in
                self?.👨‍🔧.🎬🤚()
                self?.isInferencing = false
            }
        } else {
            // end of measure
            self.👨‍🔧.🎬🤚()
            isInferencing = false
        }
    
    }
    
    
    // Deep exhibit 4
    
    @objc func tapSelector(sender: CustomTapGestureRecognizer) {
        let cnt = sender.objs.count
        if cnt == 0 {
            StillImageViewController.speak(text: "No Objects Identified", multiplier: 1)
        } else {
            var sorted=sender.x_vals.enumerated().sorted(by:{$0.element < $1.element})
            for (i,e) in sorted {
                let obj = sender.objs[i]
                //Giles commented out below
                if (obj=="aeroplane" || obj=="sheep" || obj=="cow" || obj=="horse") {
                    continue;
                }
                //Giles - Size ignoring could be put here, but size values need to be accessible here. Append size to sender.
                let objSizeCheck = sender.objSize[i]
                //Giles added Deans code for object ignoring based on size, was < 0.05 but too conservative
                if (obj != "bottle" && objSizeCheck <= 0.02) {
                    continue;
                }
                let mult = sender.mults[i]
                let x_value = sender.x_vals[i]
                            //sender.x_vals[i]
//                 StillImageViewController.speak(text: (obj+String(x_value)), multiplier: mult)
                StillImageViewController.speak(text: (obj + " " + StillImageViewController.horizontalPosition(posValue:x_value)), multiplier: mult)
//                sleep(1)
            }
        }
        
    }

    
    
    //Dean 11/23 was CustomTapGestureRecognizer
    @objc func pressSelector(sender: CustomPressGestureRecognizer) {
        if sender.state == .began {
        
        //Giles10 was commented out below:
        //let cnt = sender.objs.count

        //playSoundCamera()
        //Giles3 added below connected code to only provide segmentation values upon double tap
        if let observations = request?.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            guard let row = segmentationmap.shape[0] as? Int,
                let col = segmentationmap.shape[1] as? Int else {
                    return
            }
            
            
            //Giles3 Below code not essential, runs better when it on when also without audioplayer
//            guard let cameraTexture = cameraTexture,
//                  let segmentationTexture = multitargetSegmentationTextureGenerater.texture(segmentationmap, row, col, numberOfLabels) else {
//                return
//            }
//            let imageFrameCoordinates = StillImageViewController.getImageFrameCoordinates(segmentationmap: segmentationmap, row: row, col: col)

            
            
            
//            for counterCol in 1...10 {
//                for counterRow in 1...10 {
//                    continue
//                }
//            }
            
            //Giles4 could add a initial 'Ding' to indicate the scan started
            
            //Giles11 top here
            for counterLR in 1...5 {

            let counterLRfloat = Float(counterLR)

                let counterLRpan:Float! = (-0.9+((counterLRfloat-1.0)*0.4))
                let counterLR2pan:Float! = (-0.7+((counterLRfloat-1.0)*0.4))

                let pixelNumber1:Float! = 2056+((counterLRfloat-1)*112)
                let pixelNumber1Int = Int(pixelNumber1)
//            sound1 = 1
//            sound1str = String(sound1)
            sound1pan = counterLRpan
            sound1obj = (Int(truncating: segmentationmap[pixelNumber1Int]))
                
                if (sound1obj == 6 || sound1obj == 7 || sound1obj == 14 || sound1obj == 19 || sound1obj == 2 || sound1obj == 1) {
                    sound1str = "1trumpet"
                    sound1vol = 1.0
                }
                else if (sound1obj == 20) {
                    sound1str = "1breath"
                    sound1vol = 1.0
                }
                else if (sound1obj == 15) {
                    sound1str = "1piano"
                    sound1vol = 1.0
                }
                else if (sound1obj == 8 || sound1obj == 12) {
                    sound1str = "1cat"
                    sound1vol = 1.0
                }
                else if (sound1obj == 9 || sound1obj == 11 || sound1obj == 18) {
                    sound1str = "1chair"
                    sound1vol = 1.0
                }
                else if (sound1obj == 5) {
                    sound1str = "1bottle"
                    sound1vol = 1.0
                }
                else if (sound1obj == 3) {
                    sound1str = "1bird"
                    sound1vol = 1.0
                }
                else if (sound1obj >= 1) {
                    sound1str = "1"
                    sound1vol = 1.0
                }
                else
                {
                    sound1str = "1"
                    sound1vol = 0.0
                }
                
                

                let pixelNumber2:Float = 30784+((counterLRfloat-1)*112)
                let pixelNumber2Int = Int(pixelNumber2)
//            sound2 = 2
//            sound2str = String(sound2)
                sound2pan = counterLRpan
                sound2obj = (Int(truncating: segmentationmap[pixelNumber2Int]))

                    if (sound2obj == 6 || sound2obj == 7 || sound2obj == 14 || sound2obj == 19 || sound2obj == 2 || sound2obj == 1) {
                        sound2str = "2trumpet"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 20) {
                        sound2str = "2breath"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 15) {
                        sound2str = "2piano"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 8 || sound2obj == 12) {
                        sound2str = "2cat"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 9 || sound2obj == 11 || sound2obj == 18) {
                        sound2str = "2chair"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 5) {
                        sound2str = "2bottle"
                        sound2vol = 1.0
                    }
                    else if (sound2obj == 3) {
                        sound2str = "2bird"
                        sound2vol = 1.0
                    }
                    else if (sound2obj >= 1) {
                        sound2str = "2"
                        sound2vol = 1.0
                    }
                    else
                    {
                        sound2str = "2"
                        sound2vol = 0.0
                    }

                //Giles9 - example of previous way of if else statement
//            sound2pan = counterLRpan
//                if (Int(truncating: segmentationmap[pixelNumber2Int]) >= 1) {
//                    sound2vol = 1.0
//                }
//                else
//                {
//                    sound2vol = 0.0
//                }

                let pixelNumber3:Float = 59512+((counterLRfloat-1)*112)
                let pixelNumber3Int = Int(pixelNumber3)
                sound3pan = counterLRpan
                sound3obj = (Int(truncating: segmentationmap[pixelNumber3Int]))

                    if (sound3obj == 6 || sound3obj == 7 || sound3obj == 14 || sound3obj == 19 || sound3obj == 2 || sound3obj == 1) {
                        sound3str = "3trumpet"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 20) {
                        sound3str = "3breath"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 15) {
                        sound3str = "3piano"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 8 || sound3obj == 12) {
                        sound3str = "3cat"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 9 || sound3obj == 11 || sound3obj == 18) {
                        sound3str = "3chair"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 5) {
                        sound3str = "3bottle"
                        sound3vol = 1.0
                    }
                    else if (sound3obj == 3) {
                        sound3str = "3bird"
                        sound3vol = 1.0
                    }
                    else if (sound3obj >= 1) {
                        sound3str = "3"
                        sound3vol = 1.0
                    }
                    else
                    {
                        sound3str = "3"
                        sound3vol = 0.0
                    }

                let pixelNumber4:Float = 88240+((counterLRfloat-1)*112)
                let pixelNumber4Int = Int(pixelNumber4)
                sound4pan = counterLRpan
                sound4obj = (Int(truncating: segmentationmap[pixelNumber4Int]))

                    if (sound4obj == 6 || sound4obj == 7 || sound4obj == 14 || sound4obj == 19 || sound4obj == 2 || sound4obj == 1) {
                        sound4str = "4trumpet"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 20) {
                        sound4str = "4breath"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 15) {
                        sound4str = "4piano"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 8 || sound4obj == 12) {
                        sound4str = "4cat"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 9 || sound4obj == 11 || sound4obj == 18) {
                        sound4str = "4chair"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 5) {
                        sound4str = "4bottle"
                        sound4vol = 1.0
                    }
                    else if (sound4obj == 3) {
                        sound4str = "4bird"
                        sound4vol = 1.0
                    }
                    else if (sound4obj >= 1) {
                        sound4str = "4"
                        sound4vol = 1.0
                    }
                    else
                    {
                        sound4str = "4"
                        sound4vol = 0.0
                    }


                let pixelNumber5:Float = 116968+((counterLRfloat-1)*112)
                let pixelNumber5Int = Int(pixelNumber5)
                sound5pan = counterLRpan
                sound5obj = (Int(truncating: segmentationmap[pixelNumber5Int]))

                    if (sound5obj == 6 || sound5obj == 7 || sound5obj == 14 || sound5obj == 19 || sound5obj == 2 || sound5obj == 1) {
                        sound5str = "5trumpet"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 20) {
                        sound5str = "5breath"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 15) {
                        sound5str = "5piano"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 8 || sound5obj == 12) {
                        sound5str = "5cat"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 9 || sound5obj == 11 || sound5obj == 18) {
                        sound5str = "5chair"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 5) {
                        sound5str = "5bottle"
                        sound5vol = 1.0
                    }
                    else if (sound5obj == 3) {
                        sound5str = "5bird"
                        sound5vol = 1.0
                    }
                    else if (sound5obj >= 1) {
                        sound5str = "5"
                        sound5vol = 1.0
                    }
                    else
                    {
                        sound5str = "5"
                        sound5vol = 0.0
                    }


                let pixelNumber6:Float = 145696+((counterLRfloat-1)*112)
                let pixelNumber6Int = Int(pixelNumber6)
                sound6pan = counterLRpan
                sound6obj = (Int(truncating: segmentationmap[pixelNumber6Int]))

                    if (sound6obj == 6 || sound6obj == 7 || sound6obj == 14 || sound6obj == 19 || sound6obj == 2 || sound6obj == 1) {
                        sound6str = "6trumpet"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 20) {
                        sound6str = "6breath"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 15) {
                        sound6str = "6piano"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 8 || sound6obj == 12) {
                        sound6str = "6cat"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 9 || sound6obj == 11 || sound6obj == 18) {
                        sound6str = "6chair"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 5) {
                        sound6str = "6bottle"
                        sound6vol = 1.0
                    }
                    else if (sound6obj == 3) {
                        sound6str = "6bird"
                        sound6vol = 1.0
                    }
                    else if (sound6obj >= 1) {
                        sound6str = "6"
                        sound6vol = 1.0
                    }
                    else
                    {
                        sound6str = "6"
                        sound6vol = 0.0
                    }

                let pixelNumber7:Float = 174424+((counterLRfloat-1)*112)
                let pixelNumber7Int = Int(pixelNumber7)
                sound7pan = counterLRpan
                sound7obj = (Int(truncating: segmentationmap[pixelNumber7Int]))

                    if (sound7obj == 6 || sound7obj == 7 || sound7obj == 14 || sound7obj == 19 || sound7obj == 2 || sound7obj == 1) {
                        sound7str = "7trumpet"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 20) {
                        sound7str = "7breath"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 15) {
                        sound7str = "7piano"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 8 || sound7obj == 12) {
                        sound7str = "7cat"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 9 || sound7obj == 11 || sound7obj == 18) {
                        sound7str = "7chair"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 5) {
                        sound7str = "7bottle"
                        sound7vol = 1.0
                    }
                    else if (sound7obj == 3) {
                        sound7str = "7bird"
                        sound7vol = 1.0
                    }
                    else if (sound7obj >= 1) {
                        sound7str = "7"
                        sound7vol = 1.0
                    }
                    else
                    {
                        sound7str = "7"
                        sound7vol = 0.0
                    }

                let pixelNumber8:Float = 203152+((counterLRfloat-1)*112)
                let pixelNumber8Int = Int(pixelNumber8)
                sound8pan = counterLRpan
                sound8obj = (Int(truncating: segmentationmap[pixelNumber8Int]))

                    if (sound8obj == 6 || sound8obj == 7 || sound8obj == 14 || sound8obj == 19 || sound8obj == 2 || sound8obj == 1) {
                        sound8str = "8trumpet"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 20) {
                        sound8str = "8breath"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 15) {
                        sound8str = "8piano"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 8 || sound8obj == 12) {
                        sound8str = "8cat"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 9 || sound8obj == 11 || sound8obj == 18) {
                        sound8str = "8chair"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 5) {
                        sound8str = "8bottle"
                        sound8vol = 1.0
                    }
                    else if (sound8obj == 3) {
                        sound8str = "8bird"
                        sound8vol = 1.0
                    }
                    else if (sound8obj >= 1) {
                        sound8str = "8"
                        sound8vol = 1.0
                    }
                    else
                    {
                        sound8str = "8"
                        sound8vol = 0.0
                    }

                let pixelNumber9:Float = 231880+((counterLRfloat-1)*112)
                let pixelNumber9Int = Int(pixelNumber9)
                sound9pan = counterLRpan
                sound9obj = (Int(truncating: segmentationmap[pixelNumber9Int]))

                    if (sound9obj == 6 || sound9obj == 7 || sound9obj == 14 || sound9obj == 19 || sound9obj == 2 || sound9obj == 1) {
                        sound9str = "9trumpet"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 20) {
                        sound9str = "9breath"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 15) {
                        sound9str = "9piano"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 8 || sound9obj == 12) {
                        sound9str = "9cat"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 9 || sound9obj == 11 || sound9obj == 18) {
                        sound9str = "9chair"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 5) {
                        sound9str = "9bottle"
                        sound9vol = 1.0
                    }
                    else if (sound9obj == 3) {
                        sound9str = "9bird"
                        sound9vol = 1.0
                    }
                    else if (sound9obj >= 1) {
                        sound9str = "9"
                        sound9vol = 1.0
                    }
                    else
                    {
                        sound9str = "9"
                        sound9vol = 0.0
                    }

                let pixelNumber10:Float = 260608+((counterLRfloat-1)*112)
                let pixelNumber10Int = Int(pixelNumber10)
                sound10pan = counterLRpan
                sound10obj = (Int(truncating: segmentationmap[pixelNumber10Int]))

                    if (sound10obj == 6 || sound10obj == 7 || sound10obj == 14 || sound10obj == 19 || sound10obj == 2 || sound10obj == 1) {
                        sound10str = "10trumpet"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 20) {
                        sound10str = "10breath"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 15) {
                        sound10str = "10piano"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 8 || sound10obj == 12) {
                        sound10str = "10cat"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 9 || sound10obj == 11 || sound10obj == 18) {
                        sound10str = "10chair"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 5) {
                        sound10str = "10bottle"
                        sound10vol = 1.0
                    }
                    else if (sound10obj == 3) {
                        sound10str = "10bird"
                        sound10vol = 1.0
                    }
                    else if (sound10obj >= 1) {
                        sound10str = "10"
                        sound10vol = 1.0
                    }
                    else
                    {
                        sound10str = "10"
                        sound10vol = 0.0
                    }

                let url1 = Bundle.main.url(forResource: sound1str, withExtension: "wav")
                player1 = try! AVAudioPlayer(contentsOf: url1!)
                player1.pan = sound1pan
                player1.volume = sound1vol

                let url2 = Bundle.main.url(forResource: sound2str, withExtension: "wav")
                player2 = try! AVAudioPlayer(contentsOf: url2!)
                player2.pan = sound2pan
                player2.volume = sound2vol

                let url3 = Bundle.main.url(forResource: sound3str, withExtension: "wav")
                player3 = try! AVAudioPlayer(contentsOf: url3!)
                player3.pan = sound3pan
                player3.volume = sound3vol

                let url4 = Bundle.main.url(forResource: sound4str, withExtension: "wav")
                player4 = try! AVAudioPlayer(contentsOf: url4!)
                player4.pan = sound4pan
                player4.volume = sound4vol

                let url5 = Bundle.main.url(forResource: sound5str, withExtension: "wav")
                player5 = try! AVAudioPlayer(contentsOf: url5!)
                player5.pan = sound5pan
                player5.volume = sound5vol

                let url6 = Bundle.main.url(forResource: sound6str, withExtension: "wav")
                player6 = try! AVAudioPlayer(contentsOf: url6!)
                player6.pan = sound6pan
                player6.volume = sound6vol

                let url7 = Bundle.main.url(forResource: sound7str, withExtension: "wav")
                player7 = try! AVAudioPlayer(contentsOf: url7!)
                player7.pan = sound7pan
                player7.volume = sound7vol

                let url8 = Bundle.main.url(forResource: sound8str, withExtension: "wav")
                player8 = try! AVAudioPlayer(contentsOf: url8!)
                player8.pan = sound8pan
                player8.volume = sound8vol

                let url9 = Bundle.main.url(forResource: sound9str, withExtension: "wav")
                player9 = try! AVAudioPlayer(contentsOf: url9!)
                player9.pan = sound9pan
                player9.volume = sound9vol

                let url10 = Bundle.main.url(forResource: sound10str, withExtension: "wav")
                player10 = try! AVAudioPlayer(contentsOf: url10!)
                player10.pan = sound10pan
                player10.volume = sound10vol

                let drumUrl = Bundle.main.url(forResource: drumStr, withExtension: "wav")
                drumPlayer = try! AVAudioPlayer(contentsOf: drumUrl!)
                drumPlayer.pan = sound1pan
                drumPlayer.volume = drumVol

                if player1.isPlaying == true {
                    player1.stop()
                }
                else {
                    
                }
                
                if player2.isPlaying == true {
                    player2.stop()
                }
                else {
                    
                }
                
                if player3.isPlaying == true {
                    player3.stop()
                }
                else {
                    
                }
                
                if player4.isPlaying == true {
                    player4.stop()
                }
                else {
                    
                }
                
                if player5.isPlaying == true {
                    player5.stop()
                }
                else {
                    
                }
                
                if player6.isPlaying == true {
                    player6.stop()
                }
                else {
                    
                }
                
                if player7.isPlaying == true {
                    player7.stop()
                }
                else {
                    
                }
                
                if player8.isPlaying == true {
                    player8.stop()
                }
                else {
                    
                }
                
                if player9.isPlaying == true {
                    player9.stop()
                }
                else {
                    
                }
                
                if player10.isPlaying == true {
                    player10.stop()
                }
                else {
                    
                }
                
                if drumPlayer.isPlaying == true {
                    drumPlayer.stop()
                }
                else{
                    
                }
                
                
                drumPlayer.prepareToPlay()
                player1.prepareToPlay()
                player2.prepareToPlay()
                player3.prepareToPlay()
                player4.prepareToPlay()
                player5.prepareToPlay()
                player6.prepareToPlay()
                player7.prepareToPlay()
                player8.prepareToPlay()
                player9.prepareToPlay()
                player10.prepareToPlay()
//
//                sleep(1)
                usleep(100000)
                
//                drumPlayer.play()
//                player1.play()
//                usleep(10000)
//                player2.play()
//                usleep(10000)
//                player3.play()
//                usleep(10000)
//                player4.play()
//                usleep(10000)
//                player5.play()
//                usleep(10000)
//                player6.play()
//                usleep(10000)
//                player7.play()
//                usleep(10000)
//                player8.play()
//                usleep(10000)
//                player9.play()
//                usleep(10000)
//                player10.play()

                let dCurrentTime = player10.deviceCurrentTime

                print(dCurrentTime)

                let timeOffset1 = dCurrentTime + 0.05
                let timeOffset2 = dCurrentTime + 0.10
                let timeOffset3 = dCurrentTime + 0.15
                let timeOffset4 = dCurrentTime + 0.20
                let timeOffset5 = dCurrentTime + 0.25
                let timeOffset6 = dCurrentTime + 0.30
                let timeOffset7 = dCurrentTime + 0.35
                let timeOffset8 = dCurrentTime + 0.40
                let timeOffset9 = dCurrentTime + 0.45
                let timeOffset10 = dCurrentTime + 0.50
//
                drumPlayer.play(atTime: timeOffset1)
                player1.play(atTime: timeOffset1)
                player2.play(atTime: timeOffset2)
                player3.play(atTime: timeOffset3)
                player4.play(atTime: timeOffset4)
                player5.play(atTime: timeOffset5)
                player6.play(atTime: timeOffset6)
                player7.play(atTime: timeOffset7)
                player8.play(atTime: timeOffset8)
                player9.play(atTime: timeOffset9)
                player10.play(atTime: timeOffset10)

                

//            playSound1()
//            playSound2()
//            playSound3()
//            playSound4()
//            playSound5()
//            playSound6()
//            playSound7()
//            playSound8()
//            playSound9()
//            playSound10()
//
//            usleep(75000)


                    let pixelNumber11:Float = 2112+((counterLRfloat-1)*112)
                    let pixelNumber11Int = Int(pixelNumber11)
                sound11pan = counterLR2pan
                sound11obj = (Int(truncating: segmentationmap[pixelNumber11Int]))

                    if (sound11obj == 6 || sound11obj == 7 || sound11obj == 14 || sound11obj == 19 || sound11obj == 2 || sound11obj == 1) {
                        sound11str = "11trumpet"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 20) {
                        sound11str = "11breath"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 15) {
                        sound11str = "11piano"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 8 || sound11obj == 12) {
                        sound11str = "11cat"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 9 || sound11obj == 11 || sound11obj == 18) {
                        sound11str = "11chair"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 5) {
                        sound11str = "11bottle"
                        sound11vol = 1.0
                    }
                    else if (sound11obj == 3) {
                        sound11str = "11bird"
                        sound11vol = 1.0
                    }
                    else if (sound11obj >= 1) {
                        sound11str = "11"
                        sound11vol = 1.0
                    }
                    else
                    {
                        sound11str = "11"
                        sound11vol = 0.0
                    }

                    let pixelNumber12:Float = 30840+((counterLRfloat-1)*112)
                    let pixelNumber12Int = Int(pixelNumber12)
                sound12pan = counterLR2pan
                sound12obj = (Int(truncating: segmentationmap[pixelNumber12Int]))

                    if (sound12obj == 6 || sound12obj == 7 || sound12obj == 14 || sound12obj == 19 || sound12obj == 2 || sound12obj == 1) {
                        sound12str = "12trumpet"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 20) {
                        sound12str = "12breath"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 15) {
                        sound12str = "12piano"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 8 || sound12obj == 12) {
                        sound12str = "12cat"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 9 || sound12obj == 11 || sound12obj == 18) {
                        sound12str = "12chair"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 5) {
                        sound12str = "12bottle"
                        sound12vol = 1.0
                    }
                    else if (sound12obj == 3) {
                        sound12str = "12bird"
                        sound12vol = 1.0
                    }
                    else if (sound12obj >= 1) {
                        sound12str = "12"
                        sound12vol = 1.0
                    }
                    else
                    {
                        sound12str = "12"
                        sound12vol = 0.0
                    }

                    let pixelNumber13:Float = 59568+((counterLRfloat-1)*112)
                    let pixelNumber13Int = Int(pixelNumber13)
                sound13pan = counterLR2pan
                sound13obj = (Int(truncating: segmentationmap[pixelNumber13Int]))

                    if (sound13obj == 6 || sound13obj == 7 || sound13obj == 14 || sound13obj == 19 || sound13obj == 2 || sound13obj == 1) {
                        sound13str = "13trumpet"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 20) {
                        sound13str = "13breath"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 15) {
                        sound13str = "13piano"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 8 || sound13obj == 12) {
                        sound13str = "13cat"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 9 || sound13obj == 11 || sound13obj == 18) {
                        sound13str = "13chair"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 5) {
                        sound13str = "13bottle"
                        sound13vol = 1.0
                    }
                    else if (sound13obj == 3) {
                        sound13str = "13bird"
                        sound13vol = 1.0
                    }
                    else if (sound13obj >= 1) {
                        sound13str = "13"
                        sound13vol = 1.0
                    }
                    else
                    {
                        sound13str = "13"
                        sound13vol = 0.0
                    }

                    let pixelNumber14:Float = 88296+((counterLRfloat-1)*112)
                    let pixelNumber14Int = Int(pixelNumber14)
                sound14pan = counterLR2pan
                sound14obj = (Int(truncating: segmentationmap[pixelNumber14Int]))

                    if (sound14obj == 6 || sound14obj == 7 || sound14obj == 14 || sound14obj == 19 || sound14obj == 2 || sound14obj == 1) {
                        sound14str = "14trumpet"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 20) {
                        sound14str = "14breath"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 15) {
                        sound14str = "14piano"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 8 || sound14obj == 12) {
                        sound14str = "14cat"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 9 || sound14obj == 11 || sound14obj == 18) {
                        sound14str = "14chair"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 5) {
                        sound14str = "14bottle"
                        sound14vol = 1.0
                    }
                    else if (sound14obj == 3) {
                        sound14str = "14bird"
                        sound14vol = 1.0
                    }
                    else if (sound14obj >= 1) {
                        sound14str = "14"
                        sound14vol = 1.0
                    }
                    else
                    {
                        sound14str = "14"
                        sound14vol = 0.0
                    }

                    let pixelNumber15:Float = 117024+((counterLRfloat-1)*112)
                    let pixelNumber15Int = Int(pixelNumber15)
                sound15pan = counterLR2pan
                sound15obj = (Int(truncating: segmentationmap[pixelNumber15Int]))

                    if (sound15obj == 6 || sound15obj == 7 || sound15obj == 14 || sound15obj == 19 || sound15obj == 2 || sound15obj == 1) {
                        sound15str = "15trumpet"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 20) {
                        sound15str = "15breath"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 15) {
                        sound15str = "15piano"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 8 || sound15obj == 12) {
                        sound15str = "15cat"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 9 || sound15obj == 11 || sound15obj == 18) {
                        sound15str = "15chair"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 5) {
                        sound15str = "15bottle"
                        sound15vol = 1.0
                    }
                    else if (sound15obj == 3) {
                        sound15str = "15bird"
                        sound15vol = 1.0
                    }
                    else if (sound15obj >= 1) {
                        sound15str = "15"
                        sound15vol = 1.0
                    }
                    else
                    {
                        sound15str = "15"
                        sound15vol = 0.0
                    }

                    let pixelNumber16:Float = 145752+((counterLRfloat-1)*112)
                    let pixelNumber16Int = Int(pixelNumber16)
                sound16pan = counterLR2pan
                sound16obj = (Int(truncating: segmentationmap[pixelNumber16Int]))

                    if (sound16obj == 6 || sound16obj == 7 || sound16obj == 14 || sound16obj == 19 || sound16obj == 2 || sound16obj == 1) {
                        sound16str = "16trumpet"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 20) {
                        sound16str = "16breath"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 15) {
                        sound16str = "16piano"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 8 || sound16obj == 12) {
                        sound16str = "16cat"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 9 || sound16obj == 11 || sound16obj == 18) {
                        sound16str = "16chair"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 5) {
                        sound16str = "16bottle"
                        sound16vol = 1.0
                    }
                    else if (sound16obj == 3) {
                        sound16str = "16bird"
                        sound16vol = 1.0
                    }
                    else if (sound16obj >= 1) {
                        sound16str = "16"
                        sound16vol = 1.0
                    }
                    else
                    {
                        sound16str = "16"
                        sound16vol = 0.0
                    }

                    let pixelNumber17:Float = 174480+((counterLRfloat-1)*112)
                    let pixelNumber17Int = Int(pixelNumber17)
                sound17pan = counterLR2pan
                sound17obj = (Int(truncating: segmentationmap[pixelNumber17Int]))

                    if (sound17obj == 6 || sound17obj == 7 || sound17obj == 14 || sound17obj == 19 || sound17obj == 2 || sound17obj == 1) {
                        sound17str = "17trumpet"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 20) {
                        sound17str = "17breath"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 15) {
                        sound17str = "17piano"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 8 || sound17obj == 12) {
                        sound17str = "17cat"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 9 || sound17obj == 11 || sound17obj == 18) {
                        sound17str = "17chair"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 5) {
                        sound17str = "17bottle"
                        sound17vol = 1.0
                    }
                    else if (sound17obj == 3) {
                        sound17str = "17bird"
                        sound17vol = 1.0
                    }
                    else if (sound17obj >= 1) {
                        sound17str = "17"
                        sound17vol = 1.0
                    }
                    else
                    {
                        sound17str = "17"
                        sound17vol = 0.0
                    }

                    let pixelNumber18:Float = 203208+((counterLRfloat-1)*112)
                    let pixelNumber18Int = Int(pixelNumber18)
                sound18pan = counterLR2pan
                sound18obj = (Int(truncating: segmentationmap[pixelNumber18Int]))

                    if (sound18obj == 6 || sound18obj == 7 || sound18obj == 14 || sound18obj == 19 || sound18obj == 2 || sound18obj == 1) {
                        sound18str = "18trumpet"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 20) {
                        sound18str = "18breath"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 15) {
                        sound18str = "18piano"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 8 || sound18obj == 12) {
                        sound18str = "18cat"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 9 || sound18obj == 11 || sound18obj == 18) {
                        sound18str = "18chair"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 5) {
                        sound18str = "18bottle"
                        sound18vol = 1.0
                    }
                    else if (sound18obj == 3) {
                        sound18str = "18bird"
                        sound18vol = 1.0
                    }
                    else if (sound18obj >= 1) {
                        sound18str = "18"
                        sound18vol = 1.0
                    }
                    else
                    {
                        sound18str = "18"
                        sound18vol = 0.0
                    }

                    let pixelNumber19:Float = 231936+((counterLRfloat-1)*112)
                    let pixelNumber19Int = Int(pixelNumber19)
                sound19pan = counterLR2pan
                sound19obj = (Int(truncating: segmentationmap[pixelNumber19Int]))

                    if (sound19obj == 6 || sound19obj == 7 || sound19obj == 14 || sound19obj == 19 || sound19obj == 2 || sound19obj == 1) {
                        sound19str = "19trumpet"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 20) {
                        sound19str = "19breath"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 15) {
                        sound19str = "19piano"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 8 || sound19obj == 12) {
                        sound19str = "19cat"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 9 || sound19obj == 11 || sound19obj == 18) {
                        sound19str = "19chair"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 5) {
                        sound19str = "19bottle"
                        sound19vol = 1.0
                    }
                    else if (sound19obj == 3) {
                        sound19str = "19bird"
                        sound19vol = 1.0
                    }
                    else if (sound19obj >= 1) {
                        sound19str = "19"
                        sound19vol = 1.0
                    }
                    else
                    {
                        sound19str = "19"
                        sound19vol = 0.0
                    }

                    let pixelNumber20:Float = 260664+((counterLRfloat-1)*112)
                    let pixelNumber20Int = Int(pixelNumber20)
                sound20pan = counterLR2pan
                sound20obj = (Int(truncating: segmentationmap[pixelNumber20Int]))

                    if (sound20obj == 6 || sound20obj == 7 || sound20obj == 14 || sound20obj == 19 || sound20obj == 2 || sound20obj == 1) {
                        sound20str = "20trumpet"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 20) {
                        sound20str = "20breath"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 15) {
                        sound20str = "20piano"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 8 || sound20obj == 12) {
                        sound20str = "20cat"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 9 || sound20obj == 11 || sound20obj == 18) {
                        sound20str = "20chair"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 5) {
                        sound20str = "20bottle"
                        sound20vol = 1.0
                    }
                    else if (sound20obj == 3) {
                        sound20str = "20bird"
                        sound20vol = 1.0
                    }
                    else if (sound20obj >= 1) {
                        sound20str = "20"
                        sound20vol = 1.0
                    }
                    else
                    {
                        sound20str = "20"
                        sound20vol = 0.0
                    }

                let url11 = Bundle.main.url(forResource: sound11str, withExtension: "wav")
                player11 = try! AVAudioPlayer(contentsOf: url11!)
                player11.pan = sound11pan
                player11.volume = sound11vol

                let url12 = Bundle.main.url(forResource: sound12str, withExtension: "wav")
                player12 = try! AVAudioPlayer(contentsOf: url12!)
                player12.pan = sound12pan
                player12.volume = sound12vol

                let url13 = Bundle.main.url(forResource: sound13str, withExtension: "wav")
                player13 = try! AVAudioPlayer(contentsOf: url13!)
                player13.pan = sound13pan
                player13.volume = sound13vol

                let url14 = Bundle.main.url(forResource: sound14str, withExtension: "wav")
                player14 = try! AVAudioPlayer(contentsOf: url14!)
                player14.pan = sound14pan
                player14.volume = sound14vol

                let url15 = Bundle.main.url(forResource: sound15str, withExtension: "wav")
                player15 = try! AVAudioPlayer(contentsOf: url15!)
                player15.pan = sound15pan
                player15.volume = sound15vol

                let url16 = Bundle.main.url(forResource: sound16str, withExtension: "wav")
                player16 = try! AVAudioPlayer(contentsOf: url16!)
                player16.pan = sound16pan
                player16.volume = sound16vol

                let url17 = Bundle.main.url(forResource: sound17str, withExtension: "wav")
                player17 = try! AVAudioPlayer(contentsOf: url17!)
                player17.pan = sound17pan
                player17.volume = sound17vol

                let url18 = Bundle.main.url(forResource: sound18str, withExtension: "wav")
                player18 = try! AVAudioPlayer(contentsOf: url18!)
                player18.pan = sound18pan
                player18.volume = sound18vol

                let url19 = Bundle.main.url(forResource: sound19str, withExtension: "wav")
                player19 = try! AVAudioPlayer(contentsOf: url19!)
                player19.pan = sound19pan
                player19.volume = sound19vol

                let url20 = Bundle.main.url(forResource: sound20str, withExtension: "wav")
                player20 = try! AVAudioPlayer(contentsOf: url20!)
                player20.pan = sound20pan
                player20.volume = sound20vol
                
                if player11.isPlaying == true {
                    player11.stop()
                }
                else {
                    
                }
                
                if player12.isPlaying == true {
                    player12.stop()
                }
                else {
                    
                }
                
                if player13.isPlaying == true {
                    player13.stop()
                }
                else {
                    
                }
                
                if player14.isPlaying == true {
                    player14.stop()
                }
                else {
                    
                }
                
                if player15.isPlaying == true {
                    player15.stop()
                }
                else {
                    
                }
                
                if player16.isPlaying == true {
                    player16.stop()
                }
                else {
                    
                }
                
                if player17.isPlaying == true {
                    player17.stop()
                }
                else {
                    
                }
                
                if player18.isPlaying == true {
                    player18.stop()
                }
                else {
                    
                }
                
                if player19.isPlaying == true {
                    player19.stop()
                }
                else {
                    
                }
                
                if player20.isPlaying == true {
                    player20.stop()
                }
                else {
                    
                }
                
                player11.prepareToPlay()
                player12.prepareToPlay()
                player13.prepareToPlay()
                player14.prepareToPlay()
                player15.prepareToPlay()
                player16.prepareToPlay()
                player17.prepareToPlay()
                player18.prepareToPlay()
                player19.prepareToPlay()
                player20.prepareToPlay()
//
//                sleep(1)
//                usleep(100000)

                usleep(100000)
                
//                player11.play()
//                usleep(10000)
//                player12.play()
//                usleep(10000)
//                player13.play()
//                usleep(10000)
//                player14.play()
//                usleep(10000)
//                player15.play()
//                usleep(10000)
//                player16.play()
//                usleep(10000)
//                player17.play()
//                usleep(10000)
//                player18.play()
//                usleep(10000)
//                player19.play()
//                usleep(10000)
//                player20.play()
//                usleep(10000)

                let dCurrentTime2 = player20.deviceCurrentTime

                print(dCurrentTime2)

                let timeOffset11 = dCurrentTime2 + 0.05
                let timeOffset12 = dCurrentTime2 + 0.10
                let timeOffset13 = dCurrentTime2 + 0.15
                let timeOffset14 = dCurrentTime2 + 0.20
                let timeOffset15 = dCurrentTime2 + 0.25
                let timeOffset16 = dCurrentTime2 + 0.30
                let timeOffset17 = dCurrentTime2 + 0.35
                let timeOffset18 = dCurrentTime2 + 0.40
                let timeOffset19 = dCurrentTime2 + 0.45
                let timeOffset20 = dCurrentTime2 + 0.50

                player11.play(atTime: timeOffset11)
                player12.play(atTime: timeOffset12)
                player13.play(atTime: timeOffset13)
                player14.play(atTime: timeOffset14)
                player15.play(atTime: timeOffset15)
                player16.play(atTime: timeOffset16)
                player17.play(atTime: timeOffset17)
                player18.play(atTime: timeOffset18)
                player19.play(atTime: timeOffset19)
                player20.play(atTime: timeOffset20)



//                usleep(15000)
//
//                playSound1()
//                playSound2()
//                playSound3()
//                playSound4()
//                playSound5()
//                playSound6()
//                playSound7()
//                playSound8()
//                playSound9()
//                playSound10()
//
//                //Giles - was 150000
//
//                playSound11()
//                playSound12()
//                playSound13()
//                playSound14()
//                playSound15()
//                playSound16()
//                playSound17()
//                playSound18()
//                playSound19()
//                playSound20()

//                usleep(15000)

                //Giles9 debug - trying without the player.stop() commands
//                func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//                    print("finish playing code executes")
//                    return
//                }
                
//                if player20.isPlaying
//                if counterLR == 5 {

//                    usleep(3000000)
//
//                    //Giles10 this is for 2.5 seconds
//
////                    drumPlayer.stop()
//                    player1.stop()
//                    player2.stop()
//                    player3.stop()
//                    player4.stop()
//                    player5.stop()
//                    player6.stop()
//                    player7.stop()
//                    player8.stop()
//                    player9.stop()
//                    player10.stop()
//
//                    player11.stop()
//                    player12.stop()
//                    player13.stop()
//                    player14.stop()
//                    player15.stop()
//                    player16.stop()
//                    player17.stop()
//                    player18.stop()
//                    player19.stop()
//                    player20.stop()
//                    if (self.drumPlayer.isPlaying) {
//                    self.drumPlayer.stop()
//                    }
//
//                    if (self.player1.isPlaying){
//                        self.player1.stop()
//                    }
//
//                    if (self.player2.isPlaying){
//                        self.player2.stop()
//                    }
//
//                    if (self.player3.isPlaying){
//                        self.player3.stop()
//                    }
//
//                    if (self.player4.isPlaying){
//                        self.player4.stop()
//                    }
//
//                    if (self.player5.isPlaying){
//                        self.player5.stop()
//                    }
//
//                    if (self.player6.isPlaying){
//                        self.player6.stop()
//                    }
//
//                    if (self.player7.isPlaying){
//                        self.player7.stop()
//                    }
//
//                    if (self.player8.isPlaying){
//                        self.player8.stop()
//                    }
//
//                    if (self.player9.isPlaying){
//                        self.player9.stop()
//                    }
//
//                    if (self.player10.isPlaying){
//                        self.player10.stop()
//                    }
//
//                    if (self.player11.isPlaying){
//                        self.player11.stop()
//                    }
//
//                    if (self.player12.isPlaying){
//                        self.player12.stop()
//                    }
//
//                    if (self.player13.isPlaying){
//                        self.player13.stop()
//                    }
//
//                    if (self.player14.isPlaying){
//                        self.player14.stop()
//                    }
//
//                    if (self.player15.isPlaying){
//                        self.player15.stop()
//                    }
//
//                    if (self.player16.isPlaying){
//                        self.player16.stop()
//                    }
//
//                    if (self.player17.isPlaying){
//                        self.player17.stop()
//                    }
//
//                    if (self.player18.isPlaying){
//                        self.player18.stop()
//                    }
//
//                    if (self.player19.isPlaying){
//                        self.player19.stop()
//                    }
//
//                    if (self.player20.isPlaying){
//                        self.player20.stop()
//                    }
//                    self.player1.stop()
//                    self.player2.stop()
//                    self.player3.stop()
//                    self.player4.stop()
//                    self.player5.stop()
//                    self.player6.stop()
//                    self.player7.stop()
//                    self.player8.stop()
//                    self.player9.stop()
//                    self.player10.stop()
//
//                    self.player11.stop()
//                    self.player12.stop()
//                    self.player13.stop()
//                    self.player14.stop()
//                    self.player15.stop()
//                    self.player16.stop()
//                    self.player17.stop()
//                    self.player18.stop()
//                    self.player19.stop()
//                    self.player20.stop()

//                    sleep(1)
//                    self.playerCamera.stop()
                    
//                }
            }
            
            //Giles10 this is for 1 second
            usleep(1000000)
//            drumPlayer.stop()
            
            if player1.isPlaying == true {
                player1.stop()
            }
            else {
            }
            
            if player2.isPlaying == true {
                player2.stop()
            }
            else {
            }
            
            if player3.isPlaying == true {
                player3.stop()
            }
            else {
            }
            
            if player4.isPlaying == true {
                player4.stop()
            }
            else {
            }
            
            if player5.isPlaying == true {
                player5.stop()
            }
            else {
            }
            
            if player6.isPlaying == true {
                player6.stop()
            }
            else {
            }
            
            if player7.isPlaying == true {
                player7.stop()
            }
            else {
            }
            
            if player8.isPlaying == true {
                player8.stop()
            }
            else {
            }
            
            if player9.isPlaying == true {
                player9.stop()
            }
            else {
            }
            
            if player10.isPlaying == true {
                player10.stop()
            }
            else {
            }
            
            if player11.isPlaying == true {
                player11.stop()
            }
            else {
            }
            
            if player12.isPlaying == true {
                player12.stop()
            }
            else {
            }
            
            if player13.isPlaying == true {
                player13.stop()
            }
            else {
            }
            
            if player14.isPlaying == true {
                player14.stop()
            }
            else {
            }
            
            if player15.isPlaying == true {
                player15.stop()
            }
            else {
            }
            
            if player16.isPlaying == true {
                player16.stop()
            }
            else {
            }
            
            if player17.isPlaying == true {
                player17.stop()
            }
            else {
            }
            
            if player18.isPlaying == true {
                player18.stop()
            }
            else {
            }
            
            if player19.isPlaying == true {
                player19.stop()
            }
            else {
            }
            
            if player20.isPlaying == true {
                player20.stop()
            }
            else {
            }
            
            if drumPlayer.isPlaying == true {
                drumPlayer.stop()
            }
            else{
            }
//            player1.stop()
//            player2.stop()
//            player3.stop()
//            player4.stop()
//            player5.stop()
//            player6.stop()
//            player7.stop()
//            player8.stop()
//            player9.stop()
//            player10.stop()
//
//            player11.stop()
//            player12.stop()
//            player13.stop()
//            player14.stop()
//            player15.stop()
//            player16.stop()
//            player17.stop()
//            player18.stop()
//            player19.stop()
//            player20.stop()
        }
            //Giles11 starting above
            
//            var mlmObjs1 = Int(truncating: segmentationmap[0])
//        let mlmObjs2 = segmentationmap[2]
//        let mlmObjs3 = segmentationmap[3]
//        let mlmObjs4 = segmentationmap[4]
//        let mlmObjs5 = segmentationmap[512]
//        var mlmObjsCenter = Int(truncating: segmentationmap[131583])
//        print("The Object Values are \(mlmObjs1), \(mlmObjs2), \(mlmObjs3), \(mlmObjs4), \(mlmObjs5) and the center is \(mlmObjsCenter).")
            
            // Giles 3 assigning one of these values to 1 for later use
//            if (mlmObjs1 != 0) {
//                mlmObjs1 = 1
//            }
//            if (mlmObjsCenter != 0) {
                // could add code to play audio file here
//                playSound()
                //This stops everything including the visual image updating, its important to stop the player to avoid overloading the CPU
//                sleep(1)
//                player.stop()
//                mlmObjsCenter = 1
//            }
//            else {
//            }
//            print("Now The Object Values are \(mlmObjs1), and the center is \(mlmObjsCenter).")
            
            
//
//
        
    }
}
//Giles 3 - I needed to add the below bracket after adding the above segmentationmap lookup code
    //Giles4 - needed to add below bracket when re-adding the SSD code
}
// MARK: - 📏(Performance Measurement) Delegate
extension LiveMetalCameraViewController: 📏Delegate {
    
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int, objectIndex: Int) {
     

        self.maf1.append(element: Int(inferenceTime*1000.0))
        self.maf2.append(element: Int(executionTime*1000.0))
        self.maf3.append(element: fps)
        
        self.inferenceLabel.text = "inference: \(self.maf1.averageValue) ms"
        self.etimeLabel.text = "execution: \(self.maf2.averageValue) ms"
        self.fpsLabel.text = "fps: \(self.maf3.averageValue)"
    }
}


