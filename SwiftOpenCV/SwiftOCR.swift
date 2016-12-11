//
//  SwiftOCR.swift
//  SwiftOpenCV
//
//  Created by Lee Whitney on 10/28/14.
//  Copyright (c) 2014 WhitneyLand. All rights reserved.
//

import Foundation
import UIKit

class SwiftOCR {
    
    var _image: UIImage
    var _tesseract: Tesseract
    var _characterBoxes : Array<CharBox>
    
    var _groupedImage : UIImage
    var _recognizedText: String
    
    //Get grouped image after executing recognize method
    var groupedImage : UIImage {
        get {
            return _groupedImage;
        }
    }
    
    //Get Recognized Text after executing recognize method
    var recognizedText: String {
        get {
            return _recognizedText;
        }
    }
    
    var characterBoxes :Array<CharBox> {
        get {
            return _characterBoxes;
        }
    }
    
    init(fromImagePath path:String) {
        _image = UIImage(contentsOfFile: path)!
        _tesseract = Tesseract(language: "eng")
        _tesseract.setVariableValue("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", forKey: "tessedit_char_whitelist")
        _tesseract.image = _image
        _characterBoxes = Array<CharBox>()
        _groupedImage = _image
        _recognizedText = ""
    }
    
    init(fromImage image:UIImage) {
        let fimage = image.fixOrientation()
        
        let size = CGSize(width: (fimage?.size.width)!, height: (fimage?.size.height)!)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        fimage?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
       _image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
       
    
        
        _tesseract = Tesseract(language: "eng")
        _tesseract.setVariableValue("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", forKey: "tessedit_char_whitelist")
        _tesseract.image = _image
        _characterBoxes = Array<CharBox>()
         _groupedImage = _image
        _recognizedText = ""
        NSLog("%d",_image.imageOrientation.rawValue);
    }
    
    //Recognize function
    func recognize() {
        
         _characterBoxes = Array<CharBox>()
        
        let uImage = CImage(image: _image);
        
        let channels = uImage?.channels;
        
        let classifier1 = Bundle.main.path(forResource: "trained_classifierNM1", ofType: "xml")
        let classifier2 = Bundle.main.path(forResource: "trained_classifierNM2", ofType: "xml")
        
        let erFilter1 = ExtremeRegionFilter.createERFilterNM1(classifier1, c: 8, x: 0.00015, y: 0.13, f: 0.2, a: true, scale: 0.1);
        var _ = ExtremeRegionFilter.createERFilterNM2(classifier2, andX: 0.5);
        
        var regions = Array<ExtremeRegionStat>();
        
//        var index : Int;
        for index in 0..<(channels?.count)! {
            var region = ExtremeRegionStat()
            
            region = (erFilter1?.run(channels?[index] as! UIImage))!;
            
            regions.append(region);
        }
        
        _groupedImage = ExtremeRegionStat.groupImage(uImage, withRegions: regions);
        
        _tesseract.recognize();
    
        var words = _tesseract.getConfidenceByWord;
        
        var texts = Array<String>();
        
//        var windex: Int
        for windex in 0..<(words?.count)! {
            let dict = words?[windex] as! Dictionary<String, AnyObject>
            let text = dict["text"]! as! String
            let confidence = dict["confidence"]! as! Float
            let box = dict["boundingbox"] as! NSValue
            if((text.utf16.count < 2 || confidence < 51) || (text.utf16.count < 4 && confidence < 60)){
                continue
            }
            
            let rect = box.cgRectValue
            _characterBoxes.append(CharBox(text: text, rect: rect))
            texts.append(text)
        }
        
        var str : String = ""
        
        for (idx, item) in texts.enumerated() {
            str += item
            if idx < texts.count-1 {
                str += " "
            }
        }
        
        _recognizedText = str
    }
}
