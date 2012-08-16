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

#import "FCOnlineLeaderboard_apple.h"

extern UIViewController* s_rootViewController;

static FCOnlineLeaderboard_apple* s_pInstance;

void plt_FCOnlineLeaderboard_Init( void );
bool plt_FCOnlineLeaderboard_Available( void );
void plt_FCOnlineLeaderboard_PostScore(  const char* leaderboardName,
                                              unsigned int score,
                                              unsigned int handle,
                                              plt_FCOnlineLeaderboard_PostCallback callback );

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
                                       unsigned int score,
                                       unsigned int handle,
                                       plt_FCOnlineLeaderboard_PostCallback callback )
{
    [s_pInstance postScore:score toLeaderboard:@(leaderboardName) withHandle:handle callback:callback];
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

-(id)init
{
    self = [super init];
    if (self) {
        [self authenticateLocalPlayer];
    }
    return self;
}

-(void)postScore:(unsigned int)score
   toLeaderboard:(NSString*)leaderboardName
      withHandle:(unsigned int)handle
        callback:(plt_FCOnlineLeaderboard_PostCallback)callback
{
    if (_localPlayer) {
        GKScore *scoreReporter = [[GKScore alloc] initWithCategory:leaderboardName];
        scoreReporter.value = score;
        
        [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil)
            {
                (callback)(handle, false);
            }
            else
            {
                (callback)(handle, true);
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
        [s_rootViewController presentModalViewController: leaderboardController animated: YES];
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
    [s_rootViewController dismissModalViewControllerAnimated:YES];
}
@end


