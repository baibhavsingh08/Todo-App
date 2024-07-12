//
//  ViewController.swift
//  Todo
//
//  Created by Raramuri on 12/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    var models = [TodoListItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        
        title = "To Do List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        let action = UIAlertAction(title: "Submit", style: .cancel, handler: { _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else{
                return
            }

            self.createItem(name: text)
        })
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(TodoListItem.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch {
            print("Error")
        }
    }
    
    func createItem(name: String){
        let newItem = TodoListItem(context: context)
        
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        }catch {
            print("Error")
        }
    }
    
    func deleteItem(item: TodoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        }catch {
            print("Error")
        }
    }
    
    func updateItem(item: TodoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        }catch {
            print("Error")
        }
    }


}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            
            let action = UIAlertAction(title: "Save", style: .cancel, handler: { _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self.updateItem(item: item , newName: newName )
            })
            
            alert.addAction(action)
            self.present(alert, animated: true)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            self.deleteItem(item: item)
        }))
        
        present(sheet, animated: true)
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model  = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    
}
