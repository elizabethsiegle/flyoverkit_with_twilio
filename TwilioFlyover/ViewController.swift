//
//  ViewController.swift
//  TwilioFlyover
//
//  Created by Lizzie Siegle on 8/29/18.
//  Copyright © 2018 Lizzie Siegle. All rights reserved.
//

import UIKit
import FlyoverKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    var userInputLoc = FlyoverAwesomePlace.parisEiffelTower
    
//    static func iterate() -> AnyIterator<FlyoverAwesomePlace> {
//        return FlyoverAwesomePlace
//    }

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var startLoc: CLLocation!
    var pickerData : [String] = [String]()
    
    @IBOutlet weak var submitButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        //curr loc
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        startLoc = nil
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.stopUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        print("")
        
        let topMargin:CGFloat = view.frame.size.height - 100
        let mapWidth:CGFloat = view.frame.size.width - 40
        let mapHeight:CGFloat = view.frame.size.height/3
        
        self.mapView.frame = CGRect(x: self.view.center.x - mapWidth, y: topMargin - 250, width: mapWidth, height: mapHeight)
//        let eiffelTower = CLLocationCoordinate2D(latitude: 48.858370, longitude: 2.294481)
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 4.0, altitude: 300, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: eiffelTower)
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        self.mapView.center.x = self.view.center.x
        self.mapView.center.y = self.view.center.y/2
        view.addSubview(self.mapView)
         pickerData = ["Statue of Liberty", "New York", "Golden Gate Bridge", "Central Park NYC", "Googleplex", "Miami Beach", "Laguna Beach", "Griffith Observatory", "Luxor Resort Las Vegas", "Apple HQ", "Berlin Brandenburger Gate", "Hamburg Town Hall", "Cologne Cathedral", "Munich Church", "Neuschwanstein Castle", "Hamburg Philharmonic", "Muenster Castle", "Colosseum", "Piazza Di Trevi", "Sagrada Familia", "Big Ben", "London Eye", "Sydney Opera House", "Eiffel Tower"]
        
        var pickerRect = pickerView.frame
        pickerRect.origin.y = topMargin - 500
        pickerView.frame = pickerRect
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(pickerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        
        let latestLoc: CLLocation = locations[locations.count - 1]
        print("lat, long, horAcc, vertAcc, altitude ", latestLoc.coordinate.latitude, latestLoc.coordinate.longitude, latestLoc.horizontalAccuracy, latestLoc.verticalAccuracy, latestLoc.altitude)
//        latitude.text = String(format: "%.4f",
//                               latestLocation.coordinate.latitude)
//        longitude.text = String(format: "%.4f",
//                                latestLocation.coordinate.longitude)
//        hAccuracy.text = String(format: "%.4f",
//                                latestLocation.horizontalAccuracy)
//        altitude.text = String(format: "%.4f",
//                               latestLocation.altitude)
//        vAccuracy.text = String(format: "%.4f",
//                                latestLocation.verticalAccuracy)
        
//        if startLoc == nil {
//            startLocation = latestLocation
//        }
//
//        let distanceBetween: CLLocationDistance =
//            latestLoc.distance(from: startLocation)
//
        //distance.text = String(format: "%.2f", distanceBetween)
    }
    @objc func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            //self.textBoxButton.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
//
    @objc func mapViewTouched() {
        //self.button.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
       
        switch pickerData[row] {
        case pickerData[0]:
            userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
        case pickerData[1]:
            userInputLoc = FlyoverAwesomePlace.newYork
        case pickerData[2]:
            userInputLoc = FlyoverAwesomePlace.sanFranciscoGoldenGateBridge
        case pickerData[3]:
            userInputLoc = FlyoverAwesomePlace.centralParkNY
        case pickerData[4]:
            userInputLoc = FlyoverAwesomePlace.googlePlex
        case pickerData[5]:
            userInputLoc = FlyoverAwesomePlace.miamiBeach
        case pickerData[6]:
            userInputLoc = FlyoverAwesomePlace.lagunaBeach
        case pickerData[7]:
            userInputLoc = FlyoverAwesomePlace.griffithObservatory
        case pickerData[8]:
            userInputLoc = FlyoverAwesomePlace.luxorResortLasVegas
        case pickerData[9]:
            userInputLoc = FlyoverAwesomePlace.appleHeadquarter
        case pickerData[10]:
            userInputLoc = FlyoverAwesomePlace.berlinBrandenburgerGate
        case pickerData[11]:
            userInputLoc = FlyoverAwesomePlace.hamburgTownHall
        case pickerData[12]:
            userInputLoc = FlyoverAwesomePlace.cologneCathedral
        case pickerData[13]:
            userInputLoc = FlyoverAwesomePlace.munichCurch
        case pickerData[14]:
            userInputLoc = FlyoverAwesomePlace.neuschwansteinCastle
        case pickerData[15]:
            userInputLoc = FlyoverAwesomePlace.hamburgElbPhilharmonic
        case pickerData[16]:
            userInputLoc = FlyoverAwesomePlace.muensterCastle
        case pickerData[17]:
            userInputLoc = FlyoverAwesomePlace.romeColosseum
        case pickerData[18]:
            userInputLoc = FlyoverAwesomePlace.piazzaDiTrevi
        case pickerData[19]:
            userInputLoc = FlyoverAwesomePlace.sagradaFamiliaSpain
        case pickerData[20]:
            userInputLoc = FlyoverAwesomePlace.londonBigBen
        case pickerData[21]:
            userInputLoc = FlyoverAwesomePlace.londonEye
        case pickerData[22]:
            userInputLoc = FlyoverAwesomePlace.sydneyOperaHouse
        case pickerData[23]:
            userInputLoc = FlyoverAwesomePlace.parisEiffelTower
        default:
            userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 4.0, altitude: 500, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: userInputLoc as Flyover)
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        //        self.mapView.isZoomEnabled = true
        //        self.mapView.isScrollEnabled = true
        
        //        self.mapView.center.x = self.view.center.x
        //        self.mapView.center.y = self.view.center.y/2
        view.addSubview(self.mapView)
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

