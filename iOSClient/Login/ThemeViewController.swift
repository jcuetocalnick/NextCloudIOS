//
//  ThemeViewController.swift
//  Nextcloud
//
//  Created by Jane Calnick on 10/17/23.
//  Copyright © 2023 Marino Faggiana. All rights reserved.
//
import SwiftUI
import PhotosUI
import UIKit
import NextcloudKit
import SwiftEntryKit

class ThemeViewController: UIViewController {

    @IBOutlet weak var appName: UITextField!
    @IBOutlet weak var slogan: UITextField!
    @IBOutlet weak var color: UIColorWell!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var uploadBackground: UIButton!
    
    private var pickedImage: UIImage?
    private var showingAlert = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { (status) in
                    print("\(status)")
                }
        // Do any additional setup after loading the view.
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
    
    @IBAction func submitClicked(_ sender: Any) {
        let newViewController = storyboard?.instantiateViewController(withIdentifier: "NCLogin") as! NCLogin
        
        newViewController.newImage = background.image
        present(newViewController, animated: true, completion: nil)

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
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show" {
            let destinationVC: NCLogin = segue.destination as! NCLogin
            destinationVC.imageBrand.image = background.image
        }

    }

}

extension ThemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let bImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as?
            UIImage{
            background.image = bImage
        }
        picker.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
