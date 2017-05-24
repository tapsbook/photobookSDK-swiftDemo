platform :ios, 8.0

def available_pods

#    pod 'AFAmazonS3Manager', '~> 3.2'
#    pod 'AFNetworking', '~> 2.0’
#    pod 'AGGeometryKit', '~> 1.2'
#    pod 'AHEasing', '~> 1.2'
#    pod 'AsyncDisplayKit', '1.9.1'
#    pod 'BlocksKit', '~> 2.2'
#    #depended by Facebook
#    pod 'Bolts', '~> 1.5'
#    pod 'HappyDNS','0.2.3'
#    pod 'CocoaLumberjack', '2.2.0'
#    pod 'DZNSegmentedControl', '1.3.2'
#    pod 'FastImageCache', '1.3'
#    pod 'FBSDKCoreKit'
#    pod 'FBSDKLoginKit'
#    pod 'FBSDKShareKit'
#    pod 'FMDB'
#    pod 'FormatterKit', '1.8.0'
#    pod 'FXBlurView', '~> 1.6'
#    pod 'FXLabel', '1.5.8'
#    pod 'GoogleAnalytics', '3.14.0'
#    pod 'KVOController', '1.0.3'
#    pod 'leveldb'
#    pod 'libextobjc', '~>0.4.1'
#    pod 'Masonry', '0.6.3'
#    pod 'MBProgressHUD', '0.9.1'
#    pod 'MOBFoundation', '1.5.1'
#    pod 'MZFormSheetController', '3.1.2'
#    pod 'MZFormSheetPresentationController', '2.1.2'
#    pod 'objective-zip'
#    pod 'pop', '1.0.8'
#    pod 'Qiniu', '7.0.15'
#    pod 'Reachability', '~> 3.2'
#    pod 'SCLAlertView-Objective-C', '0.7.9'
#    pod 'SDWebImage', '3.7.3'
#    pod 'ShareSDK3', '3.2.5'
#    pod 'ShareSDK3/ShareSDKPlatforms/WeChat', '3.2.5'
#    pod 'SlackTextViewController', '1.7.2'
#    pod 'smc-runtime', '~> 6.3'
#    pod 'Stripe', '6.0.1'
#    pod 'TLLayoutTransitioning', '1.0.9'
#    pod 'TTTAttributedLabel', '~> 1.13'
#    pod 'TTTRandomizedEnumerator', '~> 0.0'
#    pod 'UICKeyChainStore', '~> 2.1'

    # tapsbook
    pod 'AFNetworking', '~> 3.0'
    pod 'Qiniu', '7.1'
    pod 'AWSS3','2.4.12'
    pod 'Reachability', '~> 3.2'

    #UI library
    pod 'AGGeometryKit', '~> 1.2'
    pod 'AHEasing', '~> 1.2'
    pod 'AsyncDisplayKit', '~> 1.9.92'
    pod 'BlocksKit', '~> 2.2'
    pod 'DZNSegmentedControl', '~> 1.3'
    pod 'FastImageCache', '~> 1.3'
    pod 'FormatterKit', '~> 1.8'
    pod 'FXBlurView', '~> 1.6'
    pod 'FXLabel', '~> 1.5'
    pod 'KVOController', '~> 1.0'
    pod 'Masonry', '~> 0.6'
    pod 'MBProgressHUD', '~> 0.9'
    pod 'MZFormSheetController', '~> 3.1'
    pod 'MZFormSheetPresentationController', '~> 2.1'
    pod 'pop', '~> 1.0'
    pod 'SCLAlertView-Objective-C', '~> 0.7'
    pod 'SDWebImage', '~> 3.7'
    pod 'SlackTextViewController', '1.7.2'
    pod 'smc-runtime', '~> 6.3'
    pod 'TLLayoutTransitioning', '~> 1.0'
    pod 'TTTAttributedLabel', '~> 1.13'
    pod 'TTTRandomizedEnumerator', '~> 0.0'

    #Modal layer library
    pod 'FMDB', '~> 2.5'
    pod 'leveldb'
    pod 'libextobjc', '~>0.4.1'
    pod 'objective-zip'
    pod 'CocoaLumberjack', '~> 2.2'
    pod 'UICKeyChainStore', '~> 2.1'

    #Payment integration (Alipay, Wechat supported via their framework)
    pod 'Stripe', '~> 6.0'

    #Social share (Wechat supported via their framework)
    pod 'FBSDKCoreKit'
    pod 'FBSDKLoginKit'
    pod 'FBSDKShareKit'
    #GoogleAnalytics
    pod 'GoogleAnalytics-CN', :path => 'GoogleAnalytics-CN'
    pod 'UMengAnalytics-NO-IDFA'
#    pod 'UMengUShare/Social/WeChat'

end

def demoapp_pods
	pod 'DKImagePickerController'
	use_frameworks!

end

target :SwiftDemo do
available_pods
demoapp_pods
end
