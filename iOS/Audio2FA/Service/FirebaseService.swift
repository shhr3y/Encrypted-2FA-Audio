//
//  FirebaseService.swift
//  Audio2FA
//
//  Created by Shrey Gupta on 21/11/22.
//

import UIKit
import Firebase

let DB_REF = Database.database().reference()
let DB_REF_USERS = DB_REF.child("users")

struct FirebaseService {
    static let shared = FirebaseService()
    
    func createAccount(withEmail email: String, fullname: String, password: String, completion: @escaping(Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Error on Registration with Email: ", error.localizedDescription)
                completion(false, error)
            } else {
                print("DEBUG: Registration Successful for Email: ", result?.user.email! as Any)
                
                guard let uid = result?.user.uid else { return }
                
                var cryptoKeys = [String: Any]()
                
                var index = 0
                
                while index < 11 {
                    cryptoKeys[String(index)] = String.randomString(length: 32)
                    index += 1
                }
                
                let userdata = ["email": email, "fullname": fullname, "keys": cryptoKeys] as [String : Any]
                
                DB_REF_USERS.child(uid).updateChildValues(userdata) { (error, reference) in
                    if let error = error {
                        print("DEBUG: Error from Database: ", error.localizedDescription)
                        completion(false, error)
                    }else{
                        print("DEBUG: Succesfully registered user and saved in database.")
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func signInAccount(withEmail email: String, password: String, completion: @escaping(Bool, User?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Error on SignIn with Email: ", error.localizedDescription)
                completion(false, nil, error)
            } else {
                print("DEBUG: SignIn Successful for Email: ", result?.user.email! as Any)
                
                guard let uid = result?.user.uid else { return }
                
                fetchUserData(currentUID: uid) { user in
                    completion(true, user, nil)
                }
            }
        }
    }
    
    func fetchUserData(currentUID: String, completion: @escaping(User) -> Void) {
        print("DEBUG: fetching user data!")
        DB_REF_USERS.child(currentUID).observeSingleEvent(of: .value, with: { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: currentUID, dictionary: dictionary)
            completion(user)
        })
    }
    
    func getCurrentUID() -> String? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return uid
    }
    
    func signOut(completion: @escaping(Error?) -> ()){
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
}
