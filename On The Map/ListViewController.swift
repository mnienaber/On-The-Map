//
//  SecondViewController.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var studentLocation: [StudentLocationObjects] = [StudentLocationObjects]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let methodParameters = [
            Constants.ParameterValues.ParseAPIKey: Constants.ParameterValues.ParseAPIKey,
            Constants.ParameterValues.RestAPIKey: Constants.ParameterValues.RestAPIKey
        ]
        
     //TODO: fix the variables for this server request:
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(Constants.Scheme.ApiScheme)" + "\(Constants.Scheme.ApiHost)" + "\(Constants.Scheme.ApiPath)" + "\(Constants.Scheme.LimitAndOrder)")!)
        request.addValue(Constants.ParameterValues.ParseAPIKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ParameterValues.RestAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            
            /* GUARD: Did Parse return an error? */
            if let _ = parsedResult[Constants.ParseResponseKeys.ObjectId] as? String {
                print("Parse returned an error. See the '\(Constants.ParseResponseKeys.ObjectId)")
                return
            }
            
            /* GUARD: Is the "FirstName" key in parsedResult? */
            guard let results = parsedResult[Constants.ParseResponseKeys.FirstName] as? [[String:AnyObject]] else {
                print("Cannot find your key, the status code is \(statusCode) and the full response is \(parsedResult)")
                return
            }
            
            //print(NSString(data: data, encoding: NSUTF8StringEncoding))
            self.studentLocation = StudentLocationObjects.SLOFromResults(results)
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        task.resume()
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
        
        self.tableView.reloadData()
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return studentLocation.count
    }


}


