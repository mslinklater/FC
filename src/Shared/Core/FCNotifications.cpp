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

#include "FCNotifications.h"

static FCNotificationManager* s_pInstance = 0;

std::string kFCNotificationContinue = "FCN_Continue";
std::string kFCNotificationQuit = "FCN_Quit";
std::string kFCNotificationRestart = "FCN_Restart";
std::string kFCNotificationRetry = "FCN_Retry";

std::string kFCNotificationPause = "FCN_Pause";
std::string kFCNotificationResume = "FCN_Resume";

std::string kFCNotificationPlayerIDChanged = "FCN_PlayerIDChanged";
std::string kFCNotificationHighScoresChanged = "FCN_HighScoresChanged";

FCNotificationManager* FCNotificationManager::Instance()
{
	if( !s_pInstance )
	{
		s_pInstance = new FCNotificationManager;
	}
	return s_pInstance;
}

FCReturn FCNotificationManager::AddSubscription(FCNotificationHandler func, std::string notification, void* context )
{
	if (m_notificationSubscriptions.find(notification) == m_notificationSubscriptions.end()) {
		FCNotificationHandlerInfoVec vec;
		m_notificationSubscriptions[ notification ] = vec;
	}
	
	FCNotificationHandlerInfo info;
	info.handler = func;
	info.context = context;
	
	m_notificationSubscriptions[ notification ].push_back( info );
	
	return kFCReturnOK;
}

FCReturn FCNotificationManager::RemoveSubscription(FCNotificationHandler func, std::string notification)
{
	if( m_notificationSubscriptions.find(notification) == m_notificationSubscriptions.end() )
	{
		return kFCReturnError_NotFound;
	}

	FCNotificationHandlerInfoVec& vec = m_notificationSubscriptions[ notification ];

	for (FCNotificationHandlerInfoVecIter i = vec.begin(); i != vec.end(); i++) {
		if (i->handler == func) {
			vec.erase(i);
			return kFCReturnOK;
		}
	}
	
	return kFCReturnError_NotFound;
}

FCReturn FCNotificationManager::SendNotification(FCNotification &notification)
{
	if (m_notificationSubscriptions.find( notification.notification ) != m_notificationSubscriptions.end())
	{
		FCNotificationHandlerInfoVec& vec = m_notificationSubscriptions[ notification.notification ];
		
		for (FCNotificationHandlerInfoVecIter i = vec.begin(); i != vec.end(); i++) {
			
			(i->handler)( notification, i->context );
		}
	}
	return kFCReturnOK;
}


