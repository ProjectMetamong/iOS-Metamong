//
//  PickerTextField.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/28.
//

import UIKit

class PickerTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
}
