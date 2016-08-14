//
//  UIDevice+Additions.m
//  ECUtils
//
//  Created by kiri on 15/5/3.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "UIDevice+Additions.h"
#import <sys/utsname.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation UIDevice (Additions)

- (NSString *)machineType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithUTF8String:systemInfo.machine];
}

- (NSString *)machineName
{
    NSString *platform = self.machineType;
    NSDictionary *commonNamesDictionary = @{@"i386": @"32-bit iPhone Simulator",
                                            @"x86_64": @"64-bit iPhone Simulator",
                                            
                                            @"iPhone1,1": @"iPhone",
                                            @"iPhone1,2": @"iPhone 3G",
                                            @"iPhone2,1": @"iPhone 3GS",
                                            @"iPhone3,1": @"iPhone 4",
                                            @"iPhone3,2": @"iPhone 4(Rev A)",
                                            @"iPhone3,3": @"iPhone 4(CDMA)",
                                            @"iPhone4,1": @"iPhone 4S",
                                            @"iPhone5,1": @"iPhone 5(GSM)",
                                            @"iPhone5,2": @"iPhone 5(GSM+CDMA)",
                                            @"iPhone5,3": @"iPhone 5C(GSM)",
                                            @"iPhone5,4": @"iPhone 5C(GSM+CDMA)",
                                            @"iPhone6,1": @"iPhone 5S(GSM)",
                                            @"iPhone6,2": @"iPhone 5S(GSM+CDMA)",
                                            @"iPhone7,1": @"iPhone 6 Plus",
                                            @"iPhone7,2": @"iPhone 6",
                                            
                                            @"iPad1,1": @"iPad",
                                            @"iPad2,1": @"iPad 2(WiFi)",
                                            @"iPad2,2": @"iPad 2(GSM)",
                                            @"iPad2,3": @"iPad 2(CDMA)",
                                            @"iPad2,4": @"iPad 2(WiFi Rev A)",
                                            @"iPad2,5": @"iPad Mini(WiFi)",
                                            @"iPad2,6": @"iPad Mini(GSM)",
                                            @"iPad2,7": @"iPad Mini(GSM+CDMA)",
                                            @"iPad3,1": @"iPad 3(WiFi)",
                                            @"iPad3,2": @"iPad 3(GSM+CDMA)",
                                            @"iPad3,3": @"iPad 3(GSM)",
                                            @"iPad3,4": @"iPad 4(WiFi)",
                                            @"iPad3,5": @"iPad 4(GSM)",
                                            @"iPad3,6": @"iPad 4(GSM+CDMA)",
                                            
                                            @"iPod1,1": @"iPod Touch", /* 1st Gen */
                                            @"iPod2,1": @"iPod Touch 2",
                                            @"iPod3,1": @"iPod Touch 3",
                                            @"iPod4,1": @"iPod Touch 4",
                                            @"iPod5,1": @"iPod Touch 5"};
    NSString *result = [commonNamesDictionary objectForKey:platform];
    if (result == nil) {
        result = platform;
    }
    if (result == nil) {
        result = @"Unknown";
    }
    return result;
}

- (NSString *)carrierName
{
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    if (carrier.carrierName.length > 0) {
        return carrier.carrierName;
    } else {
        return @"UNKNOWN_CARRIER";
    }
}

@end
