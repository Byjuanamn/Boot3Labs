
import UIKit

class ContainerViewController: UITableViewController {

    
    var model: [AZSCloudBlockBlob]? = []
    var clientStorage: AZSCloudBlobClient?
    var nameContainer: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = title! + " " + nameContainer!
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELDABLOB")
        
        let boton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(uploadBlob))
        self.navigationController?.navigationItem.rightBarButtonItem = boton
        
        readMyBlobs()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if (self.model?.isEmpty)! {
            return 0
        }
        return (self.model?.count)!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !(self.model?.isEmpty)! {
            return (self.model?.count)!
        }
        return 0
    }
    
    @IBAction func uploadAction(_ sender: AnyObject) {
        
        uploadBlob()
    }

    func readMyBlobs()  {
        
        // referencia al contenedor
        
        let container = clientStorage?.containerReference(fromName: nameContainer!)
        
        container?.listBlobsSegmented(with: nil, prefix: nil, useFlatBlobListing: true, blobListingDetails: AZSBlobListingDetails.all, maxResults: -1, completionHandler: { (error, results) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if !(self.model?.isEmpty)! {
                self.model?.removeAll()
            }
            
            for items in (results?.blobs)! {
                let blob = items as? AZSCloudBlockBlob
                print(blob?.blobName)
                
                self.model?.append(blob!)
            }
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELDABLOB", for: indexPath)

        // Configure the cell...
        
        let item = self.model?[indexPath.row]
        cell.textLabel?.text = item?.blobName

        return cell
    }
    
    
    func uploadBlob() {
        
        let container = clientStorage?.containerReference(fromName: nameContainer!)
        
        let blobBlock = container?.blockBlobReference(fromName: UUID().uuidString)
        
        let image = UIImage(named: "winter-is-coming.jpg")
        
        blobBlock?.upload(from: UIImageJPEGRepresentation(image!, 0.5)!, completionHandler: { (error) in
            
            if error != nil {
                print("nada")
            } else {
                self.readMyBlobs()
            }
            
        })
    }
    
    func deleteBlob(_ name: String){
        
        let container = clientStorage?.containerReference(fromName: nameContainer!)
        let blobBlock = container?.blockBlobReference(fromName: name)
        
        blobBlock?.delete(completionHandler: { (error) in
            if let _ = error {
                print(error)
            } else {
                self.readMyBlobs()
            }
            
        })
    }
    
    func downloadBlob(_ name: String)  {
        let container = clientStorage?.containerReference(fromName: nameContainer!)
        let blobBlock = container?.blockBlobReference(fromName: name)
        
        blobBlock?.downloadToData(completionHandler: { (error, data) in
            
            if let _ = error {
                print(error)
                return
            }
            
            if let _ = data {
                var image = UIImage(data: data!)
                print("imagen descargada \(data?.count)")
            }
        })
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
            // Delete the row from the data source
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            let name = model?[indexPath.row].blobName
            model?.remove(at: indexPath.row)
            deleteBlob(name!)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = model?[indexPath.row].blobName
        
        self.downloadBlob(item!)
    }
       /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
