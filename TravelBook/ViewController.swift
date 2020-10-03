//
//  ViewController.swift
//  TravelBook
//
//  Created by Yurii Sameliuk on 07/02/2020.
//  Copyright © 2020 Yurii Sameliuk. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // dlia na4ala rabotu sozdaem ekzempliar obekta dlia rabotu s mestopoloženiem polzowatelia
    var locationManager = CLLocationManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // sozdaem peremennue dlia pereda4i koordinat w bazy dannux pri soxranenii
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    //sozdaem 4tobu sdelat perechod ot ListViewController do ViewController
    var selectedTitle = ""
    var selectedId: UUID?
    
    // ispolzyem dlia pereda4i informaciiz z bazu dannux na kartu
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        // opredelenije to4nogo mestopoloženija polzowatelia
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // poly4aem mestopoloženie kogda polzowatel polzyetsia priloženiem
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // dobawliaem yprawlenie kartoj pri pomos4i žestow
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
        // zadaem na skolko dlinnoe dolžno buy nažatie
        gestureRecognizer.minimumPressDuration = 3.0
        // dobawliaem žestu na karty
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            
            let idString = selectedId!.uuidString
            //prowerka na rabotosposobnost id
            //print(idString)
            
            // CoreData
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let resaults = try context.fetch(fetchRequest)
                if resaults.count > 0{
                    for resault in resaults as! [NSManagedObject] {
                        //delaem takyyu prowerku so skobkami w konce 4tobu prowerit wse yslowija i tolko potom dobawliat annotacui
                        if let title = resault.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subtitle = resault.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = resault.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                    
                                    
                                    if let longitude = resault.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        self.mapView.addAnnotation(annotation)
                                        
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        //ystraniaem oshubky pri kotoroj kogda mu perechodim po sochranennum kategorijam ne otobražalas sochranennaja lokacija na karte, wmesto nee otobražalos tekys4ee mestopoloženije
                                        locationManager.stopUpdatingLocation()
                                        // sozdaem shablon z yrownem  perwona4alnoga masshtabirowanija kartu
                                        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                        // ystanawliwaem region kartu polzowatelia
                                        let regoin = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(regoin, animated: true)
                                        
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }catch {
                let nserror = error as NSError
                fatalError("\(nserror), \(nserror.userInfo)")
            }
            
            
        }
        
    }
    
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            // preobrazowuwaem w to4ky žesta koordinatu
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            //peredaem sozdanyju to4ky koordinat na karty
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            // priswaiwaem peremennum koordinatu
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            // sozdaem anotacuju pod koordinatami
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
        }
        
    }
    
    //eta funkcija wuzuwaetsia posle togo kak locationManager opredelil mestonachoždenie
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // bydet rabotat esli titl pystoj
        if selectedTitle == "" {
            // polyzaem is masiwa mestopoloženije polzowatelia w shurote i dolgote
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        // sozdaem shablon z yrownem  perwona4alnoga masshtabirowanija kartu
        let span = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        // ystanawliwaem region kartu polzowatelia
        let region = MKCoordinateRegion(center: location, span: span)
        // ykazuwaem mapView region i konkretnoe mestopoloženije polzowatelia
        mapView.setRegion(region, animated: true)
    }else {
    //
    }
}
    // funkcija kotoraja dobawlaet k bylawke na karte knopky . w nashem sly4ae eto kopka - detailDisclosure(informacija)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
      if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = #colorLiteral(red: 0.7357948422, green: 0.9737339616, blue: 0.2952556014, alpha: 1)
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else {
            
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    // funkcija wupolniaet dijstwija kogda mu najali kopky - detailDisclosure(informacija) na bylawke
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // w etoj fynkcii mu bydem ispolzowat elementu nawigacii 4tobu prolažuwat marshryt ot tekys4ego mestopoloženija k sochranennomy polzowatelem
        
        if selectedTitle != "" {
            
            let requestlocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            // konwertiryem geolokacuju
            
            CLGeocoder().reverseGeocodeLocation(requestlocation) { (placemarks, error) in
                if let placemark = placemarks {
                if placemark.count > 0 {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    // stroim marshryt ot na4alnoj do kone4noj to4ki
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.annotationTitle
                    //ystanawliwaem defoltnnoe sostojanije dlia nawigacii. režum awtomobilia
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                }
            }
            }
        }
    }

@IBAction func saveButton(_ sender: UIButton) {
    
    let newPlaces = NSEntityDescription.insertNewObject(forEntityName: "Places", into: self.context)
    //swjazuwaem elementu interfejsa s atributami bazu dannux
    newPlaces.setValue(nameText.text, forKey: "title")
    newPlaces.setValue(commentText.text, forKey: "subtitle")
    newPlaces.setValue(chosenLongitude, forKey: "longitude")
    newPlaces.setValue(chosenLatitude, forKey: "latitude")
    newPlaces.setValue(UUID(), forKey: "id")
    
    do {
        let resault = try context.save()
        
    }catch {
        let nserror = error as NSError
        fatalError("\(nserror), \(nserror.userInfo)")
    }
    NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
    self.navigationController?.popViewController(animated: true)
}
}

