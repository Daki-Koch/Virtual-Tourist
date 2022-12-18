//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by David Koch on 17.12.22.
//

import MapKit
import UIKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    var saveObserverToken: Any?
    
    var mapPins: [Pin] = []
       
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        let gestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        loadMapPins()
        
    }

    
    func loadMapPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            var annotations = [MKPointAnnotation]()
            for pin in result{
                let annotation = MKPointAnnotation()
                annotation.coordinate.longitude = pin.longitude
                annotation.coordinate.latitude = pin.latitude
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
                    
        }
    }
    
    func addPinLocation(coordinates: CLLocationCoordinate2D) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = coordinates
        mapView.addAnnotation(pinAnnotation)
        
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended {
            let location = sender.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            addPinLocation(coordinates: coordinates)
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        performSegue(withIdentifier: "presentAlbum", sender: annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController{
            if let annotation = sender.self as? MKAnnotation{
                //vc.pin.longitude = annotation.coordinate.longitude
                //vc.pin.latitude = annotation.coordinate.latitude
                print(annotation.coordinate.latitude)
                vc.dataController = dataController
            }
        }
    }

    
}



