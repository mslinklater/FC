include $(CLEAR_VARS)

LOCAL_PATH := $(MY_LOCAL_PATH)
LOCAL_MODULE := fc
LOCAL_SRC_FILES := $(FC_SRC_PATH)/Shared/Core/FCTypes.cpp
LOCAL_STATIC_LIBRARIES := android_native_app_glue
#LOCAL_CPPFLAGS = -std=c++0x

include $(BUILD_STATIC_LIBRARY)