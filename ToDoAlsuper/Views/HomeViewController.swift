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

    //Variables y constantes utilizadas en funciones
    @IBOutlet weak var tasksTable: UITableView!
    var selectedTask: Task?
    var selectedIndexPath: IndexPath?
    var tasks: [Task] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate y dataSource de la tabla de la view actual (SIN ESTO LA TABLA NO FUNCIONARIA)
        tasksTable.delegate = self
        tasksTable.dataSource = self
        
        observeTasks()
    }
    
    //ObeserveTasks se creo porque necesitamos autenticar y actualizar los datos en un orden, Siempre que la view carga ejecutamos esta funcion, para traer las Tasks del usuario en cuestión
    func observeTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return } //Jalamos el UserID para saber que Tasks son de este usuario en especifico

        db.collection("tasks")
            .whereField("userId", isEqualTo: userId) //entramos con la referencia db a la colección tasks, y filtramos por USERID las tasks
            .addSnapshotListener { [weak self] (snapshot, error) in //Obvservable que ve los cambios de la colección de esta forma, en el momento que un usuario guarde una task la podemos ver en cuanto salga a la view anterior.
                guard let self = self else { return }
                if let error = error {
                    print("Error obteniendo tareas: \(error)")
                    return
                }

                self.tasks.removeAll() //Evitamos duplicados de datos.
                
                for document in snapshot!.documents { //empezamos for para obtener los datos de las Tasks
                    let data = document.data() //convertimos la data en un diccionario, el objetivo es tener esta data lista para a cada variabla añadirle su respectivo campo
                    let title = data["title"] as? String ?? ""
                    let subtitle = data["subtitle"] as? String ?? ""
                    let completed = data["completed"] as? Bool ?? false
                    let id = document.documentID
                    
                    let task = Task(id: id, title: title, subtitle: subtitle, completed: completed, userId: data["userId"] as? String ?? "") //Creamos una instancia de Task.
                    self.tasks.append(task) //añadimos a nuestro arreglo la task
                }
                
                self.tasksTable.reloadData() //Recargamos la tabla
            }
    }

//Funcion para eliminar
    func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = tasks[indexPath.row] //Guardamos los datos de la task seleccionada
        db.collection("tasks").document(taskToDelete.id).delete { error in //utilizamos la funcion de nuestra instancia de firestore delete y como parametro mandamos el id que obtuvimos anteriormente
            if let error = error {
                print("Error al eliminar la tarea: \(error)")
            } else {
                print("Tarea eliminada correctamente")
            }
        }
    }

    //Boton para filtrar por titulo
    @IBAction func filterByTitle(_ sender: Any) {
        filterTasks(by: "title")
    }
    //Boton para filtrar por subtitulo
    @IBAction func filterBySubtitle(_ sender: Any) {
        filterTasks(by: "subtitle")
    }
    //Boton para filtrar por tareas completadas
    @IBAction func filterByCompleted(_ sender: Any) {
        filterTasks(by: "completed")
    }
    //Boton para cerrar sesión
    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut() //Intentamos usar la funcion SignOut de Auth
        UserDefaults.standard.removeObject(forKey: "session") //Borramos los datos guardados como Session de nuestro UserDefaults (para que pueda iniciar sesión con otra cuenta)
        dismiss(animated: true, completion: nil) //Hacemos un dismiss de la view para pasar a la view anterior
    }
    //Funcion CRUCIAL para la creacion de un tableView, mandamos el numero de rows a utilizar (tasks.count)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //La Creación de las celdas esta aqui
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tasksTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) //utilizamos un identificador usado en el Main.StoryBoard
        let task = tasks[indexPath.row] //Obtenemos las task

        cell.textLabel?.text = task.title //damos un titulo que viene desde la data que obtuvimos
        cell.detailTextLabel?.text = task.subtitle //damos un subtitulo

        cell.backgroundColor = .white //ponemos el background blanco
        cell.textLabel?.textColor = .black //el texto negro
        cell.detailTextLabel?.textColor = .darkGray

        if task.completed { //si completed es True
            cell.accessoryView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")) //ponemos el icono con checkmark
            (cell.accessoryView as? UIImageView)?.tintColor = .black
            cell.backgroundColor = .systemGreen //backgroun verde
            cell.textLabel?.textColor = .white //texto blanco
            cell.detailTextLabel?.textColor = .white
        } else {//en caso de que no este completado
            cell.accessoryView = UIImageView(image: UIImage(systemName: "circle"))
            (cell.accessoryView as? UIImageView)?.tintColor = .black
            cell.accessoryType = .none
        }

        return cell
    }

