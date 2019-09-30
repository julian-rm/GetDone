//
//  CategoryViewController.swift
//  GetDone
//
//  Created by Julian Mclain on 11/19/18.
//  Copyright © 2018 Julian Mclain. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // Instance variables
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
       
    }
    // Mark: - TableView data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    
    // Mark: - TableView delegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        guard let categoryColor = UIColor.init(hexString: category.color!) else { fatalError() }
        cell.backgroundColor = categoryColor
        cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTodoItems", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    // Mark: Data manipulation methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadCategories() {
        do {
            let request : NSFetchRequest<Category> = Category.fetchRequest()
            categoryArray = try context.fetch(request)
        } catch {
            print("Error loading context \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateDataModel(at indexPath: IndexPath) {
        context.delete(categoryArray[indexPath.row])
        do {
            try context.save()
        } catch {
            print("Error deleting cateogry \(error)")
        }
        categoryArray.remove(at: indexPath.row)
    }
    
    // Mark: Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Local variable to store alert text field contents
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            newCategory.color = UIColor.randomFlat.hexValue()
            self.categoryArray.append(newCategory)
            self.saveCategories()
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}
