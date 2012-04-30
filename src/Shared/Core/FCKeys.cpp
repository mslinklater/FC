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

#include "FCKeys.h"

std::string kFCKeyId = "id";
std::string kFCKeyTexture = "texture";
std::string kFCKeyAtlas = "atlas";
std::string kFCKeyName = "name";
std::string kFCKeySize = "size";

std::string kFCKeyNull = "null";

// Physics

std::string kFCKeyBody = "body";
std::string kFCKeyMaterial = "material";
std::string kFCKeyPhysics = "physics";
std::string kFCKeyDensity = "density";
std::string kFCKeyFriction = "friction";
std::string kFCKeyRestitution = "restitution";
std::string kFCKeyJointType = "type";
std::string kFCKeyJointTypeRevolute = "revolute";
std::string kFCKeyJointTypeDistance = "distance";
std::string kFCKeyJointTypePrismatic = "prismatic";
std::string kFCKeyJointTypePulley = "pulley";
std::string kFCKeyJointAnchorId = "anchorid";
std::string kFCKeyJointAnchorOffsetX = "anchorOffsetX";
std::string kFCKeyJointAnchorOffsetY = "anchorOffsetY";
std::string kFCKeyJointAnchorGroundX = "anchorgroundx";
std::string kFCKeyJointAnchorGroundY = "anchorgroundy";
std::string kFCKeyJointOffsetX = "offsetX";
std::string kFCKeyJointOffsetY = "offsetY";
std::string kFCKeyJointLowerAngle = "lowerangle";
std::string kFCKeyJointUpperAngle = "upperangle";
std::string kFCKeyJointLowerTranslation = "lowertranslation";
std::string kFCKeyJointUpperTranslation = "uppertranslation";
std::string kFCKeyJointMaxMotorTorque = "maxmotortorque";
std::string kFCKeyJointMaxMotorForce = "maxmotorforce";
std::string kFCKeyJointMotorSpeed = "motorspeed";
std::string kFCKeyJointAxisX = "axisx";
std::string kFCKeyJointAxisY = "axisy";
std::string kFCKeyJointGroundX = "groundx";
std::string kFCKeyJointGroundY = "groundy";
std::string kFCKeyJointRatio = "ratio";
std::string kFCKeyJointMaxLength1 = "maxlength1";
std::string kFCKeyJointMaxLength2 = "maxlength2";

std::string kFCKeyRndSeed = "rndseed";

std::string kFCKeyModel = "model";
std::string kFCKeyDebugShape = "debugshape";

std::string kFCKeyNumVertices = "numvertices";
std::string kFCKeyNumTriangles = "numtriangles";
std::string kFCKeyNumEdges = "numedges";
std::string kFCKeyType = "type";

std::string kFCKeyX = "x";
std::string kFCKeyY = "y";
std::string kFCKeyWidth = "width";
std::string kFCKeyHeight = "height";
std::string kFCKeyOffset = "offset";
std::string kFCKeyOffsetX = "offsetX";
std::string kFCKeyOffsetY = "offsetY";
std::string kFCKeyOffsetZ = "offsetZ";
std::string kFCKeyRotationX = "rotationX";
std::string kFCKeyRotationY = "rotationY";
std::string kFCKeyRotationZ = "rotationZ";
std::string kFCKeyAngle = "angle";
std::string kFCKeyRadius = "radius";
std::string kFCKeyShape = "shape";
std::string kFCKeyCircle = "circle";
std::string kFCKeyRectangle = "rectangle";
std::string kFCKeyBox = "box";
std::string kFCKeyXSize = "xSize";
std::string kFCKeyYSize = "ySize";
std::string kFCKeyZSize = "zSize";
std::string kFCKeyHull = "hull";
std::string kFCKeyPolygon = "polygon";
std::string kFCKeyLinearDamping = "lineardamping";
std::string kFCKeyDynamic = "dynamic";

std::string kFCKeyColor = "color";
std::string kFCKeyRed = "red";
std::string kFCKeyGreen = "green";
std::string kFCKeyBlue = "blue";
std::string kFCKeyYellow = "yellow";
std::string kFCKeyWhite = "white";

