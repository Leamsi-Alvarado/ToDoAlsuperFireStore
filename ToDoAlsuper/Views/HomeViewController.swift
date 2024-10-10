//
//  HomeViewController.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tasksTable: UITableView!
    var selectedTask: Task?
    var selectedIndexPath: IndexPath?
    var tasks: [Task] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTable.delegate = self
        tasksTable.dataSource = self
        
        observeTasks()
    }
    
    func observeTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Error obteniendo tareas: \(error)")
                    return
                }

                self.tasks.removeAll()
                
                for document in snapshot!.documents {
                    let data = document.data()
                    let title = data["title"] as? String ?? ""
                    let subtitle = data["subtitle"] as? String ?? ""
                    let completed = data["completed"] as? Bool ?? false
                    let id = document.documentID
                    
                    let task = Task(id: id, title: title, subtitle: subtitle, completed: completed, userId: data["userId"] as? String ?? "")
                    self.tasks.append(task)
                }
                
                self.tasksTable.reloadData()
            }
    }


    func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row]
        db.collection("tasks").document(taskToDelete.id).delete { error in
            if let error = error {
                print("Error al eliminar la tarea: \(error)")
            } else {
                print("Tarea eliminada correctamente")
            }
        }
    }

    
    @IBAction func filterByTitle(_ sender: Any) {
        filterTasks(by: "title")
    }
    
    @IBAction func filterBySubtitle(_ sender: Any) {
        filterTasks(by: "subtitle")
    }
    
    @IBAction func filterByCompleted(_ sender: Any) {
        filterTasks(by: "completed")
    }
    
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "session")
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]

        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = task.subtitle

        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .darkGray

        if task.completed {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            (cell.accessoryView as? UIImageView)?.tintColor = .black
            cell.backgroundColor = .systemGreen
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
        } else {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "circle"))
            (cell.accessoryView as? UIImageView)?.tintColor = .black
            cell.accessoryType = .none
        }

        return cell
    }


    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            self.selectedTask = self.tasks[indexPath.row]
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "sendData", sender: self)
            completionHandler(true)
        }

        editAction.backgroundColor = .systemCyan
        editAction.image = UIImage(systemName: "pencil.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }



    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.deleteTask(at: indexPath)
            completionHandler(true)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [delete])
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        var task = tasks[indexPath.row]
        
        task.completed.toggle()
        
        tasks[indexPath.row] = task
    
        db.collection("tasks").document(task.id).updateData(["completed": task.completed]) { error in
            if let error = error {
                print("Error al actualizar el estado de la tarea: \(error)")
            } else {
                print("Estado de la tarea actualizado correctamente")
            }
        }
        
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendData" {
            if let indexPath = selectedIndexPath {
                let row = tasks[indexPath.row]
                let destination = segue.destination as! AddTaskViewController
                destination.task = row
            }
        }
    }

    
    func showTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .order(by: "title")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error al obtener las tareas: \(error.localizedDescription)")
                } else {
                    self.tasks = querySnapshot?.documents.compactMap { document -> Task? in
                        let data = document.data()
                        return Task(id: document.documentID, title: data["title"] as? String ?? "", subtitle: data["subtitle"] as? String ?? "", completed: data["completed"] as? Bool ?? false, userId: data["userId"] as? String ?? "")
                    } ?? []
                    self.tasksTable.reloadData()
                }
            }
    }


    
    func filterTasks(by criteria: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        var query: Query!

        switch criteria {
        case "title":
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .order(by: "title")
        case "subtitle":
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .order(by: "subtitle")
        case "completed":
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .whereField("completed", isEqualTo: true)
                .order(by: "title")
        default:
            query = db.collection("tasks").whereField("userId", isEqualTo: userId)
        }

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("No se pudieron mostrar las tareas filtradas: \(error.localizedDescription)")
            } else {
                self.tasks = querySnapshot?.documents.compactMap { document -> Task? in
                    let data = document.data()
                    return Task(id: document.documentID, title: data["title"] as? String ?? "", subtitle: data["subtitle"] as? String ?? "", completed: data["completed"] as? Bool ?? false, userId: data["userId"] as? String ?? "")
                } ?? []
                self.tasksTable.reloadData()
            }
        }
    }




}

