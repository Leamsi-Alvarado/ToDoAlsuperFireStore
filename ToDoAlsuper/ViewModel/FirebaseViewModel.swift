//
//  FirebaseViewModel.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import Foundation
import FirebaseAuth

class FireBaseViewModel{
        
    public static let shared = FireBaseViewModel()
    
    func login(email:String, pass: String, completion: @escaping (_ done: Bool) -> Void ){
         Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
             if user != nil {
                 print("Entro")
                 completion(true)
             }else{
                 if let error = error?.localizedDescription {
                     print("Error en firebase", error)
                 }else{
                     print("Error en la app")
                 }
             }
         }
     }
     
     func createUser(email:String, pass: String, completion: @escaping (_ done: Bool) -> Void ){
         Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
             if user != nil {
                 print("Entro y se registro")
                 completion(true)
             }else{
                 if let error = error?.localizedDescription {
                     print("No puede registrarse", error)
                 }else{
                     print("Error en la app")
                 }
             }
         }
     }
    
}
