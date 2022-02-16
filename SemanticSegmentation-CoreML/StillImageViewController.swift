//
//  StillImageViewController.swift
//  SemanticSegmentation-CoreML
//
//  Created by Doyoung Gwak on 20/07/2019.
//  Edited by Sriram Bhimaraju on 27/01/2022
//  Copyright © 2019 Doyoung Gwak. All rights reserved.
//

/*
 * In this view controller, the user selects the still image
 * option in the app. They then select any image in their camera roll
 * for the app to analyze.
 *
 * Current features in the app:
 *   The app says aloud what it sees in the image. Based on how high or low the object is in the image frame, the program speaks in a different tone. An object high in the frame will be announced in a high-pitch female tone, while an object low in the frame will be announced in a deep, male tone
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


class StillImageViewController: UIViewController,
                                    AVSpeechSynthesizerDelegate {

    // MARK: - UI Properties
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var drawingView: DrawingSegmentationView!
    
    let imagePickerController = UIImagePickerController()
    
    // MARK - Core ML model
    // DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)
    let segmentationModel = DeepLabV3()
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?

    /*
     *
     * It takes as inputs the segmentationmap, the number of rows, and the number of columns of the camera image and returns the depth, x, and y coordinates of the image frame.
     */
    public static func getImageFrameCoordinates(segmentationmap: MLMultiArray, row: Int, col: Int) -> (d: Dictionary<Int, Int>, x: Dictionary<Int, Int>, y: Dictionary<Int, Int>) {
        var d=[Int: Int](),x=[Int:Int](),y=[Int:Int]()
        for i in 0...row-1 {
            for j in 0...col-1 {
                let key=[i,j] as [NSNumber]
                let k=segmentationmap[key].intValue
                if d.keys.contains(k) {
                    let a : Int = d[k] ?? 0
                    let b : Int = x[k] ?? 0
                    let c : Int = y[k] ?? 0
                    d[k]=a+1
                    x[k]=b+j
                    y[k]=c+i
                }
                else {
                    d[k]=0
                    x[k]=j
                    y[k]=i
                }
            }
        }
        
        return (d, x, y)
    }
    
    /*
     *
     * Returns the recognized object name and the pitch multiplier to use when speaking it out
     *
     */
    public static func getObjectAndPitchMultiplier(k: Int, v: Int, x: Dictionary<Int, Int>, y: Dictionary<Int, Int>, row: Int, col: Int) -> (obj: String, mult_val: Float) {
        let objects=["background", "aeroplane", "bicycle", "bird", "boat", "bottle", "bus", "car", "cat", "chair", "cow", "diningtable", "dog", "horse", "motorbike", "person", "pottedplant", "sheep", "sofa", "train", "tv"]
        
        let b : Int = x[k] ?? 0
        let c : Int = y[k] ?? 0
        print ("------------")
        print ("objects[k] is: ")
        print (objects[k])
        print ("------------")
        
        print(objects[k], Double(b)/Double(v)/Double(col),1-Double(c)/Double(v)/Double(row))
        print("The multiplier y is ")
        print(1-Double(c)/Double(v)/Double(row))
        
        // old: multiplier: Float((y[k]!))+0.7
        let multiplier = 0.7 + Float(1-Double(c)/Double(v)/Double(row))
        
        return (objects[k], multiplier)
        
    }
    
    /*
     * Speaks the given String using a particular tone and pitch
     *
     * @param   text is the String to be spoken
     *          multiplier alters the tone and pitch in which text is said
     */
    public static func speak(text: String, multiplier: Float) {
        let synthesizer = AVSpeechSynthesizer() // Speech
        var speechDelayTimer: Timer? // Makes sure that it doesn't speak too fast.
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.5 // slows down speaking speed
        utterance.pitchMultiplier = multiplier; // 0.7
        if (multiplier < 1) {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        }
        else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
        }
        synthesizer.speak(utterance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // image picker delegate setup
        imagePickerController.delegate = self
        
        // setup ml model
        setUpModel()
    }
    
    @IBAction func tapCamera(_ sender: Any) {
        self.present(imagePickerController, animated: true)
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
            self.visionModel = visionModel
            request?.imageCropAndScaleOption = .centerCrop
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            
            print ("----- Segmentation Model Type ------")
            print (type(of: segmentationModel))
            // DeepLabV3
            print ("------------------------------------")

        } else {
            fatalError()
        }
    }
}


// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension StillImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print ("INSIDE StillImageViewController")
        

        // speak(text: "test String")
        
        if let image = info[.originalImage] as? UIImage,
            let url = info[.imageURL] as? URL {
            mainImageView.image = image
            self.predict(with: url)
            // StillImageViewController.speak(text: "Sofa to the right", multiplier: 0.7)
        }
        dismiss(animated: true, completion: nil)
    }
}



// MARK: - Inference
extension StillImageViewController {
    // prediction
    func predict(with url: URL) {
        guard let request = request else { fatalError() }
        
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(url: url, options: [:])
        try? handler.perform([request])
    }

    
    // post-processing
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        print ("INSIDE STILL IMAGE visionRequestDidComplete")
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue {
            
            guard let row = segmentationmap.shape[0] as? Int,
                let col = segmentationmap.shape[1] as? Int else {
                    return
            }
            
            let imageFrameCoordinates = StillImageViewController.getImageFrameCoordinates(segmentationmap: segmentationmap, row: row, col: col)
            
            let d = imageFrameCoordinates.d
            let x = imageFrameCoordinates.x
            let y = imageFrameCoordinates.y

            print("any value",terminator: Array(repeating: "\n", count: 100).joined())
            
            for (k,v) in d {
                if (k==0) {
                    continue
                }

                let objectAndPitchMultiplier = StillImageViewController.getObjectAndPitchMultiplier(k:k, v:v, x:x, y:y, row: row, col: col)
                let obj = objectAndPitchMultiplier.obj
                let mult_val = objectAndPitchMultiplier.mult_val

                StillImageViewController.speak(text: obj, multiplier: mult_val)
                sleep(3);
                
                // DispatchQueue.main.asyncAfter(deadline: .now() + 2)
            }
            
            drawingView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
        }
    }
}

