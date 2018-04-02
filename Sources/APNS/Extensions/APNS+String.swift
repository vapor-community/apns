//
//  APNS+String.swift
//  APNS
//
//  Created by Anthony Castelli on 4/1/18.
//

import Foundation

extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func collapseWhitespace() -> String {
        let thecomponents = components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
        return thecomponents.joined(separator: " ")
    }
    
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of:left), let rightRange = range(of: right, options: .backwards),
            left != right && leftRange.upperBound != rightRange.lowerBound
            else { return nil }
        
        return String(self[leftRange.upperBound...index(before: rightRange.lowerBound)])
    }
    
    func splitByLength(_ length: Int) -> [String] {
        var result = [String]()
        var collectedCharacters = [Character]()
        collectedCharacters.reserveCapacity(length)
        var count = 0
        
        for character in self {
            collectedCharacters.append(character)
            count += 1
            if (count == length) {
                // Reached the desired length
                count = 0
                result.append(String(collectedCharacters))
                collectedCharacters.removeAll(keepingCapacity: true)
            }
        }
        
        // Append the remainder
        if !collectedCharacters.isEmpty {
            result.append(String(collectedCharacters))
        }
        
        return result
    }
}
