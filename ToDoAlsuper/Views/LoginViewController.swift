//
//  HomeViewController.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //En este ciclo de vida no se pueden utilizar VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    // Se utiliza ciclo de vida VIEW DID APPEAR, para que el segue (cambio de view) pueda ejecutarse.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        
    //Verificamos si el UserDefaults tiene una sesión iniciada, para no pedir credenciales
        if (UserDefaults.standard.object(forKey: "session") != nil){
            self.actionSegue(identifier: "login")
        }
    }
    


    @IBAction func login(_ sender: Any) {
            
        guard let emailtext = email.text else { return  }
        guard let passtext = password.text else { return }
        FireBaseViewModel.shared.login(email: emailtext, pass: passtext){ (done) in
            if done {
                UserDefaults.standard.set(true, forKey: "session")
                self.actionSegue(identifier: "login")
            }
            
            self.cleanTextFields()
        }
    }
    
    @IBAction func register(_ sender: Any) {
        
        guard let emailtext = email.text else { return  }
        guard let passtext = password.text else { return }
        
        FireBaseViewModel.shared.createUser(email: emailtext, pass: passtext){ (done) in
            self.actionSegue(identifier: "login")
            
        }
        
    }
    
    func actionSegue(identifier: String){
        performSegue(withIdentifier: identifier, sender: self)
    }
    
    func cleanTextFields(){
        email.text = ""
        password.text = ""
    }
    
}
