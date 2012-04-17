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

#import <Foundation/Foundation.h>

static const float kFCInvalidFloat = -FLT_MAX;
static const int kFCInvalidInt = 0x7fffffff;

extern NSString* kFCKeyId;
extern NSString* kFCKeyTexture;
extern NSString* kFCKeyAtlas;
extern NSString* kFCKeyName;
extern NSString* kFCKeySize;

extern NSString* kFCKeyNull;

// Physics

extern NSString* kFCKeyBody;
extern NSString* kFCKeyMaterial;
extern NSString* kFCKeyPhysics;
extern NSString* kFCKeyDensity;
extern NSString* kFCKeyFriction;
extern NSString* kFCKeyRestitution;
extern NSString* kFCKeyJointType;
extern NSString* kFCKeyJointTypeRevolute;
extern NSString* kFCKeyJointTypeDistance;
extern NSString* kFCKeyJointTypePrismatic;
extern NSString* kFCKeyJointTypePulley;
extern NSString* kFCKeyJointAnchorId;
extern NSString* kFCKeyJointAnchorOffsetX;
extern NSString* kFCKeyJointAnchorOffsetY;
extern NSString* kFCKeyJointAnchorGroundX;
extern NSString* kFCKeyJointAnchorGroundY;
extern NSString* kFCKeyJointOffsetX;
extern NSString* kFCKeyJointOffsetY;
extern NSString* kFCKeyJointLowerAngle;
extern NSString* kFCKeyJointUpperAngle;
extern NSString* kFCKeyJointLowerTranslation;
extern NSString* kFCKeyJointUpperTranslation;
extern NSString* kFCKeyJointMaxMotorTorque;
extern NSString* kFCKeyJointMaxMotorForce;
extern NSString* kFCKeyJointMotorSpeed;
extern NSString* kFCKeyJointAxisX;
extern NSString* kFCKeyJointAxisY;
extern NSString* kFCKeyJointGroundX;
extern NSString* kFCKeyJointGroundY;
extern NSString* kFCKeyJointRatio;
extern NSString* kFCKeyJointMaxLength1;
extern NSString* kFCKeyJointMaxLength2;

extern NSString* kFCKeyRndSeed;

extern NSString* kFCKeyModel;
extern NSString* kFCKeyDebugShape;

extern NSString* kFCKeyDiffuseColor;

extern NSString* kFCKeyNumVertices;
extern NSString* kFCKeyNumTriangles;
extern NSString* kFCKeyNumEdges;
extern NSString* kFCKeyType;

extern NSString* kFCKeyX;
extern NSString* kFCKeyY;
extern NSString* kFCKeyWidth;
extern NSString* kFCKeyHeight;
extern NSString* kFCKeyOffset;
extern NSString* kFCKeyOffsetX;
extern NSString* kFCKeyOffsetY;
extern NSString* kFCKeyOffsetZ;
extern NSString* kFCKeyRotationX;
extern NSString* kFCKeyRotationY;
extern NSString* kFCKeyRotationZ;
extern NSString* kFCKeyAngle;
extern NSString* kFCKeyRadius;
extern NSString* kFCKeyShape;
extern NSString* kFCKeyRectangle;
extern NSString* kFCKeyBox;
extern NSString* kFCKeyXSize;
extern NSString* kFCKeyYSize;
extern NSString* kFCKeyZSize;
extern NSString* kFCKeyCircle;
extern NSString* kFCKeyPolygon;
extern NSString* kFCKeyHull;
extern NSString* kFCKeyLinearDamping;
extern NSString* kFCKeyDynamic;

// Colors

extern NSString* kFCKeyColor;
extern NSString* kFCKeyRed;
extern NSString* kFCKeyGreen;
extern NSString* kFCKeyBlue;
extern NSString* kFCKeyYellow;
extern NSString* kFCKeyWhite;

extern NSString* kFCKeyCount;

// Graphics

extern NSString* kFCKeyShaderWireframe;
extern NSString* kFCKeyShaderDebug;
extern NSString* kFCKeyShaderFlatUnlit;
extern NSString* kFCKeyShaderNoTexVLit;
extern NSString* kFCKeyShaderTest;

// File types

extern NSString* kFCKeyPNG;

extern NSString* kFCKeyVertexFormat;
extern NSString* kFCKeyVertexPosition;
extern NSString* kFCKeyVertexNormal;
extern NSString* kFCKeyVertexTexCoord0;

extern NSString* kFCKeyVertexBuffer;
extern NSString* kFCKeyIndexBuffer;
extern NSString* kFCKeyNormalArray;
extern NSString* kFCKeyVertexArray;
extern NSString* kFCKeyTexcoord0Array;
extern NSString* kFCKeyTexcoord1Array;
extern NSString* kFCKeyTexcoord2Array;
extern NSString* kFCKeyTexcoord3Array;
extern NSString* kFCKeyIndexArray;
extern NSString* kFCKeyMaterialDiffuseColor;
extern NSString* kFCKeyMaterialDiffuseTexture;
extern NSString* kFCKeyShader;
extern NSString* kFCKeyShaderProgramName;
extern NSString* kFCKeyStride;

extern NSString* kFCKeyVersion;
extern NSString* kFCKeyInput;
extern NSString* kFCKeyOutput;
extern NSString* kFCKeyBinaryPayload;
extern NSString* kFCKeyTextures;
extern NSString* kFCKeyGameplay;
extern NSString* kFCKeyGame;
extern NSString* kFCKeyModels;
extern NSString* kFCKeyBuffers;
extern NSString* kFCKeyMesh;
extern NSString* kFCKeyCamera;
