//
//  PopUpViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//

import UIKit

class PopUpViewController: UIViewController {
    
    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var newsTitle: UILabel!
    
    @IBOutlet weak var newsContent: UILabel!
    
    @IBOutlet weak var authorNewsTime: UILabel!
    
    
    var currentarticle: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async{ [self] in
            newsTitle.text = currentarticle?.title ?? "No title available"
            newsContent.text = ArticleHelper.formatContent(currentarticle?.content)
            authorNewsTime.text = ArticleHelper.formatAuthorDate(publishedAt: currentarticle?.publishedAt, author: currentarticle?.author)

                ArticleHelper.loadImage(into: newsImageView, from: currentarticle?.urlToImage) { [weak self] in

                }
        }
    }
    
    init(){
        super.init(nibName: "PopUpViewController", bundle: nil)
       // self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func appear(sender: UIViewController){
        sender.present(self,animated: true)
    }
    
    func configure(with article: Article){
        currentarticle = article
    }
    

}
