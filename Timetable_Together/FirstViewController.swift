//
//  FirstViewController.swift
//  Timetable_Together
//
//  Created by Jae Yub Song on 20/01/2018.
//  Copyright © 2018 Jae Yub Song. All rights reserved.
//

import UIKit
import SwiftyJSON
import SQLite
import Alamofire

class FirstViewController: UIViewController{

    @IBOutlet weak var searchPage: UIScrollView!
    @IBOutlet weak var scrollPage: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchPicker: UIPickerView!
    @IBOutlet weak var subjectView: UITableView!
    
    @IBOutlet weak var year: UIPickerView!
    @IBOutlet weak var semester: UIPickerView!
    
    var scheduleChange = false
    var clickPlus = false
    var isSearching = false
    let searchType = ["과목명", "교수님"]
    let semesterType = ["봄", "가을"]
    let yearType = ["2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"]
    
    
    
    var filteredData = [Class]()
    let userstudentid = UserDefaults.standard.string(forKey: "userstudentid")
    let url = "http://143.248.140.251:5480/"
    
    let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    let dayColors = [UIColor(red: 0.918, green: 0.224, blue: 0.153, alpha: 1),
                     UIColor(red: 0.106, green: 0.541, blue: 0.827, alpha: 1),
                     UIColor(red: 0.200, green: 0.620, blue: 0.565, alpha: 1),
                     UIColor(red: 0.953, green: 0.498, blue: 0.098, alpha: 1),
                     UIColor(red: 0.400, green: 0.584, blue: 0.141, alpha: 1),
                     UIColor(red: 0.835, green: 0.655, blue: 0.051, alpha: 1),
                     UIColor(red: 0.153, green: 0.569, blue: 0.835, alpha: 1)]
    
    let timeWidth = 30
    let timeHeight = 51
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let dayWidth = (Int(UIScreen.main.bounds.width)-30)/5
    let dayHeight = 45
    
    
    var databaseUser: Connection!
    let usersTable = Table("userTimeTable")
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
    let Semester = Expression<String>("Semester")
    let Grade = Expression<String>("Grade")
    

    var databaseAllSubject: Connection!
    let subjectsTable = Table("SubjectList")
    let sid = Expression<Int>("id")
    let sDepartment = Expression<String>("Department")
    let sCourseType = Expression<String>("CourseType")
    let sCourseNum = Expression<String>("CourseNum")
    let sSection = Expression<String>("Section")
    let sCourseTitle = Expression<String>("CourseTitle")
    let sAU = Expression<String>("AU")
    let sCredit = Expression<String>("Credit")
    let sInstructor = Expression<String>("Instructor")
    let sClassTime = Expression<String>("ClassTime")
    let sClassroom = Expression<String>("Classroom")
    
    
    var startTime = 8
    var endTime = 18
    
