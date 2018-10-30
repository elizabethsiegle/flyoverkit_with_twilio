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

import TwilioVideo
import WebKit
import AVFoundation

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
    
    //twilio video
    var localVideoTrack: TVILocalVideoTrack?
    var remoteView: TVIVideoView?
    var screenCapturer: TVIVideoCapturer?
    var webNavigation: WKNavigation?
    // Set this value to 'true' to use ExampleScreenCapturer instead of TVIScreenCapturer.
    let useExampleCapturer = false
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
        
        setupLocalMedia()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout the remote video using frame based techniques. It's also possible to do this using autolayout
        if ((remoteView?.hasVideoData)!) {
            let dimensions = remoteView?.videoDimensions
            let remoteRect = remoteViewSize()
            let aspect = CGSize(width: CGFloat((dimensions?.width)!), height: CGFloat((dimensions?.height)!))
            let padding : CGFloat = 10.0
            let boundedRect = AVMakeRect(aspectRatio: aspect, insideRect: remoteRect).integral
            remoteView?.frame = CGRect(x: self.view.bounds.width - boundedRect.width - padding,
                                       y: self.view.bounds.height - boundedRect.height - padding,
                                       width: boundedRect.width,
                                       height: boundedRect.height)
        }
        else {
            remoteView?.frame = CGRect.zero
        }
    }
    
    func setupLocalMedia() {
        // Setup screen capturer
        let capturer: TVIVideoCapturer
        if (useExampleCapturer) {
            capturer = ScreenCapturer.init(aView: self.mapView!)
        }
        else {
            capturer = TVIScreenCapturer.init(view: self.mapView!)
        }
        
        localVideoTrack = TVILocalVideoTrack.init(capturer: capturer, enabled: true, constraints: nil, name: "Screen")
        
        if (localVideoTrack == nil) {
            presentError(message: "Failed to add screen capturer track!")
            return;
        }
        
        screenCapturer = capturer;
        
        // Setup rendering
        remoteView = TVIVideoView.init(frame: CGRect.zero, delegate: self)
        localVideoTrack?.addRenderer(remoteView!)
        
        remoteView!.isHidden = true
        self.view.addSubview(self.remoteView!)
        self.view.setNeedsLayout()
    }
    
    func presentError( message: String) {
        print(message)
    }
    
    func remoteViewSize() -> CGRect {
        let traits = self.traitCollection
        let width = traits.horizontalSizeClass == UIUserInterfaceSizeClass.regular ? 188 : 160;
        let height = traits.horizontalSizeClass == UIUserInterfaceSizeClass.regular ? 188 : 120;
        return CGRect(x: 0, y: 0, width: width, height: height)
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
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                switch bestStr {
                case "Statue of Liberty":
                    self.userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
                case "New York":
                    self.userInputLoc = FlyoverAwesomePlace.newYork
                case "Golden Gate bridge":
                    self.userInputLoc = FlyoverAwesomePlace.sanFranciscoGoldenGateBridge
                case "Central park":
                    self.userInputLoc = FlyoverAwesomePlace.centralParkNY
                case "Googolplex":
                    self.userInputLoc = FlyoverAwesomePlace.googlePlex
                case "Miami Beach":
                    self.userInputLoc = FlyoverAwesomePlace.miamiBeach
                case "Laguna Beach":
                    self.userInputLoc = FlyoverAwesomePlace.lagunaBeach
                case "Griffith Observatory":
                    self.userInputLoc = FlyoverAwesomePlace.griffithObservatory
                case "Luxor Resort":
                    self.userInputLoc = FlyoverAwesomePlace.luxorResortLasVegas
                case "Luxury Resort":
                    self.userInputLoc = FlyoverAwesomePlace.luxorResortLasVegas
                case "Apple headquarters":
                    self.userInputLoc = FlyoverAwesomePlace.appleHeadquarter
                case "Apple HQ":
                    self.userInputLoc = FlyoverAwesomePlace.appleHeadquarter
                case "Brandenburger Gate":
                    self.userInputLoc = FlyoverAwesomePlace.berlinBrandenburgerGate
                case "Brandenburg Gate":
                    self.userInputLoc = FlyoverAwesomePlace.berlinBrandenburgerGate
                case "Brandenburg gate":
                    self.userInputLoc = FlyoverAwesomePlace.berlinBrandenburgerGate
                case "Hamburg town hall":
                    self.userInputLoc = FlyoverAwesomePlace.hamburgTownHall
                case "Cologne cathedral":
                    self.userInputLoc = FlyoverAwesomePlace.cologneCathedral
                case "Munich Church":
                    self.userInputLoc = FlyoverAwesomePlace.munichCurch
                case "Neuschwanstein Castle":
                    self.userInputLoc = FlyoverAwesomePlace.neuschwansteinCastle
                case "Hamburg Philharmonic":
                    self.userInputLoc = FlyoverAwesomePlace.hamburgElbPhilharmonic
                case "Hamburger philharmonic":
                    self.userInputLoc = FlyoverAwesomePlace.hamburgElbPhilharmonic
                case "Muenster Castle":
                    self.userInputLoc = FlyoverAwesomePlace.muensterCastle
                case "Colosseum":
                    self.userInputLoc = FlyoverAwesomePlace.romeColosseum
                case "Piazza di Trevi":
                    self.userInputLoc = FlyoverAwesomePlace.piazzaDiTrevi
                case "Sagrada Familia":
                    self.userInputLoc = FlyoverAwesomePlace.sagradaFamiliaSpain
                case "Big Ben":
                    self.userInputLoc = FlyoverAwesomePlace.londonBigBen
                case "London eye":
                    self.userInputLoc = FlyoverAwesomePlace.londonEye
                case "Sydney opera House":
                    self.userInputLoc = FlyoverAwesomePlace.sydneyOperaHouse
                case "Eiffel Tower":
                    self.userInputLoc = FlyoverAwesomePlace.parisEiffelTower
                default:
                    self.userInputLoc = FlyoverAwesomePlace.newYorkStatueOfLiberty
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
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
// MARK: WKNavigationDelegate
extension ViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView:", webView, "finished navigation:", navigation)
        
        self.navigationItem.title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let message = String(format: "WebView:", webView, "did fail navigation:", navigation, error as CVarArg)
        presentError(message: message)
    }
}

// MARK: TVIVideoViewDelegate
extension ViewController : TVIVideoViewDelegate {
    func videoViewDidReceiveData(_ view: TVIVideoView) {
        if (view == remoteView) {
            remoteView?.isHidden = false
            self.view.setNeedsLayout()
        }
    }
    
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}
