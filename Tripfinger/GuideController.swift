//
//  GuideController.swift
//  Tripfinger
//
//  Created by Preben Ludviksen on 08/10/15.
//  Copyright (c) 2015 Preben Ludviksen. All rights reserved.
//

class GuideController: UITableViewController {
    struct TableViewCellIdentifiers {
        static let guideItemCell = "GuideItemCell"
        static let categoryCell = "CategoryCell"
        static let textChildCell = "TextChild"
    }
    
    var currentRegion: GuideItem?
    var contentService: ContentService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINib.registerNib(TableViewCellIdentifiers.guideItemCell, forTableView: tableView)
        UINib.registerNib(TableViewCellIdentifiers.categoryCell, forTableView: tableView)
        UINib.registerNib(TableViewCellIdentifiers.textChildCell, forTableView: tableView)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        contentService.getCurrentLocationData() {
            region, texts, locations in
            
            self.currentRegion = region
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

// MARK: - Table data source
extension GuideController: UITableViewDataSource {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return Attraction.Types.allValues.count - 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.guideItemCell, forIndexPath: indexPath) as! GuideItemCell
            if let currentRegion = currentRegion {
                let encodedData = currentRegion.description!.dataUsingEncoding(NSUTF8StringEncoding)!
                let options : [String: AnyObject] = [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
                ]
                let attributedString = NSMutableAttributedString(data: encodedData, options: options, documentAttributes: nil, error: nil)!
                attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(18.0), range: NSMakeRange(0, attributedString.length))
                let decodedString = attributedString.string
                cell.content.attributedText = attributedString
                cell.content.setContentOffset(CGPointZero, animated: false)
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.categoryCell, forIndexPath: indexPath) as! UITableViewCell
            let index: Int
            if indexPath.section == 1 {
                index = indexPath.row
            }
            else {
                index = indexPath.row + 2
            }
            cell.textLabel?.text = Attraction.getNameForType(Attraction.Types.allValues[index])
            return cell
        }
    }
    
}

// MARK: - Navigation
extension GuideController {
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.tabBarController?.selectedIndex = 1
        }
    }
}
