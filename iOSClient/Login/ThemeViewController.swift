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
    func didSelectImage(_ image: UIImage)
}

class ThemeViewController: UIViewController {
    
    @IBOutlet weak var appName: UITextField!
    @IBOutlet weak var slogan: UITextField!
    @IBOutlet weak var color: UIColorWell!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // Add a property to hold a reference to NCLogin view controller
    var ncLoginViewController: NCLogin?
    
    //var colorWell : UIColorWell!
    
    public var selectedColor : UIColor?
    private var pickedImage: UIImage?
    
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
        
    }
    
@IBAction func sendOnClick(_ sender: Any) {
    let imageManager = ImageManager()
    let customDirectoryPath = "/Users/juliopadron/Desktop/NextCloudIOS/iOSClient/ThemeAssets.xcassets"
    let loadedImage = imageManager.loadImageFromCustomDirectory(directoryPath: customDirectoryPath, imageName: "savedImage.png")

    if let image = loadedImage, let ncLoginViewController = getCurrentNCLoginViewController() {
        ncLoginViewController.imageBrand.image = image
    } else if let ncLoginViewController = getCurrentNCLoginViewController() {
        ncLoginViewController.imageBrand.image = UIImage(named: "logo")
    }
    
    func getCurrentNCLoginViewController() -> NCLogin? {
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
            ncLoginViewController.view.backgroundColor = color.selectedColor
            navigationController.pushViewController(ncLoginViewController, animated: true)
        }
    }

}
        
        
    @IBAction func onTappedUploadPhoto(_ sender: UIButton) {
        // Create and configure PHPickerViewController
        
        // Create a configuration object
        var config = PHPickerConfiguration()
        
        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images
        
        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current
        
        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1
        
        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)
        
        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self
        
        // Present the picker
        present(picker, animated: true)
    }
    
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

                // UI updates (like setting image on image view) should be done on main thread
                DispatchQueue.main.async {

                    // Set image on preview image view
                    self?.logo.image = image

                    // Set image to use when saving post
                    self?.pickedImage = image
                    // Usage:
                    let imageToSave = self?.pickedImage // Provide the image you want to save
                    let imageManager = ImageManager()
                    let customDirectoryPath = "/Users/juliopadron/Desktop/NextCloudIOS/iOSClient/ThemeAssets.xcassets"
                    // Save the image to the custom directory
                    imageManager.saveImageToCustomDirectory(image: imageToSave!, directoryPath: customDirectoryPath, imageName: "savedImage.png")
//                    imageManager.saveImageToDocumentsDirectory(image: imageToSave!, subdirectory: "imageBrand")
                }
            }
        }
    }
}

class ImageManager {
    // Assuming you have the selected image from PHPickerViewController stored in the variable 'selectedImage'
    func saveImageToCustomDirectory(image: UIImage, directoryPath: String, imageName: String) {
        guard let imageData = image.pngData() else {
            print("Failed to convert the image to data")
            return
        }

        let fileURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)

        do {
            try imageData.write(to: fileURL)
            print("Image saved to: \(fileURL.path)")
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    func loadImageFromCustomDirectory(directoryPath: String, imageName: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)

        do {
            let imageData = try Data(contentsOf: fileURL)
            let image = UIImage(data: imageData)
            return image
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
}