//Funcion para cuando se arrastra el CELL de izquierda a derecha
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in //funcion para hacer el swipe
            self.selectedTask = self.tasks[indexPath.row] //saber cual vamos a editar
            self.selectedIndexPath = indexPath //sabemos el indexpath
            self.performSegue(withIdentifier: "sendData", sender: self) //ejecutamos el segue que nos lleva a AddTaskViewcoNTROLLER
            completionHandler(true) //COMPLETAMOS
        }

        editAction.backgroundColor = .systemCyan //el color del swip
        editAction.image = UIImage(systemName: "pencil.circle.fill") //el icono del swipe
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }



    //Esta funcion es para cuando se arrastra el CELL de derecha izquierda
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in //funcion para hacer el swipe
            self.deleteTask(at: indexPath) //Borrar data como sabemos que row sabmoes cual borrar
            completionHandler(true) //se completo el borrado
        }
        delete.image = UIImage(systemName: "trash") //diseño de lo que esta detras del swipe, icono de basura
        delete.backgroundColor = .red //color rojo
        return UISwipeActionsConfiguration(actions: [delete]) //return de un UISwipeAction
    }

    //Crucial para saber si clickean un ROW de la tabla
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        var task = tasks[indexPath.row] //vemos que row picaron
        
        task.completed.toggle() //Cambiamos el valor del atributo completed
        
        tasks[indexPath.row] = task //
    //entramos a la collecion para cambiar el completed
        db.collection("tasks").document(task.id).updateData(["completed": task.completed]) { error in
            if let error = error {
                print("Error al actualizar el estado de la tarea: \(error)")
            } else {
                print("Estado de la tarea actualizado correctamente")
            }
        }
        
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    //Con esta funcion perparamos el Segue (Cambio de view), para mandarlos datos
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendData" { //Aqui listamos los segues de la view en cuestion
            if let indexPath = selectedIndexPath {
                let row = tasks[indexPath.row] //obtenemos el row a mandar
                let destination = segue.destination as! AddTaskViewController //ponemos el destino de este segue, con esto podemos acceder a las variables del destino
                destination.task = row // Destino.Variable = VariableLocal (es la forma mas rapida de entenderlo)
            }
        }
    }

    
    func showTasks() {
        guard let userId = Auth.auth().currentUser?.uid else { return } //Obteneoms id como antes

        db.collection("tasks") //entramos a la coleccion
            .whereField("userId", isEqualTo: userId) //filtramos por UserId
            .order(by: "title") //ordenamos por titulo (siempre es al inicio asi)
            .getDocuments { (querySnapshot, error) in
                if let error = error { //En caso de no tener los datos, mandamos error y razon
                    print("Error al obtener las tareas: \(error.localizedDescription)")
                } else {
                    self.tasks = querySnapshot?.documents.compactMap { document -> Task? in //mapeo
                        let data = document.data() //misma forma de traer data
                        return Task(id: document.documentID, title: data["title"] as? String ?? "", subtitle: data["subtitle"] as? String ?? "", completed: data["completed"] as? Bool ?? false, userId: data["userId"] as? String ?? "")
                    } ?? []
                    self.tasksTable.reloadData() //recargamos tabla
                }
            }
    }


    //Aqui hacemos los filtros
    func filterTasks(by filteredBy: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } //Obtenemos el userID

        var query: Query! //creamos una variable de tipo Query para poder jugar con los datos dentro de nuestra app

        //hacemos un switch para saber como vamos a filtrar, para lograrlo deben crearse INDICES dentro de firestore, estos fueron creados con estas 3 formas de filtrar
        switch filteredBy {
        case "title": //en caso de titulo se hace un query, de la colección tasks siempre por el usaerID y un orderBY de titulo
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .order(by: "title")
        case "subtitle": //lo mismo que titulo pero con subtitulo
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .order(by: "subtitle")
        case "completed": //Se filtra los que completes sea TRUE y sorteamos por titulo
            query = db.collection("tasks")
                .whereField("userId", isEqualTo: userId)
                .whereField("completed", isEqualTo: true)
                .order(by: "title")
        default: //El Default dejamos un filtro de solo userid
            query = db.collection("tasks").whereField("userId", isEqualTo: userId)
        }

        query.getDocuments { (querySnapshot, error) in
            if let error = error { //en caso de tener problema de obtencion de datos
                print("No se pudieron mostrar las tareas filtradas: \(error.localizedDescription)")
            } else {
                self.tasks = querySnapshot?.documents.compactMap { document -> Task? in //mapeamos los datos obtenidos
                    let data = document.data() //misma forma de convertir en diccionario
                    return Task(id: document.documentID, title: data["title"] as? String ?? "", subtitle: data["subtitle"] as? String ?? "", completed: data["completed"] as? Bool ?? false, userId: data["userId"] as? String ?? "") //obtenermos los datos que sacamos del diccionario
                } ?? []
                self.tasksTable.reloadData() //reiniciamos la tabla
            }
        }
    }




}

