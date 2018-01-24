//
//  ViewController.swift
//  Timetable_Together
//
//  Created by USER on 2018. 1. 22..
//  Copyright © 2018년 Jae Yub Song. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    let isuserloggedin = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    // let isuserloggedin = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool){
        
        
        if(isuserloggedin){
            self.performSegue(withIdentifier: "totab", sender: self)
        }
        else{
            self.performSegue(withIdentifier: "loginView", sender: self)
        }
    }
    
    
    
    
}

