//
//  ProfileViewController.swift
//  chatApp
//
//  Created by Rotimi Awani on 11/21/19.
//  Copyright © 2019 Rotimi Awani. All rights reserved.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.gray.cgColor
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.gray.cgColor
        
        fetchProfilePhoto()
        nameLabel.text = getUser()

    }
    
    @IBAction func onImageClick(_ sender: Any) {
        pickPhoto()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 100, height: 100)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        profileImageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    
    func getUser() -> String {
        let currentUser = PFUser.current()
        return currentUser?.username ?? ""
    }

    
    @IBAction func onSave(_ sender: Any) {
        setPhoto()
    }
    
    func setPhoto() {
        let title = "Saved"
        let message = "profile picture updated successfully"
        let title2 = "Error"
        let message2 = "profile picture was not updated"
        //Create PFFile Object
        let imageData = profileImageView.image!.pngData()
        let imagefile = PFFileObject(name: "image.png", data: imageData!)
        let user = PFUser.current()
        
        user?.setObject(imagefile!, forKey: "profilePicture")
        user?.saveInBackground(block: { (success, error) in
            if success {
                print("Saved")
                self.showAlert(with: title, message: message)
            } else {
                print("Error in saving")
                self.showAlert(with: title2, message: message2)
            }
        })
        
    }
        
    func pickPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
            
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated:true, completion: nil)
    }
    func fetchProfilePhoto() {
        let user = PFUser.current()!
        let imageFile = user["profilePicture"] as? PFFileObject
        if imageFile != nil {
            let urlString = imageFile?.url!
            let url = URL(string: urlString!)
            profileImageView.af_setImage(withURL: url!)
        } else {
            //set default Image
            profileImageView.image = UIImage(systemName: "person.fill")
        }
    }
    private func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) //Creates an OK action
        alertController.addAction(OKAction)
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
