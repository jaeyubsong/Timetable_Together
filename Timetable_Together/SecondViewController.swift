//
//  SecondViewController.swift
//  Timetable_Together
//
//  Created by Jae Yub Song on 20/01/2018.
//  Copyright © 2018 Jae Yub Song. All rights reserved.
//

import UIKit
import SQLite

class SecondViewController: UIViewController {
    
    @IBOutlet weak var viewPage: UIView!
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
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
        DBlistClasses()
        
        var (startSem, endSem) = getMinMaxSemester()
        print("Start Semester is: ", Int2Sem(startSem))
        print("End Semester is: ", Int2Sem(endSem))
        print("Start Semester is: ", startSem)
        print("End Semester is: ", endSem)
        
        //print averages of all semester
        for i in startSem...endSem {
            var currentSem = DBSemesterTotalGrade(Semester: Int2Sem(i))[0]
            if (currentSem.count == 0) {
                print (Int2Sem(i), "has no grades")
            } else {
                print (Int2Sem(i), ": ", (getAverage(Array: currentSem)*1000).rounded() / 1000)
            }
        }
        
        //Draw graph if there are any grades
        if (endSem-startSem > 0) {
            var totalAverage = averageArray(startSem, endSem, "total")
            var majorAverage = averageArray(startSem, endSem, "major")
            for i in 0...totalAverage.count-1 {
                print(Int2Sem(startSem+i),"has average of: ",totalAverage[i])
            }
            let viewPageHeight = Int(viewPage.frame.size.height)
            
            //drawSquare(0, 20, Int(screenWidth), viewPageHeight/2-20, UIColor.blue)
            print("Screen size is: ",viewPageHeight)
            drawGraph(topX: 0, topY: 20, bottomX: Int(screenWidth), bottomY: viewPageHeight/2-20, minSem: startSem, maxSem: endSem, grades: totalAverage, graphTitle: "전체평점")
            
            //drawSquare(0, viewPageHeight/2, Int(screenWidth), viewPageHeight-20, UIColor.blue)
            drawGraph(topX: 0, topY: viewPageHeight/2, bottomX: Int(screenWidth), bottomY: viewPageHeight-20, minSem: startSem, maxSem: endSem, grades: majorAverage, graphTitle: "전공평점")
            
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // returnArray[0]: Total Grades
    // returnArray[1]: Major Grades
    func DBSemesterTotalGrade(Semester: String) -> [[Double]] {
        var returnArray = [[Double]]()
        var TotalGrades = [Double]()
        var MajorGrades = [Double]()
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.Semester] ==  Semester && user[self.Grade] != "") {
                    var userGrade = Double(user[self.Grade])!
                    TotalGrades.append(userGrade)
                    if (user[self.CourseType] == "전공선택" || user[self.CourseType] == "전공필수" ) {
                        MajorGrades.append(userGrade)
                    }
                }
            }
        } catch {
            print(error)
        }
        returnArray.append(TotalGrades)
        returnArray.append(MajorGrades)
        return returnArray
    }
    
    func DBgetSemesterMajorGrade(Semester: String) -> [Double] {
        var Grades = [Double]()
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.Semester] ==  Semester && user[self.Grade] != "") {
                    Grades.append( Double(user[self.Grade])! )
                }
            }
        } catch {
            print(error)
        }
        return Grades
    }
    
    func getAverage(Array: [Double]) -> Double {
        var sum: Double = 0
        var numbers: Int = Array.count
        for i in 0...numbers-1 {
            sum += Array[i]
        }
        return sum/Double(numbers)
    }
    
    func getMinMaxSemester() -> (start: Int, end: Int) {
        var min = 100000
        var max = -100000
        do {
            let users = try self.databaseUser.prepare(self.usersTable)
            for user in users {
                if (user[self.Grade] != "") { //Check if grade was put in
                    var semesterInt = Sem2Int(user[self.Semester])
                    if ( semesterInt < min ) {
                        min = semesterInt
                    }
                    if ( semesterInt > max) {
                        max = semesterInt
                    }
                }
            }
            if (min == 10000) {
                min = 0
                max = 0
            }
        } catch {
            print (error)
        }
        return (min, max)
    }
    
    func Sem2Int(_ semester: String) -> Int {
        var arrayChars = Array(semester)
        let last = arrayChars.popLast()
        let year: Int = Int( String(arrayChars) )!
        if (last == "S") {
            return year * 2
        } else {
            return year * 2 + 1
        }
    }
    
    func Int2Sem(_ intSemester: Int) -> String {
        if (intSemester % 2 == 0) {
            return String(intSemester / 2) + "S"
        } else {
            return String(intSemester / 2) + "F"
        }
    }
    
    func shortSem(_ longSem: String) -> String{
        var resultArr = [Character]()
        var arrayChars = Array(longSem)
        for i in (2...4) {
            resultArr.append(arrayChars[i])
        }
        return String(resultArr)
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
        viewPage.layer.addSublayer(square)
    }

    
    func addTextLabel(_ topX: Int, _ topY: Int, _ bottomX: Int, _ bottomY: Int, _ text: String,  _ fontSize: Int, _ color: UIColor) {
        
        let label = UILabel(frame: CGRect(x: topX, y: topY, width: bottomX-topX, height: bottomY-topY))
        label.text = text
        label.textAlignment = .center
        label.font = UIFont(name:"Times New Roman", size: CGFloat(fontSize))
        label.textColor = color
        viewPage.addSubview(label)
    }
    func addLine(_ x: Int, _ y: Int, _ width: Int, _ height: Int, _ color: UIColor) {
        let leftLine = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        leftLine.backgroundColor = color
        leftLine.tag = 20
        viewPage.addSubview(leftLine)
    }
    
    func averageArray(_ startSem: Int, _ endSem: Int, _ gradeType: String) -> [Double] {
        var averageArray = [Double]()
        if (gradeType == "total") {
            for i in startSem...endSem {
                var currentSem = DBSemesterTotalGrade(Semester: Int2Sem(i))[0]
                if (currentSem.count == 0) {
                    print (Int2Sem(i), "has no grades")
                    averageArray.append(0.0)
                } else {
                    print (Int2Sem(i), ": ", (getAverage(Array: currentSem)*100).rounded() / 100)
                    averageArray.append( (getAverage(Array: currentSem)*100).rounded() / 100 )
                }
            }
        } else if (gradeType == "major") {
            for i in startSem...endSem {
                var currentSem = DBSemesterTotalGrade(Semester: Int2Sem(i))[1]
                if (currentSem.count == 0) {
                    print (Int2Sem(i), "has no grades")
                    averageArray.append(0.0)
                } else {
                    print (Int2Sem(i), ": ", (getAverage(Array: currentSem)*100).rounded() / 100)
                    averageArray.append( (getAverage(Array: currentSem)*100).rounded() / 100 )
                }
            }
        } else {
            return [0.0]
        }
        return averageArray
    }
    
    func validSemNums(gradeArray: [Double]) -> Int {
        var validSemester: Int = 0
        for i in 0...gradeArray.count-1 {
            if gradeArray[i] != 0.0 {
                validSemester += 1
            }
        }
        return validSemester
    }
    
    func drawGraph(topX: Int, topY: Int, bottomX: Int, bottomY: Int, minSem: Int, maxSem: Int, grades: [Double], graphTitle: String) {
        let borderLine = validSemNums(gradeArray: grades)+1
        print("borderLine:",borderLine)
        var counter = 0
        
        print("Graph with coordinates:", topX, topY, bottomX, bottomY)
        
        let lineThickness = 2
        // Draw Graph Border
        //Horizontal
        addLine(topX+10, topY, bottomX-topX-20, lineThickness, UIColor.black)
        addLine(topX+10, bottomY, bottomX-topX-20, lineThickness, UIColor.black)
        //Vertical
        addLine(topX+10, topY, lineThickness, bottomY-topY, UIColor.black)
        addLine(bottomX-10, topY, lineThickness, bottomY-topY+lineThickness, UIColor.black)
        
        for i in 0...maxSem-minSem {
            if (grades[i] != 0) {
                counter += 1
                
                // Add bars
                let BleftX = topX + (bottomX - topX) / borderLine * counter - 7
                let BrightY = bottomY - 50
                let BleftY = topY + 30 + Int((430.0-grades[i]*100) / 430.0 * Double(BrightY - topY))
                let BrightX = topX + (bottomX - topX) / borderLine * counter + 7
                drawSquare(BleftX , BleftY , BrightX, BrightY, UIColor.black)
                
                // Add semester label
                let SleftX = topX + Int( Double(bottomX - topX) / Double(borderLine) * (Double(counter) - 0.5) )
                let SleftY = BrightY + 5
                let SrightX = topX + Int( Double(bottomX - topX) / Double(borderLine) * (Double(counter) + 0.5) )
                let SrightY = SleftY + 15
                addTextLabel(SleftX, SleftY, SrightX, SrightY, shortSem(String(Int2Sem(minSem+i))), 13, UIColor.black)
                
                // Add grades
                let GleftX = SleftX
                let GleftY = BleftY - 20
                let GrightX = SrightX
                let GrightY = BleftY
                addTextLabel(GleftX, GleftY, GrightX, GrightY, String(grades[i]), 13, UIColor.black)
                
                print("Drew graph of", Int2Sem(minSem + i ),":",grades[i], "with coordinates: (", BleftX, BleftY, BrightX, BrightY, ")","current Counter:",counter)
            }
        }
        
        // Add graph Title
        addTextLabel(topX, bottomY-20, bottomX, bottomY, graphTitle, 15, UIColor.black)
    }
    

    
    
    


}

