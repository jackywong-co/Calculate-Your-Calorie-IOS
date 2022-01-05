//
//  AddViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 3/1/2022.
//

import UIKit
import CoreData

class AddViewController: UIViewController{
    var theFood : Food?
    
    
    var managedObjectContext : NSManagedObjectContext? {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            return delegate.persistentContainer.viewContext;
        }
        return nil;
    }
    
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var foodNameTF: UITextField!
    @IBOutlet weak var caloriesTF: UITextField!
    
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        timeFormatter.dateFormat = "HH:mm"

        self.dataLabel.text = dateFormatter.string(from: date)
        self.timeLabel.text = timeFormatter.string(from: date)
        
        
    }
    
    
    

    
}
