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
    
    func getStudentList() {
        
        Client.sharedInstance().getStudentLocations { (studentLocation, errorString) in
            if let studentLocation = studentLocation {
                [self.studentLocation = studentLocation]
                performUIUpdatesOnMain {
                    for student in self.studentLocation {
                        
                        let first = student.firstName
                        let last = student.lastName
                        let mediaURL = student.mediaURL
                        
                        self.tableView.reloadData()
                    }
                }
            }
        
        }
    
    }
}

extension ListViewController {
    
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


}


