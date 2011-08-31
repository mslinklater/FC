/*
 Copyright (C) 2011 by Martin Linklater
 
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

// enums for caps

extern NSString* kFCCapsTrue;
extern NSString* kFCCapsFalse;

extern NSString* kFCCapsPresent;
extern NSString* kFCCapsNotPresent;
extern NSString* kFCCapsUnknown;

extern NSString* kFCCapsPlatformPhone;
extern NSString* kFCCapsPlatformPhoneRetina;
extern NSString* kFCCapsPlatformPhoneOnPad;
extern NSString* kFCCapsPlatformPad;
extern NSString* kFCCapsPlatformPadRetina;

// actual caps

extern NSString* kFCCapsDisplayAspectRatio;
extern NSString* kFCCapsDisplayLogicalXRes;
extern NSString* kFCCapsDisplayLogicalYRes;
extern NSString* kFCCapsDisplayPhysicalXRes;
extern NSString* kFCCapsDisplayPhysicalYRes;
extern NSString* kFCCapsDisplayScale;

extern NSString* kFCCapsHardwareModelID;
extern NSString* kFCCapsHardwareModel;
extern NSString* kFCCapsHardwareUDID;
extern NSString* kFCCapsHardwareName;

extern NSString* kFCCapsOSMultitaskingSupported;
extern NSString* kFCCapsOSVersion;
extern NSString* kFCCapsOSName;
extern NSString* kFCCapsOSGameCenter;
extern NSString* kFCCapsPlatform;
extern NSString* kFCCapsSimulator;

extern NSString* kFCCapsAppPirated;

@interface FCCaps : NSObject {
}
@property(nonatomic,readonly) NSMutableDictionary* caps;

+(FCCaps*)instance;

-(void)probeCaps;
-(void)setWindowBounds:(CGRect)bounds;
-(void)setPhysicalResolutionX:(int)x Y:(int)y;
-(void)setGameCenterUnavailable;
-(void)setGameCenterAvailable;

-(void)dumpToTTY;

-(id)valueForKey:(NSString*)key;
-(BOOL)valueForKey:(NSString*)key equalTo:(NSString*)key2;
-(BOOL)isPresent:(NSString*)key;

@end

#endif // TARGET_OS_IPHONE
