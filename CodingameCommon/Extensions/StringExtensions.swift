//
//  StringExtensions.swift
//  CodingameCommon
//
//  Created by Steven Morin on 06/09/2024.
//

import Foundation


// String extension to extract substring with a stable syntax
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}


extension String {
    func padded(toLength length: Int) -> String {
        let currentLength = self.count
        if currentLength < length {
            let padding = String(repeating: " ", count: length - currentLength)
            return self + padding
        } else {
            return self // If the string is already longer, return as is
        }
    }
}
