//
//  TapsbookObject.swift
//  Wow
//
//  Created by adiel on 29/02/2016.
//  Copyright © 2016 adiel. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

class TapsbookObject: NSObject {

    struct PhotoListViewControllerMode {
        static let PhotoListViewControllerMode_CreateAlbum : Int = 0;
        static let PhotoListViewControllerMode_AddPhoto : Int = 1;
    }
    static let sharedInstance : TapsbookObject = TapsbookObject()
    func createProcuctWithType(_ productType : TBProductType,mode : Int,assetsArray : [PHAsset], completionBlock: (([AnyObject]?) -> Void)?,completeToOpen :@escaping (_ sdkAlbum : TBSDKAlbum? )->Void)
    {
//        let selectedIndex : [NSIndexPath] = collectionView.indexPathsForSelectedItems()!
        if(assetsArray.count > 0)
        {
//            let indexSet : NSMutableIndexSet = NSMutableIndexSet()
//            for indexPath : NSIndexPath in selectedIndex
//            {
//                indexSet.addIndex(indexPath.row)
//            }
//            let selectedAssets : Array = assetsArray
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
                let cachePath : String = NSHomeDirectory().stringByAppendingPathComponent("Library").stringByAppendingPathComponent("ImageCache")
                let fileManager : FileManager = FileManager.default
                if(!fileManager.fileExists(atPath: cachePath, isDirectory: nil)){
                    try! fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
                }
                var tbImages : [TBImage] = []
                var counter : NSInteger = 0;
                for asset : PHAsset in assetsArray
                {
                    autoreleasepool(invoking: { () -> () in
                        
                        let name : String = asset.localIdentifier.components(separatedBy: "/").first!;
                        //Size
                        let boundingSize_s : CGSize = TBPSSizeUtil.size(from: TBPSImageSize.s)
                        let boundingSize_l : CGSize = TBPSSizeUtil.size(from: TBPSImageSize.l)
//                        let boundingSize_xxl : CGSize = TBPSSizeUtil.size(from: TBPSImageSize.xxl)
                        
                        var convertedSize_s : CGSize = boundingSize_s;
                        var convertedSize_l : CGSize = boundingSize_l;
//                        var convertedSize_xxl : CGSize = boundingSize_xxl;
                        
                        if(asset.pixelWidth * asset.pixelHeight > 0)
                        {
                            let photoSize : CGSize = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight));
                            convertedSize_s = TBPSSizeUtil.convert(photoSize, to: boundingSize_s, contentMode: UIViewContentMode.scaleAspectFill);
                            convertedSize_l = TBPSSizeUtil.convert(photoSize, to: boundingSize_l, contentMode: UIViewContentMode.scaleAspectFill);
//                            convertedSize_xxl = TBPSSizeUtil.convert(photoSize, to: boundingSize_xxl, contentMode: .scaleAspectFill)
                        }
                        
                        let sPath : String = cachePath.stringByAppendingPathComponent(String(format:"%@_s",name));
                        let lPath : String = cachePath.stringByAppendingPathComponent(String(format:"%@_l",name));
                        print("sPAth : " + sPath)
                        print("lPAth : " + lPath)
                        print("downloading file for:" + name)
                        let requestOptions : PHImageRequestOptions = PHImageRequestOptions()
                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.opportunistic;
                        requestOptions.isNetworkAccessAllowed = true;
                        
                        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast;
                        
                        if(!fileManager.fileExists(atPath: sPath)){
                            
                            PHImageManager.default().requestImage(for: asset, targetSize: convertedSize_s, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (result , info) -> Void in

                                result?.write(toFile: sPath, withCompressQuality: 1);
                            })
                        }
                        if(!fileManager.fileExists(atPath: lPath)){
                            
                            PHImageManager.default().requestImage(for: asset, targetSize: convertedSize_l, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (result , info) -> Void in
                                
                                result?.write(toFile: lPath, withCompressQuality: 1);
                            })
                        }
                        let tbImage : TBImage = TBImage(identifier: name)
                        tbImage.setImagePath(sPath, size: TBImageSize.s)
                        tbImage.setImagePath(lPath, size: TBImageSize.l)
                        counter += 1
                        tbImage.desc = NSNumber(value: counter as Int).description
                        tbImages.append(tbImage)
                        
                    })
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    if mode == PhotoListViewControllerMode.PhotoListViewControllerMode_CreateAlbum
                    {
                        var albumOption : NSDictionary;
                        let subTypeDict : NSDictionary = [11 : WZProductType_8x8layflat,10 : WZProductType_8x8layflat];
                        albumOption = [kTBProductSubType : subTypeDict]
                        
                        TBSDKAlbumManager.sharedInstance().createSDKAlbum(withImages: tbImages , identifier: nil, title: "Album", tag: 0, options: albumOption as! [AnyHashable: Any], completionBlock: { (success, sdkAlbum, error) -> Void in
                            
                            completeToOpen(sdkAlbum)
                            
                        })
                    }
                    else if mode == PhotoListViewControllerMode.PhotoListViewControllerMode_AddPhoto
                    {
                        completionBlock!(tbImages)
                    }
                    
                })
            })
            
        }
    }

    func preloadImageWithEnumerator(_ assetsLibrary : [AnyObject],enumerator : NSEnumerator,currentIdx : NSInteger, total : NSInteger, progressBlock :(_ int1 : NSInteger,_ int2:NSInteger,_ float : Float)->Void,completionBlock :(_ int1 : NSInteger,_ int2:NSInteger,_ error : NSError)->Void)
    {
        let tbImage : TBImage = enumerator.nextObject() as! TBImage
    
//        let assetsURL : NSURL = NSURL(string: tbImage.identifier)!
//        let diskIOQueue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        



        
        
    }
}
