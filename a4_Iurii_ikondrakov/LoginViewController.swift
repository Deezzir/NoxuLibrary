//
//  ViewController.swift
//  a4_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-04-06.
//
import UIKit
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        usernameField.delegate = self
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        authenticate()
    }
    
    private func login() {
        guard let library = storyboard?
            .instantiateViewController(withIdentifier: "library")
                as? LibraryViewController
        else {
            print("ERROR: Could not find Library Screen")
            return
        }
        
        library.username = usernameField.text!.trimmingCharacters(in: [" "])
        
        self.navigationController?
            .pushViewController(library, animated: true)
    }
    
    private func authenticate() {
        errorLabel.text = " "
        
        if(validate()) {
            db.collection("users")
                .whereField("username", isEqualTo: usernameField.text!.trimmingCharacters(in: [" "]))
                .whereField("password", isEqualTo: passwordField.text!.trimmingCharacters(in: [" "]))
                .getDocuments(completion: { users, error in
                    if let err = error {
                        print("ERROR: Failed to retrieve users")
                        print(err)
                    } else {
                        if(!users!.documents.isEmpty) {
                            self.login()
                            print("INFO: User authenticated")
                        } else {
                            self.errorLabel.text = "Incorrect Username/password"
                            print("INFO: Username/password invalid")
                        }
                    }
                })
        }
    }
    
    private func validate() -> Bool {
        var valid = true
        usernameErrorLabel.text = " "
        passwordErrorLabel.text = " "
        
        if let username = usernameField.text, let password = passwordField.text {
            if(username.isEmpty) {
                usernameErrorLabel.text = "Username is required"
                valid = false
                print("INFO: Username is empty")
            }
            if(password.isEmpty) {
                passwordErrorLabel.text = "Password is required"
                valid = false
                print("INFO: Password is empty")
            }
        }
        return valid
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 15
    }
    
}

