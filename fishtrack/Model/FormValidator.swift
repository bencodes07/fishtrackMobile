//
//  FormValidator.swift
//  fishtrack
//
//  Created by Ben Böckmann on 02.06.24.
//

import Foundation

class FormValidator {
    func validateEmail(_ value: String) -> Bool {
        let regex = /^[^\.\s][\w\-\.{2,}]+@([\w-]+\.)+[\w-]{2,}$/
        return value.wholeMatch(of: regex) != nil
    }
    
    func validatePassword(_ value: String) -> Bool {
        if value.count < 8 || value.count > 16 {
            return false
        }
        return true
    }
}
