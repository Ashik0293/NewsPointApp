//
//  LoginViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginViewController: UIViewController {

    @IBOutlet weak var SignInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationController?.isNavigationBarHidden = true
    }
    
//MARK: Google SignIN Button Action
    @IBAction func GoogleSignInBtn(_ sender: UIButton) {
        signInWithGoogle()
    }
    
    
    private func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return
            }

            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    return
                }

                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Firebase Auth error: \(error.localizedDescription)")
                    } else {
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(Auth.auth().currentUser?.displayName, forKey: "username")
                        UserDefaults.standard.set(Auth.auth().currentUser?.email, forKey: "useremail")
                        UserDefaults.standard.set(Auth.auth().currentUser?.photoURL?.absoluteString, forKey: "userphoto")
                        self.navigateToHomeScreen()
                    }
                }
            }
        }

    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController {
            
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }
}
