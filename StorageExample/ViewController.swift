//
//  ViewController.swift
//  StorageExample
//
//  Created by Nick O'Neill on 11/4/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import UIKit
import Storage

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveText() {
        if let text = textField.text where !text.isEmpty {
            Storage.pack(text, key: "saved_text")
            textField.text = ""
            print("Stored text")
        }
    }
    
    @IBAction func loadText() {
        if let unpackedText: String = Storage.unpack("saved_text") {
            textField.text = unpackedText
            print("Loaded text")
        }
    }
}

