//
//  ThemeViewController.swift
//  Nextcloud
//
//  Created by Jane Calnick on 10/17/23.
//  Copyright © 2023 Marino Faggiana. All rights reserved.
//

import NextcloudKit
import SwiftEntryKit
import PhotosUI
import UIKit

// Add a protocol in ThemeViewController to send the selected image back to NCLogin
protocol ImageSelectionDelegate: AnyObject {
//    func didSelectImage(_ image: UIImage)
    func didSelectImage(_ image: UIImage)
    func didSelectColor(_ color: UIColor)
}

enum UploadType {
    case logo
    case backgroundImage
}

class ThemeViewController: UIViewController {
    
    @IBOutlet weak var appName: UITextField!
    @IBOutlet weak var slogan: UITextField!
    @IBOutlet weak var color: UIColorWell!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!

    
    // Add a property to hold a reference to NCLogin view controller
    var ncLoginViewController: NCLogin?
    var currentUploadType: UploadType = .logo // Default to logo
    
    //var colorWell : UIColorWell!
    
    public var selectedColor : UIColor?
    private var pickedImage: UIImage?
    private var pickedImage2: UIImage?
    
    weak var imageSelectionDelegate: ImageSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addColorWell()
        
        PHPhotoLibrary.requestAuthorization { (status) in
            print("\(status)")
        }
        // Do any additional setup after loading the view.
    }
    func addColorWell(){
        //        colorWell = UIColorWell(frame: CGRect(x: 0 , y : 0, width : 50 , height: 50))
        //        self.view.addSubview(colorWell)
        //        colorWell.center = view.center
        color?.addTarget(self, action: #selector(colorWellValueChanged), for: .valueChanged)
    }
    @objc public func colorWellValueChanged(_sender: Any){
//        self.view.backgroundColor = color?.selectedColor
        let imageManager = ImageManager()
        imageManager.deleteImageFromDocumentsDirectory(filename: "backgroundImage.png")
        
    }
    
@IBAction func sendOnClick(_ sender: Any) {
    let imageManager = ImageManager()
    let loadedImage = imageManager.loadImageFromDocumentsDirectory(filename: "logoImage.png")
    if let image = loadedImage, let ncLoginViewController = getCurrentNCLoginViewController() {
        DispatchQueue.main.async{
            if let imageBrand = ncLoginViewController.imageBrand {
                    imageBrand.image = image
                }
//            ncLoginViewController.imageBrand.image = image
        }
    } else if let ncLoginViewController = getCurrentNCLoginViewController() {
        DispatchQueue.main.async {
            ncLoginViewController.imageBrand.image = UIImage(named: "logo")
        }
    }
    
    let loadedBackground = imageManager.loadImageFromDocumentsDirectory(filename: "backgroundImage.png")
//    if let image = loadedBackground {
//        DispatchQueue.main.async {
//            if let ncLoginViewController = getCurrentNCLoginViewController() {
//                // Remove existing background image view if exists
//                ncLoginViewController.view.subviews
//                    .filter { $0 is UIImageView }
//                    .forEach { $0.removeFromSuperview() }
//                
//                // Set the loaded background image
//                let backgroundImageView = UIImageView(image: image)
//                backgroundImageView.contentMode = .scaleAspectFill
//                backgroundImageView.frame = ncLoginViewController.view.bounds
//                backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                ncLoginViewController.view.insertSubview(backgroundImageView, at: 0)
//            }
//        }
//    }
//    else if let ncLoginViewController = getCurrentNCLoginViewController() {
//        DispatchQueue.main.async {
//            // Check if the background color is different from the saved image
//            if ncLoginViewController.view.backgroundColor != self.color.selectedColor {
//                // Delete the background image from documents directory
//                imageManager.deleteImageFromDocumentsDirectory(filename: "backgroundImage.png")
//            }
//            // Set the background color regardless of the image
//            ncLoginViewController.view.backgroundColor = self.color.selectedColor
//        }
//    }
    // Load selected background image
        if let image = loadedBackground {
            DispatchQueue.main.async {
                if let ncLoginViewController = getCurrentNCLoginViewController() {
                    ncLoginViewController.setBackgroundImage(image)
                }
            }
        } else if let ncLoginViewController = getCurrentNCLoginViewController() {
            DispatchQueue.main.async {
                if ncLoginViewController.view.backgroundColor != self.color.selectedColor {
                    // Delete the background image from documents directory
                    imageManager.deleteImageFromDocumentsDirectory(filename: "backgroundImage.png")
                }
                // Set the background color regardless of the image
                if let selectedColor = self.color.selectedColor {
                    ncLoginViewController.setBackgroundColor(selectedColor)
                    ncLoginViewController.newSlogan = self.slogan.text
                }
            }
        }
    
    func getCurrentNCLoginViewController() -> NCLogin? {
        if let existingNCLoginViewController = ncLoginViewController {
            return existingNCLoginViewController
        }
        
        if let navController = navigationController {
            for viewController in navController.viewControllers {
                if let ncLoginVC = viewController as? NCLogin {
                    return ncLoginVC
                }
            }
        }
        return nil
    }
    
    if let navigationController = self.navigationController {
        if let ncLoginViewController = storyboard?.instantiateViewController(withIdentifier: "NCLogin") as? NCLogin {
            ncLoginViewController.newSlogan = slogan.text
            ncLoginViewController.view.backgroundColor = color.selectedColor
            // Assign the delegate
            ncLoginViewController.imageSelectionDelegate = self
            navigationController.pushViewController(ncLoginViewController, animated: true)
        }
    }
    // Notify the delegate about the selected color
        if let delegate = imageSelectionDelegate {
            delegate.didSelectColor(color.selectedColor ?? .clear)
        }
}
        
    @IBAction func onTappedUploadLogo(_ sender: UIButton) {
        presentImagePicker(for: .logo)
    }

    @IBAction func onTappedUploadBackground(_ sender: UIButton) {
        presentImagePicker(for: .backgroundImage)
    }

    func presentImagePicker(for type: UploadType) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        currentUploadType = type // Save the current upload type
        present(picker, animated: true)
    }
    
