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
import ReplayKit

struct TokenUtils {
    static func fetchToken(url : String) throws -> String {
        var token: String = "TWILIO_ACCESS_TOKEN"
        let requestURL: URL = URL(string: url)!
        do {
            let data = try Data(contentsOf: requestURL)
            if let tokenReponse = String.init(data: data, encoding: String.Encoding.utf8) {
                token = tokenReponse
            }
        } catch let error as NSError {
            print ("Invalid token url, error = \(error)")
            throw error
        }
        return token
    }
}

class ViewController: UIViewController, MKMapViewDelegate, RPBroadcastControllerDelegate, SFSpeechRecognizerDelegate, RPScreenRecorderDelegate, TVIRoomDelegate {
    var locDict = [
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
    var userInputLoc = FlyoverAwesomePlace.parisEiffelTower //init
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //other languages
    
    //generate recognition tasks, return results, handle authorization and configure locales
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var recordButton: UIButton!

    @IBOutlet weak var voiceLbl: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var broadcastButton: UIButton!
    // Treat this view as generic, since RPSystemBroadcastPickerView is only available on iOS 12.0 and above.
    @IBOutlet weak var broadcastPickerView: UIView?
    @IBOutlet weak var conferenceButton: UIButton?
    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var settingsButton: UIBarButtonItem?
    
    // Conference state.
    var screenTrack: TVILocalVideoTrack?
    var videoSource: ReplayKitVideoSource?
    var conferenceRoom: TVIRoom?
    
    // Broadcast state. Our extension will capture samples from ReplayKit, and publish them in a Room.
    var broadcastController: RPBroadcastController?
    
    var accessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImN0eSI6InR3aWxpby1mcGE7dj0xIn0.eyJqdGkiOiJTS2ZlYTljNWI4ZDc1MTUzNzc2NmZmOTcwNGE5MmIxZmFlLTE1NDIxNDA1NDQiLCJpc3MiOiJTS2ZlYTljNWI4ZDc1MTUzNzc2NmZmOTcwNGE5MmIxZmFlIiwic3ViIjoiQUNkNzU0NmI5ZWQyMDU1ZmU1NWVlNDIwOWJiMzA0MzU5MSIsImV4cCI6MTU0MjE0NDE0NCwiZ3JhbnRzIjp7ImlkZW50aXR5IjoiTGl6emllJ3MgUGh5c2ljYWwgRGV2aWNlIiwidmlkZW8iOnsicm9vbSI6IkZseW92ZXJLaXQifX19.v1GN-1IJb8_xub2_rctN5x2xw-MKshBUCJEKcyicusk"
    let accessTokenUrl = "http://127.0.0.1:5000/"
    
    static let kBroadcastExtensionBundleId = "com.twilio.ReplayKitExample.BroadcastVideoExtension"
    static let kBroadcastExtensionSetupUiBundleId = "com.twilio.ReplayKitExample.BroadcastVideoExtensionSetupUI"
    
//    static let kStartBroadcastButtonTitle = "Start Broadcast"
//    static let kInProgressBroadcastButtonTitle = "Broadcasting"
//    static let kStopBroadcastButtonTitle = "Stop Broadcast"
//    static let kStartConferenceButtonTitle = "Start Conference"
//    static let kStopConferenceButtonTitle = "Stop Conference"
    static let kRecordingAvailableInfo = "Ready to share the screen in a Broadcast (extension), or Conference (in-app)."
    static let kRecordingNotAvailableInfo = "ReplayKit is not available at the moment. Another app might be recording, or AirPlay may be in use."
    
    // An application has a much higher memory limit than an extension. You may choose to deliver full sized buffers instead.
    static let kDownscaleBuffers = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        // The setter fires an availability changed event, but we check rather than rely on this implementation detail.
        RPScreenRecorder.shared().delegate = self
        checkRecordingAvailability()
        
        NotificationCenter.default.addObserver(forName: UIScreen.capturedDidChangeNotification, object: UIScreen.main, queue: OperationQueue.main) { (notification) in
            if self.broadcastPickerView != nil && self.screenTrack == nil {
                let isCaptured = UIScreen.main.isCaptured
            }
        }
        
        // Use RPSystemBroadcastPickerView when available (iOS 12+ devices).
        if #available(iOS 12.0, *) {
            setupPickerView()
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
        //startbroadcast
        if let controller = self.broadcastController {
            controller.finishBroadcast { [unowned self] error in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.broadcastController = nil
                }
            }
        } else {
            // This extension should be the broadcast upload extension UI, not broadcast update extension
            RPBroadcastActivityViewController.load(withPreferredExtension:ViewController.kBroadcastExtensionSetupUiBundleId) {
                (broadcastActivityViewController, error) in
                if let broadcastActivityViewController = broadcastActivityViewController {
                    broadcastActivityViewController.delegate = self as! RPBroadcastActivityViewControllerDelegate
                    broadcastActivityViewController.modalPresentationStyle = .popover
                    self.present(broadcastActivityViewController, animated: true)
                }
            }
        }
       
    }
    @IBAction func startConference(_ sender: UIButton) {
        sender.isEnabled = false
        if self.screenTrack != nil {
            stopConference(error: nil)
        } else {
            startConference()
        }
    }
    
    @available(iOS 12.0, *)
    func setupPickerView() {
        // Swap the button for an RPSystemBroadcastPickerView.
        #if !targetEnvironment(simulator)
        let pickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0,
                                                                   y: 0,
                                                                   width: view.bounds.width,
                                                                   height: 80))
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.preferredExtension = ViewController.kBroadcastExtensionBundleId

        view.addSubview(pickerView)

        self.broadcastPickerView = pickerView
        #endif
    }
    
    //MARK: RPBroadcastActivityViewControllerDelegate
    func broadcastActivityViewController(_ broadcastActivityViewController: RPBroadcastActivityViewController, didFinishWith broadcastController: RPBroadcastController?, error: Error?) {
        
        DispatchQueue.main.async {
            self.broadcastController = broadcastController
            self.broadcastController?.delegate = self
            self.conferenceButton?.isEnabled = false
            self.infoLabel?.text = ""
            
            broadcastActivityViewController.dismiss(animated: true) {
                self.startBroadcast()
            }
        }
    }
    
    //MARK: RPBroadcastControllerDelegate
    func broadcastController(_ broadcastController: RPBroadcastController, didFinishWithError error: Error?) {
        // Update the button UI.
        DispatchQueue.main.async {
            self.broadcastController = nil
            if let picker = self.broadcastPickerView {
                picker.isHidden = false
                self.broadcastButton.isHidden = false
            } else {
                self.broadcastButton.isEnabled = true
            }
            self.spinner?.stopAnimating()
            
            if let theError = error {
                print("Broadcast did finish with error:", error as Any)
                self.infoLabel?.text = theError.localizedDescription
            } else {
                print("Broadcast did finish.")
            }
        }
    }
    
    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateServiceInfo serviceInfo: [String : NSCoding & NSObjectProtocol]) {
        print("Broadcast did update service info: \(serviceInfo)")
    }
    
    func broadcastController(_ broadcastController: RPBroadcastController, didUpdateBroadcast broadcastURL: URL) {
        print("Broadcast did update URL: \(broadcastURL)")
    }

    
    //MARK: TVIRoomDelegate
    func didConnect(to room: TVIRoom) {
        print("Connected to Room: ", room)
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        stopConference(error: error)
        print("Failed to connect with error: ", error)
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        if let error = error {
            print("Disconnected with error: ", error)
        }
        
        if self.screenTrack != nil {
            stopConference(error: error)
        } else {
            conferenceRoom = nil
        }
    }
    
    //MARK: RPScreenRecorderDelegate
    func screenRecorderDidChangeAvailability(_ screenRecorder: RPScreenRecorder) {
        // Assume we will get an error raised if we are actively broadcasting / capturing and access is "stolen".
        if (self.broadcastController == nil && screenTrack == nil) {
            checkRecordingAvailability()
        }
    }
    
    //MARK: Private
    func checkRecordingAvailability() {
        let isScreenRecordingAvailable = RPScreenRecorder.shared().isAvailable
    }
    
    func startBroadcast() {
        self.broadcastController?.startBroadcast { [unowned self] error in
            DispatchQueue.main.async {
                if let theError = error {
                    print("Broadcast controller failed to start with error:", theError as Any)
                } else {
                    print("Broadcast controller started.")
                    self.spinner.startAnimating()
                }
            }
        }
    }
    
    func stopConference(error: Error?) {
        // Stop recording the screen.
        let recorder = RPScreenRecorder.shared()
        recorder.stopCapture { (captureError) in
            if let error = captureError {
                print("Screen capture stop error: ", error as Any)
            } else {
                print("Screen capture stopped.")
                DispatchQueue.main.async {
                    if let picker = self.broadcastPickerView {
                        picker.isHidden = false
                        self.broadcastButton.isHidden = false
                    } else {
                        self.broadcastButton.isEnabled = true
                    }
                    self.spinner.stopAnimating()
                    
                    self.videoSource = nil
                    self.screenTrack = nil
                    
                    if let userError = error {
                        self.infoLabel?.text = userError.localizedDescription
                    }
                }
            }
        }
        
        if let room = conferenceRoom,
            room.state == TVIRoomState.connected {
            room.disconnect()
        } else {
            conferenceRoom = nil
        }
    }
    
    func startConference() {
        if self.screenTrack != nil {
            stopConference(error: nil)
        } else {
            startConference()
        }
       
        
        // Start recording the screen.
        let recorder = RPScreenRecorder.shared()
        recorder.isMicrophoneEnabled = false
        recorder.isCameraEnabled = false
        
        // Our source produces either downscaled buffers with smoother motion, or an HD screen recording.
        videoSource = ReplayKitVideoSource(isScreencast: !ViewController.kDownscaleBuffers)
        let constraints = TVIVideoConstraints.init { (builder) in
            if (ViewController.kDownscaleBuffers) {
                builder.maxSize = CMVideoDimensions(width: Int32(ReplayKitVideoSource.kDownScaledMaxWidthOrHeight),
                                                    height: Int32(ReplayKitVideoSource.kDownScaledMaxWidthOrHeight))
            } else {
                builder.minSize = CMVideoDimensions(width: Int32(ReplayKitVideoSource.kDownScaledMaxWidthOrHeight + 1),
                                                    height: Int32(ReplayKitVideoSource.kDownScaledMaxWidthOrHeight + 1))
                var screenSize = UIScreen.main.bounds.size
                screenSize.width *= UIScreen.main.nativeScale
                screenSize.height *= UIScreen.main.nativeScale
                builder.maxSize = CMVideoDimensions(width: Int32(screenSize.width),
                                                    height: Int32(screenSize.height))
            }
        }
        screenTrack = TVILocalVideoTrack(capturer: videoSource!,
                                         enabled: true,
                                         constraints: constraints,
                                         name: "Screen")
        
        recorder.startCapture(handler: { (sampleBuffer, type, error) in
            if error != nil {
                print("Capture error: ", error as Any)
                return
            }
            
            switch type {
            case RPSampleBufferType.video:
                self.videoSource?.processVideoSampleBuffer(sampleBuffer)
                break
            case RPSampleBufferType.audioApp:
                break
            case RPSampleBufferType.audioMic:
                // We use `TVIDefaultAudioDevice` to capture and playback audio for conferencing.
                break
            }
            
        }) { (error) in
            if error != nil {
                print("Screen capture error: ", error as Any)
            } else {
                print("Screen capture started.")
            }
        }
    }
    
    func connectToRoom(name: String) {
        // Configure access token either from server or manually.
        // If the default wasn't changed, try fetching from server.
        if (accessToken == "TWILIO_ACCESS_TOKEN" || accessToken.isEmpty) {
            do {
                accessToken = try TokenUtils.fetchToken(url: accessTokenUrl)
            } catch {
                stopConference(error: error)
                return
            }
        }

        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: self.accessToken) { (builder) in

            builder.audioTracks = [TVILocalAudioTrack()!]

            if let videoTrack = self.screenTrack {
                builder.videoTracks = [videoTrack]
            }

            if (!name.isEmpty) {
                builder.roomName = name
            }
        }

        // Connect to the Room using the options we provided.
        conferenceRoom = TwilioVideo.connect(with: connectOptions, delegate: self)
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
                if self.locDict.keys.contains(bestStr!) {
                    self.userInputLoc = FlyoverAwesomePlace.parisEiffelTower
                }
                else {
                    self.userInputLoc = self.locDict[bestStr!]!
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
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}


