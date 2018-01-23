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

class FirstViewController: UIViewController{

    @IBOutlet weak var searchPage: UIScrollView!
    @IBOutlet weak var scrollPage: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchPicker: UIPickerView!
    @IBOutlet weak var subjectView: UITableView!
    
    @IBOutlet weak var year: UIPickerView!
    @IBOutlet weak var semester: UIPickerView!
    
    var timer = Timer.self
    var clickPlus = false
    var isSearching = false
    let searchType = ["과목명", "교수님"]
    let semesterType = ["봄", "가을"]
    let yearType = ["2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"]
    
    var filteredData = [Class]()
    //var searchTypeBool = true ///true: 과목명 false: 교수님
    
    //update to DB
    ///end of the semester
    @IBAction func saveButton(_ sender: Any) {
        
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
    //Do Delete
    @objc func pressButton(_ button: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {
            (action: UIAlertAction!) in
            //button delete
            print("Do Delete: " + String(button.tag))
        }))
        self.present(alert,animated: true,completion: nil)
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrlUser = documentDirectory.appendingPathComponent("userTimeTable").appendingPathExtension("sqlite3")
            let databaseUser = try Connection(fileUrlUser.path)
            self.databaseUser = databaseUser
        } catch {
            print (error)
        }

        createUserTable()
        
        // 중복과목은 CourseNum을 통해서 같은 항목 추가 안함
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS204", Section: "A", CourseTitle: "이산구조", AU: "0", Credit: "3.0:0:3.0", Instructor: "강성원", ClassTime: "월 13:00~14:30\n수 13:00~14:30", Classroom: "(E3)정보전자공학동2112", Semester: "2018S", Grade: "")
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS204", Section: "A", CourseTitle: "이산구조", AU: "0", Credit: "3.0:0:3.0", Instructor: "강성원", ClassTime: "월 13:00~14:30\n수 13:00~14:30", Classroom: "(E3)정보전자공학동2112", Semester: "2018S", Grade: "")
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS316", Section: "", CourseTitle: "이산 아무거나", AU: "0", Credit: "3.0:0:3.0", Instructor: "윤현수", ClassTime: "화 14:30~16:00\n목 14:30~16:00", Classroom: "(N1)김병호·김삼열 IT융합빌딩201", Semester: "2018S", Grade: "")
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS311", Section: "", CourseTitle: "전산기조직", AU: "0", Credit: "3.0:0:3.0", Instructor: "윤현수", ClassTime: "화 14:30~16:00\n목 14:30~16:00", Classroom: "(N1)김병호·김삼열 IT융합빌딩201", Semester: "2018S", Grade: "")
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS315", Section: "", CourseTitle: "이산 수학", AU: "0", Credit: "3.0:0:3.0", Instructor: "윤현수", ClassTime: "화 14:30~16:00\n목 14:30~16:00", Classroom: "(N1)김병호·김삼열 IT융합빌딩201", Semester: "2018S", Grade: "")
        DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS320", Section: "", CourseTitle: "프로그래밍언어", AU: "0", Credit: "3.0:0:3.0", Instructor: "류석영", ClassTime: "월 14:30~16:00\n수 14:30~16:00", Classroom:
            "(E11)창의학습관터만홀", Semester: "2018S", Grade: "")
         DBinsertClass(Department: "전산학부", CourseType: "전공필수", CourseNum: "CS319", Section: "", CourseTitle: "중간에 이산 끝", AU: "0", Credit: "3.0:0:3.0", Instructor: "윤현수", ClassTime: "화 14:30~16:00\n목 14:30~16:00", Classroom: "(N1)김병호·김삼열 IT융합빌딩201", Semester: "2018S", Grade: "")
        DBupdateGrade(CourseNum: "CS311", Grade: "4.3")
        
        //DBdeleteClass(CourseNum: "CS204")
        DBfindClassByTitle(CourseTitlePart: "전산")
        DBfindClassByInstructor(InstructorPart: "석영")
        // DBdeleteAllClass()
        DBlistClasses()
        
        
        let startTime = 8
        let endTime = 18
        
        CreateTimeTable(startTime: startTime, endTime: endTime)
        addClass(14, 15.5, 0, "데이타구조",startTime, dayColors)
        addClass(12, 13, 2, "운영체제", startTime, dayColors)
        addClass(12, 13, 3, "다른과목", startTime, dayColors)
        addClass(13, 14, 2, "과목2", startTime, dayColors)
        addClass(16, 18, 4, "체육과목", startTime, dayColors)
        removeClass(startTime: 13, tableStart: startTime, day: 2)
        
        searchPage.addSubview(searchBar)
        
        searchPicker.delegate = self
        searchPicker.dataSource = self
        
        searchBar.barTintColor = UIColor(red: 0.6667, green: 0.8, blue: 0, alpha: 1.0)
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        searchPicker.tag = 1
        year.tag = 2
        semester.tag = 3
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
        } catch {
            print(error)
        }
    }
    
    func DBdeleteClass(CourseNum: String) {
        let userClass = self.usersTable.filter(self.CourseNum == CourseNum)
        let deleteClass = userClass.delete()
        do {
            try self.databaseUser.run(deleteClass)
        } catch {
            print(error)
        }
    }
    
    func DBdeleteAllClass() {
        
    }
    
    func DBfindClassByTitle(CourseTitlePart: String) -> [Class] {
        var classes = [Class]()
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.CourseTitle].contains(CourseTitlePart)) {
                    let oneClass = Class(Department: user[self.Department], CourseType: user[self.CourseType], CourseNum: user[self.CourseNum], Section: user[self.Section], CourseTitle: user[self.CourseTitle], AU: user[self.AU], Credit: user[self.Credit], Instructor: user[self.Instructor], ClassTime: user[self.ClassTime], Classroom: user[self.Classroom], Semester: user[self.Semester], Grade: user[self.Grade])
                    classes.append(oneClass)
                }
            }
        } catch {
            print (error)
        }
        //print(classes[1].CourseNum)
        //print(classes.count)
        return classes
    }
    
    func DBfindClassByInstructor(InstructorPart: String) -> [Class] {
        var classes = [Class]()
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.Instructor].contains(InstructorPart)) {
                    let oneClass = Class(Department: user[self.Department], CourseType: user[self.CourseType], CourseNum: user[self.CourseNum], Section: user[self.Section], CourseTitle: user[self.CourseTitle], AU: user[self.AU], Credit: user[self.Credit], Instructor: user[self.Instructor], ClassTime: user[self.ClassTime], Classroom: user[self.Classroom], Semester: user[self.Semester], Grade: user[self.Grade])
                    classes.append(oneClass)
                }
            }
        } catch {
            print (error)
        }
        print(classes[0].CourseNum)
        return classes
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
        
        /// Add background lines
        /// 가로
        
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

    func addClass(_ startTime: Double, _ endTime: Double, _ day: Int, _ text: String, _ tableStart: Int, _ daycolors: [UIColor]) {
        let screenWidth = UIScreen.main.bounds.width
        let button = UIButton(type: UIButtonType.custom) as UIButton
        let xPosition:CGFloat = CGFloat( timeWidth + Int(screenWidth - 30) * day / 5 )
        let yPosition:CGFloat = CGFloat( Double(dayHeight) + Double(timeHeight) * (startTime - Double(tableStart)) )
        let buttonWidth:CGFloat = CGFloat( (Double(screenWidth) - Double(timeWidth)) / 5 )
        let buttonHeight:CGFloat = CGFloat( (endTime - startTime) * Double(timeHeight) )
        let fontName = "Times New Roman"
        let fontSize = 10
        let color = daycolors[Int(arc4random_uniform(7))]
        
        button.frame = CGRect(x: xPosition, y:yPosition, width: buttonWidth, height: buttonHeight)
        button.setTitle(text, for: UIControlState.normal)
        button.setTitleColor(color, for: UIControlState.normal)
        button.titleLabel?.font = UIFont(name:fontName, size: CGFloat(fontSize))
        //button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        
        button.layer.cornerRadius = 5
        button.layer.backgroundColor = color.withAlphaComponent(0.3).cgColor
        button.layer.borderWidth = 1
        button.layer.borderColor = color.cgColor
    
        button.tag = 10
        button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        
        scrollPage.addSubview(button)

    }
    
    func removeClass(startTime: Double, tableStart: Int, day: Int) {
        let xPosition = (timeWidth + Int(screenWidth - 30) * day / 5)
        let yPosition = Int( (Double(dayHeight) + Double(timeHeight) * (startTime - Double(tableStart))) )
        for button in scrollPage.subviews {
            if( button.tag == pairing(xPosition, yPosition)) {
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
        }else{
            pickerLabel?.text = semesterType[row]
        }
        
        
        return pickerLabel!
    }
}

