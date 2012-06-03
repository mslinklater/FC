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

typedef FCActorPtr (*FCActorCreateFunc)(void);

class FCActorSystem : public FCBase
{
public:
	FCActorSystem();
	virtual ~FCActorSystem();
	
	static FCActorSystem* Instance();
	
	void Init();
	FCActorPtr ActorWithFullName(std::string name);
	FCActorPtr ActorWithHandle(FCHandle handle);
	
	void AddToDeleteArray(FCActorPtr actor);
	void RemoveActor(FCActorPtr actor);
	void RemoveAllActors();
	void Reset();
	
	FCActorVec CreateActors(std::string actorClass, FCResourcePtr res, std::string name);
	
	FCActorPtr CreateActor( FCXMLNode actorXML, std::string actorClass, FCResourcePtr res, std::string name);
	FCActorPtr CreateActor( std::string actorClass, std::string name );
	
	void Update(float realTime, float gameTime);

	const FCActorVec& TapGestureActorsVec(){ return m_tapGestureActorsVec; }
	const FCActorMapByHandle& ActorByHandleMap(){ return m_actorHandleMap; }
	
	void AddActorCreateFunction( std::string type, FCActorCreateFunc func)
	{
		m_createFuncs[ type ] = func;
	}
	
private:
	
	typedef std::map<std::string, FCActorCreateFunc> ActorCreateFunctionMap;

	ActorCreateFunctionMap	m_createFuncs;
	
	FCActorPtr ActorOfClass(std::string actorClass);
	
	FCActorVec		m_allActorsVec;
	FCActorVec		m_updateActorsVec;
	FCActorVec		m_renderActorsVec;
	FCActorVec		m_tapGestureActorsVec;
	FCActorVec		m_deleteList;
	
	FCActorMapByString m_actorFullNameMap;
	FCActorMapByHandle m_actorHandleMap;
};

#endif // FCACTORSYSTEM_H
