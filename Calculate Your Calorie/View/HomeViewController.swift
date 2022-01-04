//
//  HomeViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 4/1/2022.
//

import UIKit
import CoreData

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
  
    var foods : [Food]?;
    
    var managedObjectContext : NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil;
        
    }
    
    func searchAndReloadTable(query:String){
        if let managedObjectContext = self.managedObjectContext {
            let fetchRequest = NSFetchRequest<Food>(entityName: "Food");
            if query.count > 0 {
                let predicate = NSPredicate(format: "name contains[cd] %@", query)
                fetchRequest.predicate = predicate
            }
            do {
                let theFoods = try managedObjectContext.fetch(fetchRequest)
                self.foods = theFoods
                self.tableView.reloadData()
            } catch { }
        }
        
    }
    
    
    @IBAction func cancel(segue : UIStoryboardSegue){
    }
    
    @IBAction func save(segue : UIStoryboardSegue){
        if let source = segue.source as? AddViewController,
           let context = self.managedObjectContext {
            
            if let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into:context) as? Food {
                newFood.foodname = source.foodNameTF.text
                newFood.category = source.categoryTF.text
            }; do {
                try context.save();
            } catch  {
                print("can't save");
            }
            self.searchAndReloadTable(query: "")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchAndReloadTable(query: "")
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Table
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let foods = self.foods {
            return foods.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FoodTableViewCell else {
            fatalError("Can't instantiate FoodTableViewCell")
        }
        
        if let food = self.foods?[indexPath.row] {
            cell.foodName?.text = "\(food.foodname!)"
//            cell.addDate?.text = "\(food.category!)"
//            cell.kcal?.text = "\(food.calories)"
        }
        
        return cell
    }
    
}
