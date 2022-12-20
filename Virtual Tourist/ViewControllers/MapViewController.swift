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
        
        let gestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
        gestureRecognizer.minimumPressDuration = 1
        mapView.addGestureRecognizer(gestureRecognizer)
        
        loadMapPins()
        
    }
    
    
    func loadMapPins() {
        var annotations = [MKPointAnnotation]()
        var result = fetchPins()
        for pin in result{
            let annotation = MKPointAnnotation()
            annotation.coordinate.longitude = pin.longitude
            annotation.coordinate.latitude = pin.latitude
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func fetchPins() -> [Pin]{
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            return result
        } else {
            return []
        }
        
    }
    
    func fetchPinData(coordinates: CLLocationCoordinate2D) -> Pin? {
        let existingPins = fetchPins()
        var pin: Pin?
        if existingPins.count > 0 {
            for existingPin in existingPins {
                if existingPin.latitude == coordinates.latitude && existingPin.longitude == coordinates.longitude{
                    pin = existingPin
                }
            }
        }
        return pin
    }
    
    func addPinLocation(coordinates: CLLocationCoordinate2D) {
        let existingPins = fetchPins()
        
        if existingPins.count > 0 {
            for existingPin in existingPins {
                if existingPin.latitude == coordinates.latitude && existingPin.longitude == coordinates.longitude{
                    return
                } else {
                    addNewPin(coordinates: coordinates)
                    return
                }
            }
           
        } else {
            addNewPin(coordinates: coordinates)
        }
        
    }
    
    func addNewPin(coordinates: CLLocationCoordinate2D){
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = coordinates.latitude
        pin.longitude = coordinates.longitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
        
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = coordinates
        mapView.addAnnotation(pinAnnotation)
    }
    
    @objc func handleTap(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let location = sender.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView)
            addPinLocation(coordinates: coordinates)
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        
        performSegue(withIdentifier: "presentAlbum", sender: annotation)
        mapView.deselectAnnotation(annotation, animated: true)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoAlbumViewController{
            if let annotation = sender.self as? MKAnnotation{
                
                vc.pin = fetchPinData(coordinates: annotation.coordinate)
                vc.dataController = dataController
            }
        }
    }
    
    
}



