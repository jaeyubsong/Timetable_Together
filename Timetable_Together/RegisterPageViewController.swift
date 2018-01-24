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

class RegisterPageViewController: UIViewController{
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userStudentidTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var userschoolTextField: UITextField!
    
    
    let schoollist = ["KAIST", "한양대", "숙명여대","연세대"]
    var userSchool : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSchoolPicker()
        createToolbar()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let userName = userNameTextField.text;
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
            "name" : userName!,
            "studentid" : userStudentid!,
            "password" : userPassword!,
            "school" : userSchool!
        ]
        
        let url = "http://143.248.140.251:5480/"
        
        Alamofire.request(url + "post", method:.post, parameters:userinformation,encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success:
                // print(response.result.value!)
                let respon  = response.result.value!
                print(respon)
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
    
    func createSchoolPicker(){
        let schoolPicker = UIPickerView().self
        schoolPicker.delegate = self
        userschoolTextField.inputView = schoolPicker
    }
    
    func createToolbar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        userschoolTextField.inputAccessoryView = toolBar
        /*
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        userschoolTextField.inputAccessoryView = toolBar
    */
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    
    
}

extension RegisterPageViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schoollist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schoollist[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        userSchool = schoollist[row]
        userschoolTextField.text = userSchool
        
    }
    
    
    
    
}
