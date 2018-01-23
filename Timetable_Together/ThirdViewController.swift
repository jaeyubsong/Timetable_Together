///
///  ThirdViewController.swift
///  Timetable_Together
///
///  Created by USER on 2018. 1. 22..
///  Copyright © 2018년 Jae Yub Song. All rights reserved.
///

import UIKit

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
        alert.addAction(UIAlertAction(title: "참여", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            // 서버 그룹 리스트에 추가. 유저 참여 그룹 리스트에 추가
            self.values.append(textField!.text!)
            self.choiced.append(textField!.text!)
            self.allGroup.reloadData()
            self.myGroup.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //sever에서 불러오기
    var values = ["hurricane", "sparcs", "k-bird", "창작동화", "둘리", "오케스트라"]
    var filtered = [String]()
    var choiced = [String]()
    
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
        NaviBar.backgroundColor = UIColor(red: 0, green: 0.7333, blue: 0.8, alpha: 1.0) ///* #00bbcc */
        SearchBarList.barTintColor = UIColor(red: 0, green: 0.7569, blue: 0.8588, alpha: 1.0) ///* #00c1db */
    }
    
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
            return [add]
        }else {
            let del = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                print("Delete button tapped")
            }
            del.backgroundColor = UIColor(red: 0.8078, green: 0.2, blue: 0, alpha: 1.0)
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
