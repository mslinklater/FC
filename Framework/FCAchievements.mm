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

#import <GameKit/GameKit.h>

#import "FCCore.h"
#import "FCAchievements.h"
#import "FCAppContext.h"
#import "FCXMLData.h"
#import "FCNotifications.h"

@implementation FCAchievements

#pragma mark - FCSingleton

+(FCAchievements*)instance
{
	static FCAchievements* pInstance;
	
	if (!pInstance) {
		pInstance = [[FCAchievements alloc] init];
	}
	return pInstance;
}

#pragma mark - Misc

-(void)checkAchievements
{
	FC_LOG(@"Checking achievements");
}

-(void)getAchievementsFromServer
{
	FC_LOG(@"Get achievements from server");
	
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
		if (error != nil)
		{
			// handle errors
			FC_ERROR1(@"achievements error: %@", error);
		}
		if (achievements != nil)
		{
			// process the array of achievements.
			
			for(GKAchievement* ach in achievements)
			{
				FC_LOG(ach.identifier);
			}
		}
	}];
}

#pragma mark - Notification responders

-(void)playerIdChanged:(NSNotification*)note
{
	[self getAchievementsFromServer];
}

#pragma mark - Object Lifetime

-(id)init
{
    self = [super init];
    if (self) {
        mAchievementsState = [[NSMutableDictionary alloc] init];
		
		mCheckTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkAchievements) userInfo:nil repeats:YES];	
		
		// read achievements from gamedata

		mAchievementsDefs = [[[FCAppContext instance] gameData] arrayForKeyPath:@"gamedata.achievements.achievement"];
		
		[self getAchievementsFromServer];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIdChanged:) name:[NSString stringWithUTF8String:kFCNotificationPlayerIDChanged.c_str()] object:nil];
		
    }
    return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithUTF8String:kFCNotificationPlayerIDChanged.c_str()] object:nil];
	mAchievementsState = nil;
	[mCheckTimer invalidate];
	mCheckTimer = nil;
}

@end

#endif // TARGET_OS_IPHONE
