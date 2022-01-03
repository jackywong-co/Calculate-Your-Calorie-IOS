//
//  HomeTableViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 3/1/2022.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    
    var foods: [Food]?;
    
    var managedObjectContext:NSManagedObjectContext?{
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    func searchAndReloadTable(query:String){
        if let managedObjectContext = self.managedObjectContext {
            let fetchRequest = NSFetchRequest<Food>(entityName: "Food");
            if query.count > 0 {
                let predicate = NSPredicate(format: "name contains[cd] %@", query)
                fetchRequest.predicate = predicate
            }
            do {
                let theDevices = try managedObjectContext.fetch(fetchRequest)
                self.foods = theDevices
                self.tableView.reloadData()
            } catch { }
        } }
    
    
    @IBAction func save(segue : UIStoryboardSegue){
        if let source = segue.source as? AddViewController,
                   let context = self.managedObjectContext {
                   if let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into:
       context) as? Food {
                       //for new device
                       newFood.foodname = source.foodNameTF.text
                       let toInt = source.CalorieTF.text!
                       newFood.calories = Double(toInt) ?? 0.0
                  
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let foods = self.foods {
            return foods.count
        }
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let food = self.foods?[indexPath.row] {
            cell.textLabel?.text = "\(food.foodname!)"
            cell.detailTextLabel?.text = " \(food.calories)"
        }
        return cell;
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
