include $(CLEAR_VARS)

LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_MODULE := fc
LOCAL_SRC_FILES := 	$(BOX2D_SRC_PATH)/Box2D/Collision/b2BroadPhase.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2CollideCircle.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2CollideEdge.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2CollidePolygon.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2Collision.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2Distance.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2DynamicTree.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/b2TimeOfImpact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/Shapes/b2ChainShape.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/Shapes/b2CircleShape.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/Shapes/b2EdgeShape.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Collision/Shapes/b2PolygonShape.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2BlockAllocator.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2Draw.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2Math.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2Settings.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2StackAllocator.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Common/b2Timer.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2Body.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2ContactManager.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2Fixture.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2Island.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2World.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/b2WorldCallbacks.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2ChainAndCircleContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2ChainAndPolygonContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2CircleContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2Contact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2ContactSolver.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2EdgeAndCircleContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2EdgeAndPolygonContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2PolygonAndCircleContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Contacts/b2PolygonContact.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2DistanceJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2FrictionJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2GearJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2Joint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2MouseJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2PrismaticJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2PulleyJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2RevoluteJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2RopeJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2WeldJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Dynamics/Joints/b2WheelJoint.cpp \
					$(BOX2D_SRC_PATH)/Box2D/Rope/b2Rope.cpp \
					$(SHA1_SRC_PATH)/sha1.cpp \
					$(LUA_SRC_PATH)/lapi.c \
					$(LUA_SRC_PATH)/lauxlib.c \
					$(LUA_SRC_PATH)/lbaselib.c \
					$(LUA_SRC_PATH)/lbitlib.c \
					$(LUA_SRC_PATH)/lcode.c \
					$(LUA_SRC_PATH)/lcorolib.c \
					$(LUA_SRC_PATH)/lctype.c \
					$(LUA_SRC_PATH)/ldblib.c \
					$(LUA_SRC_PATH)/ldebug.c \
					$(LUA_SRC_PATH)/ldo.c \
					$(LUA_SRC_PATH)/ldump.c \
					$(LUA_SRC_PATH)/lfunc.c \
					$(LUA_SRC_PATH)/lgc.c \
					$(LUA_SRC_PATH)/linit.c \
					$(LUA_SRC_PATH)/liolib.c \
					$(LUA_SRC_PATH)/llex.c \
					$(LUA_SRC_PATH)/lmathlib.c \
					$(LUA_SRC_PATH)/lmem.c \
					$(LUA_SRC_PATH)/loadlib.c \
					$(LUA_SRC_PATH)/lobject.c \
					$(LUA_SRC_PATH)/lopcodes.c \
					$(LUA_SRC_PATH)/loslib.c \
					$(LUA_SRC_PATH)/lparser.c \
					$(LUA_SRC_PATH)/lstate.c \
					$(LUA_SRC_PATH)/lstring.c \
					$(LUA_SRC_PATH)/lstrlib.c \
					$(LUA_SRC_PATH)/ltable.c \
					$(LUA_SRC_PATH)/ltablib.c \
					$(LUA_SRC_PATH)/ltm.c \
					$(LUA_SRC_PATH)/luac.c \
					$(LUA_SRC_PATH)/lundump.c \
					$(LUA_SRC_PATH)/lvm.c \
					$(LUA_SRC_PATH)/lzio.c \
					$(FC_SRC_PATH)/Shared/Audio/FCAudioManager.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCCrypto.cpp	\
					$(FC_SRC_PATH)/Shared/Core/FCError.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCFile.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCKeys.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCNotifications.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCStringUtils.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCTypes.cpp \
					$(FC_SRC_PATH)/Shared/Core/FCXML.cpp \
					$(FC_SRC_PATH)/Shared/Core/Debug/FCConnect.cpp \
					$(FC_SRC_PATH)/Shared/Core/Debug/FCPerformanceCounter.cpp \
					$(FC_SRC_PATH)/Shared/Core/Device/FCDevice.cpp \
					$(FC_SRC_PATH)/Shared/Core/Maths/FCHalfPrecision.cpp \
					$(FC_SRC_PATH)/Shared/Core/Maths/FCMatrix.cpp \
					$(FC_SRC_PATH)/Shared/Core/Maths/FCRandom.cpp \
					$(FC_SRC_PATH)/Shared/Core/Maths/FCVector.cpp \
					$(FC_SRC_PATH)/Shared/Core/Resources/FCResource.cpp \
					$(FC_SRC_PATH)/Shared/Core/Resources/FCResourceManager.cpp \
					$(FC_SRC_PATH)/Shared/Framework/FCApplication.cpp \
					$(FC_SRC_PATH)/Shared/Framework/FCBuild.cpp \
					$(FC_SRC_PATH)/Shared/Framework/FCPersistentData.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Actor/FCActor.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Actor/FCActorSystem.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Ads/FCAds.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Analytics/FCAnalytics.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Gameplay/FCObjectManager.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Input/FCInput.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Online/FCOnlineLeaderboard.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Online/FCTwitter.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Phase/FCPhase.cpp \
					$(FC_SRC_PATH)/Shared/Framework/Phase/FCPhaseManager.cpp \
					$(FC_SRC_PATH)/Shared/Framework/UI/FCViewManager.cpp \
					$(FC_SRC_PATH)/Shared/Graphics/FCRenderer.cpp \
					$(FC_SRC_PATH)/Shared/Lua/FCLua.cpp \
					$(FC_SRC_PATH)/Shared/Lua/FCLuaCommon.cpp \
					$(FC_SRC_PATH)/Shared/Lua/FCLuaMemory.cpp \
					$(FC_SRC_PATH)/Shared/Lua/FCLuaThread.cpp \
					$(FC_SRC_PATH)/Shared/Lua/FCLuaVM.cpp \
					$(FC_SRC_PATH)/Shared/Physics/FCPhysics.cpp \
					$(FC_SRC_PATH)/Shared/Physics/FCPhysicsMaterial.cpp \
					$(FC_SRC_PATH)/Shared/Physics/2D/FCPhysics2D.cpp \
					$(FC_SRC_PATH)/Shared/Physics/2D/FCPhysics2DBody.cpp \
					$(FC_SRC_PATH)/Shared/Physics/2D/FCPhysics2DContactListener.cpp \
					$(FC_SRC_PATH)/Shared/Physics/3D/FCPhysics3D.cpp \
					$(FC_SRC_PATH)/GLES/FCGL.cpp \
					$(FC_SRC_PATH)/GLES/FCGLDebugDraw.cpp \
					$(FC_SRC_PATH)/GLES/FCGLHelpers.cpp \
					$(FC_SRC_PATH)/GLES/FCGLMesh.cpp \
					$(FC_SRC_PATH)/GLES/FCGLModel.cpp \
					$(FC_SRC_PATH)/GLES/FCGLRenderer.cpp \
					$(FC_SRC_PATH)/GLES/FCGLShader.cpp \
					$(FC_SRC_PATH)/GLES/FCGLShaderManager.cpp \
					$(FC_SRC_PATH)/GLES/FCGLShaderProgram.cpp \
					$(FC_SRC_PATH)/GLES/FCGLTextureFile.cpp \
					$(FC_SRC_PATH)/GLES/FCGLTextureFilePVR.cpp \
					$(FC_SRC_PATH)/GLES/FCGLTextureManager.cpp \
					$(FC_SRC_PATH)/GLES/FCGLView.cpp \
					$(FC_SRC_PATH)/Android/cpp/FCPlatformInterface.cpp \
					$(FC_SRC_PATH)/Android/cpp/Framework/FCApplication_android.cpp

LOCAL_CPPFLAGS := $(MY_LOCAL_CPPFLAGS)
LOCAL_CFLAGS := $(MY_LOCAL_CFLAGS)
LOCAL_C_INCLUDES := $(MY_LOCAL_C_INCLUDES)
LOCAL_STATIC_LIBRARIES := android_native_app_glue

include $(BUILD_STATIC_LIBRARY)