    @IBAction func setting(_ sender: Any) {
        let alert = UIAlertController(title: "시간표", message: "시작 시간과 끝시간을 적어주세요", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "시작시간 ex)오전 8시 => 8 입력"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "끝시간 ex)오후 8시 => 20 입력"
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            var textField = alert?.textFields![0]
            if textField?.text != "" {
                let temp = Int(textField!.text!)!
                textField = alert!.textFields![1]
                if textField?.text != ""{
                    self.startTime = temp
                    self.endTime = Int(textField!.text!)!
                    if(self.endTime > self.startTime){
                        for view in self.scrollPage.subviews{
                            view.removeFromSuperview()
                        }
                        //DB 에서 있으면 불러오기 없으면 새로 고침
                        self.viewDidLoad()
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    ///end of the semester
    @IBAction func saveButton(_ sender: Any) {
        let alert = UIAlertController(title: "학기를 마치며", message: "성적을 숫자로 입력해 주세요", preferredStyle: UIAlertControllerStyle.alert)
        var subjectCode = [String]()
        var subjectSemester = [String]()
        var subjectNum = [String]()
        do{
            let subjects = try self.databaseUser.prepare(self.usersTable)
            for subjectdb in subjects{
                alert.addTextField { (textField) in
                    textField.placeholder = subjectdb[self.CourseTitle]
                    subjectCode.append(subjectdb[self.CourseNum] + subjectdb[self.Section])
                    subjectNum.append(subjectdb[self.CourseNum])
                    subjectSemester.append(subjectdb[self.Semester])
                }
            }
        }catch{
            print(error)
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            for index in 0...((alert?.textFields!.count)!-1){
                let textField = alert?.textFields![index]
                let subject: [String: String] = [
                    "semester" : subjectSemester[index],
                    "code" : subjectCode[index],
                    "grade" : textField!.text!
                ]
                
                let info : [String: AnyObject] = [
                    "studentid" : "111111" as AnyObject, //self.userstudentid as AnyObject,
                    "subject" : subject as AnyObject
                ]
                Alamofire.request(self.url + "grade", method:.post, parameters: info, encoding: JSONEncoding.default).responseString { response in
                    switch response.result {
                    case .success:
                        let respon  = response.result.value!
                    case .failure(let error):
                        print(error)
                        
                    }
                }
                self.DBupdateGrade(CourseNum: subjectNum[index], Grade: (textField!.text!))
                print("Save BUTTON"+textField!.text!)
                self.DBlistClasses()
                
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///plusButton
    @IBAction func search(_ sender: Any) {
        print("IN plus Button")
        clickPlus = !clickPlus
        if(clickPlus){
            scrollPage.frame.size.height = scrollPage.frame.size.height / 2
            searchPage.isHidden = false
        }else{
            searchPage.isHidden = true
            scrollPage.frame.size.height = scrollPage.frame.size.height * 2
        }
    }
    ///subjectButton
    @objc func pressButton(_ button: UIButton) {
        //같이 듣는 사람들 목록(서버연동)
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
            (action: UIAlertAction!) in
            self.removeClass(tag: button.tag)
            let Title = button.titleLabel!.text!.split(separator: "\n")[0]
            self.DBdeleteClass(CourseTitle: String(Title))
            
            print("Do Delete: " + String(button.tag))
        }))
        self.present(alert,animated: true,completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userstudentid)
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrlUser = documentDirectory.appendingPathComponent("userTimeTable").appendingPathExtension("sqlite3")
            let databaseUser = try Connection(fileUrlUser.path)
            self.databaseUser = databaseUser
            
            let documentDirectorySubject = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrlUserSubject = documentDirectorySubject.appendingPathComponent("SubjectList").appendingPathExtension("sqlite3")
            let databaseAllSubject = try Connection(fileUrlUserSubject.path)
            self.databaseAllSubject = databaseAllSubject
        } catch {
            print (error)
        }

        createUserTable()
        DBdeleteAll()
        DBlistClasses()
        
        CreateTimeTable(startTime: startTime, endTime: endTime)
        searchPage.addSubview(searchBar)
        
        searchPicker.delegate = self
        searchPicker.dataSource = self
        
        searchBar.barTintColor = UIColor(red: 0.6667, green: 0.8, blue: 0, alpha: 1.0)
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        searchPicker.tag = 1
        year.tag = 2
        semester.tag = 3
        
        year.selectRow(6, inComponent: 0, animated: true)
        semester.selectRow(0, inComponent: 0, animated: true)

    
        //처음 시작하면 DB 불러오기 (클래스 + 학기)
        
    }
    
    
    
    
    func action(sender:UIButton!) {
        print("Button Clicked")
    }
    
    func createUserTable() {
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.Department)
            table.column(self.CourseType)
            table.column(self.CourseNum, unique: true)
            table.column(self.Section)
            table.column(self.CourseTitle)
            table.column(self.AU)
            table.column(self.Credit)
            table.column(self.Instructor)
            table.column(self.ClassTime)
            table.column(self.Classroom)
            table.column(self.Semester)
            table.column(self.Grade)
        }
        
        do {
            try self.databaseUser.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    
    func DBinsertClass(Department: String, CourseType: String, CourseNum: String, Section: String, CourseTitle: String, AU: String, Credit: String, Instructor: String, ClassTime: String, Classroom: String, Semester: String, Grade: String) {
        let insertClass = self.usersTable.insert(self.Department <- Department,
                                                self.CourseType <- CourseType,
                                                self.CourseNum <- CourseNum,
                                                self.Section <- Section,
                                                self.CourseTitle <- CourseTitle,
                                                self.AU <- AU,
                                                self.Credit <- Credit,
                                                self.Instructor <- Instructor,
                                                self.ClassTime <- ClassTime,
                                                self.Classroom <- Classroom,
                                                self.Semester <- Semester,
                                                self.Grade <- Grade)
        do {
            try self.databaseUser.run(insertClass)
            print("Inserted User")
        } catch {
            print(error)
        }
    }
    
    func DBupdateGrade(CourseNum: String, Grade: String) {
        let userClass = self.usersTable.filter(self.CourseNum == CourseNum)
        let updateClass = userClass.update(self.Grade <- Grade)
        do {
            try self.databaseUser.run(updateClass)
            print("UPdateGrade " + Grade)
            DBlistClasses()
        } catch {
            print(error)
        }
    }
    
    func DBdeleteClass(CourseTitle: String) {
        let userClass = self.usersTable.filter(self.CourseTitle == CourseTitle)
        let deleteClass = userClass.delete()
        do {
            try self.databaseUser.run(deleteClass)
        } catch {
            print(error)
        }
        DBlistClasses()
    }
    
    func DBdeleteOneSemester(Semester: String) {
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.Semester] == Semester) {
                    DBdeleteClass(CourseTitle: user[self.CourseTitle])
                }
            }
        } catch {
            print(error)
        }
    }
    
