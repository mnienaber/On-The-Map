//
//  StudentSingleton.swift
//  On The Map
//
//  Created by Michael Nienaber on 8/10/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation


class StudentModel: NSObject {
    
    var studentLocation = [StudentLocation]()

    class func sharedInstance() -> StudentModel {
        struct Singleton {
            static var sharedInstance = StudentModel()
        }
        return Singleton.sharedInstance
    }
}