//
//  HomeViewController.swift
//  ToDoAlsuper
//
//  Created by Leamsi Alvarado on 10/10/24.
//

import UIKit
import FirebaseAuth
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{

    


    @IBOutlet weak var tasksTable: UITableView!
    var tasks = [Tasks]()
    var fetchResultController : NSFetchedResultsController<Tasks>!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksTable.delegate = self
        tasksTable.dataSource = self
        showTasks()
    }
    
    
    //IBACTION con 3 botones para llamar filterTasks con su respectivo case
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





    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "delete"){(_,_,_)in
            let context = TaskModel.shared.context()
            let delete = self.fetchResultController.object(at: indexPath)
            context.delete(delete)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("no se pudo eliminar", error)
            }
        }
        
        
        delete.image = UIImage(systemName: "pencil.circle.fill")
        delete.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = self.fetchResultController.object(at: indexPath)
        let context = TaskModel.shared.context()

        
        task.completed.toggle()

        do {
            try context.save()
        } catch let error as NSError {
            print("No se pudo actualizar la tarea", error)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendData"{
            if let id = tasksTable.indexPathForSelectedRow{
                let row = tasks[id.row]
                let destination = segue.destination as! AddTaskViewController
                destination.task = row
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            
            self.performSegue(withIdentifier: "sendData", sender: self)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemCyan
        editAction.image = UIImage(systemName: "pencil.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }


    
    func showTasks() {
        let context = TaskModel.shared.context()
        let fetchRequest : NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let order = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [order]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            tasks = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("no se mostraron las tareas",  error.localizedDescription)
        }
    }
    
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tasksTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tasksTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        
        switch type {
        case .insert:
            self.tasksTable.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            self.tasksTable.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.tasksTable.reloadRows(at: [indexPath!], with: .fade )
        default:
            self.tasksTable.reloadData()
        }
        self.tasks = controller.fetchedObjects as! [Tasks]
        
    }
    
    func filterTasks(by criteria: String) {
        let context = TaskModel.shared.context()
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        switch criteria {
        case "title":
            
            let titlePredicate = NSPredicate(format: "title != nil")
            fetchRequest.predicate = titlePredicate
            let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [titleSortDescriptor]
            
        case "subtitle":
            let subtitlePredicate = NSPredicate(format: "subtitle != nil")
            fetchRequest.predicate = subtitlePredicate
            let subtitleSortDescriptor = NSSortDescriptor(key: "subtitle", ascending: true)
            fetchRequest.sortDescriptors = [subtitleSortDescriptor]
            
        case "completed":
            let completedPredicate = NSPredicate(format: "completed == %@", NSNumber(value: true))
            fetchRequest.predicate = completedPredicate
            let completedSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [completedSortDescriptor]
            
        default:
            break
        }
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            tasks = fetchResultController.fetchedObjects ?? []
            tasksTable.reloadData()
        } catch let error as NSError {
            print("No se pudieron mostrar las tareas filtradas: \(error.localizedDescription)")
        }
    }


    
}
