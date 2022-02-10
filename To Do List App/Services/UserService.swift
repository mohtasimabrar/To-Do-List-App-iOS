//
//  UserService.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase
import GoogleSignIn
import FirebaseStorage

class UserService {
    static var currentUserProfile:UserProfile?
    static var ref = Database.database(url: Constants.dataBaseURL).reference()
    static let storage = Storage.storage(url: Constants.storageURL).reference()
    
    static func observeUserProfile(_ userID:String, completion: @escaping ((_ userProfile:UserProfile?)->())) {
        
        ref.child("users").child(userID).observe(.value, with: { snapshot in
            var userProfile:UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
               let email = dict["email"] as? String,
               let firstName = dict["firstName"] as? String,
               let lastName = dict["lastName"] as? String,
               let profilePictureURL = dict["profilePictureURL"] as? String{
                
                userProfile = UserProfile(uid: snapshot.key, email: email, firstName: firstName, lastName: lastName, profilePictureURL: profilePictureURL)
                
            }
            
            completion(userProfile)
            
        })
    }
    
    
    static func getUserData(completionHandler: @escaping ((_ userProfile:UserProfile?)->())) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userID).observe(.value, with: { snapshot in
            var userProfile:UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
               let email = dict["email"] as? String,
               let firstName = dict["firstName"] as? String,
               let lastName = dict["lastName"] as? String,
               let profilePictureURL = dict["profilePictureURL"] as? String{
                
                userProfile = UserProfile(uid: snapshot.key, email: email, firstName: firstName, lastName: lastName, profilePictureURL: profilePictureURL)
                
            }
            
            completionHandler(userProfile)
            
        })
    }
    
    
    static func signIn(email: String, password: String, completionHandler: @escaping ((_ error: Error?)->())){
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {
            result, error in
            guard error == nil else {
                completionHandler(error)
                return
            }
            
            completionHandler(nil)
        })
    }
    
    
    static func googleSignIn(view: UIViewController, completionHandler: @escaping ((_ error: Error?)->()) ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: view) { user, error in
            
            if error != nil {
                completionHandler(error)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                completionHandler(error)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { result, error in
                if error != nil {
                    completionHandler(error)
                    return
                }
                
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                ref.child("users").child(userID).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        completionHandler(nil)
                        return
                    } else {
                        guard let user = user else { return }
                        
                        let emailAddress = user.profile?.email
                        let givenName = user.profile?.givenName
                        let familyName = user.profile?.familyName
                        let profilePicUrl = user.profile?.imageURL(withDimension: 320)
                        guard let profilePicUrl = profilePicUrl?.absoluteString else {
                            return
                        }

                        
                        let data: [String:String] = [
                            "email": emailAddress ?? "",
                            "firstName": givenName ?? "",
                            "lastName":familyName ?? "",
                            "profilePictureURL":profilePicUrl
                        ]
                        
                        self.ref.child("users").child(userID).setValue(data)
                        completionHandler(nil)
                    }
                }
            }
        }
    }
    
    
    static func signUp(imageData: Data?, user: [String:String?], completionHandler: @escaping ((_ error: Error?)->())) {
        if let imageData = imageData {
            let uuid = UUID().uuidString
            
            self.storage.child("images/\(uuid).png").putData(imageData, metadata: nil) { _ , error in
                guard error == nil else {
                    completionHandler(error)
                    return
                }
                
                
                self.storage.child("images/\(uuid).png").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        completionHandler(error)
                        return
                    }
                    
                    guard let email = user["email"],
                          let password = user["password"],
                          let firstName = user["firstName"],
                          let lastName = user["lastName"] else {
                              return
                          }
                    
                    FirebaseAuth.Auth.auth().createUser(withEmail: email ?? "", password: password ?? "", completion: {
                        result, error in
                        guard error == nil else {
                            completionHandler(error)
                            return
                        }
                        
                        guard let userID = Auth.auth().currentUser?.uid else { return }
                        
                        let data: [String:String?] = [
                            "email": email,
                            "firstName": firstName,
                            "lastName": lastName,
                            "profilePictureURL": url.absoluteString
                        ]
                        
                        
                        self.ref.child("users").child(userID).setValue(data)
                        
                        completionHandler(nil)
                        
                    })
                })
                
            }
        } else {
            guard let email = user["email"],
                  let password = user["password"],
                  let firstName = user["firstName"],
                  let lastName = user["lastName"] else {
                      return
                  }
            FirebaseAuth.Auth.auth().createUser(withEmail: email ?? "", password: password ?? "", completion: {
                result, error in
                guard error == nil else {
                    completionHandler(error)
                    return
                }
                
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                let data: [String:String?] = [
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "profilePictureURL": ""
                ]
                
                
                self.ref.child("users").child(userID).setValue(data)
                
                completionHandler(nil)
                
            })
        }
        
    }
    
    
    static func signOut(completionHandler: @escaping ((_ state: String?)->())) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            completionHandler(nil)
        }
        catch {
            completionHandler("error")
        }
    }
    
    
    static func resetPassword(for email: String, completionHandler: @escaping ((_ error: Error?)->())) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                completionHandler(error)
            }
            
            completionHandler(nil)
        }
    }
    
    static func updateProfile(imageData: Data?, user: UserProfile, completionHandler: @escaping ((_ error: Error?)->())) {
        
        if let imageData = imageData {
            let uuid = UUID().uuidString
            
            self.storage.child("images/\(uuid).png").putData(imageData, metadata: nil) { _ , error in
                guard error == nil else {
                    completionHandler(error)
                    return
                }
                
                
                self.storage.child("images/\(uuid).png").downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        completionHandler(error)
                        return
                    }

                        
                    let data: [String:String?] = [
                        "email": user.email,
                        "firstName": user.firstName,
                        "lastName": user.lastName,
                        "profilePictureURL": url.absoluteString
                    ]
                        
                        
                    self.ref.child("users").child(user.uid).setValue(data)
                        
                    completionHandler(nil)
                        
                })
            }
        } else {
            let data: [String:String?] = [
                "email": user.email,
                "firstName": user.firstName,
                "lastName": user.lastName,
                "profilePictureURL": user.profilePictureURL
            ]
                
                
            self.ref.child("users").child(user.uid).setValue(data)
                
            completionHandler(nil)
        }
        
        
            
    }

}
    

