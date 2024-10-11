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

        password.isSecureTextEntry = true
       
    }
    // Se utiliza ciclo de vida VIEW DID APPEAR, para que el segue (cambio de view) pueda ejecutarse.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        
    //Verificamos si el UserDefaults tiene una sesión iniciada, para no pedir credenciales
        if (UserDefaults.standard.object(forKey: "session") != nil){
            self.actionSegue(identifier: "login")
        }
    }
    
    @IBAction func showPass(_ sender: Any) {
        password.isSecureTextEntry.toggle()
    }
    
    

    //Funcion del boton login
    @IBAction func login(_ sender: Any) {
            //nos protegemos de no llenar el fieldtext
        guard let emailText = email.text, !emailText.isEmpty else {
            showAlert(message: "Por favor, ingresa tu correo electrónico.")
            return
        }
        guard let passText = password.text, !passText.isEmpty else {
            showAlert(message: "Por favor, ingresa tu contraseña.")
            return
        }
               // Utilizamos el shared del viewmodel de Firebase para poder entrar a la función login
               FireBaseViewModel.shared.login(email: emailText, pass: passText) { (done, errorMessage) in
                   if done {
                       // Si se logró el inicio de sesión, guardamos las credenciales en UserDefaults
                       UserDefaults.standard.set(true, forKey: "session")
                       // Ejecutamos el segue establecido en el Main.Storyboard
                       self.performSegue(withIdentifier: "login", sender: self)
                   } else if let errorMessage = errorMessage {
                       // Mostrar el mensaje de error en una alerta
                       self.showAlert(message: errorMessage)
                   }
                   
                   // Borramos los textos por si se cierra sesión
                   self.cleanTextFields()
               }
    }
    
    //el segue para iniciar sesion
    func actionSegue(identifier: String){
        performSegue(withIdentifier: identifier, sender: self)
    }
    //borramos los datos de los textfields
    func cleanTextFields(){
        email.text = ""
        password.text = ""
    }
    
    func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    
}
