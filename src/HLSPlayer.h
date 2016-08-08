#pragma once

#include "ofMain.h"


#ifdef __OBJC__
    #import "AVFPlayer.h"
#endif

#if defined TARGET_OF_IOS || defined TARGET_OSX
#import <CoreVideo/CoreVideo.h>
#endif

class HLSPlayer
{
    
public:
    
    HLSPlayer();

	   
    bool load(string name);

    void update();
    
    void draw();
    void draw(float x, float y);
    float videoWidth;
    float videoHeight;
    
#ifdef __OBJC__
    AVFPlayer* videoPlayer;
#else
    void * videoPlayer;
#endif
    
    bool bFrameNew;
    bool bResetPixels;
    bool bUpdatePixels;
    bool bUpdateTexture;
    bool bUseTextureCache;
    
    ofPixels pixels;
    ofPixelFormat pixelFormat;
    ofTexture videoTexture;
    
#ifdef TARGET_OF_IOS
    CVOpenGLESTextureCacheRef _videoTextureCache = nullptr;
    CVOpenGLESTextureRef _videoTextureRef = nullptr;
#endif
    
    CVOpenGLTextureCacheRef _videoTextureCache = nullptr;
    CVOpenGLTextureRef _videoTextureRef = nullptr;
};

