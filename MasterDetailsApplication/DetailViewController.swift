import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var url: UILabel!
    
    var detailItem: ObjectDetail? {
        didSet {
            self.configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.name
            }
            if let nameLabel = self.name {
                nameLabel.text = detail.name
            }
            if let dateLabel = self.createdDate {
                dateLabel.text = detail.date
            }
            if let urlLabel = self.url {
                urlLabel.text = detail.htmlURL
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
                url.isUserInteractionEnabled = true
                url.addGestureRecognizer(tap)
            }
            
            let myURL=URL(string: detail.imageURL)
            let session=URLSession.shared
            let task=session.dataTask(with: myURL!, completionHandler: { (data, respone, error) in
                if data != nil {
                    let image=UIImage(data: data!)
                    if image != nil{
                        DispatchQueue.main.async {
                            self.image.image=image
                        }
                    }
                }
            })
            task.resume()
            
        }
        
    }
    
    
    func tapFunction(sender:UITapGestureRecognizer) {
        UIApplication.shared.open(URL(string: url.text!)!, options: [:], completionHandler: nil)
    }
    
}

