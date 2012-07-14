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

#ifndef FCACTORSYSTEM_H
#define FCACTORSYSTEM_H

#include "Shared/Core/FCCore.h"
#include "FCActor.h"

typedef FCActorRef (*FCActorCreateFunc)(void);

class FCActorSystem : public FCBase
{
public:
	FCActorSystem();
	virtual ~FCActorSystem();
	
	static FCActorSystem* Instance();
	
	void Init();
	FCActorRef ActorWithFullName(std::string name);
	FCActorRef ActorWithHandle(FCHandle handle);
	
	void AddToDeleteArray(FCActorRef actor);
	void RemoveActor(FCActorRef actor);
	void RemoveAllActors();
	void Reset();
	
	FCActorRefVec CreateActors(std::string actorClass, FCResourceRef res, std::string name);
	
	FCActorRef CreateActor( FCXMLNode actorXML, std::string actorClass, FCResourceRef res, std::string name);
	FCActorRef CreateActor( std::string actorClass, std::string name );
	
	void Update(float realTime, float gameTime);

	const FCActorRefVec& TapGestureActorsVec(){ return m_tapGestureActorsVec; }
	const FCActorRefMapByHandle& ActorByHandleMap(){ return m_actorHandleMap; }
	
	void AddActorCreateFunction( std::string type, FCActorCreateFunc func)
	{
		m_createFuncs[ type ] = func;
	}
	
private:
	
	typedef std::map<std::string, FCActorCreateFunc> ActorCreateFunctionMap;

	ActorCreateFunctionMap	m_createFuncs;
	
	FCActorRef ActorOfClass(std::string actorClass);
	
	FCActorRefVec		m_allActorsVec;
	FCActorRefVec		m_updateActorsVec;
	FCActorRefVec		m_renderActorsVec;
	FCActorRefVec		m_tapGestureActorsVec;
	FCActorRefVec		m_deleteList;
	
	FCActorRefMapByString m_actorFullNameMap;
	FCActorRefMapByHandle m_actorHandleMap;
};

#endif // FCACTORSYSTEM_H
