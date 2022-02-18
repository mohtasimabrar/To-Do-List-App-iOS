//
//  CreateNewTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 1/2/22.
//

import UIKit


class CreateNewTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var backgroundSV: UIScrollView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
                
        title = "Create New Task"
        self.initializeHideKeyboard()
        
        titleTextField.delegate = self
        detailsTextView.delegate = self
        
        detailsTextView.layer.borderColor = CGColor(red:215.0 / 255.0, green:215.0 / 255.0, blue:215.0 / 255.0, alpha:1)
        detailsTextView.layer.borderWidth = 0.6
        detailsTextView.layer.cornerRadius = 5
        
        detailsTextView.text = "Enter task details here..."
        detailsTextView.textColor = UIColor.lightGray
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done , target: self, action: #selector(createTask))
    }
    
    
    @objc func createTask() {
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let detailsText = detailsTextView.text,
              let navController = self.navigationController else {
                   let alert = AlertService.createAlertController(title: "Error", message: "Title cannot be empty")
                   self.present(alert, animated: true, completion: nil)
                   return
              }
        
        TaskService.createNewTask(title: titleText, details: detailsText)
        navController.popViewController(animated: true)
    }
}

extension CreateNewTaskViewController {
    
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
            let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y
            
            // Set the scroll view's content inset & scroll indicator to avoid the keyboard
            scrollView.contentInset.bottom = keyboardOverlap
            //scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
            
            if (keyboardOverlap != 0) {
                scrollViewBottomConstraint.constant = keyboardOverlap
            } else {
                scrollViewBottomConstraint.constant = 40
            }
            
            let duration = (durationValue as AnyObject).doubleValue
            let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
            UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

}


extension CreateNewTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter task details here..."
            textView.textColor = UIColor.lightGray
        }
    }
}
