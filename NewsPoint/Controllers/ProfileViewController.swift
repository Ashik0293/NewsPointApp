//
//  ProfileViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit
import CoreLocation
import CoreData
import Photos
import FirebaseAuth
import FirebaseCore
import GoogleSignIn


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var UserNameLbl: UILabel!
    
    @IBOutlet weak var Usermaillbl: UILabel!
    
    
    private let locationManager = CLLocationManager()
        
        private var context: NSManagedObjectContext {
            (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        }
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.isNavigationBarHidden = true
            retrieveData()
            setupImageTapGesture()
            setupLocationManager()
            requestLocationAccessIfNeeded()
            updateLabelWithLatestLocation()
        }
        
    
    //MARK: IBoutlet Button action for Signout
    @IBAction func SignoutBtn(_ sender: UIButton) {
        
        do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                
                // Clear UserDefaults
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "isLoggedIn")
                defaults.removeObject(forKey: "username")
                defaults.removeObject(forKey: "useremail")
                defaults.removeObject(forKey: "userphoto")
                
                // Redirect to login screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(loginVC, animated: true)

            } catch let error {
                print("Logout failed: \(error.localizedDescription)")
            }
        
    }
    
    //MARK: Retrieve Data from Firebase
    
    func retrieveData(){
//        if let imageurl = URL(string: UserDefaults.standard.string(forKey: "userphoto") ?? "") {
//            
//            URLSession.shared.dataTask(with: imageurl) { (data, response, error) in
//                
//                if let data = data, error == nil {
//                    
//                    DispatchQueue.main.async {
//                       // self.profileImageView.image = UIImage(data: data)
//                    }
//                }
//                
//            }.resume()
//        }
        
        UserNameLbl.text = UserDefaults.standard.string(forKey: "username") ?? ""
        Usermaillbl.text = UserDefaults.standard.string(forKey: "useremail") ?? ""
        
    }
    
    
        // MARK: - Image Handling
        private func setupImageTapGesture() {
            profileImageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            profileImageView.addGestureRecognizer(tapGesture)
        }
        
        @objc private func imageTapped() {
            let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                    self.presentImagePicker(sourceType: .camera)
                })
            }
            
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.presentImagePicker(sourceType: .photoLibrary)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
            if sourceType == .camera {
                checkCameraPermission {
                    self.showImagePicker(sourceType: .camera)
                }
            } else {
                checkPhotoLibraryPermission {
                    self.showImagePicker(sourceType: .photoLibrary)
                }
            }
        }
        
        private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
        }
        
        private func checkCameraPermission(grantedHandler: @escaping () -> Void) {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                grantedHandler()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        granted ? grantedHandler() : self.showPermissionAlert("Camera access is required.")
                    }
                }
            case .denied, .restricted:
                showPermissionAlert("Please enable camera access in Settings.")
            @unknown default:
                break
            }
        }

        private func checkPhotoLibraryPermission(grantedHandler: @escaping () -> Void) {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized, .limited:
                grantedHandler()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized || status == .limited {
                            grantedHandler()
                        } else {
                            self.showPermissionAlert("Photo access is required.")
                        }
                    }
                }
            case .denied, .restricted:
                showPermissionAlert("Please enable photo access in Settings.")
            @unknown default:
                break
            }
        }

        private func showPermissionAlert(_ message: String) {
            let alert = UIAlertController(title: "Permission Required", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            var selectedImage: UIImage?
            
            if let editedImage = info[.editedImage] as? UIImage {
                selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                selectedImage = originalImage
            }
            
            if let image = selectedImage {
                profileImageView.image = image
                
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
                    
                    do {
                        let users = try context.fetch(fetchRequest)
                        let user = users.first ?? Entity(context: context)
                        user.profileImage = imageData
                        user.timestamp = Date()
                        
                        try context.save()
                        print("Image saved to Core Data")
                    } catch {
                        print("Failed to save image: \(error)")
                    }
                }
            }
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    // MARK: - CLLocationManagerDelegate
    extension ProfileViewController: CLLocationManagerDelegate {
        
        private func setupLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        private func requestLocationAccessIfNeeded() {
            locationLabel.text = "Fetching location..."
            let status = CLLocationManager.authorizationStatus()
            
            switch status {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.requestLocation()
            default:
                locationLabel.text = "Location access denied"
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                saveLocationToCoreData(latitude: lat, longitude: lon)
                updateLabelWithLatestLocation()
            }
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.requestLocation()
            } else {
                locationLabel.text = "Location access denied"
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            locationLabel.text = "Error fetching location"
            print("Location error: \(error.localizedDescription)")
        }

        // MARK: - Core Data
        private func saveLocationToCoreData(latitude: Double, longitude: Double) {
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            
            do {
                let users = try context.fetch(fetchRequest)
                let user = users.first ?? Entity(context: context)
                user.latitude = latitude
                user.longitude = longitude
                user.timestamp = Date()
                
                try context.save()
                print("Saved location: (\(latitude), \(longitude))")
            } catch {
                print("Error saving to CoreData: \(error.localizedDescription)")
            }
        }
        
        private func updateLabelWithLatestLocation() {
            let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if let user = results.first {
                    getAddressFromCoordinates(latitude: user.latitude, longitude: user.longitude) { [self] text in
                        locationLabel.text = text
                    }
                   // locationLabel.text = String(format: "Lat: %.4f\nLon: %.4f", user.latitude, user.longitude)
                    if let imageData = user.profileImage {
                        profileImageView.image = UIImage(data: imageData)
                    }
                } else {
                    locationLabel.text = "No location data"
                }
            } catch {
                print("Error fetching from CoreData: \(error.localizedDescription)")
                locationLabel.text = "Error fetching location"
            }
        }
        
        private func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Reverse geocoding failed: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let placemark = placemarks?.first {
                    var address = ""
                    
                    if let name = placemark.name {
                        address += name + ", "
                    }
                    if let city = placemark.locality {
                        address += city + ", "
                    }
                    if let state = placemark.administrativeArea {
                        address += state + ", "
                    }
                    if let country = placemark.country {
                        address += country
                    }
                    
                    completion(address)
                } else {
                    completion(nil)
                }
            }
        }

    }
