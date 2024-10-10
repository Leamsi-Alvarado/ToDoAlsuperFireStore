import UIKit
import FirebaseFirestore
import FirebaseAuth
class AddTaskViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskTitle: UITextField!
  
    var task: Task?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if let task = task {

            taskTitle.text = task.title
            taskDescription.text = task.subtitle
            taskButton.setTitle("Editar", for: .normal)
            taskButton.backgroundColor = .systemTeal
        } else {
            textValidation()
        }

    }
    
    @IBAction func taskSave(_ sender: UIButton) {
        let title = taskTitle.text ?? ""
            let description = taskDescription.text ?? ""
            let completed = false
            let userId = Auth.auth().currentUser?.uid ?? ""

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
                // Crear nueva tarea
                let newTaskRef = db.collection("tasks").document()
                newTaskRef.setData([
                    "title": title,
                    "subtitle": description,
                    "completed": completed,
                    "userId": userId
                ]) { error in
                    if let error = error {
                        print("Error al guardar la tarea: \(error)")
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
    }
    
    func textValidation() {
        taskButton.isEnabled = false
        taskButton.backgroundColor = .systemGray2
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
    func textValidationEdition() {
        taskTitle.addTarget(self, action: #selector(validateTextField), for: .editingChanged)
    }
    
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
