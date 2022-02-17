//
//  SignUpViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit


class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var uploadPictureButton: UIButton!
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    var imageData: Data?
    
    @IBOutlet weak var backgroundSV: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        resetForm()
        self.initializeHideKeyboard()
        passwordTextField.textContentType = .oneTimeCode
        confirmPasswordTextField.textContentType = .oneTimeCode
        
        [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach{ $0?.delegate = self }
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Unsubscribe from all our notifications
        unsubscribeFromAllNotifications()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePictureImageView.makeUploadPictureRounded()
    }
    
    func resetForm() {
        registerButton.isEnabled = false
        
        [emailErrorLabel, firstNameErrorLabel, lastNameErrorLabel, passwordErrorLabel, confirmPasswordErrorLabel].forEach{
            $0?.isHidden = false
            $0?.text = "Required"
        }
                
        [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, confirmPasswordTextField].forEach{ $0?.text = "" }
            
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        if let email = emailTextField.text {
            if let errorMessage = ValidationService.invalidEmail(email) {
                emailErrorLabel.text = errorMessage
                emailErrorLabel.isHidden = false
            } else {
                emailErrorLabel.isHidden = true
            }
        }
        
        checkForValidForm()
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        if let password = passwordTextField.text {
            if let errorMessage = ValidationService.invalidPassword(password) {
                passwordErrorLabel.text = errorMessage
                passwordErrorLabel.isHidden = false
            } else {
                passwordErrorLabel.isHidden = true
            }
        }
        
        checkForValidForm()
    }
    
    @IBAction func confirmPasswordChanged(_ sender: Any) {
        if let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text {
            if (confirmPassword.elementsEqual(password)) {
                confirmPasswordErrorLabel.isHidden = true
            } else {
                confirmPasswordErrorLabel.text = "Password does not match. Please try again."
                confirmPasswordErrorLabel.isHidden = false
            }
        }
        
        
        checkForValidForm()
    }
    
    
    @IBAction func firstNameChanged(_ sender: Any) {
        if let firstName = firstNameTextField.text {
            if let errorMessage = ValidationService.invalidLength(firstName) {
                firstNameErrorLabel.text = "First Name" + errorMessage
                firstNameErrorLabel.isHidden = false
            } else {
                firstNameErrorLabel.isHidden = true
            }
        }
        checkForValidForm()
    }
    
    @IBAction func lastNameChanged(_ sender: Any) {
        if let lastName = lastNameTextField.text {
            if let errorMessage = ValidationService.invalidLength(lastName) {
                lastNameErrorLabel.text = "Last Name" + errorMessage
                lastNameErrorLabel.isHidden = false
            } else {
                lastNameErrorLabel.isHidden = true
            }
        }
        checkForValidForm()
    }
    
    func checkForValidForm() {
        if emailErrorLabel.isHidden && firstNameErrorLabel.isHidden && lastNameErrorLabel.isHidden && passwordErrorLabel.isHidden && confirmPasswordErrorLabel.isHidden {
            registerButton.isEnabled = true
        } else {
            registerButton.isEnabled = false
        }
    }
    
    @IBAction func uploadPictureButtonTapped(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Please fill up all fields")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        
        let data: [String:String?] = [
            "email": email,
            "password": password,
            "firstName": firstNameTextField.text,
            "lastName": lastNameTextField.text
        ]
        
        UserService.signUp(imageData: imageData, user: data) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        resetForm()
        
    }
    
    func makeStatusBarWhite() {
        if #available(iOS 13, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            let statusBar = UIView(frame: (keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = .white
            keyWindow?.addSubview(statusBar)
        }
    }
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.profilePictureImageView.image = image
        
        guard let imageData = image.pngData() else {
            return
        }
        
        self.imageData = imageData
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


extension SignUpViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShowOrHide(notification: NSNotification) {
        // Get required info out of the notification
        if let scrollView = backgroundSV, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
            
            // Transform the keyboard's frame into our view's coordinate system
            let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
            
            // Find out how much the keyboard overlaps our scroll view
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y + 10
            
            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap
            //scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}
