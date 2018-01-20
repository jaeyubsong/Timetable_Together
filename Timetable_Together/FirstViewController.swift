//
//  FirstViewController.swift
//  Timetable_Together
//
//  Created by Jae Yub Song on 20/01/2018.
//  Copyright © 2018 Jae Yub Song. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var scrollPage: UIScrollView!
    @IBOutlet weak var viewPage: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //drawSquare(0, 0, 100, 100)
        drawSquare(100, 600, 200, 700)
        // addButton(x: 200, y: 200, width: 100, height: 100)
        // addButton(x: 200, y: 500, width: 100, height: 100)
        addClass(startTime: 14, endTime: 15.5, day: 0)
        addClass(startTime: 12, endTime: 13, day: 2)
    }
    
    
    
    func action(sender:UIButton!) {
        print("Button Clicked")
    }
    
    func addButton(x: Int, y: Int, width: Int, height: Int) {
        let button = UIButton(type: UIButtonType.custom) as UIButton
        let xPosition:CGFloat = CGFloat(x)
        let yPosition:CGFloat = CGFloat(y)
        let buttonWidth:CGFloat = CGFloat(width)
        let buttonHeight:CGFloat = CGFloat(height)
        
        button.frame = CGRect(x: xPosition, y:yPosition, width: buttonWidth, height: buttonHeight)
        
        button.backgroundColor = UIColor.lightGray
        button.setTitle("Tap me", for: UIControlState.normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: Selector(("onClick:forEvent:")), for: UIControlEvents.touchUpInside)
        button.tag = pairing(x, y)
        scrollPage.addSubview(button)
    }

    func addClass(startTime: Double, endTime: Double, day: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let button = UIButton(type: UIButtonType.custom) as UIButton
        let xPosition:CGFloat = CGFloat( 30 + Int(screenWidth - 30) * day / 5 )
        let yPosition:CGFloat = CGFloat( 30 + 60 * (startTime - 8) )
        let buttonWidth:CGFloat = CGFloat( (screenWidth - 30) / 5 )
        let buttonHeight:CGFloat = CGFloat( (endTime - startTime) * 60 )
        
        button.frame = CGRect(x: xPosition, y:yPosition, width: buttonWidth, height: buttonHeight)
        
        button.backgroundColor = UIColor.lightGray
        button.setTitle("Tap me", for: UIControlState.normal)
        button.tintColor = UIColor.black
        button.addTarget(self, action: Selector(("onClick:forEvent:")), for: UIControlEvents.touchUpInside)
        button.tag = pairing(Int(xPosition), Int(yPosition))
        scrollPage.addSubview(button)
    }
    
    @objc func onClick(_ sender: UIButton!, forEvent event: UIEvent) {
        print("button click: ", sender.frame)
        print(sender.tag)
        print(sender)
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        print(screenWidth)
    }
    
    
    func drawSquare(_ topX: Int, _ topY: Int, _ bottomX: Int, _ bottomY: Int) {
        let squarePath = UIBezierPath() // 1
        squarePath.move(to: CGPoint(x: topX, y: topY))
        squarePath.addLine(to: CGPoint(x: bottomX, y: topY))
        squarePath.addLine(to: CGPoint(x: bottomX, y: bottomY))
        squarePath.addLine(to: CGPoint(x: topX, y: bottomY))
        squarePath.close()
        
        let square = CAShapeLayer() // 6
        square.path = squarePath.cgPath // 7
        //square.fillColor = UIColor.red.cgColor
        scrollPage.layer.addSublayer(square)
    }
    
    func pairing(_ a: Int, _ b: Int) -> Int {
        return Int( (a + b) * (a + b + 1) / 2 + b )
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}


