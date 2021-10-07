//
//  MapViewController.swift
//  TAMUBuildingSeeker
//
//  Created by Alexander Hall on 10/3/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet var mapView: MKMapView!
    
    let manager = CLLocationManager()
    
    let buildingCoordinates: [String: (CLLocationCoordinate2D)] = ["BSBW":CLLocationCoordinate2D(latitude: 30.61567,longitude: -96.33946)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .mutedStandard
        self.mapView.delegate = self
        manager.delegate = self
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: buildingCoordinates["BSBW"]!))
            
            request.requestsAlternateRoutes = true
            request.transportType = .walking
            
            let buildingMarker = MKPointAnnotation()
            buildingMarker.coordinate = buildingCoordinates["BSBW"]!
            buildingMarker.title = "Biological Sciences Building West"
            mapView.addAnnotation(buildingMarker)

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to fetch user's location: \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }

}
