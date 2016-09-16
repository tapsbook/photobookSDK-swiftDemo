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
import MBProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var assets: [DKAsset]?
    var tbImages : [TBImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showImagePickerWithAssetType(assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .Both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
        pickerController.defaultSelectedAssets = self.assets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            print("didSelectAssets")
            self.assets = assets
            
            self.createBookWithSelectedAssets()
        }
        
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
    
    func createBookWithSelectedAssets (){
        let cachePath : String = NSHomeDirectory().stringByAppendingPathComponent("Library").stringByAppendingPathComponent("ImageCache")
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        if(!fileManager.fileExistsAtPath(cachePath, isDirectory: nil)){
            try! fileManager.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil)
        }

        let hud : MBProgressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true);

        for asset in assets! {
            let photo_id = asset.identifier().componentsSeparatedByString("/").first
            let filename_s = String.localizedStringWithFormat("%@-s.jpg", photo_id!)
            let filename_l = String.localizedStringWithFormat("%@-l.jpg", photo_id!)
            let sPath = cachePath.stringByAppendingPathComponent(filename_s)
            let lPath = cachePath.stringByAppendingPathComponent(filename_l)
            
            //save the file to local cache for SDK
            if(!fileManager.fileExistsAtPath(sPath)){
                asset.writeSizedImageToFile(sPath, size: CGSizeMake(100, 100), completeBlock: { (success) in
                    print("didSelectAssets:",filename_s)
                })
            }
            
            if(!fileManager.fileExistsAtPath(lPath)){
                asset.writeSizedImageToFile(lPath, size: CGSizeMake(800, 800), completeBlock: { (success) in
                    print("didSelectAssets:",filename_l)
                })
            }
            
            //then wrap image as TBImage
            let tbImage : TBImage = TBImage(identifier: photo_id)
            tbImage.setImagePath(sPath, size: TBImageSize.s)
            tbImage.setImagePath(lPath, size: TBImageSize.l)
            tbImages.append(tbImage)
        }
        hud.hide(true, afterDelay: 1.0)
        
        //launch SDK with images
        let albumOption : NSDictionary = [
        kTBPreferredProductSKU:     "1003"
        ] //sku=1003 is a layflat book
        
        TBSDKAlbumManager.sharedInstance().createSDKAlbumWithImages(tbImages , identifier: nil, title: "Album", tag: 0, options: albumOption as [NSObject : AnyObject], completionBlock: { (success, sdkAlbum, error) -> Void in
            
            TBSDKAlbumManager.sharedInstance().openSDKAlbum(sdkAlbum, presentOnViewController: self, shouldPrintDirectly: false)
        })
        
    }

}

