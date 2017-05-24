#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # use filter instead of exclude so missing patterns dont' throw errors
  echo "rsync -av --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync -av --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    echo "/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements \"$1\""
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements "$1"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current file
  archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | rev)"
  stripped=""
  for arch in $archs; do
    if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "$BUILT_PRODUCTS_DIR/AFNetworking/AFNetworking.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AGGeometryKit/AGGeometryKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AHEasing/AHEasing.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AWSCore/AWSCore.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AWSS3/AWSS3.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AsyncDisplayKit/AsyncDisplayKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/BlocksKit/BlocksKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Bolts/Bolts.framework"
  install_framework "$BUILT_PRODUCTS_DIR/CocoaLumberjack/CocoaLumberjack.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DKImagePickerController/DKImagePickerController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DZNSegmentedControl/DZNSegmentedControl.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FMDB/FMDB.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FXBlurView/FXBlurView.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FXLabel/FXLabel.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FastImageCache/FastImageCache.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FormatterKit/FormatterKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/HappyDNS/HappyDNS.framework"
  install_framework "$BUILT_PRODUCTS_DIR/KVOController/KVOController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MBProgressHUD/MBProgressHUD.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZAppearance/MZAppearance.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZFormSheetController/MZFormSheetController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZFormSheetPresentationController/MZFormSheetPresentationController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Masonry/Masonry.framework"
  install_framework "$BUILT_PRODUCTS_DIR/PINCache/PINCache.framework"
  install_framework "$BUILT_PRODUCTS_DIR/PINRemoteImage/PINRemoteImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Qiniu/Qiniu.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Reachability/Reachability.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SCLAlertView-Objective-C/SCLAlertView_Objective_C.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SDWebImage/SDWebImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SlackTextViewController/SlackTextViewController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Stripe/Stripe.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TLLayoutTransitioning/TLLayoutTransitioning.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TTTAttributedLabel/TTTAttributedLabel.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TTTRandomizedEnumerator/TTTRandomizedEnumerator.framework"
  install_framework "$BUILT_PRODUCTS_DIR/UICKeyChainStore/UICKeyChainStore.framework"
  install_framework "$BUILT_PRODUCTS_DIR/leveldb/leveldb.framework"
  install_framework "$BUILT_PRODUCTS_DIR/libextobjc/libextobjc.framework"
  install_framework "$BUILT_PRODUCTS_DIR/objective-zip/objective_zip.framework"
  install_framework "$BUILT_PRODUCTS_DIR/pop/pop.framework"
  install_framework "$BUILT_PRODUCTS_DIR/smc-runtime/smc_runtime.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "$BUILT_PRODUCTS_DIR/AFNetworking/AFNetworking.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AGGeometryKit/AGGeometryKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AHEasing/AHEasing.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AWSCore/AWSCore.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AWSS3/AWSS3.framework"
  install_framework "$BUILT_PRODUCTS_DIR/AsyncDisplayKit/AsyncDisplayKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/BlocksKit/BlocksKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Bolts/Bolts.framework"
  install_framework "$BUILT_PRODUCTS_DIR/CocoaLumberjack/CocoaLumberjack.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DKImagePickerController/DKImagePickerController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/DZNSegmentedControl/DZNSegmentedControl.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FMDB/FMDB.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FXBlurView/FXBlurView.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FXLabel/FXLabel.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FastImageCache/FastImageCache.framework"
  install_framework "$BUILT_PRODUCTS_DIR/FormatterKit/FormatterKit.framework"
  install_framework "$BUILT_PRODUCTS_DIR/HappyDNS/HappyDNS.framework"
  install_framework "$BUILT_PRODUCTS_DIR/KVOController/KVOController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MBProgressHUD/MBProgressHUD.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZAppearance/MZAppearance.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZFormSheetController/MZFormSheetController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/MZFormSheetPresentationController/MZFormSheetPresentationController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Masonry/Masonry.framework"
  install_framework "$BUILT_PRODUCTS_DIR/PINCache/PINCache.framework"
  install_framework "$BUILT_PRODUCTS_DIR/PINRemoteImage/PINRemoteImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Qiniu/Qiniu.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Reachability/Reachability.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SCLAlertView-Objective-C/SCLAlertView_Objective_C.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SDWebImage/SDWebImage.framework"
  install_framework "$BUILT_PRODUCTS_DIR/SlackTextViewController/SlackTextViewController.framework"
  install_framework "$BUILT_PRODUCTS_DIR/Stripe/Stripe.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TLLayoutTransitioning/TLLayoutTransitioning.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TTTAttributedLabel/TTTAttributedLabel.framework"
  install_framework "$BUILT_PRODUCTS_DIR/TTTRandomizedEnumerator/TTTRandomizedEnumerator.framework"
  install_framework "$BUILT_PRODUCTS_DIR/UICKeyChainStore/UICKeyChainStore.framework"
  install_framework "$BUILT_PRODUCTS_DIR/leveldb/leveldb.framework"
  install_framework "$BUILT_PRODUCTS_DIR/libextobjc/libextobjc.framework"
  install_framework "$BUILT_PRODUCTS_DIR/objective-zip/objective_zip.framework"
  install_framework "$BUILT_PRODUCTS_DIR/pop/pop.framework"
  install_framework "$BUILT_PRODUCTS_DIR/smc-runtime/smc_runtime.framework"
fi
