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
    
    var studentLocation: [StudentLocation] = [StudentLocation]()
    var appDelegate: AppDelegate!
    let studentSegueIdentifier = "ShowStudentDetail"
    var refreshCount = 0

//    func refresh(sender: AnyObject) {
//
//        Client.sharedInstance().getStudentLocations() { (studentLocation, error) in
//            
//            print("studentLocation \(studentLocation)")
//
//            if error != nil {
//
//                print("that's an error")
//
//            } else {
//                
//                if let studentLocation = studentLocation {
//                    
//                    [self.studentLocation = studentLocation]
//                    
//                    performUIUpdatesOnMain {
//                        
//                        for student in studentLocation {
//                            
//                            performUIUpdatesOnMain {
//                                
//                                print(student.firstName + " " + student.lastName)
////                                self.tableView.reloadData()
//                                
//                            }
//                            
//                            
//                        }
//                        self.tableView.reloadData()
//                        self.refreshControl?.endRefreshing()
//                        self.refreshCount += 1
//                        print(self.refreshCount)
//                        
//                    }
//                }
//            }
//        } 
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        print("viewwillload")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
//        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        getStudentList()
        self.tableView.reloadData()
        print("viewwillappear")

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "TableViewCell"
        let location = Client.sharedInstance().studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
                
                Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
                    
                    if studentLocation != nil {
                        
                        if errorString != nil {
                            
                            self.failAlertGeneral("Yikes", message: "There was a problem retrieving data, please try again later", actionTitle: "OK")
                            
                            }
                        } else {
                            
                            if let studentLocation = studentLocation {
                                
                                performUIUpdatesOnMain {
                                    for student in studentLocation {
                                        
                                        self.tableView.reloadData()
                                    }
                                }
                        }
                    }
                }
                
                
            }
        } else if Client.sharedInstance().studentLocation.isEmpty == false {
            
            performUIUpdatesOnMain {
                
                for _ in Client.sharedInstance().studentLocation {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    })
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

    func isEqual(lhs: [String: AnyObject], rhs: [String: AnyObject]) -> Bool {

        return NSDictionary(dictionary: lhs).isEqualToDictionary(rhs)
    }
}


