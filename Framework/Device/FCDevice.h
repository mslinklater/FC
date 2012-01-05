/*
 Copyright (C) 2011-2012 by Martin Linklater
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if TARGET_OS_IPHONE

#import <Foundation/Foundation.h>
#import "FCLuaClass.h"

// enums for caps

extern NSString* kFCDeviceTrue;
extern NSString* kFCDeviceFalse;

extern NSString* kFCDevicePresent;
extern NSString* kFCDeviceNotPresent;
extern NSString* kFCDeviceUnknown;

extern NSString* kFCDevicePlatformPhone;
extern NSString* kFCDevicePlatformPhoneRetina;
extern NSString* kFCDevicePlatformPhoneOnPad;
extern NSString* kFCDevicePlatformPad;
extern NSString* kFCDevicePlatformPadRetina;

// actual caps

extern NSString* kFCDeviceDisplayAspectRatio;
extern NSString* kFCDeviceDisplayLogicalXRes;
extern NSString* kFCDeviceDisplayLogicalYRes;
extern NSString* kFCDeviceDisplayPhysicalXRes;
extern NSString* kFCDeviceDisplayPhysicalYRes;
extern NSString* kFCDeviceDisplayScale;

extern NSString* kFCDeviceHardwareModelID;
extern NSString* kFCDeviceHardwareModel;
extern NSString* kFCDeviceHardwareUDID;
extern NSString* kFCDeviceHardwareName;

extern NSString* kFCDeviceOSVersion;
extern NSString* kFCDeviceOSName;
extern NSString* kFCDeviceOSGameCenter;
extern NSString* kFCDevicePlatform;
extern NSString* kFCDeviceSimulator;

extern NSString* kFCDeviceAppPirated;

@interface FCDevice : NSObject <FCLuaClass> {
}
@property(strong, nonatomic,readonly) NSMutableDictionary* caps;

+(FCDevice*)instance;

-(void)probe;
-(void)warmProbe;

-(void)print;
-(void)getScreenCaps;

-(id)valueForKey:(NSString*)key;
-(BOOL)valueForKey:(NSString*)key equalTo:(NSString*)key2;
-(BOOL)isPresent:(NSString*)key;

@end

#endif // TARGET_OS_IPHONE
