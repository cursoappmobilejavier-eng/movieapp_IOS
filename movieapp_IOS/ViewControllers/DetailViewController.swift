//
//  DetailViewController.swift
//  MovieApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: Outlets (conecta estos en el storyboard)
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!

    // MARK: Input
    var imdbID: String!

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Detalle"

        // Preparar UI inicial
        titleLabel.text = ""
        yearLabel.text = ""
        plotLabel.text = ""
        runtimeLabel.text = ""
        directorLabel.text = ""
        genreLabel.text = ""
        countryLabel.text = ""
        posterImageView.image = nil

        debugPrint("[DetailVC] viewDidLoad. imdbID =", imdbID ?? "nil")

        Task { [weak self] in
            await self?.loadDetail()
        }
    }

    // MARK: Data Loading

    private func loadDetail() async {
        guard let imdbID = imdbID else {
            debugPrint("[DetailVC] loadDetail aborted: imdbID es nil")
            return
        }

        debugPrint("[DetailVC] Llamando a MovieProvider.fetchMovieDetail(imdbID: \(imdbID))")
        let start = Date()
        let detail = await MovieProvider.fetchMovieDetail(imdbID: imdbID)
        let elapsed = Date().timeIntervalSince(start)
        debugPrint("[DetailVC] fetchMovieDetail completado en \(String(format: "%.2f", elapsed))s. Resultado es nil?", detail == nil)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let detail else {
                debugPrint("[DetailVC] No se pudo obtener detalle para imdbID:", imdbID)
                return
            }
            self.navigationItem.title = detail.title
            self.titleLabel.text = detail.title
            self.yearLabel.text = detail.year
            self.plotLabel.text = detail.plot ?? ""
            self.runtimeLabel.text = detail.runtime ?? ""
            self.directorLabel.text = detail.director ?? ""
            self.genreLabel.text = detail.genre ?? ""
            self.countryLabel.text = detail.country ?? ""

            let posterURL = detail.poster ?? ""
            debugPrint("[DetailVC] Asignando UI con título:", detail.title, "| year:", detail.year, "| poster:", posterURL)
            self.posterImageView.loadFrom(url: posterURL)
        }
    }
}
