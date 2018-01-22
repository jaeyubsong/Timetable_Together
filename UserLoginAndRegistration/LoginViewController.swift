//
//  LoginViewController.swift
//  UserLoginAndRegistration
//
//  Created by user on 2018. 1. 21..
//  Copyright © 2018년 daeseung. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    @IBOutlet weak var userStudentidTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    var servermessage : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let userStudentid = userStudentidTextField.text
        let userPassword = userPasswordTextField.text
        
        let userinformation  = [
            "studentid" : userStudentid!,
            "password" : userPassword!
        ]
        
        let url = "http://143.248.132.154:80/"
        
        Alamofire.request(url + "login", method:.post, parameters:userinformation,encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success:
                let respon  = response.result.value!
                self.response(serverresponse: respon, userstudentid: userStudentid!, userpassword: userPassword!)
                
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func response(serverresponse : String, userstudentid:String, userpassword:String){
        
        if (serverresponse == "sucess") {
            
            
            
            let myAlert = UIAlertController(title: "Alert", message: "Login is sucessful", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)  {    action in
                self.performSegue(withIdentifier: "example", sender: self)
            }
            myAlert.addAction(okAction)
            self.present(myAlert,animated: true,completion: nil)
            
            
            
            
        }
            
        else if (serverresponse == "empty"){
            self.displayMyAlertMessage(userMessage: "cannot find any id");
            return;
        }
            
        else if (serverresponse == "loginfail"){
            self.displayMyAlertMessage(userMessage: "Passwords do not match");
            return;
        }
        
    }
    
    
    
    func displayMyAlertMessage(userMessage : String)
    {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler : nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion:nil)
    }
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


