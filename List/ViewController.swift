//
//  ViewController.swift
//  List
//
//  Created by Bladimir Reyes on 5/3/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

struct ToDo: Equatable {
    let id = UUID()
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?

    static func ==(lhs: ToDo, rhs: ToDo) -> Bool {
        return lhs.id == rhs.id
    }
}
var todos = [ToDo]()

override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todos.count
}

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath)

    let todo = todos[indexPath.row]
    cell.textLabel?.text = todo.title
    return cell
}

static func loadToDos() -> [ToDo]?  {
    return nil
}

static func loadSampleToDos() -> [ToDo] {
    let todo1 = ToDo(title: "ToDo One", isComplete: false, dueDate: Date(), notes: "Notes 1")
    let todo2 = ToDo(title: "ToDo Two", isComplete: false, dueDate: Date(), notes: "Notes 2")
    let todo3 = ToDo(title: "ToDo Three", isComplete: false, dueDate: Date(), notes: "Notes 3")

    return [todo1, todo2, todo3]
}

override func viewDidLoad() {
    super.viewDidLoad()

    if let savedToDos = ToDo.loadToDos() {
        todos = savedToDos
    } else {
        todos = ToDo.loadSampleToDos()
    }
}

override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}

override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        todos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

@IBAction func unwindToToDoList(segue: UIStoryboardSegue) {

}

@IBOutlet var titleTextField: UITextField!
@IBOutlet var isCompleteButton: UIButton!
@IBOutlet var dueDateLabel: UILabel!
@IBOutlet var dueDatePickerView: UIDatePicker!
@IBOutlet var notesTextView: UITextView!


@IBOutlet var saveButton: UIBarButtonItem!


func updateSaveButtonState() {
    let shouldEnableSaveButton = titleTextField.text?.isEmpty == false
    saveButton.isEnabled = shouldEnableSaveButton
}

override func viewDidLoad() {
    super.viewDidLoad()
    updateSaveButtonState()
}


@IBAction func returnPressed(_ sender: UITextField) {
    sender.resignFirstResponder()
}

@IBAction func isCompleteButtonTapped(_ sender: UIButton) {
    isCompleteButton.isSelected.toggle()
}

//Inside ToDo type definition
static let dueDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

override func viewDidLoad() {
    super.viewDidLoad()
    updateDueDateLabel(date: dueDatePickerView.date)
    updateSaveButtonState()
}

func updateDueDateLabel(date: Date) {
    dueDateLabel.text = ToDo.dueDateFormatter.string(from: date)
}

@IBAction func datePickerChanged(_ sender: UIDatePicker) {
    updateDueDateLabel(date: sender.date)
}

override func viewDidLoad() {
    super.viewDidLoad()
    dueDatePickerView.date = Date().addingTimeInterval(24*60*60)
    updateDueDateLabel(date: dueDatePickerView.date)
    updateSaveButtonState()
}

var isDatePickerHidden = true
let dateLabelIndexPath = IndexPath(row: 0, section: 1)
let datePickerIndexPath = IndexPath(row: 1, section: 1)
let notesIndexPath = IndexPath(row: 0, section: 2)

override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath {
    case datePickerIndexPath where isDatePickerHidden == true:
        return 0
    case notesIndexPath:
        return 200
    default:
        return UITableView.automaticDimension
    }
}

override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath == dateLabelIndexPath {
        isDatePickerHidden.toggle()
        dueDateLabel.textColor = .black
        updateDueDateLabel(date: dueDatePickerView.date)
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)

    guard segue.identifier == "saveUnwind" else { return }

    let title = titleTextField.text!
    let isComplete = isCompleteButton.isSelected
    let dueDate = dueDatePickerView.date
    let notes = notesTextView.text
}

var todo: ToDo?
todo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)

@IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
    guard segue.identifier == "saveUnwind" else { return }
    let sourceViewController = segue.source as! ToDoDetailTableViewController

    if let todo = sourceViewController.todo {
        let newIndexPath = IndexPath(row: todos.count, section: 0)

        todos.append(todo)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
}

@IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
    guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
        return nil
    }
    tableView.deselectRow(at: indexPath, animated: true)

    let detailController = ToDoDetailTableViewController(coder: coder)
    detailController?.todo = todos[indexPath.row]

    return detailController
}

override func viewDidLoad() {
    super.viewDidLoad()
    if let todo = todo {
      navigationItem.title = "To-Do"
      titleTextField.text = todo.title
      isCompleteButton.isSelected = todo.isComplete
      dueDatePickerView.date = todo.dueDate
      notesTextView.text = todo.notes
    } else {
      dueDatePickerView.date = Date().addingTimeInterval(24*60*60)
    }

    updateDueDateLabel(date: dueDatePickerView.date)
    updateSaveButtonState()
}

@IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
    guard segue.identifier == "saveUnwind" else { return }
    let sourceViewController = segue.source as! ToDoDetailTableViewController

    if let todo = sourceViewController.todo {
        if let indexOfExistingToDo = todos.firstIndex(of: todo) {
            todos[indexOfExistingToDo] = todo
            tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: todos.count, section: 0)
            todos.append(todo)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
}

let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

    let todo = todos[indexPath.row]
    cell.titleLabel?.text = todo.title
    cell.isCompleteButton.isSelected = todo.isComplete

    return cell
}

protocol ToDoCellDelegate: AnyObject {
    func checkmarkTapped(sender: ToDoCell)
}

weak var delegate: ToDoCellDelegate?

@IBAction func completeButtonTapped() {
    delegate?.checkmarkTapped(sender: self)
}

class ToDoTableViewController: UITableViewController, ToDoCellDelegate

func checkmarkTapped(sender: ToDoCell) {

}

cell.delegate = self

func checkmarkTapped(sender: ToDoCell) {
    if let indexPath = tableView.indexPath(for: sender) {
        var todo = todos[indexPath.row]
        todo.isComplete.toggle()
        todos[indexPath.row] = todo
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

struct ToDo: Equatable, Codable { ... }
static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
static let archiveURL = documentsDirectory.appendingPathComponent("todos").appendingPathExtension("plist")


static func loadToDos() -> [ToDo]?  {
    guard let codedToDos = try? Data(contentsOf: archiveURL) else {return nil}
    let propertyListDecoder = PropertyListDecoder()
    return try? propertyListDecoder.decode(Array<ToDo>.self, from: codedToDos)
}

static func saveToDos(_ todos: [ToDo]) {
    let propertyListEncoder = PropertyListEncoder()
    let codedToDos = try? propertyListEncoder.encode(todos)
    try? codedToDos?.write(to: archiveURL, options: .noFileProtection)
}

override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        todos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        ToDo.saveToDos(todos)
    }
}

@IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
    guard segue.identifier == "saveUnwind" else { return }
    let sourceViewController = segue.source as! ToDoDetailTableViewController

    if let todo = sourceViewController.todo {
        if let indexOfExistingToDo = todos.firstIndex(of: todo) {
            todos[indexOfExistingToDo] = todo
            tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
        } else {
            let newIndexPath = IndexPath(row: todos.count, section: 0)
            todos.append(todo)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    ToDo.saveToDos(todos)
}

func checkmarkTapped(sender: ToDoCell) {
    if let indexPath = tableView.indexPath(for: sender) {
        var todo = todos[indexPath.row]
        todo.isComplete.toggle()
        todos[indexPath.row] = todo
        tableView.reloadRows(at: [indexPath], with: .automatic)
        ToDo.saveToDos(todos)
    }
}


