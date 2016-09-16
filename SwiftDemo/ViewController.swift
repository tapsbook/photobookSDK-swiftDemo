//
//  ViewController.swift
//  SwiftDemo
//
//  Created by yoda on 8/29/16.
//  Copyright © 2016 Tapsbook. All rights reserved.
//

import UIKit
import Photos
import AVKit
import DKImagePickerController

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showImagePickerWithAssetType(assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .Both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        // Custom camera
        //		pickerController.UIDelegate = CustomUIDelegate()
        //		pickerController.modalPresentationStyle = .OverCurrentContext
        
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
        pickerController.defaultSelectedAssets = nil
        
//        pickerController.showsCancelButton = true
//        pickerController.showsEmptyAlbums = false
//        pickerController.defaultAssetGroup = PHAssetCollectionSubtype.SmartAlbumFavorites
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
        }

        
        
//        pickerController.defaultSelectedAssets = self.assets
//        
//        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
//            print("didSelectAssets")
//            
//            self.assets = assets
//        }
        
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            pickerController.modalPresentationStyle = .FormSheet
        }
        
        self.presentViewController(pickerController, animated: true) {}
    }
    
    struct Demo {
        static let titles = [
            ["Create Book"],
            ["View Books"],
            ["View Shopping cart"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.AllPhotos]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Demo.titles.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Demo.titles[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = Demo.titles[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (indexPath.row == 0) {
            showPhotoPicker()
        }
    }
    
    func showPhotoPicker() {
        let assetType = Demo.types[0]
        let allowMultipleType = false
        let sourceType: DKImagePickerControllerSourceType = .Photo
        let allowsLandscape = false
        let singleSelect = false
        
        showImagePickerWithAssetType(
            assetType,
            allowMultipleType: allowMultipleType,
            sourceType: sourceType,
            allowsLandscape: allowsLandscape,
            singleSelect: singleSelect
        )
        
    }

}

