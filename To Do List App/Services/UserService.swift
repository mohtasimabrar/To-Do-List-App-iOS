//
//  UserService.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserService {
    static var currentUserProfile:UserProfile?
    static var ref = Database.database(url: Constants.dataBastURL).reference()
    
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
    
}
