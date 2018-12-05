//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/3/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class MainMapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var touristMap: MKMapView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var textFooterView: UITextField!
    @IBOutlet weak var editButtnOutlet: UIBarButtonItem!
    
    // this index to know the index of the selected annotation
    var indexNumber = 0
    
    // these are the sent(selected) annotation latitude and longitude, that will be send to collectionviewcontroller
    var latitudeSend: Double?
    var LongitudeSend:Double?
    
    // flag for edidt/delete button
    var isEdit = false
    
    // these are the latitude and longitude of the loaded(previous-persistant) annotion
    var latitudePrev: Double?
    var LongitudePrev:Double?
    
    var annotCoord:[AnnotCoord]? = nil
    var region:[Region]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        annotCoord = DataController.fetchAnnot()
        region = DataController.fetchRegion()
        touristMap.delegate = self
        footerView.isHidden = true
        let tap = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress))
        tap.minimumPressDuration = 0.5
        tap.delaysTouchesBegan = true
        touristMap.isUserInteractionEnabled = true
        touristMap.addGestureRecognizer(tap)
        
        addEditButtn()
        loadPreviousAnnAndRegion()
    }

    // edit buttom function Action
    @objc func addTapped() {
        if isEdit == false {
            buttnDone(condition: false)
            isEdit = true
        } else {
            buttnDone(condition: true)
            isEdit = false
        }
    }

    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            let touchLocation = gestureReconizer.location(in: touristMap)
            let locationCoordinate = touristMap.convert(touchLocation,toCoordinateFrom: touristMap)
            let ann = DataController.saveAnnotation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            annotCoord?.append(ann as! AnnotCoord)
            addAnnotationToMap(locationCoord: locationCoordinate)
            if gestureReconizer.state != UIGestureRecognizerState.began {
                return
            }
        }
    }
    
    func addAnnotationToMap(locationCoord: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoord
        self.touristMap.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        DataController.saveRegion(regionLatit: touristMap.region.center.latitude, regionLong: touristMap.region.center.longitude, spanDeltaLat: touristMap.region.span.latitudeDelta, spanDeltaLong: touristMap.region.span.longitudeDelta, date: Date())
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = false
            pin!.animatesDrop = true
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pin!.annotation = annotation
        }
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        touristMap.deselectAnnotation(annotation, animated: true)
        deleteAnnotFromMapAndCoreData(annotation: annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbum" {
            if let controller = segue.destination as? CollectionViewViewController {
                controller.lat = latitudeSend
                controller.long = LongitudeSend
                controller.annotCoordTapped = annotCoord![indexNumber]
            }
        }
    }
}

extension MainMapViewController {
    
    // load saved(persistence) annotations
    func loadPreviousAnnotToMap(annotCoord: [AnnotCoord]){
        annotCoord.map{
            latitudePrev =  $0.value(forKeyPath: "latitude") as? Double
            LongitudePrev = $0.value(forKeyPath: "longitude") as? Double
            let lat = CLLocationDegrees(latitudePrev!)
            let long = CLLocationDegrees(LongitudePrev!)
            let locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            addAnnotationToMap(locationCoord: locationCoordinate)
        }
    }
    // load saved(persistence) Region,user left at
    func loadPreviousRegionToMap(region: [Region]){
        if region.isEmpty == false{
            let center = CLLocationCoordinate2D(latitude: region.last?.value(forKeyPath: "regionLat") as! CLLocationDegrees, longitude: region.last?.value(forKeyPath: "regionLong") as! CLLocationDegrees)
            let span = MKCoordinateSpan(latitudeDelta:    region.last?.value(forKeyPath: "spanDeltaLat") as! CLLocationDegrees, longitudeDelta: region.last?.value(forKeyPath: "spanDeltaLong") as! CLLocationDegrees)
            let regionLast = MKCoordinateRegion(center: center, span: span)
            touristMap.setRegion(regionLast, animated: true)
        }
    }
    
    func deleteAnnotFromMapAndCoreData(annotation: MKAnnotation) {
        latitudeSend = Double(annotation.coordinate.latitude)
        LongitudeSend = Double(annotation.coordinate.longitude)
        if isEdit {
            touristMap.removeAnnotation(annotation)
            annotCoord!.enumerated().filter {$0.element.latitude == latitudeSend && $0.element.longitude == LongitudeSend}.map{
                DataController.deleteAnnotCoord(annotCoord: annotCoord![$0.offset])
                annotCoord?.remove(at: $0.offset)
            }
        } else {
            annotCoord!.enumerated().filter { $0.element.latitude == latitudeSend && $0.element.longitude == LongitudeSend }.map { indexNumber = $0.offset
                self.performSegue(withIdentifier: "ShowAlbum", sender: nil) }
        }
    }
    
    func loadPreviousAnnAndRegion() {
        // here we load the persistant annotion and region
        loadPreviousAnnotToMap(annotCoord: annotCoord!)
        loadPreviousRegionToMap(region: region!)
    }
    
    func buttnDone(condition: Bool){
        footerView.isHidden = condition
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func addEditButtn() {
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addButton
    }
}
