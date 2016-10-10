//
//  ContainersViewController.swift
//  Boot3Labs
//
//  Created by Juan Antonio Martin Noguera on 10/10/2016.
//  Copyright © 2016 Cloud On Mobile. All rights reserved.
//

import UIKit

class ContainersViewController: UITableViewController {

    var clientStorage: AZSCloudBlobClient?
    var accout: AZSCloudStorageAccount?
    var model: [AZSCloudBlobContainer]? = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = "Conatainers Explorer"
        
        setupStorageSession()
        setupTableView()
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }

    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELDA")
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl){
        self.readMyContainers()
        self.refreshControl?.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (model?.isEmpty)! {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (model?.isEmpty)! {
            return 0
        }
        return (model?.count)!
        
    }

    @IBAction func addContainer(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Nuevo Container", message: "Escribe un nombre de 3 a 24 caracteres", preferredStyle: .alert)
        
        
        let actionOk = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            let nameContainer = alert.textFields![0] as UITextField
            print("Boton OK --> \(nameContainer.text)")
            self.newContainer(nameContainer.text!)
            
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        alert.addTextField { (textField) in
            
            textField.placeholder = "Introduce un nombre para el container"
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDA", for: indexPath)

        // Configure the cell...
        let item = model?[indexPath.row]
        cell.textLabel?.text = item?.name

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.eraseContainer((self.model?[indexPath.row])!)
            self.model?.remove(at: indexPath.row)
            tableView.endUpdates()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = model?[indexPath.row].name
        
        performSegue(withIdentifier: "selectContainer", sender: item)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "selectContainer" {
            let vc = segue.destination as! ContainerViewController
            
            vc.nameContainer = sender as? String
            vc.clientStorage = self.clientStorage
        }

    }
    

    
    func readMyContainers() {
        clientStorage?.listContainersSegmented(with: nil,
                                               prefix: nil,
                                               containerListingDetails: AZSContainerListingDetails.all,
                                               maxResults: -1, completionHandler: { (error, containersResults) in
                                                
                                                if let _ = error {
                                                    print(error)
                                                    return
                                                }
                                                
                                                if !(self.model?.isEmpty)! {
                                                    self.model?.removeAll()
                                                }
                                                for items in (containersResults?.results)!  {
                                                    print(items)
                                                    
                                                    self.model?.append((items as? AZSCloudBlobContainer)!)
                                                }
                                                
                                                DispatchQueue.main.async {
                                                    
                                                    self.tableView.reloadData()
                                                }
                                                
        })

    }
    
    
    func setupStorageSession(){
        
      
        do {
            let credentials = AZSStorageCredentials.init(accountName: "#Aqui la cuenta de Storage", accountKey: "#Aqui tu Key")
            accout = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            
            clientStorage = accout?.getBlobClient()
            
            readMyContainers()
            
        } catch let error {
            print(error)
        }
    }
    
    func newContainer(_ name: String) {
    
        // creamos la referencia al contenedor en local
        
        let blobContainer = clientStorage?.containerReference(fromName: name.lowercased())
        
        blobContainer?.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil,
                                                  completionHandler: { (error, noExists) in
            
            if let _ = error {
                print(error)
            }
            if noExists {
                print("Creado con exito")
                self.readMyContainers()
            } else {
                print("Ya estaba creado")
            }
            
            
        })
        
    }
    
    func eraseContainer(_ container: AZSCloudBlobContainer) {
        
        container.deleteIfExists { (error, deleted) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if deleted {
                print("Borrando")
                self.readMyContainers()
            } else {
                print("no borrado")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
