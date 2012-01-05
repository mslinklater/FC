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
#import <GameKit/GameKit.h>

#import "Lua/FCLua.h"

@class FCPhaseManager;

@protocol FCAppDelegate <NSObject>
-(void)registerPhasesWithManager:(FCPhaseManager*)manager;
//-(BOOL)shouldRotateToInterfaceOrientation:(UIInterfaceOrientation)orient;
@end

@interface FCApp : NSObject <GKLeaderboardViewControllerDelegate>
+(void)coldBootWithViewController:(UIViewController*)vc delegate:(id<FCAppDelegate>)delegate;
+(void)warmBoot;
+(void)shutdown;
+(void)update;
+(void)startInternalUpdate;
+(void)stopInternalUpdate;

+(void)willResignActive;
+(void)didEnterBackground;
+(void)willEnterForeground;
+(void)didBecomeActive;
+(void)willTerminate;

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
+(FCLuaVM*)lua;

+(void)showGameCenterLeaderboard;
+(void)launchExternalURL:(NSString*)stringURL;
@end

#endif