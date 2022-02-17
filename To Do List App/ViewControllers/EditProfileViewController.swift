//
//  EditProfileViewController.swift
//  To Do List App
//
//  Created by BS236 on 9/2/22.
//

import UIKit
import SDWebImage

class EditProfileViewController: UIViewController {
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var backgroundSV: UIScrollView!
    var imageData: Data?
    var user: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewConfiguration()
        initiateNavBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePictureImageView.makeEditPictureRounded()
    }
    
    func initiateNavBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Edit Profile")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelEdit))
        navItem.rightBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
    }
    
    func viewConfiguration() {
        
        guard let user = user else {
            return
        }

        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        profilePictureImageView.sd_setImage(with: URL(string: user.profilePictureURL), placeholderImage: UIImage(named: "defaultUserImage"), options: .continueInBackground, completed: nil)
        
    }
    
    @objc func cancelEdit() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func uploadPictureButtonTapped(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    @IBAction func updateButtonTapped(_ sender: Any) {
        
        guard let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text,
              let userID = user?.uid,
              let email = user?.email,
              let profilePictureURL = user?.profilePictureURL else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Fields cannot be empty")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        
        let userData = UserProfile(uid: userID, email: email, firstName: firstName, lastName: lastName, profilePictureURL: profilePictureURL)
        
        UserService.updateProfile(imageData: imageData, user: userData) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}


extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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



extension EditProfileViewController {
    
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


