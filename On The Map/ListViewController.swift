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
    //var studentLocation = Client.sharedInstance().studentLocation
    let studentSegueIdentifier = "ShowStudentDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        //print("\(studentLocation)" + "viewdidload")
        
        self.navigationController?.navigationBarHidden = false
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        getStudentList()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "TableViewCell"
        let location = Client.sharedInstance().studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print("\(studentLocation.count)" + "tableview count")
        return Client.sharedInstance().studentLocation.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = Client.sharedInstance().studentLocation[indexPath.row]
        let url = location.mediaURL
        
        if verifyUrl(url) == true {
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
        } else if verifyUrl(url) == false {
            
            self.failAlertGeneral("Unable to open that URL", message: "Unfrt this item doesn't contain a valid URL", actionTitle: "Try another")
        }
    }
    
    override internal func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override internal func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            print("Shaked")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
            failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
            failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(failLogoutAlert, animated: true, completion: nil)
        }
        
    }
    
    func getStudentList() {
        
        if Client.sharedInstance().studentLocation.isEmpty == true {
            
            performUIUpdatesOnMain {
                
                self.failAlertGeneral("Yikes", message: "There was a problem retrieving data, please try again later", actionTitle: "OK")
            }
        } else if Client.sharedInstance().studentLocation.isEmpty == false {
            
            performUIUpdatesOnMain {
                
                for _ in Client.sharedInstance().studentLocation {
                    
                    self.tableView.reloadData()
                }
            }
        }
    }

    @IBAction func logOutButton(sender: AnyObject) {
        
        self.logOut()
    }
    
    func logOut() {
        
        self.appDelegate.accountKey = nil
        self.appDelegate.accountRegistered = nil
        self.appDelegate.sessionID = nil
        self.appDelegate.sessionExpiration = nil
        dispatch_async(dispatch_get_main_queue(), {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

extension ListViewController {
    
    func failAlertGeneral(title: String, message: String, actionTitle: String) {
        
        let failAlertGeneral = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        failAlertGeneral.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failAlertGeneral, animated: true, completion: nil)
    }
    
    func failLogOutAlert() {
        
        let failLogoutAlert = UIAlertController(title: "Wanna Logout?", message: "Just double checking, we'll miss you!", preferredStyle: UIAlertControllerStyle.Alert)
        failLogoutAlert.addAction(UIAlertAction(title: "Log Me Out", style: UIAlertActionStyle.Default, handler: { alertAction in self.logOut() }))
        failLogoutAlert.addAction(UIAlertAction(title: "Take Me Back!", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(failLogoutAlert, animated: true, completion: nil)
    }
    
    func verifyUrl(urlString: String?) -> Bool {

        if let urlString = urlString {
            
            if NSURL(string: urlString) != nil {
                
                return true
            }
        }
        return false
    }
}


