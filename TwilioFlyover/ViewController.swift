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
    var locArr = [
        FlyoverAwesomePlace.newYorkStatueOfLiberty,
        FlyoverAwesomePlace.newYork,
        FlyoverAwesomePlace.sanFranciscoGoldenGateBridge,
        FlyoverAwesomePlace.centralParkNY,
        FlyoverAwesomePlace.googlePlex,
        FlyoverAwesomePlace.miamiBeach,
        FlyoverAwesomePlace.lagunaBeach,
        FlyoverAwesomePlace.griffithObservatory,
        FlyoverAwesomePlace.luxorResortLasVegas,
        FlyoverAwesomePlace.appleHeadquarter,
        FlyoverAwesomePlace.berlinBrandenburgerGate,
        FlyoverAwesomePlace.hamburgTownHall,
        FlyoverAwesomePlace.cologneCathedral,
        FlyoverAwesomePlace.munichCurch,
        FlyoverAwesomePlace.neuschwansteinCastle,
        FlyoverAwesomePlace.hamburgElbPhilharmonic,
        FlyoverAwesomePlace.muensterCastle,
        FlyoverAwesomePlace.romeColosseum,
        FlyoverAwesomePlace.piazzaDiTrevi,
        FlyoverAwesomePlace.sagradaFamiliaSpain,
        FlyoverAwesomePlace.londonBigBen,
        FlyoverAwesomePlace.londonEye,
        FlyoverAwesomePlace.sydneyOperaHouse,
        FlyoverAwesomePlace.parisEiffelTower
    ]
    
    @IBOutlet weak var voiceLbl: UILabel!
    

    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func locButtonClicked(_ sender: Any) {
        self.userInputLoc = locArr.randomElement()!
        voiceLbl.text = "\(self.userInputLoc)"
        self.mapSetUp()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        voiceLbl.center.x = self.view.center.x
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func mapSetUp() {
        let topMargin:CGFloat = view.frame.size.height - 100
        let mapWidth:CGFloat = view.frame.size.width - 40
        let mapHeight:CGFloat = view.frame.size.height/3
        
        self.mapView.frame = CGRect(x: self.view.center.x - mapWidth, y: topMargin - 250, width: mapWidth, height: mapHeight)
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 6.0, altitude: 300, pitch: 45.0, headingStep: 40.0))
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
