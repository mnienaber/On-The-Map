//
//  ListViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import AudioToolbox

class ListViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    let studentSegueIdentifier = "ShowStudentDetail"
    var refreshCount = 0
    @IBOutlet weak var dimOutlet: UIView!
    @IBOutlet weak var activityIndOutlet: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        tableView.delegate = self
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        print("viewwillload")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        tableView.delegate = self
        self.navigationController?.isNavigationBarHidden = false
        print("viewwillappear")
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "TableViewCell"
        let location = StudentModel.sharedInstance().studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return StudentModel.sharedInstance().studentLocation.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = StudentModel.sharedInstance().studentLocation[indexPath.row]
        let url = location.mediaURL
        
        if verifyUrl(url) == true {
            
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        } else if verifyUrl(url) == false {
            
            self.failAlertGeneral("Unable to open that URL", message: "Unfrt this item doesn't contain a valid URL", actionTitle: "Try another")
        }
    }
    
    override internal var canBecomeFirstResponder: Bool {
        return true
    }
    
    override internal func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("Shaked")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: .alert)
            failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: .default, handler: { alertAction in self.logOut() }))
            failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: .default, handler: nil))
            self.present(failLogoutAlert, animated: true, completion: nil)
        }
    }

    func refresh(_ sender: AnyObject) {

        Client.sharedInstance().getStudentLocations() { [weak self] (studentLocations, error) in
            guard let self = self else { return }
            performUIUpdatesOnMain {
                if let error = error {
                    print("Error fetching student locations: \(error.localizedDescription)")
                    let failDataAlert = UIAlertController(title: "Sorry", message: "There was a problem with retrieving Student Location data. \(error.localizedDescription)", preferredStyle: .alert)
                    failDataAlert.addAction(UIAlertAction(title: "I'll Come Back Later", style: .default, handler: nil))
                    // Example: Adding a mailto link for feedback
                    // Ensure the URL is valid
                    if let mailURL = URL(string: "mailto:mnienaber@google.com") {
                        failDataAlert.addAction(UIAlertAction(title: "Leave Feedback", style: .default, handler: { alertAction in
                            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
                        }))
                    }
                    self.present(failDataAlert, animated: true, completion: nil)
                } else if studentLocations != nil {
                    // StudentModel is already updated by getStudentLocations in Convenience.swift
                    // So, just reload data.
                    self.tableView.reloadData()
                    print("Refreshed student locations successfully.")
                } else {
                     // Handle case where studentLocations is nil but error is also nil (should ideally not happen)
                    print("No student locations and no error after refresh.")
                }
                // Ensure refresh control ends refreshing if it was used
                self.refreshControl?.endRefreshing()
            }
        }
    }

    @IBAction func refreshButton(_ sender: AnyObject) {

        if Reachability.isConnectedToNetwork() == false {

            let failPostAlert = UIAlertController(title: "No Internet Connection", message: "Please check your connection and try again", preferredStyle: .alert)
            failPostAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(failPostAlert, animated: true, completion: nil)
        } else if Reachability.isConnectedToNetwork() == true {

            self.refresh(self)
        }
    }
    
    func getStudentList() {
        
        if StudentModel.sharedInstance().studentLocation.isEmpty == true {
            
            performUIUpdatesOnMain {

                self.refresh(self)
            }
        } else if StudentModel.sharedInstance().studentLocation.isEmpty == false {
            
            performUIUpdatesOnMain {
                
                for _ in StudentModel.sharedInstance().studentLocation {
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    @IBAction func logOutButton(_ sender: AnyObject) {
        
        failLogOutAlert()
    }
    
    func logOut() {
        
        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil

        Client.sharedInstance().deleteSession() { [weak self] (deleteResponse, error) in
            guard let self = self else { return }
            performUIUpdatesOnMain {
                if let error = error {
                    print("Logout error: \(error.localizedDescription)")
                    self.failAlertGeneral("LogOut Unsuccessful", message: "Something went wrong, please try again", actionTitle: "OK")
                } else {
                    print("Logout success \(String(describing: deleteResponse))")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    func failAlertGeneral(title: String, message: String, actionTitle: String) {

        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: .alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        self.present(failAlertGeneral, animated: true, completion: nil)
    }

    func failLogOutAlert() {

        let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: .alert)
        failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: .default, handler: { alertAction in self.logOut() }))
        failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: .default, handler: nil))
        self.present(failLogoutAlert, animated: true, completion: nil)
    }
}

// Removed redundant ListViewController extension for verifyUrl, as it's in Convenience.swift (UIViewController extension)


