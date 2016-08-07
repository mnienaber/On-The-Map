//
//  LoginViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 31/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UIApplicationDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugText: UILabel!
    @IBOutlet weak var dimOulet: UIView!
    @IBOutlet weak var activityOutlet: UIActivityIndicatorView!
    
    var studentLocation: [StudentLocation] = [StudentLocation]()
    var accountVerification: [AccountVerification] = [AccountVerification]()
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var session: NSURLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    let loginLimit = 2
    var loginCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        debugText.text = "Please login to Udacity"
        hideKeyboardWhenTappedAround()
        session = NSURLSession.sharedSession()
        configureUI()
        subscribeToKeyboardNotifications()
        dimOulet.hidden = true
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
        
        activityOutlet.stopAnimating()
        dimOulet.hidden = true
        dispatch_async(dispatch_get_main_queue(), {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func executeLogin() {
        
        Client.sharedInstance().loginToApp(usernameTextField.text!, password: passwordTextField.text!) { (details, error) in
            
            if error != nil {
                
                performUIUpdatesOnMain{
                    
                    self.failAlert()
                }
            } else {

                if let account = details as [String: AnyObject]! {
                    
                    let accountDetail = account["account"] as! [String: AnyObject]
                    let sessionDetail = account["session"] as! [String: AnyObject]
                    
                    let registeredDetail = accountDetail["registered"]! as! Int
                    if registeredDetail == 1 {
                        
                        self.appDelegate.accountRegistered = registeredDetail
                        self.appDelegate.accountKey = accountDetail["key"] as AnyObject!
                        self.appDelegate.sessionID = sessionDetail["id"] as? String
                        self.appDelegate.sessionExpiration = sessionDetail["expiration"] as? String
                    }

                    performUIUpdatesOnMain{
                        
                        self.completeLogin()
                    }
                }
            }
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        loginButton.enabled = false
        dimOulet.hidden = false
        activityOutlet.startAnimating()
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugText.text = "Username or Password Empty."
            setUIEnabled(true)
            loginButton.enabled = true
        } else {
            
            executeLogin()
        }
    }
    
    func failAlert() {
        
        if self.loginCount <= self.loginLimit {
            
            let failLoginAlert = UIAlertController(title: "Sorry", message: "It seems your login credentials didn't work - try again", preferredStyle: UIAlertControllerStyle.Alert)
            failLoginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failLoginAlert, animated: true, completion: nil)
            setUIEnabled(true)
            usernameTextField.text = nil
            passwordTextField.text = nil
            loginButton.enabled = true
            activityOutlet.stopAnimating()
            dimOulet.hidden = true
            self.debugText.text! = "Try again:)"
            loginCount += 1
        } else {
            
            let failLoginAlert = UIAlertController(title: "Forgotten your Username or Password?", message: "Please check your credentials with Udacity and try again later", preferredStyle: UIAlertControllerStyle.Alert)
            failLoginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failLoginAlert, animated: true, completion: nil)
            failLoginAlert.addAction(UIAlertAction(title: "Go To Udacity", style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction!) in
                UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        }))
            setUIEnabled(true)
            usernameTextField.text = nil
            passwordTextField.text = nil
            loginButton.enabled = true
            activityOutlet.stopAnimating()
            dimOulet.hidden = true
            self.debugText.text! = ""
            loginCount = 0
        }
    }
    
    func setAccountKey(details: [String: AnyObject]) {
        
        performUIUpdatesOnMain {
            
            if let accountDetail = details["key"]! as? Int {
                
                self.appDelegate.accountKey = accountDetail
                print(accountDetail)
            }
            
        }
    }
}

extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugText.enabled = enabled
        
        if enabled {
            loginButton.hidden = false
        } else {
            loginButton.hidden = true
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