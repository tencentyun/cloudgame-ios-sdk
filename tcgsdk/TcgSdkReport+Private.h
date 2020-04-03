//
//  TcgSdkReport+TcgSdkReport_Private.h
//  TCGSDK
//
//  Created by okhowang(王沛文) on 2020/4/3.
//

#import <WebRTC/WebRTC.h>
#import "TcgSdkReport.h"
NS_ASSUME_NONNULL_BEGIN

@interface TcgSdkReport ()
- (void)retrieveFromRTCStatsReports:(NSArray<RTCLegacyStatsReport *> *)reports;
@end

NS_ASSUME_NONNULL_END
