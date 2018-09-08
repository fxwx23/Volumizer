//
//  ViewController.swift
//  Demo
//
//  Created by Fumitaka Watanabe on 2017/03/17.
//  Copyright © 2017年 Fumitaka Watanabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    var imagePicler: UIImagePickerController?
    var volumizer: Volumizer?
    let defaultOptions: [VolumizerAppearanceOption] = [ .overlayIsTranslucent(true),
                                                        .overlayBackgroundBlurEffectStyle( .extraLight),
                                                        .overlayBackgroundColor( .white),
                                                        .sliderProgressTintColor( .black)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target:nil, action: nil)
        let doneButton = UIBarButtonItem(title: "close", style: .done, target: self, action: #selector(resignKeyboard(sender:)))
        toolbar.setItems([space, doneButton], animated: true)
        textField?.inputAccessoryView = toolbar
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @objc func resignKeyboard(sender: UIBarButtonItem) {
        textField?.resignFirstResponder()
    }
    
    // MARK: IB Actions
    
    @IBAction func showAnAlertButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func callResignButtonTapped(_ sender: UIButton) {
        if let volumizer = volumizer {
            defer { self.volumizer = nil }
            
            volumizer.resign()
            configureButton.setTitle("call configure()", for: .normal)
            configureButton.setTitleColor( .black, for: .normal)
            resultLabel.text = "Before"
        }
        else {
            volumizer = Volumizer.configure(defaultOptions)
            configureButton.setTitle("call resign()", for: .normal)
            configureButton.setTitleColor( .red, for: .normal)
            resultLabel.text = "After"
        }
    }
    
}

