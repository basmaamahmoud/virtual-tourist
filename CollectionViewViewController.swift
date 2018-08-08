//
//  CollectionViewViewController.swift
//  Virtual Tourist
//
//  Created by Basma Ahmed Mohamed Mahmoud on 4/3/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CollectionViewViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var lat: Double?
    var long: Double?
    var annotCoordTapped : AnnotCoord!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButtnOutlet: UIButton!
    
    
    
    var imageUrls: [ImageUrl]? = []
    var newPhotoImages: [ImageUrl]? = []
    var finalAlbumImages: [ImageUrl]? = nil
    var deleteArray: [ImageUrl]? = []
    var saveImageData: [Data]? = []
    
    
    
    // flag to check if buuton in deleting option or not
    var flag = true
    
    var storeFlag = false
    
    var arrSelect = [Int] ()
    var arrImagesPerPageAfterDelete = [Int]()
    var ind = [IndexPath]()
    
    
    var numberOfImagesPerPage = 0
    var numberOfImagesAfterDelete = 0
    var flagForDelete = false
    
    
    var dataController:DataController!
    
    override func viewDidDisappear(_ animated: Bool) {
        imageUrls?.removeAll()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here if i want to delete all data in coredata
        // DataControllerCollectionView.deleteAllData()
        
        let context = DataControllerCollectionView.getContext()
        let fetchRequest: NSFetchRequest<ImageUrl> = ImageUrl.fetchRequest()
        let predicate = NSPredicate(format:"anootCoordR == %@", self.annotCoordTapped!)
        fetchRequest.predicate = predicate
        imageUrls = try! context.fetch(fetchRequest)
        print(imageUrls)
        
        Activity.shared.startActivityIndicator(view: view)
        
        newCollectionButtnOutlet.isEnabled = false
        
        
        if imageUrls?.count == 0{
            getPinPhotos()
            
        }else{
            print(self.imageUrls?.count)
            storeFlag = true
            self.finalAlbumImages = self.imageUrls
            self.numberOfImagesPerPage = (self.imageUrls?.count)!
            self.numberOfImagesAfterDelete = (self.imageUrls?.count)!
        }
        
        mapView.delegate = self
        self.albumCollectionView.delegate = self
        self.albumCollectionView.dataSource = self
        
        
        let C = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        addAnnotation(locationCoord: C)
    }
    
    
    
    
    func getPinPhotos(){
        var checKK = true
        FlickerComponentsCoord.Instance.getComponentsCoordinate(latitude:annotCoordTapped.latitude , logitude: annotCoordTapped.longitude){(error: String?)in
            DispatchQueue.main.sync {
                
                guard error == nil else{
                    // handel error
                    if error == "Connection Error"{
                        Activity.shared.stopActivityIndicator()
                        
                        self.alertTheUser(title: "Connection Error", message: "Please check your internet connection")
                    } else if error == "Cant download Students data" {
                        Activity.shared.stopActivityIndicator()
                        self.alertTheUser(title: "Cant download Pictures", message: "Problem in downloading")
                    }
                    
                    return
                }
                
                
                for xx in Pin.shared.albumPicturesURL
                {
                    
                    let im = DataControllerCollectionView.saveImageUrls(imageUrl: xx)
                    self.imageUrls?.append(im as! ImageUrl)
                    
                    
                    if checKK == true{
                        self.annotCoordTapped.setValue(NSSet(object: im), forKey: "imageUrlsR")
                        try? self.annotCoordTapped.managedObjectContext?.save()
                        
                        checKK = false
                    }else{
                        let images = self.annotCoordTapped.mutableSetValue(forKey: "imageUrlsR")
                        images.add(im)
                    }
                    
                }
                
                self.finalAlbumImages = self.imageUrls
                
                self.numberOfImagesPerPage = (self.imageUrls?.count)!
                
                self.numberOfImagesAfterDelete = (self.imageUrls?.count)!
                self.albumCollectionView?.reloadData()
                
            }
        }
    }
    
    
    func addAnnotation(locationCoord: CLLocationCoordinate2D) {
        
        mapView.removeAnnotations(mapView.annotations)
        // zooming the map to my location
        let Location = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.long!);
        let region = MKCoordinateRegion(center: Location, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2));
        
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
        
        if numberOfImagesPerPage == 0{
            return 0
        }else if flagForDelete == true{
            // return number of images after delete
            return numberOfImagesAfterDelete
        }else{
            //return number of images
            return numberOfImagesPerPage
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        flagForDelete = false
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        
        cell.myImage.image = UIImage(named: "placeholder.png")
        cell.cellActivityIndicator.startAnimating()
        
        if self.storeFlag == false{
            let imageURL = URL(string:  imageUrls![indexPath.row].imageUrlText!)
          
            DispatchQueue.global().async {
                // here if the annotation is new and we have loaded a new set of images
                if let imageData = try? Data(contentsOf: imageURL!) {
                    self.saveImageData?.append(imageData)
                    performUIUpdatesOnMain {
                        cell.myImage.image = UIImage(data: imageData)
                        Activity.shared.stopActivityIndicator()
                        cell.cellActivityIndicator.stopAnimating()
                        cell.cellActivityIndicator.isHidden = true
                        self.newCollectionButtnOutlet.isEnabled = true
                        self.albumCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
                    }
                    
                    
                }
                // here after loading the new set of images we store them as images in coredata
                if self.saveImageData?.count == self.imageUrls?.count {
                    var checKK = true
                    for x in self.saveImageData!{
                        let im = DataControllerCollectionView.saveImage(actualimage: x)
                        
                        if checKK == true{
                            self.annotCoordTapped.setValue(NSSet(object: im), forKey: "imageUrlsR")
                            try? self.annotCoordTapped.managedObjectContext?.save()
                            checKK = false
                        }else{
                            let imagess = self.annotCoordTapped.mutableSetValue(forKey: "imageUrlsR")
                            imagess.add(im)
                            print(imagess.count)
                        }
                    }
                }
            }
            
        }else{
            // here er are using the stored images from coredata
            performUIUpdatesOnMain {
                if let imageData = self.imageUrls![indexPath.row].actualImage{
                cell.myImage.image = UIImage(data: imageData)
                }
                Activity.shared.stopActivityIndicator()
                cell.cellActivityIndicator.stopAnimating()
                cell.cellActivityIndicator.isHidden = true
                self.newCollectionButtnOutlet.isEnabled = true
                self.albumCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
                
            }
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
        finalAlbumImages = finalAlbumImages?.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
        imageUrls = imageUrls?.enumerated().filter { !indexesToRemove.contains($0.offset) }.map { $0.element }
        
        self.albumCollectionView.deleteItems(at: ind)
        
        
        let context = DataControllerCollectionView.getContext()
        
        let fetchRequest: NSFetchRequest<ImageUrl> = ImageUrl.fetchRequest()
        
        let predicate = NSPredicate(format:"anootCoordR == %@", self.annotCoordTapped!)
        
        fetchRequest.predicate = predicate
        
        deleteArray = try! context.fetch(fetchRequest)
        
        var ii = 0
        for object in deleteArray! {
            
            if indexesToRemove.contains(ii){
                
                context.delete(object)
                
            }
            ii = ii + 1
        }
        try! context.save()
        deleteArray = try! context.fetch(fetchRequest)
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
            newPhotoImages?.removeAll()
            
            
            let context = DataControllerCollectionView.getContext()
            
            let fetchRequest: NSFetchRequest<ImageUrl> = ImageUrl.fetchRequest()
            
            let predicate = NSPredicate(format:"anootCoordR == %@", self.annotCoordTapped!)
            
            fetchRequest.predicate = predicate
            
            deleteArray = try! context.fetch(fetchRequest)
            
            
            for object in deleteArray! {
                
                context.delete(object)
                
            }
            try! context.save()
            
            storeFlag = false
            flagForDelete = false
            Activity.shared.startActivityIndicator(view:view)
            
            self.finalAlbumImages = newPhotoImages
            self.numberOfImagesPerPage = 0
            self.numberOfImagesAfterDelete = 0
            self.albumCollectionView?.reloadData()
            
            
            
            var checKK = true
            FlickerComponentsCoord.Instance.getComponentsCoordinate(latitude:annotCoordTapped.latitude , logitude: annotCoordTapped.longitude){(error: String?)in
                DispatchQueue.main.sync {
                    
                    guard error == nil else{
                        // handel error
                        if error == "Connection Error"{
                            Activity.shared.stopActivityIndicator()
                            self.alertTheUser(title: "Connection Error", message: "Please check your internet connection")
                        } else if error == "Cant download Students data" {
                            Activity.shared.stopActivityIndicator()
                            self.alertTheUser(title: "Cant download Pictures", message: "Problem in downloading")
                        }else if error == "There is no Pictures" {
                            Activity.shared.stopActivityIndicator()
                            self.alertTheUser(title: "There is no Pictures at this place", message: "please choose another place mark")
                        }
                        
                        return
                    }
                    
                    for xx in Pin.shared.albumPicturesURL
                    {
                        
                        let im = DataControllerCollectionView.saveImageUrls(imageUrl: xx)
                        self.newPhotoImages?.append(im as! ImageUrl)
                        let images = self.annotCoordTapped.mutableSetValue(forKey: "imageUrlsR")
                        images.add(im)
                        
                    }
                    
                    self.imageUrls?.removeAll()
                    self.imageUrls = self.newPhotoImages
                    self.finalAlbumImages = self.newPhotoImages
                    self.numberOfImagesPerPage = (self.newPhotoImages?.count)!
                    self.numberOfImagesAfterDelete = (self.newPhotoImages?.count)!
                    self.albumCollectionView?.reloadData()
                    
                    
                }
            }
            
        }
    }
    
    
    private func alertTheUser(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

