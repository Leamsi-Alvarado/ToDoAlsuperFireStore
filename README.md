# Leamsi Alvarado
Contacto: leamsi-a-alvarado-g@outlook.com
## ToDo - Alsuper - FireStore
 Fecha de inicio: 10/OCT/2024 \
 Fecha solicitada entrega: 11/OCT/2024 \
 Versión CoreData: https://github.com/Leamsi-Alvarado/ToDoAlsuper \
 Ese link es la primera versión, sin FireStore, sin responsive, sin dark mode, entre otras funciones que la version de FireStore si tiene, solamente es por si interesa ver el dominio de CoreData
# Frameworks utilizados
 UiKit (Storyboards)
# Puntos de la aplicación
Authentication con Firestore
Guardado de datos con FireStore
Responsive para Iphone's y Ipad's
Dark y Light mode activado -> Cambiar ambiente en Modo Obscuro en las configuraciones del simulador
# Como correr la Aplicación
 La aplicación está lista para plug and play con la descarga de Xcode y un simulador, en caso de ser necesario instalar dependencias de FireBase en la aplicación\
para Realizarlo es necesario entrar en xcode -> Dar click en file -> Add Package dependencies -> pegar https://github.com/firebase/firebase-ios-sdk en el buscador e instalar Firebase, fireabaseAuth, FireStore

# Explicación de aplicación
Esta aplicación es un TodoList, tendremos: \
 [Login](#0a192f) -> para demostrar las habilidades con servicios de Authentication de Firebase, Proteccion visual de contraseñas.\
[Register](#0a192f) -> Para demostrar las habilidad con servicios de auth de firebase con la creación de usuarios.\
[Home](#0a192f) -> Uso de TableViews, Cells, Obtención de datos, Segue con parametros, cerrado de sesión, Filtro con 3 categorias, eliminación de datos (LeftSwipe), edición de datos (RightSwipe), completado de datos (Tap)\
[AddTask](#0a192f) -> Edición de datos, Creación de datos

El patron de presentación utilizado es MVVM, apesar de UiKit ser arraigado a ser un MVP puede ser utilizado como MVVM,por lo que he tomado la decisión de utilizar un ViewModel para hacer de manera más rapida las funciones de FireStore.

