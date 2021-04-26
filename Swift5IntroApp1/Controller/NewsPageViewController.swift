//
//  NewsPageViewController.swift
//  Swift5IntroApp1
//
//  Created by user on 2021/04/16.
//

//タップされたニュース記事ごとの処理

import UIKit
import SegementSlide
import Alamofire
import SwiftyJSON

class NewsPageViewController: UITableViewController, SegementSlideContentScrollViewDelegate{
    
    var jsonDataArray = [JSONModel]()
    
    var urlString:String?
    
    init(urlString: String){
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        request()
        print(self.jsonDataArray)
        
    }

    @objc var scrollView: UIScrollView{
        return tableView
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonDataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height / 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        let article = self.jsonDataArray[indexPath.row]
        
        cell.backgroundColor = .systemGreen
        cell.textLabel?.text = article.title
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        cell.textLabel?.textColor = .black
        cell.textLabel?.numberOfLines = 3
            
        cell.detailTextLabel?.text = article.url
        cell.detailTextLabel?.textColor = .black
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //WKWebViewControllerにURLを渡して表示

        let webViewController = WebViewController()
        webViewController.modalTransitionStyle = .crossDissolve
        let article = jsonDataArray[indexPath.row]
        UserDefaults.standard.set(article.url, forKey: "url")
        present(webViewController, animated: true, completion: nil)
        
    }
    
    func request() {

        AF.request(urlString! as URLConvertible , method: .get,encoding: JSONEncoding.default).responseJSON{(response) in
            switch response.result{
            case .success:
                do{
                    
                    let json:JSON = try JSON(data: response.data!)
                    var totalHitCount = json.count
                    
                    if totalHitCount > 50{
                        totalHitCount = 50
                    }
                    
                    for i in 0...totalHitCount - 1 {
                        
                        if json[i]["title"] != "" && json[i]["url"] != "" {
                            
                            let item = JSONModel(title: json[i]["title"].string, url: json[i]["url"].string)
                            self.jsonDataArray.append(item)
                           
                        }else{
                            print("何かしらが空です")
                        }
                    }
                    
                }catch{
                    print("error")
                }
                
                break
                
            case .failure:break
                
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
}
