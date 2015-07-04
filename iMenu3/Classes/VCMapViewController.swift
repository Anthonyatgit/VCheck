//
//  VCMapViewController.swift
//  iMenu3
//
//  Created by Gabriel Anthony on 15/7/3.
//  Copyright (c) 2015年 Siyo Technology Co., Ltd. All rights reserved.
//

import UIKit


class VCMapViewController: VCBaseViewController, BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    var parentNav: UINavigationController?
    
    var longtitude: CLLocationDegrees?
    var latitude: CLLocationDegrees?
    var pinTitle: String?
    
    var mapView: BMKMapView!
    var annotation: BMKPointAnnotation!
    
    var locationService: BMKLocationService!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = VCAppLetor.StringLine.StoreLocation
        
        self.mapView = BMKMapView(frame: CGRectMake(0, 62, self.view.width, self.view.height-62))
        self.view.addSubview(self.mapView)
        
        self.startLocationService()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        self.mapView.showMapScaleBar = true
        
        self.annotation = BMKPointAnnotation()
        
        var pt: CLLocationCoordinate2D = CLLocationCoordinate2D()
        pt.latitude = self.latitude!
        pt.longitude = self.longtitude!
        self.annotation.coordinate = pt
        self.annotation.title = self.pinTitle!
        
        self.mapView.addAnnotation(self.annotation)
        
        
        self.mapView.setCenterCoordinate(pt, animated: true)
        self.mapView.setRegion(BMKCoordinateRegionMakeWithDistance(pt, 3000.0, 3000.0), animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.viewWillAppear()
        self.mapView.delegate = self
        self.locationService.delegate = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.mapView.viewWillDisappear()
        self.mapView.delegate = nil
        self.locationService.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - BMKMapView Delegate
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        
        if self.annotation.isKindOfClass(BMKPointAnnotation.classForCoder()) {
            
            let newAnnotationView: BMKPinAnnotationView = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            newAnnotationView.pinColor = UInt(BMKPinAnnotationColorGreen)
            newAnnotationView.animatesDrop = true
            newAnnotationView.setSelected(true, animated: true)
            return newAnnotationView
        }
        
        return nil
    }
    
    // MARK: - BMKLocationService Delegate
    
    func didUpdateUserHeading(userLocation: BMKUserLocation!) {
        
    }
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        
        self.mapView.updateLocationData(userLocation)
    }
    
    // MARK: - Functions
    func startLocationService() {
        
        BMKLocationService.setLocationDesiredAccuracy(kCLLocationAccuracyBest)
        BMKLocationService.setLocationDistanceFilter(VCAppLetor.ConstValue.LocationServiceDistanceFilter)
        
        self.locationService = BMKLocationService()
        
        self.locationService.startUserLocationService()
        
        self.mapView.userTrackingMode = BMKUserTrackingModeNone
        self.mapView.showsUserLocation = true
    }
    
    
}


