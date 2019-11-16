//
//  ViewController.swift
//  chatApp
//
//  Created by Rotimi Awani on 11/9/19.
//  Copyright © 2019 Rotimi Awani. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Private Methods
    
    private func showErrorAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) //Creates an OK action
        alertController.addAction(OKAction)
        present(alertController, animated: true)
        
    }

    @IBAction func onSignup(_ sender: Any) {
        let errorTitle = "Cannot Sign Up"
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else {
                return
        }
        
        if username.isEmpty || password.isEmpty {
            let errorMessage = "Please fill out all fields"
            showErrorAlert(with: errorTitle, message: errorMessage)
            
        }
        
        let newUser = PFUser()
        newUser.username = username
        newUser.password = password
        
        newUser.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let errorMessage = error?.localizedDescription ?? "There was a problem signing up"
                self.showErrorAlert(with: errorTitle, message: errorMessage)
            }
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let errorTitle = "Cannot Log In"
        guard let username = usernameTextField.text,
            let password = passwordTextField.text else {
                return
        }
        
        if username.isEmpty || password.isEmpty {
            let errorMessage = "Please fill out all fields"
            showErrorAlert(with: errorTitle, message: errorMessage)
            
        }
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (newUser, error) in
            if newUser != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                let errorMessage = error?.localizedDescription ?? "There was a problem Logging in"
                self.showErrorAlert(with: errorTitle, message: errorMessage)
            }
        }
        
    }
    
}

