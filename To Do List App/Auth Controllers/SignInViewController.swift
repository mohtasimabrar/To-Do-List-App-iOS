
//
//  SignInViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var backgroundSV: UIScrollView!
    
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    
    let screenRect = UIScreen.main.bounds
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
        centerContentInView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }

    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        UserService.googleSignIn(view: self) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Please fill up all fields")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        UserService.signIn(email: email, password: password) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }

        }
        
    }
    
    func centerContentInView() {
        if (screenRect.size.height > 900) {
            topViewConstraint.constant = screenRect.size.height * 0.12
        } else if (screenRect.size.height > 700) {
            topViewConstraint.constant = screenRect.size.height * 0.09
        } else {
            topViewConstraint.constant = screenRect.size.height * 0.05
        }
    }
    
}


extension SignInViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if let scrollView = backgroundSV, let userInfo = notification.userInfo,
            let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey],
            let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey],
            let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap + 10
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            
            if (keyboardOverlap != 0) {
                topViewConstraint.constant = 0
            } else {
                centerContentInView()
            }
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}

