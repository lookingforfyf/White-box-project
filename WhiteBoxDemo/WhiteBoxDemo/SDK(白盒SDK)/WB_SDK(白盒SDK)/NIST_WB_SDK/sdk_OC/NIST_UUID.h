//
//  NIST_UUID.h
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/10/31.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.本地算法产生一个唯一标示（用来代替设备唯一标识）
 ***********************************************/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const NIST_UUIDsOfUserDevicesDidChangeNotification;

@interface NIST_UUID : NSObject
{
    NSMutableDictionary * _uuidForKey;
    NSString            * _uuidForSession;
    NSString            * _uuidForInstallation;
    NSString            * _uuidForVendor;
    NSString            * _uuidForDevice;
    NSString            * _uuidsOfUserDevices;
    BOOL                  _uuidsOfUserDevices_iCloudAvailable;
}

+ (NSString *)uuid;

+ (NSString *)uuidForKey:(id<NSCopying>)key;

+ (NSString *)uuidForSession;

+ (NSString *)uuidForInstallation;

+ (NSString *)uuidForVendor;

+ (NSString *)uuidForDevice;

+ (NSString *)uuidForDeviceMigratingValue:(NSString *)value
                          commitMigration:(BOOL)commitMigration;

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key
                                commitMigration:(BOOL)commitMigration;

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key
                                        service:(NSString *)service
                                commitMigration:(BOOL)commitMigration;

+ (NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key
                                        service:(NSString *)service
                                    accessGroup:(NSString *)accessGroup
                                commitMigration:(BOOL)commitMigration;

+ (NSArray *)uuidsOfUserDevices;

+ (NSArray *)uuidsOfUserDevicesExcludingCurrentDevice;

+ (BOOL)uuidValueIsValid:(NSString *)uuidValue;


@end
