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

#ifndef FCPHASE_H
#define FCPHASE_H


#include "Shared/Core/FCCore.h"

enum FCPhaseUpdate {
	kFCPhaseUpdateOK,
	kFCPhaseUpdateDeactivate
};

enum FCPhaseState {
	kFCPhaseStateInactive,
	kFCPhaseStateActivating,
	kFCPhaseStateUpdating,
	kFCPhaseStateDeactivating
};

class FCPhase;

typedef std::shared_ptr<FCPhase> FCPhasePtr;
typedef std::vector<FCPhasePtr>	FCPhaseVector;
typedef FCPhaseVector::iterator	FCPhaseVectorIter;
typedef FCPhaseVector::const_iterator	FCPhaseVectorConstIter;
typedef std::map<std::string, FCPhasePtr>	FCPhaseMapByString;

class FCPhase : public FCBase
{
public:
	
	FCPhase( std::string name );
	virtual ~FCPhase(){}
	
	virtual FCPhaseUpdate Update( float dt );
	virtual void WasAddedToQueue();
	virtual void WasRemovedFromQueue();
	virtual void WillActivate();
	virtual void IsNowActive();
	virtual void WillDeactivate();
	virtual void IsNowDeactive();
	virtual void WillActivatePostLua();
	virtual void IsNowActivePostLua();
	virtual void WillDeactivatePostLua();
	virtual void IsNowDeactivePostLua();
	
	
	std::string m_name;
	std::string	m_namePath;
	FCPhasePtr	m_parent;
	FCPhaseMapByString	m_children;
	FCPhasePtr	m_activeChild;
	float		m_activateTimer;
	float		m_deactivateTimer;
	FCPhaseState	m_state;
	std::string	m_luaTable;
	bool		m_luaLoaded;
	std::string	m_luaUpdateFunc;
	std::string m_luaWasAddedToQueueFunc;
	std::string	m_luaWasRemovedFromQueueFunc;
	std::string	m_luaWillActivateFunc;
	std::string	m_luaIsNowActiveFunc;
	std::string	m_luaWillDeactivateFunc;
	std::string	m_luaIsNowDeactiveFunc;
protected:
};


#endif // FCPHASE_H

#if 0
#import <Foundation/Foundation.h>

@interface FCPhase : NSObject {
	NSString* _name;
	NSString* _namePath;
	__weak FCPhase* _parent;
	NSMutableDictionary* _children;
	FCPhase* _activeChild;
	float _activateTimer;
	float _deactivateTimer;
	FCPhaseState _state;
	
	NSString* _luaTable;
	BOOL _luaLoaded;
	
	NSString* _luaUpdateFunc;
	NSString* _luaWasAddedToQueueFunc;
	NSString* _luaWasRemovedFromQueueFunc;
	NSString* _luaWillActivateFunc;
	NSString* _luaIsNowActiveFunc;
	NSString* _luaWillDeactivateFunc;
	NSString* _luaIsNowDeactiveFunc;
}
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* namePath;
@property(nonatomic, weak) FCPhase* parent;
@property(nonatomic, strong) NSMutableDictionary* children;
@property(nonatomic, strong) FCPhase* activeChild;
@property(nonatomic) float activateTimer;
@property(nonatomic) float deactivateTimer;
@property(nonatomic) FCPhaseState state;

#if defined (FC_LUA)
@property(nonatomic, strong) NSString* luaTable;
@property(nonatomic, readonly) BOOL luaLoaded;

@property(nonatomic, strong) NSString* luaUpdateFunc;
@property(nonatomic, strong) NSString* luaWasAddedToQueueFunc;
@property(nonatomic, strong) NSString* luaWasRemovedFromQueueFunc;
@property(nonatomic, strong) NSString* luaWillActivateFunc;
@property(nonatomic, strong) NSString* luaIsNowActiveFunc;
@property(nonatomic, strong) NSString* luaWillDeactivateFunc;
@property(nonatomic, strong) NSString* luaIsNowDeactiveFunc;
#endif

-(id)initWithName:(NSString*)name;

-(FCPhaseUpdate)update:(float)dt;

-(void)wasAddedToQueue;
-(void)wasRemovedFromQueue;
-(void)willActivate;
-(void)isNowActive;
-(void)willDeactivate;
-(void)isNowDeactive;

-(void)willActivatePostLua;
-(void)isNowActivePostLua;
-(void)willDeactivatePostLua;
-(void)isNowDeactivePostLua;
@end
#endif
