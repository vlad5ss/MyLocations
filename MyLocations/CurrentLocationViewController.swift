//
//  FirstViewController.swift
//  MyLocations
//

//

import UIKit
import CoreLocation
import CoreData
import MapKit
import Alamofire

class CurrentLocationViewController: UIViewController , CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentTempnow: UILabel!
    @IBOutlet weak var currentWeathernow: UILabel!
    @IBOutlet weak var datenow: UILabel!
    
    var locationName : String = "Current Location"
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    var timer: Timer?
    var managedObjectContext: NSManagedObjectContext!
    var currentWeather = CurrentWeather()
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError \(error)")
        if(error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    


    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
//        let newLocation = locations.last!
//
//        locationManager.stopUpdatingLocation()
//        Location2.sharedInstance.latitude = (locationManager.location?.coordinate.latitude)!
//        Location2.sharedInstance.longitude = (locationManager.location?.coordinate.longitude)!
//        currentWeather.downloadWeatherData{
//            self.downloadForecastData{
//                self.updateMainUI()
//            }
//        }
         let newLocation = locations.last!
        let location1 = locations[0]
        
        
        let center = CLLocationCoordinate2D(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        self.mapView.setRegion(region, animated: true)
        let coordinate = CLLocationCoordinate2D(latitude: location1.coordinate.latitude, longitude: location1.coordinate.longitude)


        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationName
        self.mapView.addAnnotation(annotation)
//        
        stopLocationManager()
        updateLabels()
        
        print("didUpdateLocations \(newLocation)")

         1
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // 2
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
//         3
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // 4
            lastLocationError = nil
            location = newLocation
            updateLabels()
            // 5
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                print("*** We're done!")
                stopLocationManager()
                if distance > 0{
                    performingReverseGeocoding = false
                }
            }
        
            if !performingReverseGeocoding{
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler:
                    // Closure, placemark and error are parameters
                    {placemark, error in
                        print("*** Found placemarks: \(placemark), error: \(error)")
                        self.lastLocationError = error
                        if error == nil, let p = placemark, !p.isEmpty{
                            self.placemark = p.last!
                        }else{
                            self.placemark = nil
                        }
                        self.performingReverseGeocoding = false
                        self.updateLabels()
                    }
                )
            }
        }else if distance < 1{
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            if timeInterval > 10{
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()

        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    func updateLabels(){
        if let location = location{
            latitudeLabel.text = String(format:"%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        }else{
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError?{
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue{
                    statusMessage = "Location Services Disabled"
                }else{
                    statusMessage = "Error Getting Location"
                }
            }else if !CLLocationManager.locationServicesEnabled(){
                statusMessage = "Location Services Disabled"
            }else if updatingLocation{
                statusMessage = "Searching..."
            }else{
                statusMessage = "Tap 'Het My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager(){
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer {
                timer.invalidate()
            }
        }
    }

    
    func string(from placemark: CLPlacemark) -> String{
        var line1 = ""
        if let s = placemark.subThoroughfare{
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
    // Called after one minute out
    func didTimeOut(){
        print("*** Time out")
        
        if location == nil{
            stopLocationManager()
            
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation"{
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    func downloadForecastData(completed: @escaping DownloadComplete){
        //Downloading forecast weather data for Tableview
        let forecastURL = URL(string: FORECAST_URL)!
        Alamofire.request(forecastURL).responseJSON{
            response in
            let result = response.result
            if let dictionary = result.value as? Dictionary<String, AnyObject> {
                if let list = dictionary["list"] as? [Dictionary<String, AnyObject>] {
                    for obj in list {
                        let forecast = Forecast(weatherDictionary: obj)
                        self.forecasts.append(forecast)
                    }
                    self.forecasts.remove(at: 0)
                }
            }
            completed()
        }
    }
    
    func updateMainUI(){
        datenow.text = currentWeather.date
        currentTempnow.text = "\(currentWeather.currentTemp)"
        currentWeathernow.text = currentWeather.weatherType
    }
}

