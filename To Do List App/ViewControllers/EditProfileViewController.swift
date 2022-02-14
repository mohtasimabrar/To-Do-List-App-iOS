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
    var imageData: Data?
    var user: UserProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self

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
