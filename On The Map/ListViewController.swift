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
    var studentLocation: [StudentLocation] = [StudentLocation]()
    let studentSegueIdentifier = "ShowStudentDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let location = studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return studentLocation.count
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
        
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
            
            print("getstudentlocations")
            
            if errorString != nil {
                
                print("our errorstring")
                performUIUpdatesOnMain {
                    
                    self.failAlertGeneral("Yikes", message: "There was a problem retrieving data, please try again later", actionTitle: "OK")
                }
            } else {
                
                if let studentLocation = studentLocation {
                    [self.studentLocation = studentLocation]
                    performUIUpdatesOnMain {
                        for student in self.studentLocation {
                            
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if  (segue.identifier == studentSegueIdentifier) {
            
            let destination = segue.destinationViewController as? StudentDetailController
            let studentIndex = tableView.indexPathForSelectedRow?.row
            let studentDetailDict = [studentLocation[studentIndex!]]
            destination?.studentDetailLocation = studentDetailDict
        }
    }
    
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
}


