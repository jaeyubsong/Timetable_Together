//
//  ViewController.swift
//  UserLoginAndRegistration
//
//  Created by user on 2018. 1. 21..
//  Copyright © 2018년 daeseung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ToLoginButton(_ sender: Any) {
        self.performSegue(withIdentifier: "loginView", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
    }
    
    
    

}

