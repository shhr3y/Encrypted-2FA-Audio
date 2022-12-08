//
//  User.swift
//  Audio2FA
//
//  Created by Shrey Gupta on 21/11/22.
//

import Foundation

struct User: Codable {
    let uid: String
    let fullname: String
    let email: String
    var keys : [String]
    
    var firstInitial: String { return String(fullname.prefix(1)) }

    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.keys = dictionary["keys"] as? [String] ?? [String]()
    }
    
    func getEncryptionKey() -> String {
        let date = Date()
        let calendar = Calendar.current

        let seconds = calendar.component(.second, from: date)
        
        let currentSecond = Int(date.timeIntervalSince1970) - seconds
        
        let keyIndex = currentSecond % (self.keys.count)
        print("DEBUG:- KEY INDEX: \(keyIndex) | key: \(keys[keyIndex])")
        
        return keys[keyIndex]
    }
}
