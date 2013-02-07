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

#if defined(FC_ONLINE)

#import "FCOnlineLeaderboard_apple.h"
#import "FCApplication_apple.h"

static FCOnlineLeaderboard_apple* s_pInstance;

void plt_FCOnlineLeaderboard_Init( void );
bool plt_FCOnlineLeaderboard_Available( void );
void plt_FCOnlineLeaderboard_PostScore(  const char* leaderboardName,
                                              unsigned int score );

void plt_FCOnlineLeaderboard_Init( void )
{
    [FCOnlineLeaderboard_apple instance];
}

void plt_FCOnlineLeaderboard_Show( void )
{
    [s_pInstance show];
}

bool plt_FCOnlineLeaderboard_Available( void )
{
    if (s_pInstance.localPlayer) {
        return true;
    }
    return false;
}

void plt_FCOnlineLeaderboard_PostScore(  const char* leaderboardName,
                                       unsigned int score )
{
    [s_pInstance postScore:score toLeaderboard:@(leaderboardName)];
    return;
}

@implementation FCOnlineLeaderboard_apple

+(FCOnlineLeaderboard_apple*)instance
{
    if (!s_pInstance) {
        s_pInstance = [[FCOnlineLeaderboard_apple alloc] init];
    }
    return s_pInstance;
}

-(NSString*)filename
{
	NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [documentDirectories objectAtIndex:0];
	return [documentDirectory stringByAppendingPathComponent:@"scores"];
}

-(id)init
{
    self = [super init];
    if (self) {
		_unreportedScores = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filename]];
		if (_unreportedScores == nil) {
			_unreportedScores = [NSMutableArray array];
		}
		
        [self authenticateLocalPlayer];
		[self postUnreportedScores];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)willResignActiveNotification:(NSNotification*)note
{
	[NSKeyedArchiver archiveRootObject:_unreportedScores toFile:[self filename]];
}

-(void)postScore:(unsigned int)value
   toLeaderboard:(NSString*)leaderboardName

{
    if (_localPlayer) {
		
		BOOL isNew = YES;
		
		for (GKScore* score in _unreportedScores) {
			if( [score.category isEqualToString:leaderboardName] )
			{
				isNew = NO;
				if (score.value < value) {
					score.value = value;
				}
			}
		}
		
		if (isNew) {
			GKScore *score = [[GKScore alloc] initWithCategory:leaderboardName];
			score.value = value;
			[_unreportedScores addObject:score];
		}

    } else {
		[self authenticateLocalPlayer];
	}
	
	[self postUnreportedScores];
}

-(void)postUnreportedScores
{
	for (GKScore* score in _unreportedScores) {
		[score reportScoreWithCompletionHandler:^(NSError *error) {
			if (error == nil)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[_unreportedScores removeObject:score];
				});
			}
		}];
	}
}

-(void)show
{
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardController != nil)
    {
        leaderboardController.leaderboardDelegate = self;
        [FCRootViewController() presentModalViewController: leaderboardController animated: YES];
    }
}

-(void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            _localPlayer = localPlayer;
        } else {
            _localPlayer = nil;
        }
    }];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [FCRootViewController() dismissModalViewControllerAnimated:YES];
}
@end

#endif // FC_ONLINE
