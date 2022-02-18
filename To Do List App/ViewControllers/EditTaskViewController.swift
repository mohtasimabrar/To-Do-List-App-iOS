//
//  EditTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 8/2/22.
//

import UIKit

protocol EditTaskDelegate: AnyObject {
    func didDismissView (task: Task)
}

class EditTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var backgroundSV: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    var task:Task?
    
    weak var editTaskDelegate: EditTaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        titleTextField.delegate = self
        
        initiateNavBar()
        

        detailsTextView.layer.borderColor = CGColor(red:215.0 / 255.0, green:215.0 / 255.0, blue:215.0 / 255.0, alpha:1)
        detailsTextView.layer.borderWidth = 0.6
        detailsTextView.layer.cornerRadius = 5
                
        
        loadViewData()
        
        
        //Subscribe to a Notification which will fire before the keyboard will show
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide))
                
        //Subscribe to a Notification which will fire before the keyboard will hide
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide))
        
    }
    
    func initiateNavBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Edit Task")
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelEdit))
        navItem.leftBarButtonItem = cancelItem
        let saveItem = UIBarButtonItem(title: "Update", style: .done, target: nil, action: #selector(updateTask))
        navItem.rightBarButtonItem = saveItem

        navBar.setItems([navItem], animated: false)
    }
    
    func loadViewData() {
        if let task = task {
            titleTextField.text = task.title
            detailsTextView.text = task.task
        }
    }
    
    @objc func cancelEdit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func updateTask() {
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let detailsText = detailsTextView.text, let task = task,
              let editTaskDelegate = editTaskDelegate else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Title cannot be empty")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        
        let updatedTask = Task(id: task.id, title: titleText, task: detailsText, isDone: "false", time: Date.getCurrentTime(), date: Date.getCurrentDate())
            
        TaskService.saveTask(task: updatedTask)
        
        editTaskDelegate.didDismissView(task: updatedTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}



extension EditTaskViewController {
    
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
            scrollView.contentInset.bottom = keyboardOverlap + 10
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
