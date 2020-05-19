//
//  NewBeefViewController.swift
//  Beefmode
//
//  Created by Jake Loresch on 4/21/20.
//  Copyright © 2020 Jake Loresch. All rights reserved.
//

import UIKit

class NewBeefViewController: UIViewController {
 
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var beefTitle: UITextField!
    @IBOutlet weak var charactersRemaining: UILabel!
    @IBOutlet weak var beefBody: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beefTitle.delegate = self
        charactersRemaining.text = String(64) //ensure that value matches 'length' at end of textField function in extention.
    }

}

//extention for charactersRemaining
extension NewBeefViewController: UITextFieldDelegate {

    func textField(_ beefTitle: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let text = beefTitle.text else { return true }
        let length = text.count + string.count - range.length

        // create an Integer of 64 - the length of your TextField.text to count down
        let count = 64 - length

        // set the .text property of your UILabel to the live created String
        charactersRemaining.text =  String(count)

        // if you want to limit to 64 charakters
        // you need to return true and <= 64

        return length <= 63 // To just allow up to 64 characters
    }

}