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


#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <GameKit/GameKit.h>
#endif

#if defined(FC_LUA)
#import "Shared/Lua/FCLua.h"
#endif

class FCPhaseManager;

@protocol FCAppDelegate <NSObject>
-(void)registerPhasesWithManager:(FCPhaseManager*)manager;
-(void)initialiseSystems;
-(void)updateRealTime:(float)realTime gameTime:(float)gameTime;
@end

#if TARGET_OS_IPHONE
@interface FCApplication : NSObject <GKLeaderboardViewControllerDelegate>
#else
@interface FCApplication : NSObject
#endif

+(FCApplication*)instance;

#if TARGET_OS_IPHONE
-(void)coldBootWithViewController:(UIViewController*)vc delegate:(id<FCAppDelegate>)delegate;
#else
-(void)coldBootWithDelegate:(id<FCAppDelegate>)delegate;
#endif

-(void)warmBoot;
-(void)shutdown;
-(void)update;
-(void)pause;
-(void)resume;
-(void)setUpdateFrequency:(int)fps;

-(void)willResignActive;
-(void)didEnterBackground;
-(void)willEnterForeground;
-(void)didBecomeActive;
-(void)willTerminate;

#if TARGET_OS_IPHONE
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)showGameCenterLeaderboard;
#endif

-(CGSize)mainViewSize;
-(UIViewController*)rootViewController;

#if defined(FC_LUA)
-(FCLuaVM*)lua;
#endif

-(void)launchExternalURL:(NSString*)stringURL;
@end
