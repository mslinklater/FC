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

#include "Shared/Core/FCCore.h"
#include "FCPhase.h"

class FCPhaseManager : public FCBase
{
public:
	static FCPhaseManager* Instance();
	
	FCPhaseManager();
	virtual ~FCPhaseManager();
	
	void Update( float dt );
	void AttachPhase( FCPhaseRef phase );
	void AddPhaseToQueue( std::string name );
	void DeactivatePhase( std::string name );
protected:
	FCPhaseRef		m_rootPhase;
	FCPhaseRefVector	m_phaseQueue;
	FCPhaseRefVector	m_activePhases;
};





#if 0
#import <Foundation/Foundation.h>
#import "FCPhase.h"

class FCLuaVM;

@interface FCPhaseManager : NSObject
{
	FCPhase* _rootPhase;
	NSMutableArray* _phaseQueue;
	NSMutableArray* _activePhases;
}
@property(nonatomic, strong) FCPhase* rootPhase;
@property(nonatomic, strong) NSMutableArray* phaseQueue;
@property(nonatomic, strong) NSMutableArray* activePhases;

+(FCPhaseManager*)instance;
+(void)registerLuaFunctions:(FCLuaVM*)lua;
-(void)update:(float)dt;
-(FCPhase*)createPhaseWithName:(NSString*)name;
-(void)attachPhase:(FCPhase*)phase toParent:(FCPhase*)parentPhase;

-(void)addPhaseToQueue:(NSString*)name;
-(void)deactivatePhase:(NSString*)name;

@end
#endif