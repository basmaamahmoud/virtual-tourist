//
//  CollectionViewViewController.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/3/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import MapKit

class CollectionViewViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var lat: Double?
    var long: Double?
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    @IBOutlet weak var newCollectionButtnOutlet: UIButton!
    var annotCoordImages : AnnotCoord!
    var x = 0
    var flag = true
    var arrSelect = [Int] ()
    var arrImagesPerPageAfterDelete = [Int]()
    var finalAlbumImages = [ImageUrls]()
    var ind = [IndexPath]()
   
    
    var numberOfImagesPerPage = 0
    var numberOfImagesAfterDelete = 0
    var flagForDelete = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Activity.shared.startActivityIndicator(view: view)
        newCollectionButtnOutlet.isEnabled = false
        FlickerComponentsCoord.Instance.getComponentsCoordinate(latitude:annotCoordImages.latitude , logitude: annotCoordImages.longitude){(error: String?)in
            DispatchQueue.main.sync {
                
                guard error == nil else{
                    return
                }
                
                for xx in Pin.shared.albumPicturesURL
                {
                    self.addImages(imagesUrls: xx)
                }
                self.finalAlbumImages = self.annotCoordImages.annotation
                self.numberOfImagesPerPage = self.annotCoordImages.annotation.count / 10
                self.numberOfImagesAfterDelete = self.annotCoordImages.annotation.count / 10
                self.albumCollectionView?.reloadData()
                
            }
        }
        
        
        mapView.delegate = self
        let C = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        addAnnotation(locationCoord: C)
        
        
        self.albumCollectionView.delegate = self
        self.albumCollectionView.dataSource = self
        
    }
    func addImages(imagesUrls: String) {
        annotCoordImages.addAlbumPictures(text: imagesUrls)
    }
    
    func addAnnotation(locationCoord: CLLocationCoordinate2D) {
        
        mapView.removeAnnotations(mapView.annotations)
        // zooming the map to my location
        let Location = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!);
        let region = MKCoordinateRegion(center: Location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
        
        self.mapView.setRegion(region, animated: true);
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locationCoord
        
        self.mapView.addAnnotation(annotation)
        
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(annotCoordImages.annotation.count)
        print(numberOfImagesAfterDelete)
        
        if numberOfImagesPerPage == 0{
            return 0
        }else if flagForDelete == true{
            print(numberOfImagesAfterDelete)
            return numberOfImagesAfterDelete
        }else{
            print(numberOfImagesPerPage)
            return numberOfImagesPerPage
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        flagForDelete = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        
        
        let imageURL = URL(string: annotCoordImages.annotation[indexPath.row+x].imageUrltext)
        print(imageURL)
        performUIUpdatesOnMain {
            
            
            if let imageData = try? Data(contentsOf: imageURL!) {
                cell.myImage.image = UIImage(data: imageData)
                
            }
            Activity.shared.stopActivityIndicator()
            self.newCollectionButtnOutlet.isEnabled = true
            self.albumCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
        }
        arrImagesPerPageAfterDelete.append(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = albumCollectionView.cellForItem(at: indexPath)
        
        
        
        
        if arrSelect.contains(indexPath.row) {
            
            cell?.layer.borderWidth = 0
            cell?.layer.borderColor = UIColor.clear.cgColor
            if let index = arrSelect.index(of: indexPath.row) {
                arrSelect.remove(at: index)
            }
            if arrSelect.isEmpty == true{
                newCollectionButtnOutlet.setTitle("New Album Collection", for: .normal)
                flag = true
            }
            
            
        } else {
            
            cell?.layer.borderWidth = 200.0
            cell?.layer.borderColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4).cgColor
            arrSelect.append(indexPath.row)
            
            newCollectionButtnOutlet.setTitle("Delete selected photos", for: .normal)
            flag = false
            
        }
        
        
    }
    func deleteSelectedCells(){
        let indexesToRemove = arrSelect
        numberOfImagesAfterDelete = numberOfImagesAfterDelete-arrSelect.count
        
        for c in arrSelect{
            let indexPathD = IndexPath(row: c, section: 0)
            ind.append(indexPathD)
        }
        finalAlbumImages = finalAlbumImages.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
        annotCoordImages.annotation = annotCoordImages.annotation.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
        
        self.albumCollectionView.deleteItems(at: ind)
       
        arrSelect.removeAll()
        ind.removeAll()
    }
    
    func imagesAfterDelete(){
      let indexesToRemove = arrSelect
       arrImagesPerPageAfterDelete = arrImagesPerPageAfterDelete.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
    }
    
    
    @IBAction func newAlbumCollectionButtn(_ sender: Any) {
        if flag == false{
            flagForDelete = true
            deleteSelectedCells()
            newCollectionButtnOutlet.setTitle("New Album Collection", for: .normal)
            
            flag = true
            
        }
            
        else{
            flagForDelete = false
            imagesAfterDelete()
            if (arrImagesPerPageAfterDelete.max()! + numberOfImagesPerPage) > (numberOfImagesPerPage*10){
               x=1
                
            }else{
                
                x = arrImagesPerPageAfterDelete.max()!+1
                newCollectionButtnOutlet.isEnabled = false
                Activity.shared.startActivityIndicator(view: view)
                
                albumCollectionView.reloadData()
            }
        }
    }
    
    
}