extension FirstViewController: UISearchBarDelegate {
    
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if (searchBar.text == nil || searchBar.text == ""){
//
//            isSearching = false
//            view.endEditing(true)
//            subjectView.reloadData()
//
//        }else if searchType[searchPicker.selectedRow(inComponent: 0)] == "과목명" {
//            print(searchBar.text!)
//            isSearching = true
//            filteredData = DBfindClassByTitle( CourseTitlePart: searchBar.text! )
//            print(filteredData)
//            subjectView.reloadData()
//        }else{
//            print("교수님")
//            isSearching = true
//            filteredData = DBfindClassByInstructor(InstructorPart: searchBar.text! )
//            subjectView.reloadData()
//        }
//    }
    
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
//        if(isSearching){
//            return filteredData.count
//        }
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
            
            //cell.ClassTime.text = filteredData[indexPath.row].ClassTime.split(separator: '\n')
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
            //push to local DB
            
            //addButton(<#T##x: Int##Int#>, <#T##y: Int##Int#>, <#T##width: Int##Int#>, <#T##height: Int##Int#>, <#T##text: String##String#>)
        }
        add.backgroundColor = .lightGray
        
        return [add]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}


class CustomCell: UITableViewCell{
    @IBOutlet weak var CourseTitlewithInstructor: UILabel!
    @IBOutlet weak var ClassTime: UILabel!
    @IBOutlet weak var Classroom: UILabel!
}


