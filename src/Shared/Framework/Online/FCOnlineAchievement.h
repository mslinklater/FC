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

#ifndef CR3_FCOnlineAchievement_h
#define CR3_FCOnlineAchievement_h

#include "Shared/Core/FCCore.h"

class FCOnlineAchievement {
public:
	
	static FCOnlineAchievement* Instance();
	
	FCOnlineAchievement();
	virtual ~FCOnlineAchievement();
	
	void Register( std::string name );
	void RefreshFromServer();
	void SetProgress( std::string name, float progress );
	void ServerProgress( std::string name, float progress );
	void ReportUnreported();
	void ClearAll();
	
private:
	
	typedef std::map<std::string, float> AchievementMap;
	typedef AchievementMap::iterator AchievementMapIter;

	AchievementMap m_achievements;
};

#endif
