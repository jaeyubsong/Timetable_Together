//
//  FirstViewController.swift
//  Timetable_Together
//
//  Created by Jae Yub Song on 20/01/2018.
//  Copyright © 2018 Jae Yub Song. All rights reserved.
//

import UIKit
import SwiftyJSON
import SQLite3

class FirstViewController: UIViewController{

    @IBOutlet weak var searchPage: UIScrollView!
    @IBOutlet weak var scrollPage: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchPicker: UIPickerView!
    @IBOutlet weak var subjectView: UITableView!
    
    @IBOutlet weak var year: UIPickerView!
    @IBOutlet weak var semester: UIPickerView!
    
    
    var clickPlus = false
    let searchType = ["과목명", "교수님"]
    let semesterType = ["봄", "가을"]
    let yearType = ["2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"]

    ///save to DB
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
            (action: UIAlertAction!) in print("Do Delete: " + String(button.tag))
        }))
        self.present(alert,animated: true,completion: nil)
    }
    
    /// Tag numbers
    /// Background Line: 20
    
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
    
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///database file
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("semesterDatabase.sqlite")
        ///opening the database
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening database")
            return
        }

        ///creating table
        let createTableQuery = "CREATE TABLE IF NOT EXISTS semester(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)"
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print ("error creating table")
            return

        }

        print("Everything is fine")
        
        
        
        let startTime = 8
        let endTime = 18
        
        CreateTimeTable(startTime: startTime, endTime: endTime)
        addClass(14, 15.5, 0, "데이타구조",startTime, dayColors)
        addClass(12, 13, 2, "운영체제", startTime, dayColors)
        addClass(12, 13, 3, "다른과목", startTime, dayColors)
        addClass(13, 14, 2, "과목2", startTime, dayColors)
        addClass(16, 18, 4, "체육과목", startTime, dayColors)
        searchPage.addSubview(searchBar)
        searchPicker.delegate = self
        searchPicker.dataSource = self
        searchBar.barTintColor = UIColor(red: 0.6667, green: 0.8, blue: 0, alpha: 1.0)

        searchPicker.tag = 1
        year.tag = 2
        semester.tag = 3
    }
    
    
    
    func action(sender:UIButton!) {
        print("Button Clicked")
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

        button.addTarget(self, action: Selector(("onClick:forEvent:")), for: UIControlEvents.touchUpInside)
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
    
        button.tag = pairing(Int(xPosition), Int(yPosition))
        button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        
        scrollPage.addSubview(button)

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

extension FirstViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectList", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let add = UITableViewRowAction(style: .normal, title: "Add") { action, index in
            print("Add button tapped")
            //addButton(<#T##x: Int##Int#>, <#T##y: Int##Int#>, <#T##width: Int##Int#>, <#T##height: Int##Int#>, <#T##text: String##String#>)
        }
        add.backgroundColor = .lightGray
        
        return [add]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}


