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
    var userInputLoc = FlyoverAwesomePlace.parisEiffelTower
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier:"en-us"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    func mapSetUp() {
        let topMargin:CGFloat = view.frame.size.height - 100
        let mapWidth:CGFloat = view.frame.size.width - 40
        let mapHeight:CGFloat = view.frame.size.height/3
        
        self.mapView.frame = CGRect(x: self.view.center.x - mapWidth, y: topMargin - 250, width: mapWidth, height: mapHeight)
        
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        self.mapView.center.x = self.view.center.x
        self.mapView.center.y = self.view.center.y/2
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 6.0, altitude: 300, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: self.userInputLoc) //init
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(9), execute: {
            camera.stop()
        })
        
        self.view.addSubview(self.mapView)
    }
    
    let locDict = [
        "Statue of Liberty": FlyoverAwesomePlace.newYorkStatueOfLiberty,
        "New York": FlyoverAwesomePlace.newYork,
        "Golden Gate Bridge": FlyoverAwesomePlace.sanFranciscoGoldenGateBridge,
        "Central Park": FlyoverAwesomePlace.centralParkNY,
        "Googleplex": FlyoverAwesomePlace.googlePlex,
        "Miami Beach": FlyoverAwesomePlace.miamiBeach,
        "Laguna Beach": FlyoverAwesomePlace.lagunaBeach,
        "Griffith Observatory":FlyoverAwesomePlace.griffithObservatory,
        "Luxor Resort": FlyoverAwesomePlace.luxorResortLasVegas,
        "Apple HQ": FlyoverAwesomePlace.appleHeadquarter,
        "Brandenburger Gate": FlyoverAwesomePlace.berlinBrandenburgerGate,
        "Hamburg Town Hall": FlyoverAwesomePlace.hamburgTownHall,
        "Cologne Cathedral": FlyoverAwesomePlace.cologneCathedral,
        "Munich Church": FlyoverAwesomePlace.munichCurch,
        "Neuschwanstein Castle": FlyoverAwesomePlace.neuschwansteinCastle,
        "Hamburg Philharmonic": FlyoverAwesomePlace.hamburgElbPhilharmonic,
        "Muenster Castle": FlyoverAwesomePlace.muensterCastle,
        "Rome Colosseum": FlyoverAwesomePlace.romeColosseum,
        "Piazza di Trevi": FlyoverAwesomePlace.piazzaDiTrevi,
        "Sagrada Familia": FlyoverAwesomePlace.sagradaFamiliaSpain,
        "Big Ben": FlyoverAwesomePlace.londonBigBen,
        "London Eye": FlyoverAwesomePlace.londonEye,
        "Sydney Opera House": FlyoverAwesomePlace.sydneyOperaHouse,
        "Eiffel Tower": FlyoverAwesomePlace.parisEiffelTower
    ]
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
                self.locButton.isEnabled = buttonState
            }
        }
        self.placeLbl.frame.size.width = view.bounds.width - 64
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
                
                self.locButton.isEnabled = true
                let bestStr = res?.bestTranscription.formattedString
                var inDict = self.locDict.contains { $0.key == bestStr}
                
                if inDict {
                    self.placeLbl.text = bestStr
                    self.userInputLoc = self.locDict[bestStr!]!
                }
                else {
                    self.placeLbl.text = "can't find it in the dictionary"
                    self.userInputLoc = FlyoverAwesomePlace.centralParkNY
                }
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
    
    
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var locButton: UIButton!
    @IBAction func locButtonClicked(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            locButton.isEnabled = false
            self.locButton.setTitle("Record", for: .normal)
        } else {
            startRecording()
            locButton.setTitle("Stop", for: .normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

