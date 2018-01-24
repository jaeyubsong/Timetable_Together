///
///  ThirdViewController.swift
///  Timetable_Together
///
///  Created by USER on 2018. 1. 22..
///  Copyright © 2018년 Jae Yub Song. All rights reserved.
///

import UIKit
import Alamofire
import SwiftyJSON

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var SearchBarList: UISearchBar!
    @IBOutlet weak var myGroup: UITableView!
    @IBOutlet weak var allGroup: UITableView!
    @IBOutlet weak var NaviBar: UINavigationBar!

    @IBAction func addGroup(_ sender: Any) {
        
        let alert = UIAlertController(title: "그룹 등록", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "그룹명"
        }
        alert.addAction(UIAlertAction(title: "등록", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            var inChoiced  = false
            var inValues = false
            
            for i in 0...(self.values.count-1){
                if (self.values[i] == textField!.text!){
                    inValues = true
                    for j in 0...(self.choiced.count-1){
                        if (self.choiced[j] == textField!.text!){
                            inChoiced = true
                            break;
                        }
                    }
                    if (!inChoiced){
                        self.choiced.append(textField!.text!)
                        let addclub = [
                            "studentid" : self.userstudentid!,
                            "club" : textField!.text!
                        ]
                        Alamofire.request(self.url + "insertclub", method:.post, parameters:addclub,encoding: JSONEncoding.default).responseString { response in
                            switch response.result {
                            case .success:
                                let respon  = response.result.value!
                            case .failure(let error):
                                print(error)
                            }
                        }
                        self.myGroup.reloadData()
                    }
                    break
                }
            }
            if ( !inValues ){
                self.values.append(textField!.text!)
                self.allGroup.reloadData()
                
                //서버 모든 그룹에 추가
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //sever에서 불러오기
    var values = [String]()
    var filtered = [String]()
    var choiced = [String]()
    let url = "http://143.248.140.251:5480/"
    let userstudentid = UserDefaults.standard.string(forKey: "userstudentid")
    
    var searchActivated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Do any additional setup after loading the view, typically from a nib.
        
        allGroup.dataSource = self
        allGroup.delegate = self
        
        myGroup.dataSource = self
        myGroup.delegate = self
        
        allGroup.register(UITableViewCell.self, forCellReuseIdentifier: "allcell")
        myGroup.register(UITableViewCell.self, forCellReuseIdentifier: "mycell")
        
        NaviBar.topItem?.title = "My Group List"

        NaviBar.backgroundColor = UIColor(red: 0, green: 0.7333, blue: 0.8, alpha: 1.0) /* #00bbcc */
        SearchBarList.barTintColor = UIColor(red: 0, green: 0.7569, blue: 0.8588, alpha: 1.0) /* #00c1db */
        
        Alamofire.request(url + "club").responseJSON { response in
            switch response.result{
            case .success(_):
                if let data = response.result.value{
                    let json = JSON(data)
                    for item in json.arrayValue{
                        var list = item["club"].arrayValue
                        for i in 0 ..< list.count{
                            self.values.append(list[i].stringValue)
                        }
                        self.allGroup.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
        let userid = [
            "studentid" : userstudentid!
        ]
        
        Alamofire.request(url + "getuserclub", method:.post, parameters: userid, encoding: JSONEncoding.default).responseJSON {
            response in switch response.result{
            case .success:
                if let data = response.result.value{
                    let json = JSON(data)
                    for item in json["club"].arrayValue{
                        print(item["name"].stringValue)
                        self.choiced.append(item["name"].stringValue)
                    }
                    self.myGroup.reloadData()
                }
            case .failure(let error):
                print(error)

            }
        }
        

    }
//
//    func parseData(JSONData: Data) {
// self.parseData(JSONData: response.data!)
//        do {
//            let readableJSON = try JSONDecoder().decode([String].self,from : JSONData)
//            print(readableJSON)
//        }
//        catch {
//            print(error)
//        }
//    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActivated && tableView == self.allGroup{
            return filtered.count
        } else if tableView == self.allGroup {
            return values.count
        } else{
            return choiced.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        
        if tableView == self.allGroup{
            cell = tableView.dequeueReusableCell(withIdentifier: "allcell")! as UITableViewCell
            if searchActivated{
                cell!.textLabel!.text = filtered[indexPath.row]
            }else{
                cell!.textLabel!.text = values[indexPath.row]
            }
            cell?.textLabel?.textAlignment = .center
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "mycell")! as UITableViewCell
            cell!.textLabel!.text = choiced[indexPath.row]
        }
        
        cell!.textLabel!.textAlignment = .center
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        if tableView == self.allGroup{
            let add = UITableViewRowAction(style: .normal, title: "Add") { action, index in
                print("Add button tapped")
            }
            add.backgroundColor = .lightGray
            choiced.append(values[editActionsForRowAt.row])
            
            let club : [String : String] = [
                "name" : values[editActionsForRowAt.row]
            ]
            
            let addclub = [
                "studentid" : userstudentid! ,
                "club" : club
                ] as [String : Any]
            
            Alamofire.request(url + "insertclub", method:.post, parameters: addclub, encoding: JSONEncoding.default).responseString { response in
                switch response.result {
                case .success:
                    let respon  = response.result.value!
                case .failure(let error):
                    print(error)
                    
                }
            }
            return [add]
            
        }else {
            let del = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                print("Delete button tapped")
            }
            del.backgroundColor = UIColor(red: 0.8078, green: 0.2, blue: 0, alpha: 1.0)
            
            let club : [String : String] = [
                "name" : values[editActionsForRowAt.row]
            ]
            
            
            let addclub = [
                "studentid" : userstudentid!,
                "club" : club
            ] as [String : Any]
            
            Alamofire.request(url + "deleteclub", method:.post, parameters:addclub,encoding: JSONEncoding.default).responseString { response in
                switch response.result {
                case .success:
                    let respon  = response.result.value!
                case .failure(let error):
                    print(error)
                }
            }
            myGroup.reloadData()
            return [del]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ThirdViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        allGroup.isHidden = false
        myGroup.isHidden = true
        NaviBar.topItem?.title = "All Group List"
        NaviBar.backgroundColor = UIColor(red: 0.8471, green: 0.749, blue: 0, alpha: 1.0) ///* #d8bf00 */
        SearchBarList.barTintColor = UIColor(red: 0.949, green: 0.8431, blue: 0.0627, alpha: 1.0) ///* #f2d710 */
        self.SearchBarList.showsCancelButton = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.SearchBarList.showsCancelButton = false
        self.SearchBarList.text = ""
        self.SearchBarList.resignFirstResponder()
        allGroup.isHidden = true
        myGroup.isHidden = false
        NaviBar.topItem?.title = "My Group List"
        NaviBar.backgroundColor = UIColor(red: 0, green: 0.7333, blue: 0.8, alpha: 1.0)
        SearchBarList.barTintColor = UIColor(red: 0, green: 0.7569, blue: 0.8588, alpha: 1.0) ///* #00c1db */
        myGroup.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActivated = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filtered = values.filter({ (text) -> Bool in
            let tmp: NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0){
            searchActivated = false
        } else {
            searchActivated = true
        }
        self.allGroup.reloadData()
    }
    
}
