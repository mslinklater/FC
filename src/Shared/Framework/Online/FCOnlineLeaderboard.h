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

#ifndef CR2_FCOnlineLeaderboard_h
#define CR2_FCOnlineLeaderboard_h

#include <string>
#include <map>
#include "FCOnline_platform.h"
#include "Shared/Core/FCCore.h"

class FCOnlineLeaderboard
{
public:
    
    static FCOnlineLeaderboard* Instance();

    FCOnlineLeaderboard();
    virtual ~FCOnlineLeaderboard();
    
    bool    Available();    // Do we really need this ? Should auto-save for when online anyway
    
    void    PostScore( std::string leaderboardName, unsigned int score );

    // read score API... TBD
    
private:
    
    static void ScoreCallback( unsigned int handle, bool success );
    void StoreScoreForLater( FCHandle handle );
    
    void SuccessfulPost( FCHandle handle )
    {
        m_pendingScores.erase( handle );
    }
    
    void FailedPost( FCHandle handle );
    
    struct PendingScore {
        std::string     leaderboardName;
        unsigned int    score;
    };
    
    typedef std::map<FCHandle, PendingScore>    PendingScoreMap;
    
    PendingScoreMap m_pendingScores;
};

#endif