std::string kFCKeyCount = "count";

// Graphics

std::string kFCKeyShaderWireframe = "wireframe";
std::string kFCKeyShaderDebug = "debug";
std::string kFCKeyShaderFlatUnlit = "flatunlit";
std::string kFCKeyShaderNoTexVLit = "notex_vlit";
std::string kFCKeyShaderNoTexPLit = "notex_plit";
std::string kFCKeyShader1TexVLit = "1tex_vlit";
std::string kFCKeyShader1TexPLit = "1tex_plit";
std::string kFCKeyShaderTest = "test";

std::string kFCKeyDiffuseColor = "diffusecolor";

// File types

std::string kFCKeyPNG = "png";

std::string kFCKeyVertexFormat = "vertexformat";
std::string kFCKeyVertexPosition = "vertexposition";
std::string kFCKeyVertexNormal = "vertexnormal";
std::string kFCKeyVertexTexCoord0 = "vertextexcoord0";

std::string kFCKeyVertexBuffer = "vertexbuffer";
std::string kFCKeyIndexBuffer = "indexbuffer";
std::string kFCKeyNormalArray = "normalarray";
std::string kFCKeyVertexArray = "vertexarray";
std::string kFCKeyTexcoord0Array = "texcoord0array";
std::string kFCKeyTexcoord1Array = "texcoord1array";
std::string kFCKeyTexcoord2Array = "texcoord2array";
std::string kFCKeyTexcoord3Array = "texcoord3array";
std::string kFCKeyIndexArray = "indexarray";
std::string kFCKeyMaterialDiffuseColor = "materialdiffusecolor";
std::string kFCKeyMaterialDiffuseTexture = "materialdiffusetexture";
std::string kFCKeyShader = "shader";
std::string kFCKeyShaderProgramName = "shaderprogramname";
std::string kFCKeyStride = "stride";

std::string kFCKeyVersion = "version";
std::string kFCKeyInput = "input";
std::string kFCKeyOutput = "output";
std::string kFCKeyBinaryPayload = "binarypayload";
std::string kFCKeyTextures = "textures";
std::string kFCKeyGameplay = "gameplay";
std::string kFCKeyGame = "game";
std::string kFCKeyModels = "models";
std::string kFCKeyBuffers = "buffers";
std::string kFCKeyMesh = "mesh";
std::string kFCKeyCamera = "camera";

// Caps

std::string kFCDeviceTrue = "true";
std::string kFCDeviceFalse = "false";

std::string kFCDevicePresent = "present";
std::string kFCDeviceNotPresent = "not present";
std::string kFCDeviceUnknown = "unknown";

std::string kFCDevicePlatformPhone = "platform_iphone";
std::string kFCDevicePlatformPhoneRetina = "platform_iphone_retina";
std::string kFCDevicePlatformPhoneOnPad = "platform_iphone_on_ipad";
std::string kFCDevicePlatformPad = "platform_ipad";
std::string kFCDevicePlatformPadRetina = "platform_ipad_retina";

//------- keys

std::string kFCDeviceDisplayAspectRatio = "display_aspect_ratio";
std::string kFCDeviceDisplayLogicalXRes = "display_logical_xres";
std::string kFCDeviceDisplayLogicalYRes = "display_logical_yres";
std::string kFCDeviceDisplayPhysicalXRes = "display_physical_xres";
std::string kFCDeviceDisplayPhysicalYRes = "display_physical_yres";
std::string kFCDeviceDisplayScale = "display_scale";

std::string kFCDeviceHardwareModelID = "hardware_model_id";
std::string kFCDeviceHardwareModel = "hardware_model";
std::string kFCDeviceHardwareUDID = "hardware_udid";
std::string kFCDeviceHardwareName = "hardware_name";

std::string kFCDeviceLocale = "locale";

std::string kFCDeviceOSVersion = "os_version";
std::string kFCDeviceOSName = "os_name";
std::string kFCDeviceOSGameCenter = "os_gamecenter";

std::string kFCDevicePlatform = "platform";

std::string kFCDeviceSimulator = "simulator";

std::string kFCDeviceAppPirated = "pirated";

