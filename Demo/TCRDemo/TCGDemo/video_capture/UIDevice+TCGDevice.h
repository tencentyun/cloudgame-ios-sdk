/*
 *  Copyright 2016 The WebTCG project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TCGDeviceType) {
  TCGDeviceTypeUnknown,
  TCGDeviceTypeIPhone1G,
  TCGDeviceTypeIPhone3G,
  TCGDeviceTypeIPhone3GS,
  TCGDeviceTypeIPhone4,
  TCGDeviceTypeIPhone4Verizon,
  TCGDeviceTypeIPhone4S,
  TCGDeviceTypeIPhone5GSM,
  TCGDeviceTypeIPhone5GSM_CDMA,
  TCGDeviceTypeIPhone5CGSM,
  TCGDeviceTypeIPhone5CGSM_CDMA,
  TCGDeviceTypeIPhone5SGSM,
  TCGDeviceTypeIPhone5SGSM_CDMA,
  TCGDeviceTypeIPhone6Plus,
  TCGDeviceTypeIPhone6,
  TCGDeviceTypeIPhone6S,
  TCGDeviceTypeIPhone6SPlus,
  TCGDeviceTypeIPhone7,
  TCGDeviceTypeIPhone7Plus,
  TCGDeviceTypeIPhoneSE,
  TCGDeviceTypeIPhone8,
  TCGDeviceTypeIPhone8Plus,
  TCGDeviceTypeIPhoneX,
  TCGDeviceTypeIPhoneXS,
  TCGDeviceTypeIPhoneXSMax,
  TCGDeviceTypeIPhoneXR,
  TCGDeviceTypeIPhone11,
  TCGDeviceTypeIPhone11Pro,
  TCGDeviceTypeIPhone11ProMax,
  TCGDeviceTypeIPhone12Mini,
  TCGDeviceTypeIPhone12,
  TCGDeviceTypeIPhone12Pro,
  TCGDeviceTypeIPhone12ProMax,
  TCGDeviceTypeIPhoneSE2Gen,
  TCGDeviceTypeIPhone13,
  TCGDeviceTypeIPhone13Mini,
  TCGDeviceTypeIPhone13Pro,
  TCGDeviceTypeIPhone13ProMax,

  TCGDeviceTypeIPodTouch1G,
  TCGDeviceTypeIPodTouch2G,
  TCGDeviceTypeIPodTouch3G,
  TCGDeviceTypeIPodTouch4G,
  TCGDeviceTypeIPodTouch5G,
  TCGDeviceTypeIPodTouch6G,
  TCGDeviceTypeIPodTouch7G,
  TCGDeviceTypeIPad,
  TCGDeviceTypeIPad2Wifi,
  TCGDeviceTypeIPad2GSM,
  TCGDeviceTypeIPad2CDMA,
  TCGDeviceTypeIPad2Wifi2,
  TCGDeviceTypeIPadMiniWifi,
  TCGDeviceTypeIPadMiniGSM,
  TCGDeviceTypeIPadMiniGSM_CDMA,
  TCGDeviceTypeIPad3Wifi,
  TCGDeviceTypeIPad3GSM_CDMA,
  TCGDeviceTypeIPad3GSM,
  TCGDeviceTypeIPad4Wifi,
  TCGDeviceTypeIPad4GSM,
  TCGDeviceTypeIPad4GSM_CDMA,
  TCGDeviceTypeIPad5,
  TCGDeviceTypeIPad6,
  TCGDeviceTypeIPadAirWifi,
  TCGDeviceTypeIPadAirCellular,
  TCGDeviceTypeIPadAirWifiCellular,
  TCGDeviceTypeIPadAir2,
  TCGDeviceTypeIPadMini2GWifi,
  TCGDeviceTypeIPadMini2GCellular,
  TCGDeviceTypeIPadMini2GWifiCellular,
  TCGDeviceTypeIPadMini3,
  TCGDeviceTypeIPadMini4,
  TCGDeviceTypeIPadPro9Inch,
  TCGDeviceTypeIPadPro12Inch,
  TCGDeviceTypeIPadPro12Inch2,
  TCGDeviceTypeIPadPro10Inch,
  TCGDeviceTypeIPad7Gen10Inch,
  TCGDeviceTypeIPadPro3Gen11Inch,
  TCGDeviceTypeIPadPro3Gen12Inch,
  TCGDeviceTypeIPadPro4Gen11Inch,
  TCGDeviceTypeIPadPro4Gen12Inch,
  TCGDeviceTypeIPadMini5Gen,
  TCGDeviceTypeIPadAir3Gen,
  TCGDeviceTypeIPad8,
  TCGDeviceTypeIPad9,
  TCGDeviceTypeIPadMini6,
  TCGDeviceTypeIPadAir4Gen,
  TCGDeviceTypeIPadPro5Gen11Inch,
  TCGDeviceTypeIPadPro5Gen12Inch,
  TCGDeviceTypeSimulatori386,
  TCGDeviceTypeSimulatorx86_64,
};

@interface UIDevice (TCGDevice)

+ (TCGDeviceType)deviceType;
+ (BOOL)isIOS11OrLater;

@end
