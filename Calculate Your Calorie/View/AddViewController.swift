//
//  AddViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 3/1/2022.
//

import UIKit
import CoreData

class AddViewController: UIViewController {
    
    @IBOutlet weak var foodNameTF : UITextField!;
    @IBOutlet weak var CalorieTF : UITextField!;
    @IBOutlet weak var addBTN : UIButton!;
    
    var managedObjectContext : NSManagedObjectContext? {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                return delegate.persistentContainer.viewContext;
            }
    return nil; }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
