//
//  HomeViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    @IBOutlet weak var SwipeView: UIView!
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    var viewModel = NewsViewModel.shared
    
    let refreshControl = UIRefreshControl()
    
    var currentPage = 0
    
    var currentarticle: Article?
    
    let pageSize = 20
    
    var isLoading = false
    
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        loadData()
        setupSwipeGestures()
        retrieveandSaveData()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        LoadUserImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCurrentArticle()
    }
    
    
    
    
    private func LoadUserImage() {
        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first {
                if let imageData = user.profileImage {
                    userImage.image = UIImage(data: imageData)
                }else{
                    userImage.image = UIImage(named: "personImage")
                }
            } else {
                
            }
        } catch {
            print("Error fetching from CoreData: \(error.localizedDescription)")
        }
    }
        
    func retrieveandSaveData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Entity> = Entity.fetchRequest()
        

        do {
            let users = try context.fetch(fetchRequest)

            if let user = users.first, let imageData = user.profileImage {
                self.userImage.image = UIImage(data: imageData)
            } else {
                if let imageurl = URL(string: UserDefaults.standard.string(forKey: "userphoto") ?? "") {
                    URLSession.shared.dataTask(with: imageurl) { (data, response, error) in
                        if let data = data, error == nil {
                            DispatchQueue.main.async {
                                self.userImage.image = UIImage(data: data)
                            }

                            let newUser = Entity(context: context)
                            newUser.profileImage = data

                            do {
                                try context.save()
                            } catch {
                                print("Failed to save image to Core Data:", error)
                            }
                        }
                    }.resume()
                }
            }

        } catch {
            print("Failed to fetch from Core Data:", error)
        }
    }

    
    private func setupSwipeGestures() {
        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUP.direction = .up
        SwipeView.addGestureRecognizer(swipeUP)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        SwipeView.addGestureRecognizer(swipeDown)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .up {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else if gesture.direction == .down {
            currentPage -= 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }else if gesture.direction == .right {
            
            if let article = currentarticle {
                let popUpView = PopUpViewController()
                popUpView.appear(sender: self)
                popUpView.configure(with: article)
            }
            
        }else if gesture.direction == .left {
            viewModel.removeArticle(at: currentPage)
            Toast.show(message: "This Article Was Deleted", in: self, duration: 3.0)
            collectionView.reloadData()
        }
    }
    
    func removeArticle(at index: Int) {
        guard index >= 0 && index < NewsManager.shared.articles.count else { return }
        NewsManager.shared.articles.remove(at: index)
        collectionView.reloadData()
    }

    
    private func loadData() {
            viewModel.fetchNews(page: currentPage, pageSize: pageSize) { success in
                DispatchQueue.main.async {
                    if success {
                        self.collectionView.reloadData()
                    } else {
                        print("Failed to load news")
                    }
                }
            }
        }
        
        @objc func refreshData() {
            viewModel.fetchNews(page: currentPage, pageSize: pageSize) { success in
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    if success {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height * 1.5, !isLoading {
            isLoading = true
            loadData()
        }
    }
    
}

extension HomeViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.numberOfArticles
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsListCollectionViewCell", for: indexPath) as! NewsListCollectionViewCell
        
        if let article = viewModel.getArticle(at: indexPath.row) {
            cell.configure(with: article)
            currentarticle = article
        }
        
        return cell
        
    }
    
    func updateCurrentArticle() {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)),
           let article = viewModel.getArticle(at: indexPath.row) {
            currentarticle = article
            print("Initial visible article: \(article.title ?? "Unknown")")
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentArticle()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: collectionView.bounds.width,
                       height: collectionView.bounds.height)
       }
    
}

