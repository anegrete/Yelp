//
//  FiltersViewController.swift
//  Yelp
//
//  Created by anegrete on 10/22/16.
//  Copyright © 2016 Alejandra Negrete. All rights reserved.
//

import UIKit


protocol FiltersViewControllerDelegate {

    func filterWith(filters: [String:AnyObject])
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var categories: [[String: String]]!
    var switchCategoriesStates = [Int:Bool]()
    var deals = false
    var distanceSelected:[String:Any]? = nil
    var sortBySelected:[String:Any]? = nil
    var sort:YelpSortMode = YelpSortMode(rawValue: 0)!
    var delegate: FiltersViewControllerDelegate?
    var minCategories = 3

    var tableViewSections =
        [Section(name: "Most Popular", options: YelpAPIHelper.mostPopularOptions()),
         Section(name: "Distance", options: YelpAPIHelper.distanceOptions()),
         Section(name: "Sort by", options: YelpAPIHelper.sortByOptions()),
         Section(name: "Category", options: YelpAPIHelper.restaurantsCategoriesOptions())]

    var distanceExpanded = false
    var sortByExpanded = false
    var categoriesExpanded = false

    enum SectionName: Int {
        case mostPopular = 0, distance, sortBy, categories
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        categories = YelpAPIHelper.restaurantsCategoriesOptions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesExpanded = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UI Actions

    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearch(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        
        var filters = [String:AnyObject]()
        
        var selectedCategories = [String]()

        for (row, isSelected) in self.switchCategoriesStates {
            if isSelected {
                selectedCategories.append(categories[row][YelpCategories.code]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        
        filters["deals"] = deals as AnyObject?
        filters["distance"] = distanceSelected?["radius"] as AnyObject?
        filters["sort"] = sortBySelected?["sort"] as AnyObject?

        delegate?.filterWith(filters: filters)
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch SectionName(rawValue: section)! {

        case SectionName.distance:
            return (distanceExpanded ? YelpAPIHelper.distanceOptions().count: 1)
        
        case SectionName.sortBy:
            return (sortByExpanded ? YelpAPIHelper.sortByOptions().count : 1)
        
        case SectionName.categories:
            return (categoriesExpanded ? YelpAPIHelper.restaurantsCategoriesOptions().count : minCategories+1)
        
        case SectionName.mostPopular:
            return YelpAPIHelper.mostPopularOptions().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch SectionName(rawValue: indexPath.section)! {

        case SectionName.mostPopular:
            return dealsCellForRowAt(indexPath: indexPath)
            
        case SectionName.distance:
            return distanceCellForRowAt(indexPath: indexPath)
            
        case SectionName.sortBy:
            return sortByCellForRowAt(indexPath: indexPath)
            
        case SectionName.categories:
            return categoriesCellForRowAt(indexPath: indexPath)
        }
    }

    // Table View Cells

    func dealsCellForRowAt(indexPath:IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        cell.switchLabel.text = "Offering a Deal"
        cell.delegate = self
        return cell
    }
    
    func distanceCellForRowAt(indexPath:IndexPath) -> UITableViewCell {
        if distanceExpanded {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell
            let section = tableViewSections[indexPath.section]
            cell.optionSelected = false
            cell.optionLabel.text = section.options[indexPath.row]["name"] as? String
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableCell", for: indexPath) as! ExpandableTableViewCell
            let section = tableViewSections[indexPath.section]
            cell.expandableTitleLabel.text = distanceSelected?["name"] as? String ?? section.options[indexPath.row]["name"] as? String
            return cell
        }
    }
    
    func sortByCellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        if sortByExpanded {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell
            let section = tableViewSections[indexPath.section]
            cell.optionSelected = false
            cell.optionLabel.text = section.options[indexPath.row]["name"] as? String
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ExpandableCell", for: indexPath) as! ExpandableTableViewCell
            let section = tableViewSections[indexPath.section]
            cell.expandableTitleLabel.text = sortBySelected?["name"] as? String ?? section.options[indexPath.row]["name"] as? String
            return cell
        }
    }

    func categoriesCellForRowAt(indexPath:IndexPath) -> UITableViewCell {
        if !categoriesExpanded && minCategories == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell", for: indexPath)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
            cell.switchLabel.text = categories[indexPath.row][YelpCategories.name]
            cell.onSwitch.isOn = switchCategoriesStates[indexPath.row] ?? false
            cell.delegate = self
            return cell            
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewSections[section].name
    }    
}

// MARK: - UITableViewDelegate

extension FiltersViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let section = tableViewSections[indexPath.section]
        
        switch SectionName(rawValue: indexPath.section)! {
            
        case SectionName.distance:

            if distanceExpanded {
                distanceSelected = section.options[indexPath.row]
                let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
                cell.didSelect()
            }

            distanceExpanded = !distanceExpanded
            let delay = distanceExpanded ? 0 : 0.3
            self.perform(#selector(self.reloadDistanceSection), with: nil, afterDelay: delay)
        
        case SectionName.sortBy:
        
            if sortByExpanded {
                sortBySelected = section.options[indexPath.row]
                let cell = tableView.cellForRow(at: indexPath) as! OptionTableViewCell
                cell.didSelect()
            }

            sortByExpanded = !sortByExpanded
            let delay = sortByExpanded ? 0 : 0.3
            self.perform(#selector(self.reloadSortBySection), with: nil, afterDelay: delay)

        case SectionName.categories:

            if !categoriesExpanded && indexPath.row == minCategories {
                categoriesExpanded = true
                tableView.reloadSections(NSIndexSet(index: SectionName.categories.rawValue) as IndexSet, with: .none)
            }
            
        case SectionName.mostPopular:
            break
        }
    }

    func reloadDistanceSection() {
        tableView.reloadSections(NSIndexSet(index: SectionName.distance.rawValue) as IndexSet, with: .none)
    }

    func reloadSortBySection() {
        tableView.reloadSections(NSIndexSet(index: SectionName.sortBy.rawValue) as IndexSet, with: .none)
    }
}

// MARK: - SwitchTableViewCellDelegate

extension FiltersViewController: SwitchTableViewCellDelegate {

    func switchCell(switchCell: SwitchTableViewCell, didChangeValue value:Bool) {

        let indexPath = tableView.indexPath(for: switchCell)!

        switch SectionName(rawValue: indexPath.section)! {
        case SectionName.mostPopular:
            deals = value
        case SectionName.categories:
            switchCategoriesStates[indexPath.row] = value
        default:
            break
        }
    }
}

struct Section {
    let name:String
    let options:[[String:Any]]
    
    init(name:String, options:[[String:Any]]) {
        self.name = name
        self.options = options
    }
}
