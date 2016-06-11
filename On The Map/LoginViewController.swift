//
//  LoginViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 31/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
//        configureUI()
        
        subscribeToNotification(UIKeyboardWillShowNotification, selector: Client.Constants.Selectors.KeyboardWillShow)
        subscribeToNotification(UIKeyboardWillHideNotification, selector: Client.Constants.Selectors.KeyboardWillHide)
        subscribeToNotification(UIKeyboardDidShowNotification, selector: Client.Constants.Selectors.KeyboardDidShow)
        subscribeToNotification(UIKeyboardDidHideNotification, selector: Client.Constants.Selectors.KeyboardDidHide)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        //userDidTapView(self)
        
        let parameters: [String: String!] = [
            Client.Constants.ParameterKeys.Username: self.usernameTextField.text,
            Client.Constants.ParameterKeys.Password: self.passwordTextField.text]
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugText.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            var param = "{\"udacity\": {\"username\": \"" + self.usernameTextField.text! + "\", \"password\": \"" + self.passwordTextField.text! + "\"}}"
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = param.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
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
                
                /* 5. Parse the data */
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    displayError("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                /* GUARD: Did TheMovieDB return an error? */
                if let _ = parsedResult[Client.Constants.UdacityResponseKeys.Session_Id] as? Int {
                    displayError("TheMovieDB returned an error. See the statuscode in \(parsedResult)")
                    return
                }
                
                /* GUARD: Is the "sessionID" key in parsedResult? */
                guard let sessionID = parsedResult[Client.Constants.UdacityResponseKeys.Session_Id] as? String else {
                    displayError("Cannot find session ID)' in \(parsedResult)")
                    return
                }
                
                /* 6. Use the data! */
                self.appDelegate.sessionID = sessionID
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
                for items in parsedResult["account"] as! NSDictionary {
                    print(items)
                }
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        }
    }

}

    // MARK: - LoginViewController (Configure UI)


extension LoginViewController {
    
    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButton.enabled = enabled
        debugText.text = ""
        debugText.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
//    private func configureUI() {
//        
//        // configure background gradient
//        let backgroundGradient = CAGradientLayer()
//        backgroundGradient.colors = [Client.Constants.UI.LoginColorTop, Client.Constants.UI.LoginColorBottom]
//        backgroundGradient.locations = [0.0, 1.0]
//        backgroundGradient.frame = view.frame
//        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
//        
//        configureTextField(usernameTextField)
//        configureTextField(passwordTextField)
//    }
    
//    private func configureTextField(textField: UITextField) {
//        let textFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0)
//        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
//        textField.leftView = textFieldPaddingView
//        textField.leftViewMode = .Always
//        textField.backgroundColor = Client.Constants.UI.GreyColor
//        textField.textColor = Client.Constants.UI.BlueColor
//        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
//        textField.tintColor = Client.Constants.UI.BlueColor
//        textField.delegate = self
//    }
}

extension LoginViewController {
    
    private func subscribeToNotification(notification: String, selector: Selector) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    private func unsubscribeFromAllNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}