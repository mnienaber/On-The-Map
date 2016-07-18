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
    var studentDetailDict = [StudentLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        getStudentList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get cell type
        let cellReuseIdentifier = "TableViewCell"
        let location = studentLocation[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // set cell defaults
        cell.textLabel!.text = location.firstName + " " + location.lastName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return studentLocation.count
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        let row = indexPath.row
//        studentDetailDict = [studentLocation[row]]
//        print("tableview1")
//    }
    
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
}

extension ListViewController {
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("prep1")
        if  (segue.identifier == studentSegueIdentifier) {
            print("prep2")
            
            let destination = segue.destinationViewController as? StudentDetailController
            print("prep3")
            let studentIndex = tableView.indexPathForSelectedRow?.row
            print("prep4")
            studentDetailDict = [studentLocation[studentIndex!]]
            destination?.studentDetailLocation = studentDetailDict
            print("prep5")
        }
        
    }


}


