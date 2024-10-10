//
//  AddToDoViewController.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import UIKit

class AddTaskViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskTitle: UITextField!
    var task : Tasks?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        taskTitle.text = task?.title
        taskDescription.text = task?.subtitle
        if task == nil {
            textValidation()
        }else{
            taskButton.backgroundColor = .systemTeal
            textValidationEdition()
        }
    }
    
    

    //Guardado de data
    @IBAction func taskSave(_ sender: UIButton) {
        if task != nil { //si task es diferente de nulo entonces vamos a editar data
            TaskModel.shared.editData(title: taskTitle.text ?? "", description: taskDescription.text, completed: false, tasks: task!) //Utilizamos la funcion de la clase TaskModel para editar data
            navigationController?.popViewController(animated: true)
        }else{
            TaskModel.shared.saveData(title: taskTitle.text ?? "", description: taskDescription.text, completed: false) //Usamos la función SAVE, de nuestra clase TaskModel
            navigationController?.popViewController(animated: true)
        }
    }
    
    //Selector que ejecuta la funcion validateTextField cada que se escribe en el title desactivando de primeras el boton de guardar
    func textValidation(){
        taskButton.isEnabled = false
        taskButton.backgroundColor = .systemGray2
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
    
    
    //Selector que ejecuta la funcion validateTextField cada ves que se edita el text field
    func textValidationEdition(){
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
    
    //Funcion para validar que que hay texto y activar el boton de guardar
    @objc func validateTextField(sender: UITextField){
        guard let title = taskTitle.text, !title.isEmpty else{
            taskButton.isEnabled = false
            taskButton.backgroundColor = .systemGray2
            return
        }
        taskButton.isEnabled = true
        taskButton.backgroundColor = .systemTeal
    }
}
