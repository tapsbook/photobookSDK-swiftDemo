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
    func createProcuctWithType(productType : TBProductType,mode : Int,assetsArray : [PHAsset], completionBlock: (([AnyObject]!) -> Void)?,completeToOpen :(sdkAlbum : TBSDKAlbum? )->Void)
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let cachePath : String = NSHomeDirectory().stringByAppendingPathComponent("Library").stringByAppendingPathComponent("ImageCache")
                let fileManager : NSFileManager = NSFileManager.defaultManager()
                if(!fileManager.fileExistsAtPath(cachePath, isDirectory: nil)){
                    try! fileManager.createDirectoryAtPath(cachePath, withIntermediateDirectories: true, attributes: nil)
                }
                var tbImages : [TBImage] = []
                var counter : NSInteger = 0;
                for asset : PHAsset in assetsArray
                {
                    autoreleasepool({ () -> () in
                        
                        let name : String = asset.localIdentifier.componentsSeparatedByString("/").first!;
                        //Size
                        let boundingSize_s : CGSize = TBPSSizeUtil.sizeFromPSImageSize(TBPSImageSize.s)
                        let boundingSize_l : CGSize = TBPSSizeUtil.sizeFromPSImageSize(TBPSImageSize.l)
                        
                        var convertedSize_s : CGSize = boundingSize_s;
                        var convertedSize_l : CGSize = boundingSize_l;
                        
                        if(asset.pixelWidth * asset.pixelHeight > 0)
                        {
                            let photoSize : CGSize = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight));
                            convertedSize_s = TBPSSizeUtil.convertSize(photoSize, toSize: boundingSize_s, contentMode: UIViewContentMode.ScaleAspectFill);
                            convertedSize_l = TBPSSizeUtil.convertSize(photoSize, toSize: boundingSize_l, contentMode: UIViewContentMode.ScaleAspectFill);
                        }
                        
                        let sPath : String = cachePath.stringByAppendingPathComponent(String(format:"%@_s",name));
                        let lPath : String = cachePath.stringByAppendingPathComponent(String(format:"%@_l",name));
                        print("sPAth : " + sPath)
                        print("lPAth : " + lPath)
                        print("downloading file for:" + name)
                        let requestOptions : PHImageRequestOptions = PHImageRequestOptions()
                        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.Opportunistic;
                        requestOptions.networkAccessAllowed = true;
                        
                        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast;
                        
                        if(!fileManager.fileExistsAtPath(sPath)){
                            
                            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: convertedSize_s, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (result , info) -> Void in

                                result?.writeToFile(sPath, withCompressQuality: 1);
                            })
                        }
                        if(!fileManager.fileExistsAtPath(lPath)){
                            
                            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: convertedSize_l, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (result , info) -> Void in
                                
                                result?.writeToFile(lPath, withCompressQuality: 1);
                            })
                        }
                        let tbImage : TBImage = TBImage(identifier: name)
                        tbImage.setImagePath(sPath, size: TBImageSize.s)
                        tbImage.setImagePath(lPath, size: TBImageSize.l)
                        tbImage.desc = NSNumber(integer: counter++).description
                        tbImages.append(tbImage)
                        
                    })
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if mode == PhotoListViewControllerMode.PhotoListViewControllerMode_CreateAlbum
                    {
                        var albumOption : NSDictionary;
                        let subTypeDict : NSDictionary = [11 : WZProductType_8x8layflat,10 : WZProductType_8x8layflat];
                        albumOption = [kTBProductSubType : subTypeDict]
                        
                        TBSDKAlbumManager.sharedInstance().createSDKAlbumWithImages(tbImages , identifier: nil, title: "Album", tag: 0, options: albumOption as [NSObject : AnyObject], completionBlock: { (success, sdkAlbum, error) -> Void in
                            
                            completeToOpen(sdkAlbum: sdkAlbum)
                            
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

    func preloadImageWithEnumerator(assetsLibrary : [AnyObject],enumerator : NSEnumerator,currentIdx : NSInteger, total : NSInteger, progressBlock :(int1 : NSInteger,int2:NSInteger,float : Float)->Void,completionBlock :(int1 : NSInteger,int2:NSInteger,error : NSError)->Void)
    {
        let tbImage : TBImage = enumerator.nextObject() as! TBImage
    
//        let assetsURL : NSURL = NSURL(string: tbImage.identifier)!
//        let diskIOQueue : dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//        



        
        
    }
}
