import UIKit
import FirebaseFirestore
import FirebaseAuth
class AddTaskViewController: UIViewController, UIGestureRecognizerDelegate {

    //Outlets para poder utilizar el boton, textfield y textview
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskTitle: UITextField!
  
    //Creamos una variable task, para obtener los datos en caso de edit
    //Se debe utilizar como posible variable (?), Si creamos una nueva Task exisitira un error por necesitar los datos.
    var task: Task?
    // Traemos las funciones de firestore
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // EDICION
        //En caso de edicion damos las variables recibidas a los campos, con el objetivo de poder cambiarlos
        if let task = task {

            taskTitle.text = task.title
            taskDescription.text = task.subtitle
            taskButton.setTitle("Editar", for: .normal)
            taskButton.backgroundColor = .systemTeal
        } else { //En caso de que sea una nueva TASK, ejecutamos textValidation
            textValidation()
        }

    }
    
    //TaskSave es la funcion con la cual guardaremos los datos dentro de nuestra colección en firebase
    @IBAction func taskSave(_ sender: UIButton) {
            let title = taskTitle.text ?? ""
            let description = taskDescription.text ?? ""
            let completed = false
            let userId = Auth.auth().currentUser?.uid ?? ""
        //Hasta aqui recopilamos los datos de los campos
        
        //Vemos si es una task con valores, eso quiere decir que estamos editando, dentro de este seleccionamos la colección a guardar, y los campos a actualizar, los cuales utilizamos los datos arriba de nosotros
            if let task = task {
                let taskRef = db.collection("tasks").document(task.id)
                taskRef.updateData([
                    "title": title,
                    "subtitle": description,
                    "completed": completed,
                    "userId": userId
                ]) { error in
                    if let error = error {
                        print("Error al actualizar la tarea: \(error)")
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                // Si es una task nueva, utilizamos la coleccion tasks y vamos a SETEAR la data nueva
                let newTaskRef = db.collection("tasks").document()
                newTaskRef.setData([
                    "title": title,
                    "subtitle": description,
                    "completed": completed,
                    "userId": userId
                ]) { error in
                    if let error = error {
                        print("Error al guardar la tarea: \(error)") //manoe de errores, para saber que pasa en caso de problema
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }
    
    //En caso de nueva TASK, empezara siempre el boton desactivado, y el addTarget se encargara de estar escuchando la EDICION del textField, para cuando haya un verificar si tenemos que desactivar el boton
    func textValidation() {
        taskButton.isEnabled = false
        taskButton.backgroundColor = .systemGray2
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
    //En Caso de edicion, cada ves que se EDITE el textField de tituloejecutaremos ValidateTextField()
    func textValidationEdition() {
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
    //funcion validateTextField, en caso de no tener nada escrito en el titulo desactivaremos el boton, cuando se escriba activaremos el boton, para evitar guardar null
    @objc func validateTextField(sender: UITextField) {
        guard let title = taskTitle.text, !title.isEmpty else {
            taskButton.isEnabled = false
            taskButton.backgroundColor = .systemGray2
            return
        }
        taskButton.isEnabled = true
        taskButton.backgroundColor = .systemTeal
    }
}
