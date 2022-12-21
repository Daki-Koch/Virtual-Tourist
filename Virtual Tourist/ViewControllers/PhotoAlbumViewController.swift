//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by David Koch on 17.12.22.
//

import Foundation
import UIKit
import CoreData
import MapKit


class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate{
    
    
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var pin: Pin!
    var fetchedResultController: NSFetchedResultsController<Photo>!
    
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.delegate = self
        setMapView()
        fetchSavedData()
        downloadNewPhotoAlbum()
        
        
    }
    
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        clearCoreData()
        let newPage = Int.random(in: 1...fetchPages())
        downloadNewPhotoAlbum(page: newPage)

    }
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    // MARK: - Intital configuration
    func fetchSavedData(){
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "imageUrl", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-Photos")
        fetchedResultController.delegate = self
        
        try? fetchedResultController.performFetch()
        
        
    }
    
    func fetchPages() -> Int {
        FlickrClient.getImageCollectionRequest(latitute: pin.latitude, longitude: pin.longitude, page: 1) { albumDetails, _, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let albumDetails = albumDetails else{
                print("No album details could be found.")
                return
            }
            self.currentPage = albumDetails.pages
        }
        return currentPage
    }
    
    func clearCoreData(){
        for photo in fetchedResultController.fetchedObjects!{
            dataController.viewContext.delete(photo)
        }

    }
    
    func downloadNewPhotoAlbum(page: Int = 1){
        if fetchedResultController.fetchedObjects?.count != 0{
            self.collectionView.reloadData()
            return
        } else {
            FlickrClient.getImageCollectionRequest(latitute: pin.latitude, longitude: pin.longitude, page: page) { _, photoAlbum, error in
                if let error = error {
                    self.showFailure(message: error.localizedDescription, title: "Error")
                    return
                }
                guard photoAlbum.count > 0 else {
                    self.showFailure(message: "No photo album was found", title: "No Data")
                    return
                }
                
                self.saveToCoreData(photoAlbum: photoAlbum)
            }
        }
        
    }
    
    func saveToCoreData(photoAlbum: [SearchRequest.PhotoDetails]){
        for photo in photoAlbum{
            
            let photoData = Photo(context: self.dataController.viewContext)
            photoData.imageUrl = FlickrClient.Endpoints.imageUrl(serverId: photo.server, id: photo.id, secret: photo.secret).stringValue
            photoData.pin = self.pin
            
            try? self.dataController.viewContext.save()
            
        }
        self.collectionView.reloadData()
    }
    

    
    func deletePhoto(indexPath: IndexPath){
        
        let photoToDelete = fetchedResultController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
        self.collectionView.reloadData()
    }
    
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // MARK: - Collection View data source.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delete photo from collectionView and from data store.
        
        showAlert(message: "Are you sure you want to delete this item?", title: "") { action in
            if action.title == "Delete"{
                self.deletePhoto(indexPath: indexPath)
            }
            if action.title == "Cancel"{
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of photos in the flickr album
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        if let imageData = fetchedResultController.object(at: indexPath).image{
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: imageData)!
            }
            
        } else {
            cell.activityIndicator.startAnimating()
            if let imageUrl = fetchedResultController.object(at: indexPath).imageUrl{
                FlickrClient.getImageUrl(urlString: imageUrl) { data, error in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    guard let data = data else{
                        print("No data could be found.")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        cell.activityIndicator.stopAnimating()
                        cell.imageView.image = UIImage(data: data)
                    }
                    
                    self.fetchedResultController.object(at: indexPath).image = data
                    try? self.dataController.viewContext.save()
                }
            }
            
            
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space:CGFloat = 3.0
        
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        return CGSize(width: dimension, height: dimension)
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 3
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView.numberOfItems(inSection: section) == 1 {
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width)
            
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    
    
    func setMapView() {
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.setCenter(center, animated: true)
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        mapView.setRegion(myRegion, animated: true)
        let annotation: MKPointAnnotation = MKPointAnnotation()
        annotation.coordinate = center
        mapView.addAnnotation(annotation)
        
    }
}

