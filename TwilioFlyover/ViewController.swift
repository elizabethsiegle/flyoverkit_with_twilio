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
        self.mapSetUp()
    }
    
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    @IBAction func locButtonClicked(_ sender: Any) {
        let rand = locDict.randomElement()
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 6.0, altitude: 300, pitch: 45.0, headingStep: 40.0))
        camera.start(flyover: rand!.value as FlyoverAwesomePlace)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(6), execute: {
            camera.stop()
        })
        placeLbl.text = "\(rand!.key)"
        placeLbl.textAlignment = .center
        placeLbl.center.x = self.view.center.x
        placeLbl.sizeToFit()
    }
   
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
}
