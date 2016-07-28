//
//  LoginViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 31/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugText: UILabel!
    
    var studentLocation: [StudentLocation] = [StudentLocation]()
    var accountVerification: [AccountVerification] = [AccountVerification]()
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        debugText.text = "Please login to Udacity"
        hideKeyboardWhenTappedAround()
        session = NSURLSession.sharedSession()
        configureUI()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func executeLogin() {
        
        Client.sharedInstance().loginToApp(usernameTextField.text!, password: passwordTextField.text!) { (details, error) in
            
            print(details)
            if let results = details {
                print("results")
                [self.accountVerification = results]
                
                performUIUpdatesOnMain {
                    
                    for result in results {
                        print("result")
                        print(result.accountKey)
                        if result.accountRegistered == 1 {
                            
                            print("before completeLogin")
                            self.completeLogin()
                        } else {
                            
                            let failLoginAlert = UIAlertController(title: "Sorry", message: "It seems your login credentials didn't work - try again", preferredStyle: UIAlertControllerStyle.Alert)
                            failLoginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(failLoginAlert, animated: true, completion: nil)
                            self.debugText.text = "You're email address is not known to Udacity - please create an account"
                            self.usernameTextField.text = nil
                            self.passwordTextField.text = nil
                        }
                    }
                }
            } else {
                self.debugText.text! = String(error)
            }
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        loginButton.enabled = false
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugText.text = "Username or Password Empty."
        } else {
            
            executeLogin()
            
        }
    }
}

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugText.text = ""
        debugText.enabled = enabled
        
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            self.view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardAdjusted == true {
            self.view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    override func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
}