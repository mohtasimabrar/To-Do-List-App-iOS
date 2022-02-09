//
//  SignUpViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var uploadPictureButton: UIButton!
    var imageData: Data?
    var profilePictureURL: String?
    
    var ref: DatabaseReference!
    
    let storage = Storage.storage(url:"gs://to-do-list-app-f7a81.appspot.com").reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profilePictureImageView.makeUploadPictureRounded()
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
              let password = passwordTextField.text, !password.isEmpty,
        let imageData = imageData else {
            print("Field Empty")
            return
        }
        
        let uuid = UUID().uuidString
        
        
        self.storage.child("images/\(uuid).png").putData(imageData, metadata: nil) { [weak self] _ , error in
            guard error == nil else {
                return
            }
            
            print("Storing image")
            
            self?.storage.child("images/\(uuid).png").downloadURL(completion: { [weak self] url, error in
                guard let url = url, error == nil else {
                    print("Error: \(error)")
                    return
                }
                print("Setting data")
                
                FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {
                    [weak self] result, error in
                    guard error == nil else {
                        print("Failed to create")
                        print(error!)
                        return
                    }
                    
                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    
                    let data: [String:String?] = [
                        "email": email,
                        "firstName": self?.firstNameTextField.text,
                        "lastName": self?.lastNameTextField.text,
                        "profilePictureURL": url.absoluteString
                    ]
                    
                    print("Data: \(data)")
                    
                    self?.ref.child("users").child(userID).setValue(data)
                    
                    print("Data set")
                    
                })
            })
            
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
