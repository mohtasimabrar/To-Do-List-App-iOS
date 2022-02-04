//
//  UserProfile.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import Foundation


struct UserProfile: Codable {
    let uid: String
    let email: String
    let firstName: String
    let lastName: String
    let profilePictureURL: String
}
