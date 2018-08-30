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

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let leftMargin:CGFloat = view.frame.size.width-20
        let topMargin:CGFloat = view.frame.size.height-20
        let mapWidth:CGFloat = view.frame.size.width-20
        let mapHeight:CGFloat = view.frame.size.height/1.5
        
        self.mapView.frame = CGRect(x: leftMargin, y: topMargin, width: mapWidth, height: mapHeight)
        let eiffelTower = CLLocationCoordinate2D(latitude: 48.858370, longitude: 2.294481)
        let camera = FlyoverCamera(mapView: self.mapView, configuration: FlyoverCamera.Configuration(duration: 4.0, altitude: 300, pitch: 45.0, headingStep: 20.0))
        camera.start(flyover: eiffelTower)
        self.mapView.mapType = .hybridFlyover
        self.mapView.showsBuildings = true
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        
        // Or, if needed, we can position map in the center of the view
        self.mapView.center = view.center
        view.addSubview(self.mapView)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    @objc func mapViewLongPressed(sender: UILongPressGestureRecognizer) {
//        if sender.state == .began {
//            self.button.isHidden = false
//            UIView.animate(withDuration: 0.3) {
//                self.view.layoutIfNeeded()
//            }
//        }
//    }
//
//    @objc func mapViewTouched() {
//        self.button.isHidden = true
//        UIView.animate(withDuration: 0.3) {
//            self.view.layoutIfNeeded()
//        }
//    }
}

