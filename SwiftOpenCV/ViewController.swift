//
//  ViewController.swift
//  SwiftOpenCV
//
//  Created by Lee Whitney on 10/28/14.
//  Copyright (c) 2014 WhitneyLand. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImage : UIImage!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTakePictureTapped(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: nil, message: "Please choose an option", preferredStyle: .actionSheet)
        let choosePictureAction = UIAlertAction(title: "Choose Picture", style: .default) { (action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(choosePictureAction)
        let takePictureAction = UIAlertAction(title: "Take Picture", style: .default) { (action) in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(takePictureAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onDetectTapped(_ sender: AnyObject) {
        
        let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
        progressHud?.labelText = "Detecting..."
        progressHud?.mode = MBProgressHUDModeIndeterminate
        
        let ocr = SwiftOCR(fromImage: selectedImage)
        ocr.recognize()
        
        imageView.image = ocr.groupedImage
        
        progressHud?.hide(true);
    }
    
    @IBAction func onRecognizeTapped(_ sender: AnyObject) {
        
        if((self.selectedImage) != nil){
            let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
            progressHud?.labelText = "Detecting..."
            progressHud?.mode = MBProgressHUDModeIndeterminate
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: { () -> Void in
                let ocr = SwiftOCR(fromImage: self.selectedImage)
                ocr.recognize()
                
                DispatchQueue.main.sync(execute: { () -> Void in
                    self.imageView.image = ocr.groupedImage
                    
                    progressHud?.hide(true);
                    
                    let dprogressHud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    dprogressHud?.labelText = "Recognizing..."
                    dprogressHud?.mode = MBProgressHUDModeIndeterminate
                    
                    let text = ocr.recognizedText
                    
                    self.performSegue(withIdentifier: "ShowRecognition", sender: text);
                    
                    dprogressHud?.hide(true)
                })
            })
        }else {
            let alertController = UIAlertController(title: "SwiftOCR", message: "Please select image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        selectedImage = image;
        picker.dismiss(animated: true, completion: nil);
        imageView.image = selectedImage;
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc =  segue.destination as! DetailViewController
        vc.recognizedText = sender as! String!
    }
}

