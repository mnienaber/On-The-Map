//
//  Client.swift
//  On The Map
//
//  Created by Michael Nienaber on 23/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import Foundation

class Client : NSObject {
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // configuration object
    //var config = TMDBConfig()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil
}