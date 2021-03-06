/**
 * Copyright (c) 2016 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import AlamofireImage

let kCellReuseIdentifier = "Cell"

// MARK: MoviesViewController: UIViewController

class MoviesViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var imageView: UIImageView!
  
  // MARK: Properties
  
  private let tableViewDataSource = MoviesTableViewDataSource()
  var tmdb: TMDb!
  
  var didSelect: (Movie) -> () = { _ in }
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  // MARK: Private
  
  private func setup() {
    configureTableView()
    loadData()
  }
  
  private func configureTableView() {
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    tableView.remembersLastFocusedIndexPath = true
  }
  
  private func loadData() {
    tmdb.upcomingMovies { [weak self] (movies, error) in
      guard error == nil else { return print(error!) }
      self?.tableViewDataSource.movies = movies
      self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
  }
  
}

// MARK: - MoviesViewController: UITableViewDelegate -

extension MoviesViewController: UITableViewDelegate {
  
  // MARK: UITableViewDelegate
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let movie = tableViewDataSource.movieForIndexPath(indexPath)!
    didSelect(movie)
  }
  
  func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    didUpdateFocusInContext(context)
  }
  
  // MARK: Helpers
  
  fileprivate func didUpdateFocusInContext(_ context: UITableViewFocusUpdateContext) {
    guard let highlightedIndexPath = context.nextFocusedIndexPath else { return }
    
    let movie = tableViewDataSource.movieForIndexPath(highlightedIndexPath)!
    guard movie.posterPath != nil else {
      imageView.image = UIImage(named: "movie-placeholder")
      return
    }
    
    imageView.af_setImage(withURL: tmdb.posterImageURL(for: movie)!)
    
    if let row = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: row, animated: false)
    }
  }
  
}
