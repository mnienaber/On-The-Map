//
//  BlackBox.swift
//  On The Map
//
//  Created by Michael Nienaber on 25/05/2016.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}