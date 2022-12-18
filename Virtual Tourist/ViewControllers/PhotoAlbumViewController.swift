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
        
        setupFetchResultsController()
        //createPinInMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchResultsController()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //delete photo from collectionView and from data store.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the number of photos in the flickr album
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        
        return cell
    }
    
    func setupFetchResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == &@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-Photos")
        fetchedResultController.delegate = self
        do{
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error)")
        }
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
