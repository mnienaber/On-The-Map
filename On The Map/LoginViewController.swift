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
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        loginButton.enabled = false
        
        let parameters: [String: String!] = [
            Client.Constants.ParameterKeys.Username: self.usernameTextField.text,
            Client.Constants.ParameterKeys.Password: self.passwordTextField.text]
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugText.text = "Username or Password Empty."
        } else {
            setUIEnabled(true)
            
            var param = "{\"udacity\": {\"username\":\"\(self.usernameTextField.text!)\", \"password\":\"\(self.passwordTextField.text!)\"}}"
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            print(param)
            let task = session.dataTaskWithRequest(request) { data, response, error in
                // if an error occurs, print it and re-enable the UI
                
                func displayError(error: String, debugLabelText: String? = nil) {
                    print(error)
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.debugText.text = "Login Failed (Session ID)."
                    }
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    displayError("No data was returned by the request!")
                    return
                }
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    print("Error: Parsing JSON data")
                    return
                }
                
                let account = parsedResult["account"]!
                let sessionDict = parsedResult["session"]!
            
                if let accountKey = account!["key"] as? String {
                    self.appDelegate.accountKey = accountKey
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugText.text = "Login Failed (accountKey)."
                    }
                }
                
                if let accountRegistered = account!["registered"] as? Int {
                    
                    self.appDelegate.accountRegistered = accountRegistered
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugText.text = "Login Failed (accountRegistered)."
                    }
                }
                
                if let sessionExpiration = sessionDict!["expiration"] as? String {
                    self.appDelegate.sessionExpiration = sessionExpiration
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugText.text = "Login Failed (accountKey)."
                    }
                }
                
                if let sessionID = sessionDict!["id"] as? String {
                    self.appDelegate.sessionID = sessionID
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.debugText.text = "Login Failed (sessExpiration)."
                    }
                }
            }
            task.resume()
        }
        completeLogin()
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.debugText.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
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