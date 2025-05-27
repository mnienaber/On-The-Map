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
    @IBOutlet weak var dimOutlet: UIView!
    @IBOutlet weak var activityOutlet: UIActivityIndicatorView!
    
    //var studentLocation: [StudentLocation] = [StudentLocation]()
    //var accountVerification: [AccountVerification] = [AccountVerification]()
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var session: URLSession!
    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0
    let loginLimit = 2
    var loginCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetUI()
        setUIEnabled(true)
        addKeyboardDismissRecognizer()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardDismissRecognizer()
        unsubscribeToKeyboardNotifications()
    }
    
    func completeLogin() {
        
        activityOutlet.stopAnimating()
        dimOutlet.isHidden = true
        DispatchQueue.main.async {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func executeLogin() {
        
        Client.sharedInstance().loginToApp(username: usernameTextField.text!, password: passwordTextField.text!) { (udacityAccount, error) in
            
            performUIUpdatesOnMain { // Ensure UI updates are on the main thread
                if let error = error {
                    // Attempt to get more specific error info if it's an NSError
                    let nsError = error as NSError
                    let errorMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String ?? "Login Failed"
                    
                    // Check for specific error codes or messages if possible
                    // The previous check for "Optional(403)" or "Optional(-1009)" was very specific
                    // to the old error construction. Modern error handling might differ.
                    // For now, we'll use a general failure message or try to get status code if available.
                    
                    // Example: if nsError.domain == "taskForLOGINMethod" && nsError.code == 1
                    // This depends on how errors are constructed in Client.swift now.
                    // For a 403 (Forbidden), the server might return a specific message in the error body.
                    // For network connection issues (like -1009), it's usually a URLError.
                    
                    print("Login error: \(errorMessage)")
                    if (error as? URLError)?.code == .notConnectedToInternet {
                        self.failAlertGeneral("No Network Connection", message: "There seems to be a problem with your connection - please check it", actionTitle: "OK")
                    } else if errorMessage.contains("status code other than 2xx!") && errorMessage.contains("403") { // Crude check for 403
                        self.countfailAlert()
                    }
                    else {
                        // Generic error from loginToApp
                        self.failAlertGeneral("Login Failed", message: errorMessage, actionTitle: "OK")
                    }
                    // Reset UI elements after error
                    self.setUIEnabled(true)
                    self.loginButton.isEnabled = true
                    self.activityOutlet.stopAnimating()
                    self.dimOutlet.isHidden = true

                } else if let udacityAccount = udacityAccount {
                    // Successfully decoded UdacityAccount
                    // The appDelegate properties are already updated in Convenience.swift's loginToApp
                    // So, just proceed with completing the login.
                    
                    // self.appDelegate.accountRegistered = udacityAccount.account.registered // If needed
                    // self.appDelegate.accountKey = udacityAccount.account.key as AnyObject
                    // self.appDelegate.sessionID = udacityAccount.session.id
                    // self.appDelegate.sessionExpiration = udacityAccount.session.expiration
                    
                    self.completeLogin()
                } else {
                    // Fallback for unknown error
                    self.failAlertGeneral("Login Failed", message: "An unknown error occurred.", actionTitle: "OK")
                    self.setUIEnabled(true)
                    self.loginButton.isEnabled = true
                    self.activityOutlet.stopAnimating()
                    self.dimOutlet.isHidden = true
                }
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        loginButton.isEnabled = false
        dimOutlet.isHidden = false
        activityOutlet.startAnimating()
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugText.text = "Username or Password Empty."
            setUIEnabled(true)
            loginButton.isEnabled = true
        } else {
            
            executeLogin()
        }
    }
    
    func countfailAlert() {
        
        if self.loginCount <= self.loginLimit {
            
            let failLoginAlert = UIAlertController(title: "Sorry", message: "It seems your login credentials didn't work - try again", preferredStyle: .alert)
            failLoginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(failLoginAlert, animated: true, completion: nil)
            setUIEnabled(true)
            usernameTextField.text = nil
            passwordTextField.text = nil
            loginButton.isEnabled = true
            activityOutlet.stopAnimating()
            dimOutlet.isHidden = true
            self.debugText.text! = "Try again:)"
            loginCount += 1
        } else {
            
            let failLoginAlert = UIAlertController(title: "Forgotten your Username or Password?", message: "Please check your credentials with Udacity and try again later", preferredStyle: .alert)
            failLoginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(failLoginAlert, animated: true, completion: nil)
            failLoginAlert.addAction(UIAlertAction(title: "Go To Udacity", style: .default, handler: {
                (action:UIAlertAction!) in
                UIApplication.shared.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
        }))
            setUIEnabled(true)
            usernameTextField.text = nil
            passwordTextField.text = nil
            loginButton.isEnabled = true
            activityOutlet.stopAnimating()
            dimOutlet.isHidden = true
            self.debugText.text! = ""
            loginCount = 0
        }
    }
    
    func resetUI() {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        debugText.text = "Please login to Udacity"
        // hideKeyboardWhenTappedAround() // This is now in UIViewController extension (Convenience.swift)
        session = URLSession.shared // This session variable seems unused locally. Client manages its own session.
        configureUI() // For tap recognizer
        // Keyboard notifications are handled by UIViewController extension (Convenience.swift)
        // subscribeToKeyboardNotifications() 
        dimOutlet.isHidden = true
    }
    
    // This method seems to be a remnant of the old data handling.
    // Account key is now set directly from the Codable object in loginToApp or Convenience.swift
    // func setAccountKey(details: [String: AnyObject]) {
    //     performUIUpdatesOnMain {
    //         if let accountDetail = details["key"]! as? Int {
    //             self.appDelegate.accountKey = accountDetail
    //         }
    //     }
    // }
}

extension LoginViewController {
    
    private func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugText.isEnabled = enabled
        
        if enabled {
            loginButton.isHidden = false
        } else {
            loginButton.isHidden = true
        }
    }
    
    func failAlertGeneral(title: String, message: String, actionTitle: String) {
        
        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: .alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(failAlertGeneral, animated: true, completion: nil)
        setUIEnabled(true)
        usernameTextField.text = nil
        passwordTextField.text = nil
        loginButton.isEnabled = true
        activityOutlet.stopAnimating()
        dimOutlet.isHidden = true
        self.debugText.text! = "Try again:)"
    }

    func configureUI() {
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap))
        tapRecognizer?.numberOfTapsRequired = 1
    }
    
    private func subscribeToNotification(notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func addKeyboardDismissRecognizer() { // This should be part of the UIViewController extension if it's generic
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc func removeKeyboardDismissRecognizer() { // This should be part of the UIViewController extension
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleSingleTap(recognizer: UITapGestureRecognizer) { // This is fine here or in extension
        self.view.endEditing(true)
    }
    
    // subscribeToKeyboardNotifications, unsubscribeToKeyboardNotifications, keyboardWillShow, keyboardWillHide, getKeyboardHeight
    // are now part of the UIViewController extension in Convenience.swift.
    // They are automatically available and do not need to be re-declared or called from viewWillAppear/Disappear.
    
    // @objc func keyboardWillShow(_ notification: NSNotification) {
        
    //     if keyboardAdjusted == false {
    //         lastKeyboardOffset = getKeyboardHeight(notification) / 2
    //         self.view.superview?.frame.origin.y -= lastKeyboardOffset
    //         keyboardAdjusted = true
    //     }
    // }
    
    // @objc func keyboardWillHide(_ notification: NSNotification) {
    //     
    //     if keyboardAdjusted == true {
    //         self.view.superview?.frame.origin.y += lastKeyboardOffset
    //         keyboardAdjusted = false
    //     }
    // }
    
    // func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
    //     let userInfo = notification.userInfo
    //     let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    //     return keyboardSize.cgRectValue.height
    // }
    
    // hideKeyboardWhenTappedAround and dismissKeyboardViewController are in UIViewController extension (Convenience.swift)
    // and should be automatically available. No need to override unless specific behavior is desired.
}