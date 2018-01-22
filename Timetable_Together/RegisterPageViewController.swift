//
//  RegisterPageViewController.swift
//  Timetable_Together
//
//  Created by USER on 2018. 1. 22..
//  Copyright © 2018년 Jae Yub Song. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterPageViewController: UIViewController {
    @IBOutlet weak var userStudentidTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let userStudentid = userStudentidTextField.text;
        let userPassword = userPasswordTextField.text;
        let userRepeatPassword = repeatPasswordTextField.text;
        
        
        // CHeck for empty fields
        if (userStudentid!.isEmpty || userPassword!.isEmpty || userRepeatPassword!.isEmpty){
            // Display alert message
            
            self.displayMyAlertMessage(userMessage: "All fields are required");
            return;
        }
        
        // Check if passwords match
        if(userPassword != userRepeatPassword){
            // Display an alert message
            self.displayMyAlertMessage(userMessage: "Passwords do not match");
            return;
            
        }
        
        // Store data
        print(userStudentid!)
        print(userPassword!)
        print(userRepeatPassword!)
        
        let userinformation = [
            "studentid" : userStudentid!,
            "password" : userPassword!
        ]
        
        let url = "http://143.248.132.154:80/"
        
        Alamofire.request(url + "post", method:.post, parameters:userinformation,encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success:
                // print(response.result.value!)
                let respon  = response.result.value!
                self.response(serverresponse: respon)
                
            case .failure(let error):
                print(error)
                
            }
        }
        
        
        // Display alert message with confirmation.
        
        
        
    }
    
    func displayMyAlertMessage(userMessage : String)
    {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler : nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion:nil)
    }
    
    func response(serverresponse : String){
        
        if (serverresponse == "save") {
            let myAlert = UIAlertController(title: "Alert", message: "Registration is sucessful. Thank you!", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)  {    action in
                self.dismiss(animated: true, completion: nil)
            }
            myAlert.addAction(okAction)
            self.present(myAlert,animated: true,completion: nil)
        }
            
        else if(serverresponse == "already"){
            self.displayMyAlertMessage(userMessage: "StudentID was already saved");
            return;
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
    
}
