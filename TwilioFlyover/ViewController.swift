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
import Speech

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, SFSpeechRecognizerDelegate {
    
    var userInputLoc = FlyoverAwesomePlace.parisEiffelTower
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ru"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngene = AVAudioEngine()
    
//    static func iterate() -> AnyIterator<FlyoverAwesomePlace> {
//        return FlyoverAwesomePlace
//    }

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager = CLLocationManager()
    var startLoc: CLLocation!
    
    @IBOutlet weak var recordButton: UIButton!

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
        camera.start(flyover: userInputLoc)
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        self.mapView.center.x = self.view.center.x
        self.mapView.center.y = self.view.center.y/2
        view.addSubview(self.mapView)
        recordButton.isEnabled = false // 1
        
        speechRecognizer?.delegate = self // 2
        
        SFSpeechRecognizer.requestAuthorization { // 3
            status in
            var buttonState = false // 4
            switch status { // 5
            case .authorized:
                buttonState = true
                print("Permission received")
            case .denied:
                buttonState = false
                print("User did not give permission to use speech recognition")
            case .notDetermined:
                buttonState = false
                print("Speech recognition not allowed by user")
            case .restricted:
                buttonState = false
                print("Speech recognition not supported on this device")
            }
            
            DispatchQueue.main.async { // 6
                self.recordButton.isEnabled = buttonState // 7
            }
            
            
        }
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
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        case pickerData[0]:
//            userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
//        case pickerData[1]:
//            userInputLoc = FlyoverAwesomePlace.newYork
//        case pickerData[2]:
//            userInputLoc = FlyoverAwesomePlace.sanFranciscoGoldenGateBridge
//        case pickerData[3]:
//            userInputLoc = FlyoverAwesomePlace.centralParkNY
//        case pickerData[4]:
//            userInputLoc = FlyoverAwesomePlace.googlePlex
//        case pickerData[5]:
//            userInputLoc = FlyoverAwesomePlace.miamiBeach
//        case pickerData[6]:
//            userInputLoc = FlyoverAwesomePlace.lagunaBeach
//        case pickerData[7]:
//            userInputLoc = FlyoverAwesomePlace.griffithObservatory
//        case pickerData[8]:
//            userInputLoc = FlyoverAwesomePlace.luxorResortLasVegas
//        case pickerData[9]:
//            userInputLoc = FlyoverAwesomePlace.appleHeadquarter
//        case pickerData[10]:
//            userInputLoc = FlyoverAwesomePlace.berlinBrandenburgerGate
//        case pickerData[11]:
//            userInputLoc = FlyoverAwesomePlace.hamburgTownHall
//        case pickerData[12]:
//            userInputLoc = FlyoverAwesomePlace.cologneCathedral
//        case pickerData[13]:
//            userInputLoc = FlyoverAwesomePlace.munichCurch
//        case pickerData[14]:
//            userInputLoc = FlyoverAwesomePlace.neuschwansteinCastle
//        case pickerData[15]:
//            userInputLoc = FlyoverAwesomePlace.hamburgElbPhilharmonic
//        case pickerData[16]:
//            userInputLoc = FlyoverAwesomePlace.muensterCastle
//        case pickerData[17]:
//            userInputLoc = FlyoverAwesomePlace.romeColosseum
//        case pickerData[18]:
//            userInputLoc = FlyoverAwesomePlace.piazzaDiTrevi
//        case pickerData[19]:
//            userInputLoc = FlyoverAwesomePlace.sagradaFamiliaSpain
//        case pickerData[20]:
//            userInputLoc = FlyoverAwesomePlace.londonBigBen
//        case pickerData[21]:
//            userInputLoc = FlyoverAwesomePlace.londonEye
//        case pickerData[22]:
//            userInputLoc = FlyoverAwesomePlace.sydneyOperaHouse
//        case pickerData[23]:
//            userInputLoc = FlyoverAwesomePlace.parisEiffelTower
//        default:
//            userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
//        }
//    }
//
    @IBAction func recordButtonClicked(_ sender: Any) {
        if audioEngene.isRunning {
            audioEngene.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start recording", for: .normal)
        } else {
            startRecording()
            recordButton.setTitle("Stop recording", for: .normal)
        }
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 4.0, altitude: 500, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: userInputLoc as Flyover)
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
                self.mapView.isZoomEnabled = true
                self.mapView.isScrollEnabled = true
        
                self.mapView.center.x = self.view.center.x
                self.mapView.center.y = self.view.center.y/2
        view.addSubview(self.mapView)
    }
    func startRecording() {
        
        if recognitionTask != nil {  // 1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance() // 2
        
        do { // 3
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() // 4
        
        let inputNode = audioEngene.inputNode
        
        guard let recognitionRequest = recognitionRequest else { // 6
            fatalError("Could not create request instance")
        }
        
        recognitionRequest.shouldReportPartialResults = true // 7
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { // 8
            result, error in
            var isFinal = false // 9
            if result != nil { // 10
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal { // 11
                self.audioEngene.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0) // 12
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { // 13
            buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngene.prepare() //14
        
        do {  // 15
            try audioEngene.start()
        } catch {
            print("Can't start the engine")
        }
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }

}

