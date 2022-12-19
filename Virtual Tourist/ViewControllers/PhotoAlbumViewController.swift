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


class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var pin: Pin!
    var fetchedResultController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        
        setupFetchResultsController()
        downloadPhotoAlbum()
        createPinInMapView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delete photo from collectionView and from data store.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of photos in the flickr album
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.activityIndicator.startAnimating()
        print("test")
        let photo = fetchedResultController.object(at: indexPath)
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
                cell.imageView.image = data
                cell.activityIndicator.stopAnimating()
            }
        }
        
        return cell
    }
    
    
    
    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setupFetchResultsController() {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "imageUrl", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-Photos")
        fetchedResultController.delegate = self
        do{
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error)")
        }
        
        
    }
    
    func downloadPhotoAlbum(new: Bool = false){
        
        
        /*if (fetchedResultController.fetchedObjects?.count == 0) || new {
            if new{
                print("new is true")
            }
            FlickrClient.getImageCollectionRequest(latitute: pin.latitude, longitude: pin.longitude) { data, photoAlbum, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else {
                    print("No data could be found.")
                    return
                }
                guard photoAlbum.count > 0 else {
                    print("No image could be found.")
                    return
                }
                
                for photo in photoAlbum{
                    print(photo)
                    let photosData = Photo(context: self.dataController.viewContext)
                    photosData.imageUrl = FlickrClient.Endpoints.imageUrl(serverId: photo.server, id: photo.id, secret: photo.secret).stringValue
                }
            }
        }
        else {
            print(fetchedResultController.fetchedObjects?.count)
        }*/
    }
    
    func createPinInMapView() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
        
    }
    
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            collectionView.insertItems(at: [indexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            break
        }
    }
}
