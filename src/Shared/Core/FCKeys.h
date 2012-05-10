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

#ifndef FCKeys_h
#define FCKeys_h

#include <string>
#include <float.h>

static const float kFCInvalidFloat = -FLT_MAX;
static const int kFCInvalidInt = 0x7fffffff;

extern std::string kFCKeyId;
extern std::string kFCKeyTexture;
extern std::string kFCKeyAtlas;
extern std::string kFCKeyName;
extern std::string kFCKeySize;

extern std::string kFCKeyNull;

// Physics

extern std::string kFCKeyBody;
extern std::string kFCKeyMaterial;
extern std::string kFCKeyPhysics;
extern std::string kFCKeyDensity;
extern std::string kFCKeyFriction;
extern std::string kFCKeyRestitution;
extern std::string kFCKeyJointType;
extern std::string kFCKeyJointTypeRevolute;
extern std::string kFCKeyJointTypeDistance;
extern std::string kFCKeyJointTypePrismatic;
extern std::string kFCKeyJointTypePulley;
extern std::string kFCKeyJointAnchorId;
extern std::string kFCKeyJointAnchorOffsetX;
extern std::string kFCKeyJointAnchorOffsetY;
extern std::string kFCKeyJointAnchorGroundX;
extern std::string kFCKeyJointAnchorGroundY;
extern std::string kFCKeyJointOffsetX;
extern std::string kFCKeyJointOffsetY;
extern std::string kFCKeyJointLowerAngle;
extern std::string kFCKeyJointUpperAngle;
extern std::string kFCKeyJointLowerTranslation;
extern std::string kFCKeyJointUpperTranslation;
extern std::string kFCKeyJointMaxMotorTorque;
extern std::string kFCKeyJointMaxMotorForce;
extern std::string kFCKeyJointMotorSpeed;
extern std::string kFCKeyJointAxisX;
extern std::string kFCKeyJointAxisY;
extern std::string kFCKeyJointGroundX;
extern std::string kFCKeyJointGroundY;
extern std::string kFCKeyJointRatio;
extern std::string kFCKeyJointMaxLength1;
extern std::string kFCKeyJointMaxLength2;

extern std::string kFCKeyRndSeed;

extern std::string kFCKeyModel;
extern std::string kFCKeyDebugShape;

extern std::string kFCKeyDiffuseColor;

extern std::string kFCKeyNumVertices;
extern std::string kFCKeyNumTriangles;
extern std::string kFCKeyNumEdges;
extern std::string kFCKeyType;

extern std::string kFCKeyX;
extern std::string kFCKeyY;
extern std::string kFCKeyWidth;
extern std::string kFCKeyHeight;
extern std::string kFCKeyOffset;
extern std::string kFCKeyOffsetX;
extern std::string kFCKeyOffsetY;
extern std::string kFCKeyOffsetZ;
extern std::string kFCKeyRotation;
extern std::string kFCKeyRotationX;
extern std::string kFCKeyRotationY;
extern std::string kFCKeyRotationZ;
extern std::string kFCKeyAngle;
extern std::string kFCKeyRadius;
extern std::string kFCKeyShape;
extern std::string kFCKeyRectangle;
extern std::string kFCKeyBox;
extern std::string kFCKeyXSize;
extern std::string kFCKeyYSize;
extern std::string kFCKeyZSize;
extern std::string kFCKeyCircle;
extern std::string kFCKeyPolygon;
extern std::string kFCKeyHull;
extern std::string kFCKeyLinearDamping;
extern std::string kFCKeyDynamic;

// Colors

extern std::string kFCKeyColor;
extern std::string kFCKeyRed;
extern std::string kFCKeyGreen;
extern std::string kFCKeyBlue;
extern std::string kFCKeyYellow;
extern std::string kFCKeyWhite;

extern std::string kFCKeyCount;

// Graphics

extern std::string kFCKeyShaderWireframe;
extern std::string kFCKeyShaderDebug;
extern std::string kFCKeyShaderFlatUnlit;
extern std::string kFCKeyShaderNoTexVLit;
extern std::string kFCKeyShaderNoTexPLit;
extern std::string kFCKeyShader1TexVLit;
extern std::string kFCKeyShader1TexPLit;
extern std::string kFCKeyShaderTest;

// File types

extern std::string kFCKeyPNG;

extern std::string kFCKeyVertexFormat;
extern std::string kFCKeyVertexPosition;
extern std::string kFCKeyVertexNormal;
extern std::string kFCKeyVertexTexCoord0;

extern std::string kFCKeyVertexBuffer;
extern std::string kFCKeyIndexBuffer;
extern std::string kFCKeyNormalArray;
extern std::string kFCKeyVertexArray;
extern std::string kFCKeyTexcoord0Array;
extern std::string kFCKeyTexcoord1Array;
extern std::string kFCKeyTexcoord2Array;
extern std::string kFCKeyTexcoord3Array;
extern std::string kFCKeyIndexArray;
extern std::string kFCKeyMaterialDiffuseColor;
extern std::string kFCKeyMaterialDiffuseTexture;
extern std::string kFCKeyShader;
extern std::string kFCKeyShaderProgramName;
extern std::string kFCKeyStride;

extern std::string kFCKeyVersion;
extern std::string kFCKeyInput;
extern std::string kFCKeyOutput;
extern std::string kFCKeyBinaryPayload;
extern std::string kFCKeyTextures;
extern std::string kFCKeyGameplay;
extern std::string kFCKeyGame;
extern std::string kFCKeyModels;
extern std::string kFCKeyBuffers;
extern std::string kFCKeyMesh;
extern std::string kFCKeyCamera;

// Caps

extern std::string kFCDeviceTrue;
extern std::string kFCDeviceFalse;

extern std::string kFCDevicePresent;
extern std::string kFCDeviceNotPresent;
extern std::string kFCDeviceUnknown;

extern std::string kFCDevicePlatformiOS;
extern std::string kFCDevicePlatformOSX;
extern std::string kFCDevicePlatformWindows8;
extern std::string kFCDevicePlatformAndroid;

// actual caps

extern std::string kFCDeviceDisplayAspectRatio;
extern std::string kFCDeviceDisplayLogicalXRes;
extern std::string kFCDeviceDisplayLogicalYRes;
extern std::string kFCDeviceDisplayPhysicalXRes;
extern std::string kFCDeviceDisplayPhysicalYRes;
extern std::string kFCDeviceDisplayScale;

extern std::string kFCDeviceHardwareModelID;
extern std::string kFCDeviceHardwareModel;
extern std::string kFCDeviceHardwareUDID;
extern std::string kFCDeviceHardwareName;

extern std::string kFCDeviceLocale;

extern std::string kFCDeviceOSVersion;
extern std::string kFCDeviceOSName;
extern std::string kFCDeviceOSGameCenter;
extern std::string kFCDevicePlatform;
extern std::string kFCDeviceSimulator;

extern std::string kFCDeviceAppPirated;

extern std::string kFCDeviceGameCenterID;

#endif // FCKeys_h
