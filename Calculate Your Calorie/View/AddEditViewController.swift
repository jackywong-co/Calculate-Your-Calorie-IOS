//
//  AddEditViewController.swift
//  Calculate Your Calorie
//
//  Created by Jacky Wong on 3/1/2022.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

import CoreML
import Vision
import ImageIO

class AddEditViewController: UIViewController, CLLocationManagerDelegate{
    
    //for edit
    var theFood : Food?
    
    
    let category = ["Grains","Vegetables","Protein","Fruits"]
    var categoryPicker = UIPickerView()
    
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
    @IBOutlet weak var timeTF: UITextField!
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var locationTF: UITextField!
    
    
    
    let date = Date()
    let dateFormatter = DateFormatter()
    
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        self.categoryTF.inputView = categoryPicker
        
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        print(dateFormatter.string(from: date))
        self.dataLabel.text = dateFormatter.string(from: date)
        
        
        
        
        //        time picker
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(timeChange(timePicker:)), for: UIControl.Event.valueChanged)
        timePicker.frame.size = CGSize(width: 0, height: 300)
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_GB")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        self.timeTF.inputView = timePicker
        self.timeTF.text =  formatTime(date: Date())
        
        
        foodNameTF.addTarget(self, action: #selector(foodNameTFDidChange), for: UIControl.Event.editingDidEnd)
        
        // location
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager = CLLocationManager();
            self.locationManager?.delegate = self;
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.locationManager?.requestAlwaysAuthorization();
            }
            else {
                self.setupAndStartLocationManager();
                
            }
        }
        
        
        self.locationTF.isEnabled = false
        
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //for edit
        if let food = theFood {
            self.foodNameTF.text = food.foodname!
            self.categoryTF.text = food.category!
            self.caloriesTF.text = String(food.calories)
            self.dataLabel.text = food.date!
            self.timeTF.text = food.time!
            //            self.companyTF.text = food.location!
        } }
    
    @objc func viewTapped(gestureRecognizer : UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func timeChange(timePicker: UIDatePicker){
        timeTF.text = formatTime(date: timePicker.date)
    }
    
    func formatTime(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // api
    @objc func foodNameTFDidChange(){
        print("foodNameTFDidChange ing")
        print("\(String(describing: self.foodNameTF.text))")
   
                let json: [String: Any] = [  "appId": "5d7ab666",
                                             "appKey": "85168a6ba46b687d0e4642658d138b1f",
                                             "query": "\(String(describing: self.foodNameTF.text))",
                                             "fields": [
                                                 "item_name",
                                                 "brand_name",
                                                 "nf_calories"
                                             ],
                                             "sort": [
                                                 "field": "_score",
                                                 "order": "desc"
                                             ]
                ]
        
        var request = URLRequest(url: URL(string: "https://api.nutritionix.com/v1_1/search")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        struct Search: Decodable {
            let total: Int
            let max_score: Double
            let hits: [Hit]
        }

        // MARK: - Hit
        struct Hit: Decodable {
            let _index: String
            let _type: String
            let _id: String
            let _score: Double
            let fields: Fields
        }

        // MARK: - Fields
        struct Fields: Decodable {
            let item_name: String
            let brand_name: String
            let nf_calories: Double
        }

      
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let searchResult = try decoder.decode(Search.self, from: data)
                    
                    print(searchResult.hits[0].fields)
                    DispatchQueue.main.async {
                    self.caloriesTF.text = String (searchResult.hits[0].fields.nf_calories)
                    }
                } catch  {
                    print(error)
                }
            }
        }.resume()
        
       

        
    }
    
    // Location
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            self.setupAndStartLocationManager();
        }
    }
    func setupAndStartLocationManager(){
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager?.distanceFilter = kCLDistanceFilterNone;
        self.locationManager?.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            print("\(location.coordinate.latitude)")
            print("\(location.coordinate.longitude)")
            print("\(location.horizontalAccuracy)")
            
            self.locationTF.text = "\(location.coordinate.latitude)"
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01);
            let coord = location.coordinate;
            let region = MKCoordinateRegion(center: coord, span: span)
            self.mapView?.setRegion(region, animated: false);
            
            fetchCityAndCountry(from: location) { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                self.locationTF.text = "\(city), \(country)"
            }
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    var day = 0
    
    @IBAction func addDateButton(_ sender: Any) {
        //        print("add")
        day += 1
        let modifiedDate = Calendar.current.date(byAdding: .day, value: day, to: date)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        print(modifiedDate)
        self.dataLabel.text = dateFormatter.string(from: modifiedDate)
    }
    
    @IBAction func minusDateButton(_ sender: Any) {
        //        print("minus")
        day -= 1
        let modifiedDate = Calendar.current.date(byAdding: .day, value: day, to: date)!
        dateFormatter.dateFormat = "dd-MM-yyyy"
        print(modifiedDate)
        self.dataLabel.text = dateFormatter.string(from: modifiedDate)
    }
    
    
    // CoreML
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest? = {
        //TODO
        do{
            let model = try VNCoreMLModel(for: FoodClassifier().model)
            
            let request = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to perform classification.\n\(error.localizedDescription)")
        }
        
        
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        //TODO
        self.foodNameTF.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image : image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest!])
            } catch {
                print("Faild to perform classification.\n\(error.localizedDescription)")
            }
        }
        
        
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        //TODO
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.foodNameTF.text = "Usable to classify image.\n\(error!.localizedDescription)"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty{
                self.foodNameTF.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map {
                    classifications in
                    return String(format: "%@", classifications.confidence, classifications.identifier)
                }
                print(descriptions)
                self.foodNameTF.text = "\(descriptions[0])"
                
                switch descriptions[0] {
                case "apple":
                    self.caloriesTF.text = "95"
                    
                case "banana":
                    self.caloriesTF.text = "105"
                    
                case "orange":
                    self.caloriesTF.text = "60"
                    
                default:
                    self.caloriesTF.text = ""
                }
                
            }
            
        }
        
    }
    
    @IBAction func takePicture() {
        // Show options for the source picker only if the camera is available.
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    
}



extension AddEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in categoryPicker: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ categoryPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    func pickerView(_ categoryPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    func pickerView(_ categoryPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryTF.text = category[row]
        self.categoryTF.resignFirstResponder()
    }
}


extension AddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Handling Image Picker Selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as! UIImage
        updateClassifications(for: image)
    }
}
