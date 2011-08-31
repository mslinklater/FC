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

#import <GameKit/GameKit.h>

#import "FCCore.h"
#import "FCHighScores.h"
#import "FCPersistentData.h"
#import "FCGameContext.h"
#import "FCNotifications.h"

static NSString* kPersistentDataKey = @"FCHighScores";
static NSString* kLeaderboardsKey = @"FCHighScoresLeaderboards";

@implementation FCHighScores

#pragma mark - Notofication handlers

-(void)playerIdChanged:(NSNotification*)note
{
	[self syncWithLeaderboards];
}

#pragma mark - Object Lifetime

-(id)init
{
    self = [super init];
    if (self) {
		mLeaderboardsDictionary = [[NSMutableDictionary alloc] init];
		mLeaderboardIds = [[NSMutableArray alloc] init];
		mLeaderboardSet = [[NSMutableSet alloc] init];

		// world leaderboard scores

		mLeaderboardScoresDictionary = [[FCPersistentData instance] objectForKey:kLeaderboardsKey];
		
		if (!mLeaderboardScoresDictionary) {
			mLeaderboardScoresDictionary = [[NSMutableDictionary alloc] init];
			[[FCPersistentData instance] addObject:mLeaderboardScoresDictionary forKey:kLeaderboardsKey];
		}

		// level scores
		
        mScoresDictionary = [[FCPersistentData instance] objectForKey:kPersistentDataKey];
		
		if (!mScoresDictionary) {
			mScoresDictionary = [[NSMutableDictionary alloc] init];
			[[FCPersistentData instance] addObject:mScoresDictionary forKey:kPersistentDataKey];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerIdChanged:) name:kFCNotificationPlayerIDChanged object:nil];
    }
    return self;
}

-(void)dealloc
{
	[mLeaderboardIds release], mLeaderboardIds = nil;
	[mLeaderboardsDictionary release], mLeaderboardsDictionary = nil;
	[mScoresDictionary release], mScoresDictionary = nil;
	[mLeaderboardSet release], mLeaderboardSet = nil;
	[mLeaderboardScoresDictionary release], mLeaderboardScoresDictionary = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kFCNotificationPlayerIDChanged object:nil];
	
    [super dealloc];
}

#pragma mark - Getters

-(int)getScore:(NSString*)key
{
	return [[mScoresDictionary valueForKey:key] intValue];
}

#pragma mark - Setters

-(void)setScore:(int)score forKey:(NSString*)key
{
	int oldScore = [[mScoresDictionary valueForKey:key] intValue];

	if (score > oldScore) 
	{
		[mScoresDictionary setValue:[NSNumber numberWithInt:score] forKey:key];
		[[FCPersistentData instance] saveData];
	}
	
	// add all points for high scores with same leaderboard as this one and upload
	
	FC_LOG(mScoresDictionary);
	
	NSString* gameCenterId = [FCGameContext instance].localPlayerGameCenterId;

//	if ( !([gameCenterId isEqualToString:@"local"] || (gameCenterId == nil)) ) 
//	{
		NSString* leaderboardId = [mLeaderboardsDictionary valueForKey:key];
		
		if (leaderboardId) {
			NSEnumerator* keyEnumerator = [mLeaderboardsDictionary keyEnumerator];
			
			NSString* key;
			int totalLeaderboardScore = 0;
			
			while ( (key = [keyEnumerator nextObject]) ) {
				if ([[mLeaderboardsDictionary valueForKey:key] isEqualToString:leaderboardId]) {
					totalLeaderboardScore += [[mScoresDictionary valueForKey:key] intValue];
				}
			}

			// save locally
			
			[mLeaderboardScoresDictionary setValue:[NSNumber numberWithInt:totalLeaderboardScore] forKey:leaderboardId];
			[[FCPersistentData instance] saveData];

			FC_LOG(mLeaderboardScoresDictionary);

			// push score to leaderboard
			
			if ( !([gameCenterId isEqualToString:@"local"] || (gameCenterId == nil)) ) 
			{
				GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboardId] autorelease];
				scoreReporter.value = totalLeaderboardScore;
				
				NSString* blah = [NSString stringWithFormat:@"Pushing %d score to leaderboard %@", totalLeaderboardScore, leaderboardId];
				FC_LOG(blah);
				FC_UNUSED(blah);
				
				[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
					if (error != nil)
					{
						FC_ERROR(@"Error reporting score to Leaderboard");
					}
					else
					{
						FC_ERROR(@"Score push with no errors");					
					}
				}];				
			}
		}
//	}
}

-(void)setLeaderboard:(NSString*)leaderboard forKey:(NSString*)key
{
	[mLeaderboardsDictionary setValue:leaderboard forKey:key];

	[mLeaderboardSet addObject:leaderboard];
}

#pragma mark - GameCenter Stuff

-(void)syncWithLeaderboards
{
//	[mLeaderboardScoresDictionary removeAllObjects];
	
	// check if logged in

	FC_LOG([FCGameContext instance].localPlayerGameCenterId);

	NSString* gameCenterId = [FCGameContext instance].localPlayerGameCenterId;
	
	if ([gameCenterId isEqualToString:@"local"] || (gameCenterId == nil)) 
	{
		FC_LOG(@"FCHighScores - sync with leaderboards failed");
		// update leaderboard scores with local scores
		
		for(NSString* leaderboardId in mLeaderboardSet)
		{
			// go through high scores and see if the leaderboard matches this one - add score to total
			
			// get current high and compare to new high - store if bigger
			
		}		
	}
	else
	{
		// logged in - go through leaderboards and download the scores
		FC_LOG(@"FCHighScores - sync with leaderboards working");
		
		for(NSString* leaderboardId in mLeaderboardSet)
		{
			GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:gameCenterId]];
			if (leaderboardRequest != nil)
			{
				leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
				leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
				leaderboardRequest.range = NSMakeRange(1,10);
				leaderboardRequest.category = leaderboardId;
				[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
					if (error != nil)
					{
						// handle the error.
						FC_ERROR1(@"Retreive error %@", [error description]);
					}
					if (scores != nil)
					{
						// process the score information.
						GKScore* score = [scores objectAtIndex:0];
						
						int existingScore = [[mLeaderboardScoresDictionary valueForKey:leaderboardId] intValue];
						int newScore = score.value;

						if (newScore > existingScore) {
							[mLeaderboardScoresDictionary setObject:[NSNumber numberWithInt:score.value] forKey:leaderboardId];
						}
						
						dispatch_async(dispatch_get_main_queue(), ^{[[NSNotificationCenter defaultCenter] postNotificationName:kFCNotificationHighScoresChanged object:nil];});
					}
				}];
			}
			[leaderboardRequest release];
		}
	}
}

-(int)getScoreForLeaderboard:(NSString*)leaderboardId
{
	return [[mLeaderboardScoresDictionary valueForKey:leaderboardId] intValue];
}

#pragma mark - FCSingleton

+(FCHighScores*)instance
{
	static FCHighScores* pInstance;

	if (!pInstance) {
		pInstance = [[FCHighScores alloc] init];
	}
	return pInstance;
}

@end

#endif // TARGET_OS_IPHONE
