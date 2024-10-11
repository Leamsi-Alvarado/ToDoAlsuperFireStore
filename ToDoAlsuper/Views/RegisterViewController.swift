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
    
//boton registrar
    @IBAction func register(_ sender: Any) {
        // nos protegemos de campos vacios
        guard let emailText = email.text, !emailText.isEmpty else {
            showAlert(message: "Por favor, ingresa tu correo electrónico.")
            return
        }
        guard let passText = password.text, !passText.isEmpty else {
            showAlert(message: "Por favor, ingresa una contraseña.")
            return
        }
        guard let secPassText = secondPass.text, !secPassText.isEmpty else {
            showAlert(message: "Por favor, confirma tu contraseña.")
            return
        }

        // Si el password y el second password son iguales, entonces
        if passText == secPassText {
            FireBaseViewModel.shared.createUser(email: emailText, pass: passText) { (done, errorMessage) in
                if done {
                    // Si el registro es exitoso, cerramos el register y volvemos al login
                    self.dismissSegue()
                } else if let errorMessage = errorMessage {
                    // Si hay un error, mostramos una alerta con el mensaje de error
                    self.showAlert(message: errorMessage)
                }
            }
        } else {
            //alerta por match de contraseñas
            showAlert(message: "Las contraseñas no coinciden.")
        }
    }
    //borramos los textfields
    func cleanTextFields(){
        email.text = ""
        password.text = ""
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismissSegue()
    }
    //funcion para volver
    func dismissSegue(){
        dismiss(animated: true, completion: nil)
    }

    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