    func DBdeleteAll() {
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                DBdeleteClass(CourseTitle: user[self.CourseTitle])
            }
        } catch {
            print(error)
        }
    }
    
    func DBfindClassByTitle(CourseTitlePart: String) -> [Class] {
        var firstClass = [Class]()
        var secondClass = [Class]()
        do {
            let subjects = try self.databaseAllSubject.prepare(self.subjectsTable)
            for subject in subjects {
                if (subject[self.CourseTitle].contains(CourseTitlePart)) {
                    let oneClass = Class(userId: subject[self.sid], Department: subject[self.sDepartment], CourseType: subject[self.sCourseType], CourseNum: subject[self.sCourseNum], Section: subject[self.sSection], CourseTitle: subject[self.sCourseTitle], AU: subject[self.sAU], Credit: subject[self.sCredit], Instructor: subject[self.sInstructor], ClassTime: subject[self.sClassTime], Classroom: subject[self.sClassroom], Semester: "", Grade: "")
                    if (subject[self.sCourseTitle].prefix(CourseTitlePart.count) == CourseTitlePart) {
                        firstClass.append(oneClass)
                    } else {
                        secondClass.append(oneClass)
                    }
                }
            }
        } catch {
            print (error)
        }

        return insertionSortTitle(firstClass)+insertionSortTitle(secondClass)
    }
    
    func DBfindClassByInstructor(InstructorPart: String) -> [Class] {
        var firstClass = [Class]()
        var secondClass = [Class]()
        do {
            let subjects = try self.databaseAllSubject.prepare(self.subjectsTable)
            for subject in subjects {
                if (subject[self.Instructor].contains(InstructorPart)) {
                    let oneClass = Class(userId: subject[self.sid], Department: subject[self.sDepartment], CourseType: subject[self.sCourseType], CourseNum: subject[self.sCourseNum], Section: subject[self.sSection], CourseTitle: subject[self.sCourseTitle], AU: subject[self.sAU], Credit: subject[self.sCredit], Instructor: subject[self.sInstructor], ClassTime: subject[self.sClassTime], Classroom: subject[self.sClassroom], Semester: "", Grade: "")
                    if (subject[self.sInstructor].prefix(InstructorPart.count) == InstructorPart) {
                        firstClass.append(oneClass)
                    } else {
                        secondClass.append(oneClass)
                    }
                }
            }
        } catch {
            print (error)
        }
        return insertionSortInstructor(firstClass) + insertionSortInstructor(secondClass)
    }

    
    func insertionSortTitle(_ classArray: [Class]) -> [Class] {
        var a = classArray
        if(a.count > 0) {
            for x in 1..<a.count {
                var y = x
                let temp = a[y]
                while y > 0 && temp.CourseTitle < a[y - 1].CourseTitle {
                    a[y] = a[y - 1]                /// 1
                    y -= 1
                }
                a[y] = temp                      /// 2
            }
        }
        return a
    }
    
    func insertionSortInstructor(_ classArray: [Class]) -> [Class] {
        var a = classArray
        if(a.count > 0) {
            for x in 1..<a.count {
                var y = x
                let temp = a[y]
                while y > 0 && temp.Instructor < a[y - 1].Instructor {
                    a[y] = a[y - 1]                /// 1
                    y -= 1
                }
                a[y] = temp                      /// 2
            }
        }
        return a
    }
    
    
    
    func DBlistClasses() {
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                print("userId: \(user[self.id]), Department: \(user[self.Department]), CourseType: \(user[self.CourseType]), CourseNum: \(user[self.CourseNum]), Section: \(user[self.Section]), CourseTitle: \(user[self.CourseTitle]), AU: \(user[self.AU]), Credit: \(user[self.Credit]), Instructor: \(user[self.Instructor]), ClassTime: \(user[self.ClassTime]), Classroom: \(user[self.Classroom]), Semester: \(user[self.Semester]), Grade: \(user[self.Grade])")
            }
        } catch {
            print(error)
        }
    }
    
    
    func addLine(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: UIColor) {
        let leftLine = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        leftLine.backgroundColor = color
        leftLine.tag = 20
        scrollPage.addSubview(leftLine)
    }
    
    func addTextLabel(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ text: String,  _ fontSize: Int, _ color: UIColor) {
        
        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
        label.text = text
        label.textAlignment = .center
        label.font = UIFont(name:"Times New Roman", size: CGFloat(fontSize))
        label.textColor = color
        scrollPage.addSubview(label)
    }
    
    func CreateTimeTable(startTime: Int, endTime: Int) {
        
        /// Add  요일
        addTextLabel(timeWidth, 5, dayWidth, dayHeight, "월요일", 15, dayColors[0])
        addTextLabel(timeWidth + dayWidth, 5, dayWidth, dayHeight, "화요일", 15, dayColors[1])
        addTextLabel(timeWidth + dayWidth * 2, 5, dayWidth, dayHeight, "수요일", 15, dayColors[2])
        addTextLabel(timeWidth + dayWidth * 3, 5, dayWidth, dayHeight, "목요일", 15, dayColors[3])
        addTextLabel(timeWidth + dayWidth * 4, 5, dayWidth, dayHeight, "금요일", 15, dayColors[4])
        
        scrollPage.contentSize = CGSize(width: screenWidth, height: CGFloat(dayHeight + timeHeight * (endTime - startTime + 1) + 20))
        
        var index = startTime
        while index < endTime+1 {
            drawSquare(0, dayHeight + (index - startTime) * timeHeight, Int(screenWidth), dayHeight + (index - startTime + 1) * timeHeight, UIColor(red: 0.914, green: 0.914, blue: 0.906, alpha: 1))
            index += 2
        }

        for index in 0...5 {
            addLine(timeWidth + dayWidth * index, 0, 1, dayHeight + timeHeight * (endTime - startTime + 1), UIColor.white)
        }
        
        /// Add time
        for index in startTime...endTime {
            var timeNumber = index
            if (timeNumber > 12) {
                timeNumber -= 12
            }
            addTextLabel(0, dayHeight + (index - startTime) * timeHeight - 15, timeWidth,timeHeight, String(timeNumber), 12, UIColor.black)
        }
        
    }
    
    func addButton(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ text: String) {
        let button = UIButton(type: UIButtonType.custom) as UIButton
        let xPosition:CGFloat = CGFloat(x)
        let yPosition:CGFloat = CGFloat(y)
        let buttonWidth:CGFloat = CGFloat(width)
        let buttonHeight:CGFloat = CGFloat(height)
        
        button.frame = CGRect(x: xPosition, y:yPosition, width: buttonWidth, height: buttonHeight)
        
        button.layer.cornerRadius = 5
        button.layer.backgroundColor = UIColor.lightGray.cgColor
        button.setTitle(text, for: UIControlState.normal)
        button.titleLabel?.font = UIFont(name:"Times New Roman", size: 10)

        button.tag = pairing(x, y)
        scrollPage.addSubview(button)
        
    }
    
    func time2Double(_ time: Substring) -> Double {
        let h = Double(time.split(separator: ":")[0])
        let m = time.split(separator: ":")[1]
        if(m=="00"){
            return h!
        }else{
            return Double(h!+0.5)
        }
    }
    
    func day2Int(_ day:Substring) -> Int {
        if day == "월" {
            return 0
        }else if day == "화" {
            return 1
        }else if day == "수" {
            return 2
        }else if day == "목" {
            return 3
        }else if day == "금" {
            return 4
        }
        return -1
    }

    func addClass(_ time: [Substring], _ text: String, _ userId: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let color = dayColors[Int(arc4random_uniform(7))]
        let fontName = "Times New Roman"
        let fontSize = 10
        
        for i in 0...time.count-1{
            
            let button = UIButton(type: UIButtonType.custom) as UIButton
            let dayString = time[i].split(separator: " ")[0]
            let day = day2Int(dayString)
            let devide = time[i].split(separator: " ")[1].split(separator: "~")
            let ClassStart = time2Double(devide[0])
            let ClassEnd = time2Double(devide[1])
            let xPosition:CGFloat = CGFloat( timeWidth + Int(screenWidth - 30) * day / 5 )
            let yPosition:CGFloat = CGFloat( Double(dayHeight) + Double(timeHeight) * (ClassStart - Double(startTime)))
            let buttonWidth:CGFloat = CGFloat( (Double(screenWidth) - Double(timeWidth)) / 5 )
            let buttonHeight:CGFloat = CGFloat( (ClassEnd - ClassStart) * Double(timeHeight) )
            button.frame = CGRect(x: xPosition, y:yPosition, width: buttonWidth, height: buttonHeight)
            button.setTitle(text, for: UIControlState.normal)
            
            button.setTitleColor(color, for: UIControlState.normal)
            button.titleLabel?.font = UIFont(name:fontName, size: CGFloat(fontSize))
            //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
            
            button.layer.cornerRadius = 5
            button.layer.backgroundColor = color.withAlphaComponent(0.3).cgColor
            button.layer.borderWidth = 1
            button.layer.borderColor = color.cgColor
            
            button.tag = userId
            button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
            scrollPage.addSubview(button)
        }
        
        
        
        
        

    }
    
    func removeClass(tag: Int) {
        for button in scrollPage.subviews {
            if( button.tag == tag) {
                button.removeFromSuperview()
            }
        }
    }
    

    func drawSquare(_ topX: Int, _ topY: Int, _ bottomX: Int, _ bottomY: Int, _ color: UIColor) {
        let squarePath = UIBezierPath() /// 1
        squarePath.move(to: CGPoint(x: topX, y: topY))
        squarePath.addLine(to: CGPoint(x: bottomX, y: topY))
        squarePath.addLine(to: CGPoint(x: bottomX, y: bottomY))
        squarePath.addLine(to: CGPoint(x: topX, y: bottomY))
        squarePath.close()
        
        let square = CAShapeLayer() /// 6
        square.path = squarePath.cgPath /// 7
        square.fillColor = color.cgColor
        scrollPage.layer.addSublayer(square)
    }
    
    func pairing(_ a: Int, _ b: Int) -> Int {
        return Int( (a + b) * (a + b + 1) / 2 + b )
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    


}

