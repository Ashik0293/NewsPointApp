//
//  SearchViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    var viewModel = NewsViewModel.shared
    
    var filterarrayNews: [Article] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    let SearchBar = DynamicSearchBar(placeholders: [" Search Sports...", " Search Tech...", " Search Finance..."], timeInterval: 3,direction: .fromBottom,placeholdersOptions: [.infinite])
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var currentarticle: Article?
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        collectionView
            .setCollectionViewLayout(layout, animated: true)
        
        self.SearchBar.frame.origin.x = 0
        
        SearchBar.backgroundColor = UIColor.systemBackground
        SearchBar.delegate = self
        SearchBar.searchBarStyle = .minimal
        SearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(SearchBar)
        NSLayoutConstraint.activate([
            SearchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            SearchBar.leadingAnchor.constraint(equalTo:  view.trailingAnchor),
            SearchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            SearchBar.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tap.cancelsTouchesInView = false
           view.addGestureRecognizer(tap)
        
        addDoneButtonToSearchBar(SearchBar)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
//         if gesture.direction == .left {
//            viewModel.removeArticle(at: currentPage)
//            Toast.show(message: "This Article Was Deleted", in: self, duration: 3.0)
//            collectionView.reloadData()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            UIView.animate(withDuration: 0.50 ,animations: {
                self.SearchBar.frame.origin.x = 0
                UIView.animate(withDuration: 1.0, animations: {
                    NSLayoutConstraint.activate([
                        self.SearchBar.leadingAnchor.constraint(equalTo:  self.view.leadingAnchor),
                    ])
                })
            })
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        filterarrayNews = viewModel.filterArticles(with: searchText)
        collectionView.reloadData()
    }
    
    func addDoneButtonToSearchBar(_ searchBar: DynamicSearchBar) {
        if let textField = searchBar.searchTextField as? UITextField {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
            toolbar.items = [flexibleSpace, doneButton]
            textField.inputAccessoryView = toolbar
        }
    }


    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
}

extension SearchViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return isSearching ? filterarrayNews.count : viewModel.numberOfArticles

    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchListCollectionViewCell", for: indexPath) as! SearchListCollectionViewCell

        let articles = isSearching ? filterarrayNews : viewModel.articles

        if indexPath.row < articles.count {
            let article = articles[indexPath.row]
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
    
    func deleteArticle(at indexPath: IndexPath) {
        viewModel.removeArticle(at: currentPage)
        collectionView.reloadData()
    }


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentArticle()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let article = viewModel.getArticle(at: indexPath.row) {
         currentarticle = article
            let popUpView = PopUpViewController()
            popUpView.appear(sender: self)
            popUpView.configure(with: article)
         print("Initial visible article: \(article.title ?? "Unknown")")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 50, left: 15, bottom: 30, right: 15)
        
        
    }

    func collectionView(_ collectionView: UICollectionView,
                         layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: collectionView.bounds.width,
                       height: 80)
       }
    
    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteArticle(at: indexPath)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    private var isSearching: Bool {
        return !(SearchBar.text?.isEmpty ?? true)
    }
}

