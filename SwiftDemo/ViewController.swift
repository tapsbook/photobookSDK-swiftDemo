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
    
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
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
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    struct Demo {
        static let titles = [
            ["Create Book"],
            ["View Books"],
            ["View Shopping cart"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.allPhotos]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Demo.titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Demo.titles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = Demo.titles[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.row == 0) {
            showPhotoPicker()
        }
    }
    
    func showPhotoPicker() {
        let assetType = Demo.types[0]
        let allowMultipleType = false
        let sourceType: DKImagePickerControllerSourceType = .photo
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
        //the root path of cache, tip: strongly recommend you control
        //your cache disk usage, it may use a lot of space.
        //e.g. you can try SDWebImage's cache
        let cachePath : String = NSHomeDirectory().stringByAppendingPathComponent("Library").stringByAppendingPathComponent("ImageCache")
        let fileManager : FileManager = FileManager.default
        if(!fileManager.fileExists(atPath: cachePath, isDirectory: nil)){
            try! fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
        }

        let hud : MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true);

        for asset in assets! {
            let photo_id = asset.localIdentifier.components(separatedBy: "/").first
            let filename_s = String.localizedStringWithFormat("%@-s.jpg", photo_id!)
            let filename_l = String.localizedStringWithFormat("%@-l.jpg", photo_id!)
            let sPath = cachePath.stringByAppendingPathComponent(filename_s)
            let lPath = cachePath.stringByAppendingPathComponent(filename_l)
            
            //save the file to local cache for SDK
            if(!fileManager.fileExists(atPath: sPath)){
                asset.writeImageToFile(sPath, completeBlock: { (success) in
                    print("didSelectAssets:",filename_s)
                })
            }
            
            if(!fileManager.fileExists(atPath: lPath)){
                asset.writeImageToFile(lPath, completeBlock: { (success) in
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

        //Custom product options if using SDK without a product server
        //Ignore this if using Tapsbook server API to control products
        let albumOption : NSDictionary = [
        kTBPreferredProductSKU:     "1003", //1003 is a layflat
        kTBProductPreferredTheme:   "200",  //200 is for square book
        kTBProductMaxPageCount:     "20",   //set max=min will limit the page count
        kTBProductMinPageCount:     "20",
        kTBPreferredUIDirection:    "RTL"   //set this RTL or LTR
        ]
        
        //launch SDK with images
        TBSDKAlbumManager.sharedInstance().createSDKAlbum(withImages: tbImages , identifier: nil, title: "Album", tag: 0, options: albumOption as! [AnyHashable: Any], completionBlock: { (success, sdkAlbum, error) -> Void in
            
            TBSDKAlbumManager.sharedInstance().open(sdkAlbum, presentOn: self, shouldPrintDirectly: false)
        })
        
    }

}

