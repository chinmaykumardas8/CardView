//
//  CardInputView.swift
//  CreditCardView
//
//  Created by Chinmay Das on 16/07/20.
//  Copyright © 2020 Chinmay Das. All rights reserved.
//

import UIKit
import SnapKit

enum CardType: CaseIterable {
    case visa
    case mastercard
    case americanEx
    case diners
    case discover
    case maestro
    
    var initials: [String] {
        switch self {
        case .visa:
            return ["4"]
        case .mastercard:
            return ["51", "52", "53", "54", "55"]
        case .americanEx:
            return ["34", "37"]
        case .diners:
            return ["300", "301", "302", "303", "304", "305", "36", "54"]
        case .discover:
            return ["6011", "644", "645", "646", "647", "648", "649", "65"]
        case .maestro:
            return ["5018", "5020", "5038", "5893", "6304", "6759", "6761", "6762", "6763"]
        }
    }
    
    var title: String {
        switch self {
        case .visa:
            return "Visa"
        case .mastercard:
            return "Master Card"
        case .americanEx:
            return "American Express"
        case .diners:
            return "Diners Club"
        case .discover:
            return "Discover"
        case .maestro:
            return "Maestro"
        }
    }
}

protocol CardViewDelegate: class {
    func didChangeCardNumber(cardNumber: String, error: CardError?)
}

class CardInputView: UIView {
    private let inputTextField: UITextField = UITextField(frame: .zero)
    private let cardTypeLabel: UILabel = UILabel(frame: .zero)
    private let validationLabel: UILabel = UILabel(frame: .zero)
    private let placeHolderText = "XXXX XXXX XXXX XXXX"
    private let placeholderAttributes = [NSAttributedString.Key.foregroundColor : UIColor.lightGray]
    private let inputAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    private var previousTextFieldContent: NSAttributedString?
    private var previousSelection: UITextRange?
    
    weak var delegate: CardViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(inputTextField)
        self.addSubview(cardTypeLabel)
        self.addSubview(validationLabel)
        cardTypeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(10)
            maker.right.equalTo(-10)
            maker.height.equalTo(50)
            maker.width.greaterThanOrEqualTo(50)
        }
        validationLabel.snp.makeConstraints { (maker) in
            maker.bottom.equalToSuperview().offset(-10)
            maker.right.equalToSuperview().offset(-20)
            maker.left.equalToSuperview().offset(20)
            maker.height.equalTo(20)
        }
        inputTextField.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(validationLabel.snp.top).offset(-20)
            maker.right.equalToSuperview().offset(-20)
            maker.left.equalToSuperview().offset(20)
            maker.height.equalTo(35)
        }
        cardTypeLabel.textColor = .white
        validationLabel.textColor = .white
        inputTextField.delegate = self
        setTextWithPlaceholderAttribute(for: inputTextField, updatedText: "")
        inputTextField.backgroundColor = .clear
        self.backgroundColor = .black
        self.layer.cornerRadius = 5
    }
    
    /// Validates the input text(Checks for numeric entry and max size)
    /// - Parameter text: input text
    /// - Returns: Boolean for validation
    private func isValidInput(text: String) -> Bool {
        if (text.normalizedString.isEmpty || Int(text.normalizedString) != nil) && text.normalizedString.count <= 16 {
            return true
        }
        return false
    }
    
    /// Sets a formatted atrributted string to the text field which looks like Card number with XXXX placeholder.
    /// - Parameters:
    ///   - textField: text field
    ///   - updatedText: updated normalized text which needs to be formatted
    private func setTextWithPlaceholderAttribute(for textField: UITextField, updatedText: String) {
        let textWithSpace = handleSpace(forText: updatedText)
        let placeholderSubstring = placeHolderText[textWithSpace.endIndex...]
        let attributedString = NSMutableAttributedString(string: textWithSpace + placeholderSubstring, attributes: placeholderAttributes)
        attributedString.addAttributes(inputAttributes, range: NSMakeRange(0, textWithSpace.count))
        textField.attributedText = attributedString
        
        guard let cursorPosition = textField.position(from: textField.beginningOfDocument, offset: textWithSpace.count)
            else { return }
        textField.selectedTextRange = textField.textRange(from: cursorPosition, to: cursorPosition)
    }
    
    /// This function adds white space in between the card numbers
    /// - Parameter text: normalized text with the card number
    /// - Returns: text with card number with space in between.(between each 4 set of characters)
    private func handleSpace(forText text: String) -> String {
        var textWithSpace = ""
        for index in 0..<text.count {
            if index == 4 || index == 8 || index == 12 {
                textWithSpace.append(" ")
            }
            let characterToAdd = text[text.index(text.startIndex, offsetBy:index)]
            textWithSpace.append(characterToAdd)
        }
        return textWithSpace
    }
    
    /// Luhn algorithm for card validation
    /// - Parameter number: normalized card number (normalized: with out space and placeholder)
    /// - Returns: validation boolean
    private func cardValidationCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }

        for (index, element) in digitStrings.enumerated() {
            if let digit = Int(element) {
                let odd = index % 2 == 1

                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    /// Checks the card type depending on the initial letters
    /// - Parameter updatedText: normalized card number.
    /// - Returns: CardType enum
    private func checkCardType(updatedText: String) -> CardType? {
        for cardType in CardType.allCases where cardType.initials.contains(where: {updatedText.hasPrefix($0)}) {
            return cardType
        }
        return nil
    }
}

extension CardInputView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let resultString = (textField.attributedText?.string).replacingCharacters(in: range, with: string)
        guard isValidInput(text: resultString) else { return false }
        setTextWithPlaceholderAttribute(for: textField, updatedText: resultString.normalizedString)
        var error: CardError?
        if resultString.normalizedString.count == 16 && !cardValidationCheck(resultString.normalizedString) {
            error = CardError(errorCode: 101, localizedDescription: "Card info not found")
        }
        validationLabel.text = error?.localizedDescription
        self.cardTypeLabel.text = checkCardType(updatedText: resultString.normalizedString)?.title
        delegate?.didChangeCardNumber(cardNumber: resultString.normalizedString, error: error)
        return false
    }
}

extension String {
    
    /// Removes whitespace and placeholder text from formatted string
    var normalizedString: String {
        return self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "X", with: "")
    }
}

extension Optional where Wrapped == String {
    func replacingCharacters(in range: NSRange,
                             with replacement: String) -> String {
        let string: NSString = (self ?? "") as NSString
        return string.replacingCharacters(in: range, with: replacement)
    }
}

struct CardError: Error {
    let errorCode: Int
    let localizedDescription: String
}
