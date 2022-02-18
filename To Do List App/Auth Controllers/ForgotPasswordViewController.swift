//
//  ForgotPasswordViewController.swift
//  To Do List App
//
//  Created by BS236 on 8/2/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var verticalCenterAlignConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        emailTextField.delegate = self
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
        resetConstraints()
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = AlertService.createAlertController(title: "Error", message: "An Email address must be provided")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        UserService.resetPassword(for: email) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = AlertService.createAlertController(title: "Success", message: "A password reset email has been sent to '\(email)'")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func resetConstraints() {
        verticalCenterAlignConstraint.constant = -40
    }
    
}


extension ForgotPasswordViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if  let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            if (endRect.origin.y != UIScreen.main.bounds.size.height) {
                verticalCenterAlignConstraint.constant = -120
            } else {
                resetConstraints()
            }
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}
