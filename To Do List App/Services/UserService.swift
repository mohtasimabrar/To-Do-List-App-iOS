//
//  UserService.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import Foundation
import FirebaseDatabase

class UserService {
    static var currentUserProfile:UserProfile?
    
    static func observeUserProfile(_ uid:String, completion: @escaping ((_ userProfile:UserProfile?)->())) {
        let userRef = Database.database(url: Constants.dataBastURL).reference().child("users/\(uid)")
        userRef.observe(.value, with: { snapshot in
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
    
}
