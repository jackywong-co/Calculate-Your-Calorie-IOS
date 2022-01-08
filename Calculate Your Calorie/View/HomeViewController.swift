//
//  HomeViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 4/1/2022.
//

import UIKit
import CoreData
import Foundation

class HomeViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    var foods : [Food]?;
    
    var managedObjectContext : NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil;
        
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBAction func cancel(segue : UIStoryboardSegue){
    }
    
    @IBAction func save(segue : UIStoryboardSegue){
        if let source = segue.source as? AddEditViewController,
           let context = self.managedObjectContext {
            if let food = source.theFood {
                //for edit
                // Set all data to AddEditViewController
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
                // Add new food data
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
                
            };
                //        // Add data
                //        if let source = segue.source as? AddEditViewController{
                //
                //            let newFood = Food(context: self.context)
                //
                //            newFood.foodname = source.foodNameTF.text!
                //            newFood.category = source.categoryTF.text!
                //            newFood.calories = Double(source.caloriesTF.text!) ?? 0
                //
                //            newFood.date = source.dataLabel.text!
                //            newFood.time = source!.timeTF.text!
                //
                //            newFood.location = source!.locationTF.text!
                //            switch source!.categoryTF.text! {
                //            case "Grains":
                //                newFood.image = UIImage(named: "grain")!.pngData()
                //            case "Vegetables":
                //                newFood.image = UIImage(named: "vegetable")!.pngData()
                //            case "Protein":
                //                newFood.image = UIImage(named: "protein")!.pngData()
                //            case "Fruits":
                //                newFood.image = UIImage(named: "fruit")!.pngData()
                //            default:
                //                newFood.image = UIImage(named: "other")!.pngData()
                //            }
                //        }
            // Save the data
            do {
                try self.context.save();
            } catch  {
                print("can't save");
            }
            // Re-fetch the data
            self.fetchFood()
        }
    }
    
    let date = Date()
    let dateFormatter = DateFormatter()
    var day = 0
    
    @IBAction func addDateButton(_ sender: Any) {
        //        print("add")
        day += 1
        let modifiedDate = Calendar.current.date(byAdding: .day, value: day, to: date)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        print(modifiedDate)
        self.dataLabel.text = dateFormatter.string(from: modifiedDate)
        self.fetchFood()
    }
    
    @IBAction func minusDateButton(_ sender: Any) {
        //        print("minus")
        day -= 1
        let modifiedDate = Calendar.current.date(byAdding: .day, value: day, to: date)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        print(modifiedDate)
        self.dataLabel.text = dateFormatter.string(from: modifiedDate)
        self.fetchFood()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.dataLabel.text = dateFormatter.string(from: date)
        
        
        // fetch the tableview
        self.fetchFood()
        
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
    
    
    func fetchFood(){
        
        
        do{
            
            let request = Food.fetchRequest() as NSFetchRequest<Food>
            request.predicate = NSPredicate(format: "date CONTAINS '\(self.dataLabel.text ?? dateFormatter.string(from: date))'")
            request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
            
            // Fetch the date from Core Date to display in the tableview
            self.foods = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            
        }
    }
}




// MARK: - Table
extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete row of food
        let action = UIContextualAction(style: .destructive, title: "Delete") {(action,view,completionHandler) in
            // Which food to remove
            let foodToRemove = self.foods![indexPath.row]
            // Remove the food
            self.context.delete(foodToRemove)
            // Save the data
            do{
                try! self.context.save()
            }
            catch{
            }
            // Re-fetch the data
            self.fetchFood()
        }
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
