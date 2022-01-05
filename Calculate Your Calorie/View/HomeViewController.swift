//
//  HomeViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 4/1/2022.
//

import UIKit
import CoreData
import Foundation

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dataLabel: UILabel!
    
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
        if let source = segue.source as? AddEditViewController,
           let context = self.managedObjectContext {
            if let food = source.theFood {
            //for edit
                food.foodname = source.foodNameTF.text!
                food.category = source.categoryTF.text!
                food.calories = Double(source.caloriesTF.text!) ?? 0
                
                food.date = source.dataLabel.text!
                food.time = source.timeTF.text!
                food.location = source.locationTF.text!
                
                switch source.categoryTF.text! {
                case "Grains":
                    food.image = UIImage(named: "grain")!.pngData()
                case "Vegetables":
                    food.image = UIImage(named: "vegetable")!.pngData()
                case "Protein":
                    food.image = UIImage(named: "protein")!.pngData()
                case "Fruits":
                    food.image = UIImage(named: "fruit")!.pngData()
                default:
                    food.image = UIImage(named: "other")!.pngData()
                }
                
            } else if let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into:context) as? Food {

                newFood.foodname = source.foodNameTF.text!
                newFood.category = source.categoryTF.text!
                newFood.calories = Double(source.caloriesTF.text!) ?? 0
                
                newFood.date = source.dataLabel.text!
                newFood.time = source.timeTF.text!
                
                newFood.location = source.locationTF.text!
                
                switch source.categoryTF.text! {
                case "Grains":
                    newFood.image = UIImage(named: "grain")!.pngData()
                case "Vegetables":
                    newFood.image = UIImage(named: "vegetable")!.pngData()
                case "Protein":
                    newFood.image = UIImage(named: "protein")!.pngData()
                case "Fruits":
                    newFood.image = UIImage(named: "fruit")!.pngData()
                default:
                    newFood.image = UIImage(named: "other")!.pngData()
                }
               
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
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.dataLabel.text = dateFormatter.string(from: date)
        
        
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "EditSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let addEditVC = navVC.topViewController as? AddEditViewController {
                    if let indexPath = tableView.indexPathForSelectedRow {
                        if let foods = self.foods {
                            addEditVC.theFood = foods[indexPath.row]
                        }
                    }
                }
            }
        }
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
            cell.foodName?.text = "\(food.foodname!) -  \(food.category ?? "error")"
            cell.addDate?.text = "\(food.date ?? "error date")"
            cell.kcal?.text = "\(food.calories) kcal"
            cell.foodImage.image = UIImage(data: food.image!)
        }
        
        return cell
    }
    
    
    
    
}
