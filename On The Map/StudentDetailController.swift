//
//  StudentDetailController.swift
//  On The Map
//
//  Created by Michael Nienaber on 15/07/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StudentDetailController: UIViewController, MKMapViewDelegate {
    
    
    var studentDetailLocation = [StudentLocation]()
    @IBOutlet weak var mapViewOutlet: MKMapView!
    @IBOutlet weak var cancelButtonOutlet: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        self.mapViewOutlet.delegate = self

    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
            self.presentViewController(controller, animated: true, completion: nil)
        })
    
    
    }
    
    
}
