//
//  LoginViewController.swift
//  Timetable_Together
//
//  Created by USER on 2018. 1. 22..
//  Copyright © 2018년 Jae Yub Song. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SQLite

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userStudentidTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    var servermessage : String = ""
    var databaseUser: Connection!
    var databaseInfo: Connection!
    
    let usersTable = Table("SubjectList")
    
    //let id = Expression<Int>("id")
    let id = Expression<Int>("id")
    let Department = Expression<String>("Department")
    let CourseType = Expression<String>("CourseType")
    let CourseNum = Expression<String>("CourseNum")
    let Section = Expression<String>("Section")
    let CourseTitle = Expression<String>("CourseTitle")
    let AU = Expression<String>("AU")
    let Credit = Expression<String>("Credit")
    let Instructor = Expression<String>("Instructor")
    let ClassTime = Expression<String>("ClassTime")
    let Classroom = Expression<String>("Classroom")
    //let Semester = Expression<String>("Semester")
    //let Grade = Expression<String>("Grade")
    
    let infoTable = Table("UserInfo")
    let userId = Expression<String>("userId")
    let userPassword = Expression<String>("userPassword")
    let userMajor = Expression<String>("userMajor")
    let userCurrent = Expression<String>("userCurrent")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var fileUrlUser = documentDirectory.appendingPathComponent("SubjectList").appendingPathExtension("sqlite3")
            var databaseUser = try Connection(fileUrlUser.path)
            self.databaseUser = databaseUser
            print("created")
        } catch {
            print (error)
        }
        
        do {
            var documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var fileUrlUser = documentDirectory.appendingPathComponent("UserInfo").appendingPathExtension("sqlite3")
            var databaseInfo = try Connection(fileUrlUser.path)
            self.databaseInfo = databaseInfo
            print("created")
        } catch {
            print (error)
        }
        
        createUserTable()
        createInfoTable()
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
        
        let url = "http://143.248.140.251:5480/"
        
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
        
        if (serverresponse == "empty"){
            self.displayMyAlertMessage(userMessage: "cannot find any id");
            return;
        }
            
        else if (serverresponse == "loginfail"){
            self.displayMyAlertMessage(userMessage: "Passwords do not match");
            return;
        }
            
            
        else {
            
            UserDefaults.standard.set(userstudentid, forKey: "userstudentid")
            UserDefaults.standard.set(userpassword, forKey: "userpassword")
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            print(serverresponse)
            print(userstudentid)
            
            let url = "http://143.248.140.251:5480/"
            
            Alamofire.request(url + serverresponse ).responseJSON { response in
                switch response.result{
                case .success(_):
                    if let data = response.result.value{
                        
                        let json = JSON(data)
                        for item in json{
                            let b = item.1
                            print(b[" CourseNum"])
                            self.DBinsertClass(Department: b["Department"].stringValue, CourseType: b[" CourseType"].stringValue, CourseNum: b[" CourseNum"].stringValue, Section: b[" Section"].stringValue, CourseTitle: b[" CourseTitle"].stringValue, AU: b[" AU"].stringValue, Credit: b[" Credit"].stringValue, Instructor: b[" Instructor"].stringValue, ClassTime: b[" ClassTime"].stringValue, Classroom: b[" classroom"].stringValue)
                            
                        }
                        
                    }
                case .failure(let error):
                    print(error)
                }
                self.DBlistClasses()
            }
            
            Alamofire.request(url + serverresponse + "1").responseJSON { response in
                switch response.result{
                case .success(_):
                    if let data = response.result.value{
                        
                        let json = JSON(data)
                        for item in json{
                            let b = item.1
                            print(b[" CourseNum"])
                            self.DBinsertClass(Department: b["Department"].stringValue, CourseType: b[" CourseType"].stringValue, CourseNum: b[" CourseNum"].stringValue, Section: b[" Section"].stringValue, CourseTitle: b[" CourseTitle"].stringValue, AU: b[" AU"].stringValue, Credit: b[" Credit"].stringValue, Instructor: b[" Instructor"].stringValue, ClassTime: b[" ClassTime"].stringValue, Classroom: b[" classroom"].stringValue)
                            
                        }
                        
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            
            let userInfo = ["studentid" : "5555"]
            
            Alamofire.request(url + "majorInfo", method:.post, parameters:userInfo,encoding: JSONEncoding.default).responseJSON { response in
                switch response.result {
                case .success:
                    // print(response.result.value!)
                    let respon  = response.result.value!
                    print("major info response")
                    let majorResult = JSON(respon)
                    print(respon)
                    print("major:",majorResult["major"])
                    self.DBinsertInfo(userId: String(describing: majorResult["studentid"]), userPassword: String(describing: majorResult["password"]), userMajor: String(describing: majorResult["major"]))
                    
                    
                    
                case .failure(let error):
                    print(error)
                    
                }
            }
            
            //DBlistClasses()
            /*
             Alamofire.request(url + serverresponse+"club" ).responseJSON { response in
             switch response.result{
             case .success(_):
             if let data = response.result.value{
             let json = JSON(data)
             print("123123")
             print(json)
             }
             case .failure(let error):
             print(error)
             }
             }
             */
            
            
            let myAlert = UIAlertController(title: "Alert", message: "Login is sucessful", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default)  {    action in
                self.performSegue(withIdentifier: "totab", sender: self)
            }
            myAlert.addAction(okAction)
            self.present(myAlert,animated: true,completion: nil)
            
        }
        
        
        
    }
    
    
    
    func displayMyAlertMessage(userMessage : String)
    {
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler : nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion:nil)
    }
    
    func createUserTable() {
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.Department)
            table.column(self.CourseType)
            table.column(self.CourseNum)
            table.column(self.Section)
            table.column(self.CourseTitle)
            table.column(self.AU)
            table.column(self.Credit)
            table.column(self.Instructor)
            table.column(self.ClassTime)
            table.column(self.Classroom)
        }
        
        do {
            try self.databaseUser.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    
    func createInfoTable() {
        let myTable = self.infoTable.create { (table) in
            table.column(self.userId)
            table.column(self.userPassword)
            table.column(self.userMajor)
            table.column(self.userCurrent)
        }
        
        do {
            try self.databaseInfo.run(myTable)
            print("Created user information Table")
        } catch {
            print(error)
        }
    }
    
    
    
    
    func DBinsertClass(Department: String, CourseType: String, CourseNum: String, Section: String, CourseTitle: String, AU: String, Credit: String, Instructor: String, ClassTime: String, Classroom: String) {
        let insertClass = self.usersTable.insert(self.Department <- Department,
                                                 self.CourseType <- CourseType,
                                                 self.CourseNum <- CourseNum,
                                                 self.Section <- Section,
                                                 self.CourseTitle <- CourseTitle,
                                                 self.AU <- AU,
                                                 self.Credit <- Credit,
                                                 self.Instructor <- Instructor,
                                                 self.ClassTime <- ClassTime,
                                                 self.Classroom <- Classroom)
        do {
            try self.databaseUser.run(insertClass)
            print("Inserted User")
        } catch {
            print(error)
        }
    }
    
    func DBinsertInfo(userId: String, userPassword: String, userMajor: String) {
        let insertInfo = self.infoTable.insert(self.userId <- userId,
                                               self.userPassword <- userPassword,
                                               self.userMajor <- userMajor,
                                               self.userCurrent <- "current")
        do {
            try self.databaseInfo.run(insertInfo)
            print("Inserted User")
        } catch {
            print(error)
        }
    }
    
    func DBdeleteInfo(userId: String) {
        let userInfo = self.infoTable.filter(self.userId == userId)
        let deleteInfo = userInfo.delete()
        do {
            try self.databaseInfo.run(deleteInfo)
        } catch {
            print(error)
        }
        DBlistInfos()
    }
    
    func DBdeleteAllInfo() {
        do {
            let infos = try self.databaseInfo.prepare(self.infoTable)
            for info in infos {
                DBdeleteInfo(userId: info[self.userId])
            }
        } catch {
            print(error)
        }
        DBlistInfos()
    }
    
    func DBlistClasses() {
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                print("userId: \(user[self.id]), Department: \(user[self.Department]), CourseType: \(user[self.CourseType]), CourseNum: \(user[self.CourseNum]), Section: \(user[self.Section]), CourseTitle: \(user[self.CourseTitle]), AU: \(user[self.AU]), Credit: \(user[self.Credit]), Instructor: \(user[self.Instructor]), ClassTime: \(user[self.ClassTime]), Classroom: \(user[self.Classroom])")
            }
        } catch {
            print(error)
        }
    }
    
    func DBlistInfos() {
        do {
            let infos = try self.databaseInfo.prepare(self.infoTable)
            for info in infos {
                print("userId: \(info[self.userId]), userPassword: \(info[self.userPassword]), userMajor: \(info[self.userMajor])")
            }
        } catch {
            print(error)
        }
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
