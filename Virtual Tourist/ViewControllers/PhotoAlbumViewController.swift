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
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var pin: Pin!
    var fetchedResultController: NSFetchedResultsController<Photo>!
    var savedPhotos = [Photo]()
    let numberOfColumns: CGFloat = 4
    var photoImage: UIImage?
    var currentPage: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        createPinInMapView()
        let savedData = fetchSavedData()
        print(savedData!.count)
        if  savedData != nil && savedData!.count != 0  {
            savedPhotos = savedData!
            reloadColletionView()
        } else {
            downloadNewPhotoAlbum()

        }
        
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
    func fetchSavedData() -> [Photo]?{
        var photosData: [Photo] = []
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "imageUrl", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-Photos")
        fetchedResultController.delegate = self
        
        try? fetchedResultController.performFetch()
        do{
            let photoCount = try fetchedResultController.managedObjectContext.count(for: fetchRequest)
            for index in 0..<photoCount {
                photosData.append(fetchedResultController.object(at: IndexPath(row: index, section: 0)))
            }
            return photosData
        } catch {
            print(error.localizedDescription)
        }
        return nil
        
        
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
        for photo in savedPhotos{
            dataController.viewContext.delete(photo)
        }
        savedPhotos = []
    }
    
    func downloadNewPhotoAlbum(page: Int = 1){
        FlickrClient.getImageCollectionRequest(latitute: pin.latitude, longitude: pin.longitude, page: page) { _, photoAlbum, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard photoAlbum.count > 0 else {
                print("No image could be found.")
                return
            }

            DispatchQueue.main.async{
                
                self.saveToCoreData(photoAlbum: photoAlbum)
                self.reloadColletionView()
                
            }
        }
        
    }
    
    func saveToCoreData(photoAlbum: [SearchRequest.PhotoDetails]){
        for photo in photoAlbum{
            
            let photoData = Photo(context: self.dataController.viewContext)
            photoData.imageUrl = FlickrClient.Endpoints.imageUrl(serverId: photo.server, id: photo.id, secret: photo.secret).stringValue
            photoData.pin = self.pin
            self.savedPhotos.append(photoData)
            
            try? self.dataController.viewContext.save()
            
            
        }
    }
    
    func reloadColletionView(){
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
    }
    
    func createPinInMapView() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
        
    }
    
    func deletePhoto(indexPath: IndexPath){
        
        let photoToDelete = fetchedResultController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        savedPhotos.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    func convertUrlToImage(indexPath: IndexPath) -> UIImage?{
        let photo = savedPhotos[indexPath.row]
        
        if let urlString = photo.imageUrl{
            FlickrClient.getImageUrl(urlString: urlString) { data, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else {
                    print("No data found.")
                    return
                }
                self.photoImage = data
                
            }
        }
        return photoImage
    }
    func downloadImage(){
        
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
        cell.activityIndicator.startAnimating()
        if let photoImage = convertUrlToImage(indexPath: indexPath){
            cell.imageView.image = photoImage
        }
        cell.activityIndicator.stopAnimating()
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let width  = (view.frame.width)/numberOfColumns
        return CGSize(width: width, height: width)
    }
    
    
}
