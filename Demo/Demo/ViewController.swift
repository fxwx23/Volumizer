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
      
        volumizer = Volumizer.configure(defaultOptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let volumizer = volumizer else { return }
        volumizer.update(options: defaultOptions)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    func resignKeyboard(sender: UIBarButtonItem) {
        textField?.resignFirstResponder()
    }
    
    // MARK: IB Actions

    @IBAction func showAnAlertButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(closeAction)
        
        present(alert, animated: true, completion: nil)
    }
}

