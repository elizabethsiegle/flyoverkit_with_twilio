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
import Speech

class ViewController: UIViewController, MKMapViewDelegate, SFSpeechRecognizerDelegate {
    
    var userInputLoc = FlyoverAwesomePlace.parisEiffelTower //init
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //other languages
    //generate recognition tasks, return results, handle authorization and configure locales
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var voiceLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization {
            status in
            var buttonState = false
            switch status {
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
            DispatchQueue.main.async {
                self.recordButton.isEnabled = buttonState
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func mapSetUp() {
        let topMargin:CGFloat = view.frame.size.height - 100
        let mapWidth:CGFloat = view.frame.size.width - 40
        let mapHeight:CGFloat = view.frame.size.height/3
        
        self.mapView.frame = CGRect(x: self.view.center.x - mapWidth, y: topMargin - 250, width: mapWidth, height: mapHeight)
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 6.0, altitude: 300, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: self.userInputLoc) //init
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        self.mapView.center.x = self.view.center.x
        self.mapView.center.y = self.view.center.y/2
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            camera.stop()
        })
        self.view.addSubview(self.mapView) //need this or tries to like recalibrate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startRecording() {
        if recognitionTask != nil { //created when request kicked off by the recognizer. used to track progress of a transcription or cancel it
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.record)), mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest() //read from buffer
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Could not create request instance")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) {
            res, err in
            var isLast = false
            if res != nil { //res contains transcription of a chunk of audio, corresponding to a single word usually
                isLast = (res?.isFinal)!
            }
            
            if err != nil || isLast {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                let bestStr = res?.bestTranscription.formattedString
                self.voiceLbl.text = bestStr
                var locDict = [
                    "Statue of Liberty": FlyoverAwesomePlace.newYorkStatueOfLiberty,
                    "New York":FlyoverAwesomePlace.newYork,
                    "Golden Gate bridge": FlyoverAwesomePlace.sanFranciscoGoldenGateBridge,
                    "Central park": FlyoverAwesomePlace.centralParkNY,
                    "Googolplex": FlyoverAwesomePlace.googlePlex,
                    "Miami Beach": FlyoverAwesomePlace.miamiBeach,
                    "Laguna Beach": FlyoverAwesomePlace.lagunaBeach,
                    "Griffith Observatory": FlyoverAwesomePlace.griffithObservatory,
                    "Luxor Resort": FlyoverAwesomePlace.luxorResortLasVegas,
                    "Luxury Resort": FlyoverAwesomePlace.luxorResortLasVegas,
                    "Apple headquarters": FlyoverAwesomePlace.appleHeadquarter,
                    "Apple HQ": FlyoverAwesomePlace.appleHeadquarter,
                    "Brandenburger Gate": FlyoverAwesomePlace.berlinBrandenburgerGate,
                    "Brandenburg Gate": FlyoverAwesomePlace.berlinBrandenburgerGate,
                    "Hamburg town hall": FlyoverAwesomePlace.hamburgTownHall,
                    "Cologne cathedral": FlyoverAwesomePlace.cologneCathedral,
                    "Munich Church":FlyoverAwesomePlace.munichCurch,
                    "Neuschwanstein Castle":FlyoverAwesomePlace.neuschwansteinCastle,
                    "Hamburg Philharmonic":FlyoverAwesomePlace.hamburgElbPhilharmonic,
                    "Hamburger philharmonic":FlyoverAwesomePlace.hamburgElbPhilharmonic,
                    "Muenster Castle":FlyoverAwesomePlace.muensterCastle,
                    "Colosseum":FlyoverAwesomePlace.romeColosseum,
                    "Piazza di Trevi":FlyoverAwesomePlace.piazzaDiTrevi,
                    "Sagrada Familia":FlyoverAwesomePlace.sagradaFamiliaSpain,
                    "Big Ben":FlyoverAwesomePlace.londonBigBen,
                    "London eye":FlyoverAwesomePlace.londonEye,
                    "Sydney opera House":FlyoverAwesomePlace.sydneyOperaHouse,
                    "Eiffel Tower":FlyoverAwesomePlace.parisEiffelTower
                ]
                self.userInputLoc = locDict[bestStr!]! //?? FlyoverAwesomePlace.newYorkStatueOfLiberty] //default
                self.mapSetUp()
                
            }
        }
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) {
            buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Can't start the engine")
        }
        
    }

    @IBAction func recordButtonClicked(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            self.recordButton.setTitle("Record", for: .normal)
        } else {
            startRecording()
            recordButton.setTitle("Stop", for: .normal)
        }
    }
   
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
