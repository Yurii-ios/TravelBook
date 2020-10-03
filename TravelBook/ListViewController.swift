//
//  ListViewController.swift
//  TravelBook
//
//  Created by Yurii Sameliuk on 08/02/2020.
//  Copyright © 2020 Yurii Sameliuk. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var idArray = [UUID]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var chosenTitle = String()
    var chosenId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // sozdaem knopky w panele nawigacii
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
   
    @objc func addButton() {
        
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    
    @objc func getData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let resaults = try context.fetch(fetchRequest)
            if resaults.count > 0 {
                //prežde 4em sachodit w cukl nyžno o4istit masiw
                self.titleArray.removeAll(keepingCapacity: false)
                self.idArray.removeAll(keepingCapacity: false)
                
                // [NSManagedObject] - tolko tak mu polu4em raznue rezyltatu iz bazu dannux
                for resault in resaults as! [NSManagedObject] {
                    if let title = resault.value(forKey: "title") as? String{
                        self.titleArray.append(title)
                    }
                    if let id = resault.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    tableView.reloadData()
                }
                
            }
        }catch {
            let nserror = error as NSError
            fatalError("\(nserror), \(nserror.userInfo)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destinationVC = segue.destination as? ViewController
            destinationVC?.selectedTitle = chosenTitle
            destinationVC?.selectedId = chosenId
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

