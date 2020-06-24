//
//  ViewController.swift
//  ML-App
//
//  Created by Sabah, Sam on 21.05.20.
//  Copyright © 2020 Sabah, Sam. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
  
        

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userImage
            guard let ciImage = CIImage(image: userImage) else {
                fatalError("could not convert to an iomage")
            }
            
            detectImage(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectImage(image: CIImage)->UILabel{
        
        // Places Model
//        guard let model = try? VNCoreMLModel(for: MyImageClassifier_1_Basic().model) else{
//            fatalError("We need Help")
//        }
//
        
        // Food Modell
//        guard let model = try? VNCoreMLModel(for: FoodClassifier2().model) else{
//               fatalError("We need Help")
//           }
//
        // Coins Model
        
        
           guard let model = try? VNCoreMLModel(for: RomanCoinsImageClassifier_1().model) else{
                  fatalError("We need Help")
              }
           
        
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else{
                fatalError("modell faild to prossace result")
            }
            
            if let firstResult = result.first{
                if firstResult.confidence >= 0.85{
                    self.label.text = ("ohhhh hunny! give me somthing harder \(firstResult.identifier) 😎, do you wanna know how confident I am? will .. look for your self!  \(Int(firstResult.confidence * 100))% ")
                }
                
                if firstResult.confidence >= 0.7{
                    self.label.text = ("it's \(firstResult.identifier) 😎, I am like \(Int(firstResult.confidence * 100))% confident")
                } else if firstResult.confidence >= 0.6{
                      self.label.text = ("maybe it is \(firstResult.identifier) 😅 \(Int(firstResult.confidence * 100))%")
                }  else if firstResult.confidence >= 0.5{
                    self.label.text = ("propably it \(firstResult.identifier) 🥺,but I am like \(Int(firstResult.confidence * 100))% sure so dont count on it")

                } else {
                    self.label.text = ("Aaaa I dont knwo, you ask alot! maybe its \(firstResult.identifier) 🥺,I'm only  \(Int(firstResult.confidence * 100))% confident, train me some more!")

                    
                }
  
                print(firstResult)
            }
        }
        
        let habdler = VNImageRequestHandler(ciImage: image)
        do{
        try habdler.perform([request])
        }
        catch{
            print(error)
        }
       return self.label
    }
    @IBAction func camera(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

