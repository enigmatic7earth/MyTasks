//
//  ViewController.swift
//  MyTasks
//
//  Created by NETBIZ on 20/07/18.
//  Copyright © 2018 Netbiz.in. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    @IBOutlet weak var tableView: UITableView!
//    var buttonID = 0
    
    @IBAction func addTask(_ sender: Any)
    {
        let taskAlert = UIAlertController(title: "MyTasks", message: nil, preferredStyle: .alert)
        taskAlert.addTextField { (taskName: UITextField!)-> Void in
            taskName.placeholder = "Task name"
        }
        
        let add_task = UIAlertAction(title: "Add Task", style: .default) { [unowned taskAlert] _ in
            let task = taskAlert.textFields![0].text
            
            
            // Check if the view controller managed object context is not nil.
            // Since we are note cleaning this instance, on our case,
            // the guard will always return a valid context.
            // But despite that, let's have the correct way to use a optional variable.
            guard let _context = self.managedObjectContext else { return }
            
            // Using the Managed Object Context, lets create a new entry into entity "Task"
            let object = NSEntityDescription.insertNewObject(forEntityName: "Task", into: self.managedObjectContext!) as! Task
            
            // Now lets set his attributes. Since we didn't create a user interface to input
            // text, lets use the current date description as name, and by default set all
            // created tasks by default uncompleted.
            object.name = task
            object.completed = false
            
            do {
                // Then we try to persist the new entry.
                // And if everything went successfull the fetched results controller
                // will react and from the delegate methods it will call the reload
                // of the Table View.
                try _context.save()
            } catch {
                
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        taskAlert.addAction(add_task)
        taskAlert.addAction(cancel)
        
        present(taskAlert, animated: true)
        
        
        
        
        
    }
    
    // MARK: - Fetched results controller
    // The fetched results controller instance variable with the
    // pretended entity type we want to fetch from the Core Data.
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    // The proxy variable to serve as a lazy getter to our
    // fetched results controller.
    var fetchedResultsController: NSFetchedResultsController<Task>
    {
        // If the variable is already initialized we return that instance.
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        // If not lets build the required elements for the fetched
        // results controller.
        
        // First we need to create a fetch request with the pretended type.
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        // Set the batch size to a suitable number (optional).
        fetchRequest.fetchBatchSize = 20
        
        // Create at least one sort order attribute and type (ascending\descending)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        // Set the sort objects to the fetch request.
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Optionally, let's create a filter\predicate.
        // The goal of this predicate is to fetch Tasks that are not yet completed.
        let predicate = NSPredicate(format: "completed == FALSE")
        
        // Set the created predicate to our fetch request.
        fetchRequest.predicate = predicate
        
        // Create the fetched results controller instance with the defined attributes.
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set the delegate of the fetched results controller to the view controller.
        // with this we will get notified whenever occours changes on the data.
        aFetchedResultsController.delegate = self
        
        // Setting the created instance to the view controller instance.
        _fetchedResultsController = aFetchedResultsController
        
        do {
            // Perform the initial fetch to Core Data.
            // After this step, the fetched results controller
            // will only retrieve more records if necessary.
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
//    @objc func discloseDetails(_ sender: UIButton?){
////        @objc func discloseDetails(_ sender: UIButton?){
//
//
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
//        vc.headerLabel.text! = "Header"
//        vc.detailText.text! = "The quick brown fox jumps over the lazy dog. "+"\(sender!.tag)"
//        vc.modalPresentationStyle = UIModalPresentationStyle.popover
//        let popvc = vc.popoverPresentationController
//        popvc?.delegate = self
//        popvc?.permittedArrowDirections = UIPopoverArrowDirection.any
//        popvc?.sourceView = sender
//        vc.preferredContentSize = CGSize.init(width: 300, height: 200)
//
//        self.present(vc, animated: true, completion: nil)
//
//    }
    
}

extension ViewController : NSFetchedResultsControllerDelegate
{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Whenever a change occours on our data, we refresh the table view.
        self.tableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource
{
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        // We will use the proxy variable to our fetched results
        // controller and from that we try to get the sections
        // from it. If not available we will ignore and return none (0).
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // We will use the proxy variable to our fetcehed results
        // controller and from that we try to get from that section
        // index access to the number of objects available.
        // If not possible, we will ignore and return 0 objects.
        return self.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // First we get a cell from the table view with the identifier "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Then we get the object at the current index from the fetched results controller
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // And update the cell label with the task name
        cell.textLabel!.text = task.name
        
        // custom accessory view
//        buttonID = buttonID + 1
//
//        let disclosureButton = UIButton(type: .detailDisclosure)
//        disclosureButton.tag = buttonID
//        disclosureButton.addTarget(self, action: #selector(self.discloseDetails(_:)), for: .touchUpInside)
//        disclosureButton.setBackgroundImage(UIImage(named: "info"), for: .normal)
//        disclosureButton.tintColor = UIColor.clear
//        cell.accessoryView = disclosureButton
        
        // Finally we return the updated cell.
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Whenever a user swipes a cell, we will show two options.
        // A option to mark a task completed.
        let completeAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Complete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.markCompletedTaskIn(indexPath)
        })
        completeAction.backgroundColor = #colorLiteral(red: 0.09399999678, green: 0.7329999804, blue: 0.878000021, alpha: 1)
        

        
        // And a option to delete a task.
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.deleteTaskIn(indexPath)
        })
        deleteAction.backgroundColor = #colorLiteral(red: 0.9900000095, green: 0.4359999895, blue: 0.3459999859, alpha: 1)
        
        // And a option to delete a edit.
//        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Edit" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
//            self.deleteTaskIn(indexPath)
//        })
//        editAction.backgroundColor = #colorLiteral(red: 0.1140000001, green: 0.5370000005, blue: 0.3409999907, alpha: 1)
        return [deleteAction, completeAction]
    }
    
    func markCompletedTaskIn(_ indexPath : IndexPath)
    {
        // To mark a task completed we retrieve the corresponding
        // object from the cell index.
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // Update the attribute
        task.completed = true
        
        do {
            // And try to persist the change. If successfull
            // the fetched results controller will react and call the method
            // to reload the table view.
            try self.managedObjectContext?.save()
        } catch {}
    }
    
    func deleteTaskIn(_ indexPath : IndexPath)
    {
        // To delete a task we retrieve the corresponding
        // object from the cell index.
        let task = self.fetchedResultsController.object(at: indexPath)
        
        // Then we use the managed object context and delete that object.
        self.managedObjectContext?.delete(task)
        
        do {
            // And try to persist the change. If successfull
            // the fetched results controller will react and call the method
            // to reload the table view.
            try self.managedObjectContext?.save()
        } catch {}
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let selectedCell = tableView .cellForRow(at: indexPath)
        
        let taskName = selectedCell?.textLabel?.text as! String
        
//        print(taskName)
        let alert = UIAlertController(title: "", message: taskName, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
        
        
        
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
}
