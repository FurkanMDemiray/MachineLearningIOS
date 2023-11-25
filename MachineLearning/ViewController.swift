//
//  ViewController.swift
//  MachineLearning
//
//  Created by Melik Demiray on 25.11.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var label: UILabel!
    var choosenImage = CIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeButtonClicked(_ sender: Any) {

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)

        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage
        }

        recognizeImage(image: choosenImage)
    }


    func recognizeImage(image: CIImage) {

        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                if let err = error {
                    self.makeAlert(tittleInput: "Error!", messageInput: err.localizedDescription)
                }
                else {
                    if let result = vnrequest.results as? [VNClassificationObservation] {

                        if result.count > 0 {
                            let topResult = result.first
                            DispatchQueue.main.async {

                                let confidenceLevel = (topResult?.confidence ?? 0) * 100
                                let rounded = Int(confidenceLevel * 100) / 100
                                self.label.text = "\(rounded)% it's \(topResult?.identifier ?? "unknown")"
                            }
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print(error)
                }
            }
        }

    }

    func makeAlert(tittleInput: String, messageInput: String) {

        let alert = UIAlertController(title: tittleInput, message: messageInput, preferredStyle: .alert)

        let okButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        alert.addAction(okButton)

        self.present(alert, animated: true, completion: nil)
    }

}

