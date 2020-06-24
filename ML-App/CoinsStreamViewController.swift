//
//  CoinsStreamViewController.swift
//  ML-App
//
//  Created by Sabah, Sam on 19.06.20.
//  Copyright © 2020 Sabah, Sam. All rights reserved.
//

import UIKit

import UIKit
import SceneKit
import ARKit
import Vision
import AVFoundation

class CoinsStreamViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var preductionLable: UILabel!
    
    
    var currentPredection = "Empty"
    var vesionRequest = [VNRequest]()
    var coreMLqueue = DispatchQueue(label: "Uni.Goetghe.CoreMLQueue")
    
    
    

    //    Adding Voice
        let speechSynthesizer = AVSpeechSynthesizer()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Set the view's delegate
            sceneView.delegate = self
            

            
            // Create a new scene
            let scene = SCNScene()
            
            // Set the scene to the view
            sceneView.scene = scene
            sceneView.autoenablesDefaultLighting = true
            
            initlizeModell()
            coreMLUpdate()
            
            
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()

            // Run the view's session
            sceneView.session.run(configuration)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Pause the view's session
            sceneView.session.pause()
        }
        
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            switch camera.trackingState {
            case .limited(let resoan):
                statusLable.text = "Traking Lemited \(resoan) "
            case .notAvailable:
                statusLable.text = "Tracking is not avalibal"
            case .normal:
                statusLable.text = "Tap to add a Lable"
            
                    }
        }
        
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            tapHundler()
            
            let center = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
            let hittTestResults = sceneView.hitTest(center, types: [.featurePoint])
            
            if let closesPoint = hittTestResults.first {
                
                let transform = closesPoint.worldTransform
                let WorldPosition = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                
                let node = createText(for: currentPredection)
                speak(string: currentPredection)

                sceneView.scene.rootNode.addChildNode(node)
                node.position = WorldPosition
            }
            
        }
        
        
        func tapHundler (){
        
            
        }
        
        func createText (for String: String) -> SCNNode {
            
            let text = SCNText(string: String, extrusionDepth: 0.01)
            let font = UIFont(name: "AvenirNext-Bold", size: 0.15)
            text.font = font
            text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
            text.firstMaterial?.diffuse.contents = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
            text.firstMaterial?.specular.contents = UIColor.white
            text.firstMaterial?.isDoubleSided = true
            let textNode = SCNNode(geometry: text)
            let bounds = text.boundingBox
            textNode.pivot = SCNMatrix4MakeTranslation((bounds.max.x - bounds.min.x)/2, bounds.min.y, 0.005)
            textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
            let sphere = SCNSphere(radius: 0.005)
                sphere.firstMaterial?.diffuse.contents = UIColor(red: 222/255, green: 90/255, blue: 45/255, alpha: 1.0)
            let sphereNode = SCNNode(geometry: sphere)
            
            let bilBordeCostrains = SCNBillboardConstraint()
            bilBordeCostrains.freeAxes = SCNBillboardAxis.Y
            let parentNode = SCNNode()
            parentNode.addChildNode(sphereNode)
            parentNode.addChildNode(textNode)
            parentNode.constraints = [bilBordeCostrains]
            
            return parentNode
            
            
        }
        
        
        
        
        
        func initlizeModell(){
    //        guard let modell = try? VNCoreMLModel(for: Inceptionv3().model) else {
    //
    //            print("could not load modell")
    //            return
    //        }
            
            guard let modell = try? VNCoreMLModel(for: RomanCoinsClassifier1().model) else {
                  
                  print("could not load modell")
                  return
              }
            
            
            
            let classifecationRequest = VNCoreMLRequest(model: modell, completionHandler: classificationCompletionHandler)
            classifecationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            vesionRequest = [classifecationRequest]
            
        }
        
        func classificationCompletionHandler(request: VNRequest, error: Error?){
            if error != nil {
                
                print(error?.localizedDescription as Any)
                return
            }
            guard let results = request.results else {
                
                print("No result")
                return
            }
            
            if let predection = results.first as? VNClassificationObservation {
                let object = predection.identifier
                currentPredection = object
                DispatchQueue.main.async {
                    self.preductionLable.text = self.currentPredection
                }
                
            }
            
        }
        
        
        func visionRequest (){
            
            let pixleBuffer = sceneView.session.currentFrame?.capturedImage
            if pixleBuffer == nil {
                
                return
            }
            
            let image = CIImage(cvPixelBuffer: pixleBuffer!)
            let imageRequestHandler = VNImageRequestHandler(ciImage: image, options: [:])
            
            do {
                try imageRequestHandler.perform(self.vesionRequest)
                
            } catch{
                
                print("Error....")
            }
            
        }
        
        func coreMLUpdate(){
            
            coreMLqueue.async {
                self.visionRequest()
                self.coreMLUpdate()
            }
            
            
        }
        
        
        
        func speak(string:String) {
            let speechUtterance = AVSpeechUtterance(string: preductionLable.text!)
            
            speechSynthesizer.speak(speechUtterance)
        }
        

    @IBAction func resetButton(_ sender: Any) {
        
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
               node.removeFromParentNode()
           }
    }
    


}
