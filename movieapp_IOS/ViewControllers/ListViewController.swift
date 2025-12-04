//
//  ViewController.swift
//  RecipeApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {


    @IBOutlet weak var tableView: UITableView!


    var movies: [MovieSearchItem] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        Task { [weak self] in
            await self?.findMoviesByName(query: "Batman")
        }

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Películas"
    }


    func findMoviesByName(query: String) async {
        let results = await MovieProvider.searchMovies(query: query)
        DispatchQueue.main.async { [weak self] in
            self?.movies = results
            self?.tableView.reloadData()
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieViewCell
        let movie = movies[indexPath.row]
        cell.render(with: movie)
        return cell
    }

    // MARK: TableView Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowMovieDetail", sender: indexPath)
    }

    // MARK: SearchBar Delegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task { [weak self] in
            await self?.findMoviesByName(query: searchBar.text ?? "")
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Task { [weak self] in
            await self?.findMoviesByName(query: "")
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMovieDetail",
           let indexPath = sender as? IndexPath,
           let detailVC = segue.destination as? DetailViewController {
            let movie = movies[indexPath.row]
            detailVC.imdbID = movie.imdbID
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
