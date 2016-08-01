//
//  ListViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit

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
    
    func getStudentList() {
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
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
    @IBAction func refreshButton(sender: AnyObject) {
        
        getStudentList()
        print("refresh")
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
}


