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


#ifndef FCNotifications_h
#define FCNotifications_h

#include <string>
#include "Shared/Core/FCCore.h"

extern std::string kFCNotificationAppWillEnterBackground;
extern std::string kFCNotificationAppWillEnterForeground;
extern std::string kFCNotificationAppWillBeTerminated;
extern std::string kFCNotificationAppNeedsToFreeMemory;

extern std::string kFCNotificationContinue;
extern std::string kFCNotificationQuit;
extern std::string kFCNotificationRestart;
extern std::string kFCNotificationRetry;

extern std::string kFCNotificationPause;
extern std::string kFCNotificationResume;

extern std::string kFCNotificationPlayerIDChanged;
extern std::string kFCNotificationHighScoresChanged;

class FCNotification
{
public:
	std::string	notification;
	FCDataRef	data;
};

typedef void (*FCNotificationHandler)(FCNotification, void*);

class FCNotificationHandlerInfo
{
public:
	FCNotificationHandler	handler;
	void*					context;
};

typedef std::vector<FCNotificationHandlerInfo>			FCNotificationHandlerInfoVec;
typedef FCNotificationHandlerInfoVec::iterator			FCNotificationHandlerInfoVecIter;
typedef FCNotificationHandlerInfoVec::const_iterator	FCNotificationHandlerInfoVecConstIter;

typedef std::map<std::string, FCNotificationHandlerInfoVec> FCNotificationHandlerVecMapByString;

class FCNotificationManager
{
public:
	FCNotificationManager(){}
	virtual ~FCNotificationManager(){}
	
	static FCNotificationManager* Instance();

	FCReturn AddSubscription( FCNotificationHandler func, std::string notification, void* context );
	FCReturn RemoveSubscription( FCNotificationHandler func, std::string notification );

	FCReturn SendNotification( FCNotification& notification );
	
private:
	FCNotificationHandlerVecMapByString	m_notificationSubscriptions;
};

#endif // FCNotifications_h
