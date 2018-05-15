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

class MainMapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var touristMap: MKMapView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var textFooterView: UITextField!
    @IBOutlet weak var editButtnOutlet: UIBarButtonItem!
    
    
    var flag = 0
    var indexNumber = 0
  //  var AnnStorage = [AnnotationCoord]()
    var latitudeSend: Double?
    var LongitudeSend:Double?
    var isEdit = false
    
    var annots: [AnnotCoord] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        touristMap.delegate = self
        footerView.isHidden = true
        
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        
        let tap = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress))
        tap.minimumPressDuration = 0.5
        tap.delaysTouchesBegan = true
        touristMap.isUserInteractionEnabled = true
        touristMap.addGestureRecognizer(tap)
    }
    
    
    // edit buttom function Action
    @objc func addTapped() {
        print("Done")
        if isEdit == false {
            footerView.isHidden = false
            let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addTapped))
            self.navigationItem.rightBarButtonItem = addButton
            isEdit = true
        } else {
            footerView.isHidden = true
            let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addTapped))
            self.navigationItem.rightBarButtonItem = addButton
            isEdit = false
        }
        
    }
    
    func addAnnCoord(latitude: Double, longitude: Double){
        let ann = AnnotCoord(latitude: latitude, longitude: longitude)
        annots.append(ann)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            
            let touchLocation = gestureReconizer.location(in: touristMap)
            let locationCoordinate = touristMap.convert(touchLocation,toCoordinateFrom: touristMap)
            //print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            
           // saveAnn(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, id: 1)
            addAnnCoord(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            
            addAnnotationToMap(locationCoord: locationCoordinate)
            
            if gestureReconizer.state != UIGestureRecognizerState.began {
                return
            }
        }
    }
    
//    func saveAnn(latitude: Double, longitude: Double, id: Double){
//
//        let ann = AnnotationCoord.init(latitude: latitude, Longitude: longitude)
//        AnnStorage.append(ann)
//
//    }
    
    func addAnnotationToMap(locationCoord: CLLocationCoordinate2D) {
        
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoord
        
        self.touristMap.addAnnotation(annotation)
        
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
        
        latitudeSend = Double(annotation.coordinate.latitude)
        LongitudeSend = Double(annotation.coordinate.longitude)
        
        
        if isEdit == true{
            touristMap.removeAnnotation(annotation)
            var i=0
            for x in annots{
                if x.latitude == latitudeSend && x.longitude == LongitudeSend{
                    annots.remove(at: i)
                }
                i = i+1
            
            }
        }
        else{
            var i=0
            for x in annots{
                if x.latitude == latitudeSend && x.longitude == LongitudeSend{
                    indexNumber = i
                    self.performSegue(withIdentifier: "ShowAlbum", sender: nil)
                }
                i = i+1
                
            }
            
            
//            FlickerComponentsCoord.Instance.getComponentsCoordinate(latitude:latitudeSend! , logitude: LongitudeSend!){(error: String?)in
//                DispatchQueue.main.sync {
//
//                guard error == nil else{
//                    return
//                }
//               // Activity.shared.stopActivityIndicator()
//                print(Pin.shared.albumPicturesURL.count)
//
//                }
//            }
          
        }
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbum" {
            if let controller = segue.destination as? CollectionViewViewController {
                controller.lat = latitudeSend
                controller.long = LongitudeSend
                controller.annotCoordImages = annots[indexNumber]
                print(indexNumber)
                print(annots[indexNumber])
                
            }
        }
    }
    
    
    
}
