//
//  BussinessViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit

class BussinessViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!

    var businesses:[Business]!
    var searchedBusinesses = [Business]()
    var hud:MBProgressHUD?

    let searchController = UISearchController(searchResultsController: nil)
    var refreshControl = UIRefreshControl()
    var businessFilters:[String : AnyObject]?
    var loadingMoreView:InfiniteScrollActivityView?
    var offset = 0
    var loading = true
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 85

        setupSearchController()
        setupRefreshControl()
        setupLoadingMoreView()
        setupMapView()
        searchBusinesses()
     }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! UINavigationController
        let filtersViewController = destinationViewController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }

    // MARK: - Refresh Control
    
    func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(colorLiteralRed: 175/255, green: 6/255, blue: 6/255, alpha: 1)
        refreshControl.addTarget(self,
                                 action: #selector(refreshControlAction(refreshControl:)),
                                 for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        offset = 0
        if (searchController.isActive) {
            refreshControl.endRefreshing()
            return
        }

        loading = true
        searchBusinesses()
    }
    
    // MARK: - Infinite Scroll

    func setupLoadingMoreView() {

        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }

    // MARK: - Search
    
    func searchBusinesses() {
        
        showLoading()

        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in

            if (businesses?.count)! > 0 {
                self.businesses = businesses
                self.tableView.reloadData()
                self.updateMapView()
            }
            else {
                self.offset-=20
            }

            self.refreshControl.endRefreshing()
            self.hideLoading()
            self.loading = false
        })
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.delegate = self
        self.navigationItem.titleView = searchController.searchBar;
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {

        searchedBusinesses = businesses!.filter { business in
            return business.name!.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }
    
    // MARK: - MapView

    func setupMapView() {
        mapView.alpha = 0
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(centerLocation.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func updateMapView() {
        mapView.removeAnnotations(mapView.annotations)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            for business in self.searchedBusinesses {
                addAnnotationAtAddress(address: business.address!, title: business.name!, subtitle: business.address!)
            }
        }
        else {
            for business in self.businesses {
                addAnnotationAtAddress(address: business.address!, title: business.name!, subtitle: business.address!)
            }
        }
    }

    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationAtAddress(address: String, title: String, subtitle: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    annotation.subtitle = subtitle
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    // MARK: - HUD
    
    func showLoading() {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud!.label.text = "Updating restaurants..."
        hud!.contentColor = UIColor.white
        hud!.bezelView.color = UIColor.black
        self.view.addSubview(hud!)
    }
    
    func hideLoading() {
        hud?.removeFromSuperview()
    }
    
    func filterBusiness() {
        let categories = businessFilters?["categories"] as? [String]
        let deals = businessFilters?["deals"] as? Bool
        let distance = businessFilters?["distance"] as? Int
        let sort = businessFilters?["sort"] as? YelpSortMode
        
        showLoading()
        
        Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, deals: deals, distance: distance, offset:offset) { (filteredBusinesses:[Business]?, error:Error?) in
            if (filteredBusinesses?.count)! > 0 {
                self.businesses = filteredBusinesses
                self.tableView.reloadData()
                self.updateMapView()
            }
            else {
                self.offset-=20
            }
            self.hideLoading()
        }
    }
    
    // MARK: - UI Actions

    @IBAction func onRightBarButtonTap(_ sender: UIBarButtonItem) {

        if self.mapView.alpha == 0 {
            UIView.transition(with: self.mapView,
                              duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromLeft,
                              animations: {
                                self.mapView.alpha = 1
                                self.tableView.alpha = 0
                                self.rightBarButtonItem.title = "List"
                                self.updateMapView()
                }, completion: nil)
        }
        else {
            UIView.transition(with: self.tableView,
                              duration: 0.5, options: UIViewAnimationOptions.transitionFlipFromRight,
                              animations: {
                                self.mapView.alpha = 0
                                self.tableView.alpha = 1
                                self.rightBarButtonItem.title = "Map"
                }, completion: nil)
        }
    }
    
    func loadMoreData() {
        loading = true
        offset+=20
        let categories = businessFilters?["categories"] as? [String]
        let deals = businessFilters?["deals"] as? Bool
        let distance = businessFilters?["distance"] as? Int
        let sort = businessFilters?["sort"] as? YelpSortMode
        
        Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, deals: deals, distance: distance, offset:offset) { (filteredBusinesses:[Business]?, error:Error?) in
            
            if (filteredBusinesses?.count)! > 0 {
                self.businesses = filteredBusinesses
                self.tableView.reloadData()
                self.updateMapView()
            }
            else {
                self.offset-=20
            }

            self.loadingMoreView!.stopAnimating()
            self.loading = false
        }
    }
}

// MARK: - UITableViewDataSource

extension BussinessViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = businesses {
            
            if searchController.isActive && searchController.searchBar.text != "" {
                return searchedBusinesses.count
            }
            return businesses.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessTableViewCell

        let business: Business
        if searchController.isActive && searchController.searchBar.text != "" {
            business = searchedBusinesses[indexPath.row]
        } else {
            business = businesses![indexPath.row]
        }

        cell.business = business
        cell.index = offset + indexPath.row + 1
        
        return cell
    }
}

// MARK: - FiltersViewControllerDelegate

extension BussinessViewController : FiltersViewControllerDelegate {

    func filterWith(filters:[String : AnyObject]) {
        self.businessFilters = filters
        offset = 0
        filterBusiness()
    }
}

// MARK: - UISearchResultsUpdating

extension BussinessViewController : UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension BussinessViewController : UISearchControllerDelegate {

    func didDismissSearchController(_ searchController: UISearchController) {
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }
}

// MARK: - UIScrollViewDelegate

extension BussinessViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if (!loading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            let isScrollingDown = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0

            if(scrollView.contentOffset.y > scrollOffsetThreshold
                && self.tableView.isDragging
                && !isScrollingDown) {

                loading = true

                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData()
            }
        }
    }
}

