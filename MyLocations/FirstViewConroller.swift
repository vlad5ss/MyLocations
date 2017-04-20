////
////  FirstViewConroller.swift
////  MyLocations
////
////  Created by mac on 4/20/17.
////  Copyright © 2017 Yixin Xue. All rights reserved.
////
//
//import UIKit
//import CoreLocation
//import MapKit
//import Alamofire
//import CoreData
//
//class FirstViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
//    
//    var userPinView: MKAnnotationView!
//    let locationManager = CLLocationManager()
//    var currentWeather = CurrentWeather()
//        var locationName : String = "Current Location"
//    var forecast: Forecast!
//    var forecasts = [Forecast]()
//    var managedObjectContext: NSManagedObjectContext!
//    var location: CLLocation?
////    var updatingLocation = false
//    var lastLocationError: Error?
//    let geocoder = CLGeocoder()
//    var placemark: CLPlacemark?
////    var timer: Timer?
//    @IBOutlet weak var latitudeLabel: UILabel!
//    @IBOutlet weak var longitudeLabel: UILabel!
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak var tagButton: UIButton!
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var currentTempnow: UILabel!
//    @IBOutlet weak var currentWeathernow: UILabel!
//    @IBOutlet weak var datenow: UILabel!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestWhenInUseAuthorization()
//            locationManager.startUpdatingLocation()
//            mapView.showsUserLocation = true
//        
//    }
//    
//
//    
//    private func locationManager(_ manager: CLLocationManager,
//                                 didFailWithError error: NSError) {
//        let errorType = error.code == CLError.denied.rawValue
//            ? "Access Denied": "Error \(error.code)"
//        let alertController = UIAlertController(title: "Location Manager Error",
//                                                message: errorType, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel,
//                                     handler: { action in })
//        alertController.addAction(okAction)
//        present(alertController, animated: true,
//                completion: nil)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations
//        locations: [CLLocation]) {
//        locationManager.stopUpdatingLocation()
//        Location2.sharedInstance.latitude = (locationManager.location?.coordinate.latitude)!
//        Location2.sharedInstance.longitude = (locationManager.location?.coordinate.longitude)!
//        currentWeather.downloadWeatherData{
//            self.downloadForecastData{
//                self.updateMainUI()
//            }
//        }
//        let location1 = locations[0]
//        self.latitudeLabel.text = String(location1.coordinate.latitude)
//        self.longitudeLabel.text = String(location1.coordinate.longitude)
//        
//        let center = CLLocationCoordinate2D(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)
//        let latDelta:CLLocationDegrees = 0.01
//        let lonDelta:CLLocationDegrees = 0.01
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
//        self.mapView.setRegion(region, animated: true)
//        let coordinate = CLLocationCoordinate2D(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)
//        
//        CLGeocoder().reverseGeocodeLocation(location1) { (placemarks, error) in
//            
//            if error != nil {
//                
//                print(error)
//                
//            } else {
//                
//                if let placemark = placemarks?[0] {
//                    
//                    var address = ""
//                    
//                    if placemark.subThoroughfare != nil {
//                        
//                        address += placemark.subThoroughfare! + " "
//                        
//                    }
//                    
//                    if placemark.thoroughfare != nil {
//                        
//                        address += placemark.thoroughfare! + " "
//                        
//                    }
//                    
//                    if placemark.subLocality != nil {
//                        
//                        address += placemark.subLocality! + " "
//                        
//                    }
//                    
//                    if placemark.subAdministrativeArea != nil {
//                        
//                        address += placemark.subAdministrativeArea! + "\n "
//                        
//                    }
//                    
//                    if placemark.postalCode != nil {
//                        
//                        address += placemark.postalCode! + " "
//                        
//                    }
//                    
//                    if placemark.country != nil {
//                        
//                        address += placemark.country! + " "
//                        
//                    }
//                    print(address)
//                    self.addressLabel.text = address
//                }
//                
//            }
//            
//        }
//        
//        self.mapView.setRegion(region, animated: true)
//        
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = coordinate
//                annotation.title = locationName
//                self.mapView.addAnnotation(annotation)
//    }
//    
//    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        
//        switch status {
//        case .authorizedWhenInUse:
//            print("Authorization Granted")
//            break
//        case .denied:
//            // User denied your app access to Location Services, but can grant access from Settings.app
//            print("Authorization Denied")
//            break
//        default:
//            // Nothing happens
//            break
//        }
//        
//    }
//    
//    
////        func startLocationManager(){
////            if CLLocationManager.locationServicesEnabled(){
////                locationManager.delegate = self
////                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
////                locationManager.startUpdatingLocation()
////                updatingLocation = true
////                timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
////            }
////        }
////    
////        func stopLocationManager(){
////            if updatingLocation{
////                locationManager.stopUpdatingLocation()
////                locationManager.delegate = nil
////                updatingLocation = false
////                if let timer = timer {
////                    timer.invalidate()
////                }
////            }
////        }
//    
//    
////        func string(from placemark: CLPlacemark) -> String{
////            var line1 = ""
////            if let s = placemark.subThoroughfare{
////                line1 += s + " "
////            }
////            if let s = placemark.thoroughfare {
////                line1 += s }
////    
////            var line2 = ""
////            if let s = placemark.locality {
////                line2 += s + " "
////            }
////            if let s = placemark.administrativeArea {
////                line2 += s + " "
////            }
////            if let s = placemark.postalCode {
////                line2 += s
////            }
////    
////            return line1 + "\n" + line2
////        }
//    
//    
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if segue.identifier == "TagLocation"{
//                let navigationController = segue.destination as! UINavigationController
//                let controller = navigationController.topViewController as! LocationDetailsViewController
//                controller.coordinate = location!.coordinate
//                controller.placemark = placemark
//                controller.managedObjectContext = managedObjectContext
//            }
//        }
//  
//       
//    
//    
//    
//    
//    func downloadForecastData(completed: @escaping DownloadComplete){
//        //Downloading forecast weather data for Tableview
//        let forecastURL = URL(string: FORECAST_URL)!
//        Alamofire.request(forecastURL).responseJSON{
//            response in
//            let result = response.result
//            if let dictionary = result.value as? Dictionary<String, AnyObject> {
//                if let list = dictionary["list"] as? [Dictionary<String, AnyObject>] {
//                    for obj in list {
//                        let forecast = Forecast(weatherDictionary: obj)
//                        self.forecasts.append(forecast)
//                    }
//                    self.forecasts.remove(at: 0)
//                }
//            }
//            completed()
//        }
//    }
//    
//    func updateMainUI(){
//        datenow.text = currentWeather.date
//        currentTempnow.text = "\(currentWeather.currentTemp)"
//        currentWeathernow.text = currentWeather.weatherType
//    }
//}
