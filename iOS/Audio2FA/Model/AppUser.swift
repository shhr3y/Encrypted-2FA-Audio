//
//  AppUser.swift
//  Audio2FA
//
//  Created by Shrey Gupta on 07/12/22.
//

import Foundation

let defaults = UserDefaults.standard

class AppUser {
    static let shared = AppUser()
    
    func setDefaultUser(user: User) -> Bool {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            defaults.set(data, forKey: "USER")
            
            return true
        } catch {
            print("Unable to Encode User (\(error))")
            return false
        }
    }
    
    func removeDefaultUser() {
        defaults.removeObject(forKey: "USER")
    }
    
    func getDefaultUser() -> User? {
        if let checkData = defaults.data(forKey: "USER") {
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(User.self, from: checkData)
                return user
            } catch {
                print("Unable to Decode user (\(error))")
                return nil
            }
        } else {
            return nil
        }
    }
}
