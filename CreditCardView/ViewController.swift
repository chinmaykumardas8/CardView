//
//  ViewController.swift
//  CreditCardView
//
//  Created by Chinmay Das on 15/07/20.
//  Copyright © 2020 Chinmay Das. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITextFieldDelegate, CardViewDelegate {
    private var previousTextFieldContent: String?
    private var previousSelection: UITextRange?
    var yourTextField: UITextField?
    var cardView: CardInputView = CardInputView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.view.addSubview(cardView)
        cardView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(50)
            maker.right.equalToSuperview().offset(-10)
            maker.left.equalToSuperview().offset(10)
            maker.height.equalTo(200)
        }
        cardView.delegate = self
    }

    func didChangeCardNumber(cardNumber: String, error: CardError?) {
        print(cardNumber)
        print(error?.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

