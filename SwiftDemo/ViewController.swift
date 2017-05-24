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
    var dataSource:Array<Any>?
    var tbProductType : TBProductType = .photobook

    override func viewDidLoad() {
        super.viewDidLoad()
        getDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showImagePickerWithAssetType(_ assetType: DKImagePickerControllerAssetType,
                                      allowMultipleType: Bool,
                                      sourceType: DKImagePickerControllerSourceType = .both,
                                      allowsLandscape: Bool,
                                      singleSelect: Bool, maxSelectableCount: NSInteger) {
        
        let pickerController = DKImagePickerController()
        
        pickerController.assetType = assetType
        pickerController.allowsLandscape = allowsLandscape
        pickerController.allowMultipleTypes = allowMultipleType
        pickerController.sourceType = sourceType
        pickerController.singleSelect = singleSelect
//        pickerController.defaultSelectedAssets = self.assets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            print("didSelectAssets")
            self.assets = assets
            if assets.count > 0 {
                self.createBookWithSelectedAssets()
            }
        }
        pickerController.didCancel = { (Void) in
            
        }
        pickerController.maxSelectableCount = maxSelectableCount
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            pickerController.modalPresentationStyle = .formSheet
        }
        
        self.present(pickerController, animated: true) {}
    }
    
    struct Demo {
        static let titles = [
            ["Create Book"],
            ["Create Phonecase"],
            ["View Books"],
            ["View Shopping cart"]
        ]
        static let types: [DKImagePickerControllerAssetType] = [.allPhotos]
    }
    func getDataSource() {
        TBSDKAlbumManager.sharedInstance().fetchProductList { (success, products, error) in
            if success {
                print(1)
            }else {
                print(2)
            }
        }
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
        
        if (indexPath.section == 0) {
            showPhotoPicker(30)
            tbProductType = .photobook
        } else if indexPath.section == 1 {
            showPhotoPicker(1)
            tbProductType = .phonecase
        } else if indexPath.section == 2 {
            
        } else if indexPath.section == 3 {
            
        }
    }
    
    func showPhotoPicker(_ maxSelectCount : NSInteger) {
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
            singleSelect: singleSelect,
            maxSelectableCount: maxSelectCount
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
//        let albumOption : NSDictionary = [
////        ktbproduct:     "1003", //1003 is a layflat
//        kTBProductPreferredSKU:     "1003",
//        kTBProductPreferredTheme:   "200",  //200 is for square book
//        kTBProductMaxPageCount:     "20",   //set max=min will limit the page count
//        kTBProductMinPageCount:     "20",
//        kTBPreferredUIDirection:    "LTR"   //set this RTL or LTR
//        ]
        
        var albumOption : NSDictionary = [:]
        switch tbProductType {
        case .photobook:
            albumOption = [
                kTBProductPreferredSKU:     "1003",
                kTBProductPreferredTheme:   "200",  //200 is for square book
                kTBProductMaxPageCount:     "20",   //set max=min will limit the page count
                kTBProductMinPageCount:     "20",
                kTBPreferredUIDirection:    "LTR"   //set this RTL or LTR
            ]
        case .phonecase:
            albumOption = [
                kTBProductPreferredSKU : "220002"//iphone6壳子的sku
            ]
        default:
            albumOption = [:]
        }
        
        TBSDKAlbumManager.sharedInstance().createSDKAlbum(with: tbProductType, images: tbImages, identifier: nil, title: "Album", tag: 0, options: albumOption as! [AnyHashable : Any]) { (success, sdkAlbum, error) in
            if success {
                TBSDKAlbumManager.sharedInstance().open(sdkAlbum!, presentOn: self, shouldPrintDirectly: false)
            }
        }
        
//        let albumOption : NSDictionary = [
//            kTBProductPreferredSKU:     "200",
//            kTBProductPreferredTheme:   "2000",
//            ]
//        
//        TBSDKAlbumManager.sharedInstance().createSDKAlbum(with: .pillow, images: tbImages, identifier: nil, title: "Album", tag: 0, options: albumOption as! [AnyHashable : Any]) { (success, sdkAlbum, error) in
//            TBSDKAlbumManager.sharedInstance().open(sdkAlbum, presentOn: self, shouldPrintDirectly: false)
//        }
        
    }

    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

