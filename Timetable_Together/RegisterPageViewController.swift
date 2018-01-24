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
import SQLite

class RegisterPageViewController: UIViewController{
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userStudentidTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var userschoolTextField: UITextField!
    @IBOutlet weak var userMajor: UITextField!
    
    var databaseUserInfo: Connection!
    let infoTable = Table("userInfo")
    let id = Expression<Int>("id")
    let Department = Expression<String>("Department")
    let userName = Expression<String>("userName")
    let studentId = Expression<String>("studentId")
    let isRecent = Expression<String>("isRecent")
    
    
    let majorList = ["건설및환경공학과", "기계공학과", "기술경영학부", "물리학과", "바이오및뇌공학과", "산업디자인학과", "산업및시스템공학과", "생명과학과", "생명화학공학과", "수리과학과", "신소재공학과", "원자력및양자공학과", "전기및전자공학부", "전산학부", "항공우주공학과", "화학과"]
    let schoollist = ["KAIST", "한양대", "숙명여대","연세대"]
    var major : String?
    var userSchool : String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSchoolPicker()
        createMajorPicker()
        createToolbar()
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // Do any additional setup after loading the view.
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrlUser = documentDirectory.appendingPathComponent("userInfo").appendingPathExtension("sqlite3")
            let databaseUserInfo = try Connection(fileUrlUser.path)
            self.databaseUserInfo = databaseUserInfo
        } catch {
            print (error)
        }
        createInfoTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createInfoTable() {
        let createTable = self.infoTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.Department)
            table.column(self.userName)
            table.column(self.studentId)
            table.column(self.isRecent)
        }
        
        do {
            try self.databaseUserInfo.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    
    func DBInsert(Department: String, userName: String, studentId: String) {
        let insertInfo = self.infoTable.insert(self.Department <- Department,
                                                 self.userName <- userName,
                                                 self.studentId <- studentId,
                                                 self.isRecent <- "true")
        do {
            try self.databaseUserInfo.run(insertInfo)
            print("Inserted Info")
        } catch {
            print(error)
        }
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
            "school" : userSchool!,
            "major" : major
        ]
        
        let url = "http://143.248.140.251:5480/"
        
        Alamofire.request(url + "post", method:.post, parameters:userinformation,encoding: JSONEncoding.default).responseString { response in
            switch response.result {
            case .success:
                // print(response.result.value!)
                let respon  = response.result.value!
                print(respon)
                self.response(serverresponse: respon)
                self.DBInsert(Department: userinformation["major"]!!, userName: userinformation["name"]!!, studentId: userinformation["studentid"]!!)
                print("userinformation major:",userinformation["major"]!!)
                print("userinformation username:",userinformation["name"])
                print("userinformation studentId:", userinformation["studentid"])
                print(userinformation["school"])
                
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
        schoolPicker.tag = 1;
    }
    
    func createMajorPicker(){
        let majorPicker = UIPickerView().self
        majorPicker.delegate = self
        userMajor.inputView = majorPicker
        majorPicker.tag = 2
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
        
        if(pickerView.tag == 1){
            return schoollist.count
        }else{
            return majorList.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(pickerView.tag == 1){
            return schoollist[row]
        }else {
            return majorList[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(pickerView.tag == 1){
            userSchool = schoollist[row]
            userschoolTextField.text = userSchool
        }else{
            major = majorList[row]
            userMajor.text = major
        }
        
    }
    
    
    
    
}
