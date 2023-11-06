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
    private var pickedBackground: UIImage?

    
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
    let loadedImage = imageManager.loadImageFromDocumentsDirectory(imageType: "logo")
    let loadedBackground = imageManager.loadImageFromDocumentsDirectory(imageType: "background")
    if let image = loadedImage, let ncLoginViewController = getCurrentNCLoginViewController() {
        ncLoginViewController.imageBrand.image = image
    } else if let ncLoginViewController = getCurrentNCLoginViewController() {
        ncLoginViewController.imageBrand.image = UIImage(named: "logo")
    }
    
    if let bImage = loadedBackground, let ncLoginViewController = getCurrentNCLoginViewController() {
        ncLoginViewController.backgroundImage.image = bImage
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
    
    @IBAction func onTappedUploadBackground(_ sender: Any) {
        let photoVC = UIImagePickerController()
        photoVC.sourceType = .photoLibrary
        photoVC.delegate = self
        photoVC.allowsEditing = true
        present(photoVC, animated: true)
    }
    
    private func presentBadImagelert() {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "Image Could not be uploaded. Try Again.",
            preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
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
    
extension ThemeViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // PHPickerViewController required delegate method.
    // Returns PHPicker result containing picked image data.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let bImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as?
                UIImage{
                pickedBackground = bImage
                backgroundImage.image = bImage
                let imageToSave = self.pickedBackground
                let imageManager = ImageManager()
                imageManager.saveImageToDocumentsDirectory(image: imageToSave!, imageType: "background")

            }
            picker.dismiss(animated: true, completion: nil)

        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    
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
                    imageManager.saveImageToDocumentsDirectory(image: imageToSave!, imageType: "logo")
                }
            }
        }
    }
}

class ImageManager {
    func saveImageToDocumentsDirectory(image: UIImage, imageType: String) {
        guard let imageData = image.pngData() else {
            print("Failed to convert the image to data")
            return
        }

        // Get the URL for the Documents directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Append a filename or use a unique identifier to save the image
            let fileURL: URL
            if imageType == "logo"{
                fileURL = documentsDirectory.appendingPathComponent("savedImage.png")
            }else{
                fileURL = documentsDirectory.appendingPathComponent("savedBackground.png")
            }
            

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
    
    func loadImageFromDocumentsDirectory(imageType: String) -> UIImage? {
        if imageType == "logo"{
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("savedImage.png")

                do {
                    let imageData = try Data(contentsOf: fileURL)
                    let image = UIImage(data: imageData)
                    return image
                } catch {
                    print("Error loading image: \(error)")
                }
            }
        }else{
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("savedBackground.png")

                do {
                    let backgroundData = try Data(contentsOf: fileURL)
                    let bImage = UIImage(data: backgroundData)
                    return bImage
                } catch {
                    print("Error loading image: \(error)")
                }
            }

        }
            
            return nil
        }
}