extension FirstViewController: UIPickerViewDataSource,UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if ( pickerView.tag == 1 ){
            return searchType.count
        }else if ( pickerView.tag == 2 ){
            return yearType.count
        }else{
            return semesterType.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Times New Roman", size: 15)
            pickerLabel?.textAlignment = .center
        }
        if ( pickerView.tag == 1 ){
            pickerLabel?.text = searchType[row]
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            pickerView.backgroundColor = UIColor(red: 0.6667, green: 0.8, blue: 0, alpha: 1.0)
        }else if ( pickerView.tag == 2 ){
            pickerLabel?.text = yearType[row]
            scheduleChange = true
        }else{
            pickerLabel?.text = semesterType[row]
            scheduleChange = true
        }
        
        if scheduleChange {
            //DB 에서 해당되는 시간표 불러오기
        }
        
        
        return pickerLabel!
    }
    

}

extension FirstViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text == nil || searchBar.text == ""){
            
            isSearching = false
            view.endEditing(true)
            subjectView.reloadData()
            
        }else if searchType[searchPicker.selectedRow(inComponent: 0)] == "과목명" {
            print(searchBar.text!)
            isSearching = true
            filteredData = DBfindClassByTitle( CourseTitlePart: searchBar.text! )
            print(filteredData)
            subjectView.reloadData()
        }else{
            print("교수님") 
            isSearching = true
            filteredData = DBfindClassByInstructor(InstructorPart: searchBar.text! )
            subjectView.reloadData()
        }
    }
}

