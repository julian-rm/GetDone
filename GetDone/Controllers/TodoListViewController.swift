//
//  ViewController.swift
//  GetDone
//
//  Created by Julian Mclain on 11/9/18.
//  Copyright © 2018 Julian Mclain. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [TodoItem]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print file path to plist
        print(dataFilePath)

        //load items
        loadItems()
    }
    
    //Mark - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]

        cell.textLabel?.text = item.title

        if item.done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    //Mark - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Mark - Add button functionality
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Local variable to store text field contents
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Add text field contents to itemsArray and reload the table
            let newItem = TodoItem()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            self.saveItems()
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            // Set the text field local variable equal to what is in alertTextField. Must be done because alertTextField is only available in this closure which is executed when textField gets added to the Alert Controller
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error in encoding item array, \(error)")
            
        }
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([TodoItem].self, from: data)
            } catch {
                print("Error in encoding item array, \(error)")
            }
        }
    }

}

