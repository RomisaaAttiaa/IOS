
import UIKit
import CoreData

class MasterViewController: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var detailViewController: DetailViewController? = nil
    var objects = [ObjectDetail]()
    
    var name: String=""
    var desc:String = ""
    var owner:String = ""
    var fullName:String = ""
    var imageURL:String = ""
    var date:String = ""
    var htmlURL:String = ""
    var fork:Bool=false
    
    var pageNo:Int=1;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        objects=self.fetchFromCoredata()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        objects.removeAll()
        deleteAllRecordsFromCoreData()
        self.tableView.reloadData()
        getDataFromServer(url: URL(string:"https://api.github.com/search/repositories?q="+searchBar.text!+"&page=\(pageNo)&per_page=10")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = objects[indexPath.row]
        
        let nameLabel:UILabel=cell.viewWithTag(1) as! UILabel
        nameLabel.text=object.name
        
        let ownerLabel:UILabel=cell.viewWithTag(2) as! UILabel
        ownerLabel.text=object.owner
        
        let desLabel:UILabel=cell.viewWithTag(3) as! UILabel
        desLabel.text=object.desc
        
        if object.fork==true{
            cell.backgroundColor = UIColor.blue
            
        }
        
        if indexPath.row == objects.count-1{
            pageNo += 1
            getDataFromServer(url: URL(string:"https://api.github.com/search/repositories?q="+searchBar.text!+"&page=\(pageNo)&per_page=10")!)
        }
        
        return cell
    }
    
    
    
    func getDataFromServer(url: URL){
        
        let myurl=url
        var tempArray = [ObjectDetail]()
        let request=URLRequest(url:myurl)
        let session=URLSession(configuration:URLSessionConfiguration.default)
        let task=session.dataTask(with: request){
            (data,response,error)in
            do{
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String,Any>
                
                if json.count > 0{
                    print(json)
                    let myArr:Array<Dictionary<String,Any>>?=(json["items"] as? Array<Dictionary<String,Any>>)
                    if let arr = myArr{
                        for result in arr{
                            self.name=result["name"] as! String
                            if let  temp = result["description"] as? NSNull{self.desc="" }
                            else{ self.desc=result["description"] as! String }
                            
                            self.date=result["created_at"] as! String
                            self.fork=result["fork"] as! Bool
                            let owner:Dictionary<String,Any>=result["owner"] as! Dictionary<String,Any>
                            for (key,value) in owner{
                                if key=="login"{self.owner=value as! String}
                                if key=="full_name"{ self.fullName=value as! String}
                                if key=="avatar_url"{ self.imageURL=value as! String}
                                if key=="html_url"{self.htmlURL=value as! String}
                            }
                            
                            let repoObject=ObjectDetail(name: self.name,desc: self.desc,owner: self.owner,fullName: self.fullName,imageURL: self.imageURL,date: self.date,htmlURL: self.htmlURL,fork: self.fork)
                            
                            
                            tempArray.append(repoObject)
                            
                            self.insertInCoreData(name: self.name,desc:self.desc,owner:self.owner,fullName:self.fullName,image:self.imageURL,date: self.date,htmlURL:self.htmlURL,fork:self.fork)
                            
                        }
                        self.objects.append(contentsOf: tempArray)
                        self.tableView.reloadData()
                    }
                    
                }
            }catch{
                print("error  is done ")
            }
        }
        task.resume()
    }
    
    
    
    func insertInCoreData(name: String,desc:String,owner:String,fullName:String,image:String,date:String,htmlURL:String,fork:Bool) {
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let mangmentContext=appDelegate.persistentContainer.viewContext
        
        let entity=NSEntityDescription.entity(forEntityName: "Entity", in: mangmentContext)
        let repo = NSManagedObject(entity: entity!,insertInto: mangmentContext)
        
        repo.setValue(name, forKeyPath: "name")
        repo.setValue(desc, forKeyPath: "desc")
        repo.setValue(owner, forKeyPath: "owner")
        repo.setValue(fullName, forKeyPath: "fullName")
        repo.setValue(image, forKeyPath: "imageURL")
        repo.setValue(date, forKeyPath: "date")
        repo.setValue(htmlURL, forKeyPath: "htmlURL")
        repo.setValue(fork, forKeyPath: "fork")
        do {
            try mangmentContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
    func fetchFromCoredata() -> [ObjectDetail]{
        var objectsDetails = [ObjectDetail]()
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let mangmentContext=appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        
        fetchRequest.returnsObjectsAsFaults=false
        
        do {
            let result = try mangmentContext.fetch(fetchRequest)
            
            if (result.count > 0) {
                for res in result{
                    
                    let name=res.value(forKey: "name")!
                    let desc=res.value(forKey: "desc")!
                    let owner=res.value(forKey: "owner")!
                    let date=res.value(forKey: "date")!
                    let fullName=res.value(forKey: "fullName")!
                    let imageURL=res.value(forKey: "imageURL")!
                    let htmlURL=res.value(forKey: "htmlURL")!
                    let fork=res.value(forKey: "fork")!
                    
                    
                    let repoObject=ObjectDetail(name: name as! String,desc:desc as! String,owner: owner as! String,fullName: fullName as! String,imageURL: imageURL as! String,date:date as! String,htmlURL: htmlURL as! String,fork:fork as! Bool)
                    
                    objectsDetails.append(repoObject)
                   
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return objectsDetails
        
    }
    
    
    func deleteAllRecordsFromCoreData(){
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let mangmentContext=appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try mangmentContext.execute(deleteRequest)
            try mangmentContext.save()
        } catch {
            print ("There was an error")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}

