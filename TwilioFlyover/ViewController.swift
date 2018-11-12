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

class ViewController: UIViewController, MKMapViewDelegate {
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
        
        self.view.addSubview(self.mapView)
    }
    
    let locDict = [
            FlyoverAwesomePlace.newYorkStatueOfLiberty : "Statue of Liberty",
            FlyoverAwesomePlace.newYork : "New York",
            FlyoverAwesomePlace.sanFranciscoGoldenGateBridge : "Golden Gate Bridge",
            FlyoverAwesomePlace.centralParkNY : "Central Park",
            FlyoverAwesomePlace.googlePlex: "Googleplex",
            FlyoverAwesomePlace.miamiBeach: "Miami Beach",
            FlyoverAwesomePlace.lagunaBeach: "Laguna Beach",
            FlyoverAwesomePlace.griffithObservatory: "Griffith Observatory",
            FlyoverAwesomePlace.luxorResortLasVegas : "Luxor Resort",
            FlyoverAwesomePlace.appleHeadquarter : "Apple HQ",
            FlyoverAwesomePlace.berlinBrandenburgerGate : "Brandenburger Gate",
            FlyoverAwesomePlace.hamburgTownHall : "Hamburg Town Hall",
            FlyoverAwesomePlace.cologneCathedral : "Cologne Cathedral",
            FlyoverAwesomePlace.munichCurch : "Munich Church",
            FlyoverAwesomePlace.neuschwansteinCastle : "Neuschwanstein Castle",
            FlyoverAwesomePlace.hamburgElbPhilharmonic : "Hamburg Philharmonic",
            FlyoverAwesomePlace.muensterCastle: "Muenster Castle",
            FlyoverAwesomePlace.romeColosseum : "Rome Colosseum",
            FlyoverAwesomePlace.piazzaDiTrevi : "Piazza di Trevi",
            FlyoverAwesomePlace.sagradaFamiliaSpain: "Sagrada Familia",
            FlyoverAwesomePlace.londonBigBen: "Big Ben",
            FlyoverAwesomePlace.londonEye: "London Eye",
            FlyoverAwesomePlace.sydneyOperaHouse: "Sydney Opera House",
            FlyoverAwesomePlace.parisEiffelTower: "Eiffel Tower"
        ]
    
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func locButtonClicked(_ sender: Any) {
        let rand = locDict.randomElement()
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 6.0, altitude: 300, pitch: 45.0, headingStep: 40.0))
        camera.start(flyover: rand?.key as! Flyover)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            camera.stop()
        })
        placeLbl.text = "\(rand!.value)"
    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeLbl.textAlignment = .center
        placeLbl.center.x = self.view.center.x           
        self.mapSetUp()
    }
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}