extension FirstViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectList", for: indexPath) as! CustomCell
        
        if isSearching {
            let times = filteredData[indexPath.row].ClassTime.split(separator: "\n")
            if (filteredData[indexPath.row].Section == ""){
                cell.CourseTitlewithInstructor.text = filteredData[indexPath.row].CourseTitle + " / " + filteredData[indexPath.row].Instructor
            }else{
                cell.CourseTitlewithInstructor.text = filteredData[indexPath.row].CourseTitle + " / " + filteredData[indexPath.row].Section + " / " + filteredData[indexPath.row].Instructor
            }
            
            cell.Classroom.text = filteredData[indexPath.row].Classroom
            for time in 0...(times.count-1){
                
                if(time==0){
                    cell.ClassTime.text = times[time] + " / "
                }else if(time+1 < times.count){
                    cell.ClassTime.text = cell.ClassTime.text! + times[time] + " / "
                }else{
                    cell.ClassTime.text = cell.ClassTime.text! + times[time]
                }
                
            }
            cell.ClassTime.font.withSize(10)
            cell.Classroom.font.withSize(10)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let add = UITableViewRowAction(style: .normal, title: "Add") { action, index in
            print("Add button tapped")
            
            let department = self.filteredData[editActionsForRowAt.row].Department
            let courseType = self.filteredData[editActionsForRowAt.row].CourseType
            let courseNum = self.filteredData[editActionsForRowAt.row].CourseNum
            let section = self.filteredData[editActionsForRowAt.row].Section
            let courseTitle = self.filteredData[editActionsForRowAt.row].CourseTitle
            let au = self.filteredData[editActionsForRowAt.row].AU
            let credit = self.filteredData[editActionsForRowAt.row].Credit
            let instructor = self.filteredData[editActionsForRowAt.row].Instructor
            let classtime = self.filteredData[editActionsForRowAt.row].ClassTime
            let classroom = self.filteredData[editActionsForRowAt.row].Classroom
            let sem = self.semesterType[self.semester.selectedRow(inComponent: 0)] == "가을" ? "F" : "S"
            let semester = self.yearType[self.year.selectedRow(inComponent: 0)] + sem
            let grade = self.filteredData[editActionsForRowAt.row].Grade
            
            let times = classtime.split(separator: "\n")
            let text = courseTitle + "\n" + classroom
            let userId = self.filteredData[editActionsForRowAt.row].userId
            
            
            let subject: [String: String] = [
                "semester" : semester,
                "code" : courseNum + section
            ]
            
            let info : [String: AnyObject] = [
                "studentid" : "111111" as AnyObject, //self.userstudentid as AnyObject,
                "subject" : subject as AnyObject
            ]
            
            Alamofire.request(self.url + "subject", method:.post, parameters: info, encoding: JSONEncoding.default).responseString { response in
                switch response.result {
                case .success:
                    let respon  = response.result.value!
                case .failure(let error):
                    print(error)
                    
                }
            }

            self.DBinsertClass(Department: department, CourseType: courseType, CourseNum: courseNum, Section: section, CourseTitle: courseTitle, AU: au, Credit: credit, Instructor: instructor, ClassTime: classtime, Classroom: classroom, Semester: semester, Grade: grade)
            self.addClass(times, text, userId)
        }
        add.backgroundColor = .lightGray
        
        return [add]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func moveElementIn(newElement: Class, Index: Int, classArray: [Class]) -> [Class] {
        var returnArray = [Class]()
        /// Move last element
        
        for i in (Index...classArray.count-1).reversed() {
            returnArray.insert(classArray[i], at: 0)
        }
        
        returnArray.insert(newElement, at: 0)
        
        for n in (0...Index-1).reversed() {
            returnArray.insert(classArray[n], at: 0)
        }
        
        return returnArray
    }
    
    func deepCopy(targetClass: [Class]) -> [Class] {
        var returnArray = [Class]()
        for i in (0...targetClass.count-1).reversed() {
            returnArray.append(targetClass[i])
        }
        return returnArray
    }
    

}


class CustomCell: UITableViewCell{
    @IBOutlet weak var CourseTitlewithInstructor: UILabel!
    @IBOutlet weak var ClassTime: UILabel!
    @IBOutlet weak var Classroom: UILabel!
}


