//
//  UIImageViewExtensions.swift
//  To Do List App
//
//  Created by BS236 on 7/2/22.
//

import Foundation
import UIKit

extension UIImageView {

    func makeRounded() {
        super.layoutSubviews()
        self.layer.borderWidth = 4
        self.layer.masksToBounds = false
        self.layer.borderColor = CGColor(red: 21/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1)
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func makeUploadPictureRounded() {
        super.layoutSubviews()
        let screenSize: CGRect = UIScreen.main.bounds
        self.layer.borderWidth = 4
        self.layer.masksToBounds = false
        self.layer.borderColor = CGColor(red: 21/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1)
        self.layer.cornerRadius = (screenSize.width * 0.35) / 2
        self.clipsToBounds = true
    }
    
}
