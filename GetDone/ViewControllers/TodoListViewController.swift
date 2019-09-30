//
//  ViewController.swift
//  GetDone
//
//  Created by Julian Mclain on 11/9/18.
//  Copyright © 2018 Julian Mclain. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var itemArray = [TodoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reskin the navigation bar and search bar to match the category color
        guard let colorHex = selectedCategory?.color else { fatalError() }
        title = selectedCategory?.name
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Reset the navigation bar to a standard color
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Navigation bar setup methods
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        
        if let color = UIColor.init(hexString: selectedCategory!.color!)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Toggle 'done' property
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add button functionality
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Local variable to store text field contents
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new todo item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // Create new Item and save
            let newItem = TodoItem(context: self.context)
            newItem.done = false
            newItem.title = textField.text!
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
            
            // Reload the table
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
    
    //MARK: - Data manipulation methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving data, \(error)")
        }
    }
    
    func loadItems(with request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            let andPrediate = NSCompoundPredicate(type: .and, subpredicates: [categoryPredicate, additionalPredicate])
            request.predicate = andPrediate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateDataModel(at indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        do {
            try context.save()
        } catch {
            print("Error deleting Todo Item \(error)")
        }
        itemArray.remove(at: indexPath.row)
    }
}

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Build the request with predicate and sortDescriptors
        let request : NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        // Fetch the results
        loadItems(with: request, predicate: searchPredicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

