//
//  TaskModel.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import Foundation
import CoreData
import UIKit
class TaskModel {
    
    //Constante shared para poder compartir funciones y atributos con Vistas
    public static let shared = TaskModel()
    
    // Creamos método context utilizando CoreData y UIKIT para poder jugar con la data
    func context() -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    //Función save data, parametros: titulo, descripcion y completado, con context para poder jugar con la data, EntityTask para traer los atributos de la tabla, try catch para prevención de errores, intentando guardar la data con el contexto que dimos: tabla a utilizar)
    func saveData(title: String, description: String, completed: Bool){
        let context = context()
        let entityTask = NSEntityDescription.insertNewObject(forEntityName: "Tasks", into: context) as! Tasks
        entityTask.title = title
        entityTask.subtitle = description
        entityTask.completed = completed
        
        do {
            try context.save()
            print("la tarea ha sido guardada")
        } catch let error as NSError {
            print("la tarea no pudo guardarse datos, razon: ", error.localizedDescription)
        }
        
    }
    
    
    func editData(title: String, description: String, completed: Bool, tasks: Tasks){
        let context = context()
        tasks.setValue(title, forKey: "title")
        tasks.setValue(description, forKey: "subtitle")
        tasks.setValue(completed, forKey: "completed")
        
        do {
            try context.save()
            print("Se ha editado")
        } catch let error as NSError {
            print("la tarea no se puede editar, razon: ", error.localizedDescription)
        }
        
    }
    
}
