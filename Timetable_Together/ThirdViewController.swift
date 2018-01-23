//
//  ThirdViewController.swift
//  Timetable_Together
//
//  Created by USER on 2018. 1. 22..
//  Copyright © 2018년 Jae Yub Song. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var SearchBarList: UISearchBar!
    @IBOutlet weak var tableViewList: UITableView!
    
    var values = ["hurricane", "spacs", "k-bird", "창작동화", "둘리", "오케스트라"]
    var filtered : [String] = []
    
    var searchActivated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActivated
        {
            return filtered.count
        }else {
            return values.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        if searchActivated
        {
            cell.textLabel?.text = filtered[indexPath.row]
        }   else{
            cell.textLabel?.text = values[indexPath.row]
        }
        
        return cell
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActivated = true
        self.SearchBarList.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.SearchBarList.showsCancelButton = false
        self.SearchBarList.text = ""
        self.SearchBarList.resignFirstResponder()
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
        
        self.tableViewList.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let add = UITableViewRowAction(style: .normal, title: "Add") { action, index in
            print("Add button tapped")
        }
        add.backgroundColor = .lightGray
        
        return [add]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

