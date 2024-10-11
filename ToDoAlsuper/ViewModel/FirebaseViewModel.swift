//
//  FirebaseViewModel.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import Foundation
import FirebaseAuth

// Creamos ViewModel con la sintaxis que nos proporciona Firebase para completar un Auth correcto
class FireBaseViewModel{
    
    // Se debe de crear un shared, para que los viewcontrollers tengan acceso a las funciones de la Clase
    public static let shared = FireBaseViewModel()
    
    // Funcion login, parámetros: email, pass, completion.
    func login(email: String, pass: String, completion: @escaping (_ done: Bool, _ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
            if result != nil {
                completion(true, nil) // El usuario fue aceptado
            } else {
                if let error = error?.localizedDescription {
                    completion(false, error) // Devolver el error a la vista
                } else {
                    completion(false, "Error en la app") // Error no identificado
                }
            }
        }
    }
    
    // Funcion para crear usuario
    func createUser(email: String, pass: String, completion: @escaping (_ done: Bool, _ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
            if result != nil {
                completion(true, nil) // El usuario fue aceptado y puede entrar
            } else {
                if let error = error?.localizedDescription {
                    completion(false, error) // Devolver el error a la vista
                } else {
                    completion(false, "Error en la app") // Error no identificado
                }
            }
        }
    }
}
