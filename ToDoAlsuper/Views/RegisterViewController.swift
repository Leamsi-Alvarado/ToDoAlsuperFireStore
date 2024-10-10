//
//  RegisterViewController.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var secondPass: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func register(_ sender: Any) {
        
        guard let emailtext = email.text else { return  }
        guard let passtext = password.text else { return }
        guard let secpasstext = secondPass.text else {return}
        
        if (passtext == secpasstext){
            FireBaseViewModel.shared.createUser(email: emailtext, pass: passtext){ (done) in
                self.dismissSegue()
            }
        }
    }
    
    func actionSegue(identifier: String){
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    func cleanTextFields(){
        email.text = ""
        password.text = ""
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismissSegue()
    }
    func dismissSegue(){
        dismiss(animated: true, completion: nil)
    }

}
