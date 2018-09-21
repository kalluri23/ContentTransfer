//
//  StringExtension.swift
//  AppListFetchWithGoogleAPI
//
//  Created by Sun, Xin on 3/30/17.
//  Copyright © 2017 Sun, Xin. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /**
     Array of possible character set property.
     */
    private var allCharacterSets:Array<CharacterSet> {
        get {
            return [.urlQueryAllowed, .urlPathAllowed, .urlHostAllowed, .urlFragmentAllowed, .urlPasswordAllowed]
        }
    }
    
    /**
     Get class name from object. This is a class method.
     - returns:
        String value represents class name
     - parameters:
        - aClass: Class object to get the name for.
     */
    static func stringFromClass(_ aClass: AnyClass) -> String {
        let fullClassString = NSStringFromClass(aClass)
        let range = fullClassString.range(of: ".", options: .caseInsensitive, range: Range<String.Index>.init(uncheckedBounds: (lower: fullClassString.startIndex, upper: fullClassString.endIndex)), locale: nil)
        return String(fullClassString[range!.upperBound..<fullClassString.endIndex])
    }
    
    /**
     Encode the URL string components.
     - returns:
        String value represents encoded URL component.
     */
    func encodeForURLComponents() -> String {
        let encodedString = self._findProperEncoding(self.allCharacterSets[0], index: 0) // Start character set by use urlQueryAllowed.
        return encodedString.replacingOccurrences(of: "&", with: "%26").replacingOccurrences(of: "/", with: "%2F") //Important: replace & with %26, and / with %2F for URL, seems like encode method not picking this character
    }
    
    /**
     Try to get the proper encoding method for data. Method will try possible known encoding way until get the result returned. Otherwise, it will return the original string.
     - parameters:
        - characterSet: The character set using for encoding.
        - index: The index of the current character set.
     - returns:
        String value represents the encoded string.
     */
    private func _findProperEncoding(_ chracterSet: CharacterSet, index: NSInteger) -> String {
        let encodedString:String = self.addingPercentEncoding(withAllowedCharacters: chracterSet)!
        if (encodedString.isEmpty) {
            if (index == self.allCharacterSets.count-1) { // last index, I don't see in anycase code will come to this. Just for sure.
                return self
            } else {
                return self._findProperEncoding(self.allCharacterSets[index+1], index: index+1)
            }
        } else {
            return encodedString
        }
    }
}

/**
 Get localized string in swift
 - returns:
 String value represents localized string as per device locale
 - parameters:
 - key: input string to translate.
 - value: developer comment string.
 */

func CTLocalizedString(_ key: String, comment:String) -> String {
    #if STANDALONE
        return Bundle.main.localizedString(forKey: key, value: comment, table: "Localizable")
    #else
        return Bundle(identifier: "com.vzw.contentTransfer.framework.bundle")!.localizedString(forKey: key, value: comment, table: "Localizable")
    #endif
}
