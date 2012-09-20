include $(CLEAR_VARS)

LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_MODULE := fc
LOCAL_SRC_FILES := 	$(FC_SRC_PATH)/Shared/Audio/FCAudioManager.cpp \
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
					$(FC_SRC_PATH)/GLES/FCGLView.cpp

LOCAL_CPPFLAGS := $(MY_LOCAL_CPPFLAGS)
LOCAL_CFLAGS := $(MY_LOCAL_CFLAGS)
LOCAL_C_INCLUDES := $(MY_LOCAL_C_INCLUDES)
LOCAL_STATIC_LIBRARIES := android_native_app_glue

include $(BUILD_STATIC_LIBRARY)