//    @IBAction func onTappedUploadPhoto(_ sender: UIButton) {
//        // Create and configure PHPickerViewController
//        
//        // Create a configuration object
//        var config = PHPickerConfiguration()
//        
//        // Set the filter to only show images as options (i.e. no videos, etc.).
//        config.filter = .images
//        
//        // Request the original file format. Fastest method as it avoids transcoding.
//        config.preferredAssetRepresentationMode = .current
//        
//        // Only allow 1 image to be selected at a time.
//        config.selectionLimit = 1
//        
//        // Instantiate a picker, passing in the configuration.
//        let picker = PHPickerViewController(configuration: config)
//        
//        // Set the picker delegate so we can receive whatever image the user picks.
//        picker.delegate = self
//        
//        // Present the picker
//        present(picker, animated: true)
//    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
    
extension ThemeViewController: PHPickerViewControllerDelegate {
    
    // PHPickerViewController required delegate method.
    // Returns PHPicker result containing picked image data.
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss the picker
        picker.dismiss(animated: true)

        // Make sure we have a non-nil item provider
        guard let provider = results.first?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }

            // Check for and handle any errors
            if let error = error {
                self?.showAlert(description: error.localizedDescription)
                return
            } else {
                // UI updates (like setting image on image view) should be done on the main thread
                DispatchQueue.main.async {
                    if self?.currentUploadType == .logo { // Check if logo is already set
                        self?.logo.image = image
                        self?.pickedImage = image
                    } else if self?.currentUploadType == .backgroundImage{
                        self?.backgroundImage.image = image
                        self?.pickedImage2 = image
                    }
                    // Notify the delegate about the selected image
                    self?.imageSelectionDelegate?.didSelectImage(image)

                    if let imageToSave = self?.pickedImage, self?.currentUploadType == .logo {
                        let imageManager = ImageManager()
                        imageManager.saveImageToDocumentsDirectory(image: imageToSave, filename: "logoImage.png")
                    }

                    if let imageToSave = self?.pickedImage2, self?.currentUploadType == .backgroundImage {
                        let imageManager = ImageManager()
                        imageManager.saveImageToDocumentsDirectory(image: imageToSave, filename: "backgroundImage.png")
                    }
                }
            }
        }
    }
}

class ImageManager {
    func saveImageToDocumentsDirectory(image: UIImage, filename: String) {
        guard let imageData = image.pngData() else {
            print("Failed to convert the image to data")
            return
        }

        // Get the URL for the Documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Append the filename to save the image
            let fileURL = documentsDirectory.appendingPathComponent(filename)

            do {
                try imageData.write(to: fileURL)
                print("Image saved to: \(fileURL.absoluteString)")

                // At this point, the image is saved and you can use 'fileURL' as needed
                // You might, for example, want to display the image or perform further actions.
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }

    
    func loadImageFromDocumentsDirectory(filename: String) -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(filename)

            do {
                let imageData = try Data(contentsOf: fileURL)
                let image = UIImage(data: imageData)
                return image
            } catch {
                print("Error loading image: \(error)")
            }
        }
        return nil
    }
    
    func deleteImageFromDocumentsDirectory(filename: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(filename)

            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image deleted: \(fileURL.absoluteString)")
            } catch {
                print("Error deleting image: \(error)")
            }
        }
    }
}

extension ThemeViewController: ImageSelectionDelegate {
    func didSelectImage(_ image: UIImage) {
        // Send the selected image back to NCLogin
        if let ncLoginViewController = getCurrentNCLoginViewController() {
            ncLoginViewController.newImage = image
        }
    }

    func didSelectColor(_ color: UIColor) {
        // Handle color selection here if needed
        
    }
}

extension ThemeViewController {
    func getCurrentNCLoginViewController() -> NCLogin? {
        if let existingNCLoginViewController = ncLoginViewController {
            return existingNCLoginViewController
        }

        if let navController = navigationController {
            for viewController in navController.viewControllers {
                if let ncLoginVC = viewController as? NCLogin {
                    return ncLoginVC
                }
            }
        }
        return nil
    }
}
