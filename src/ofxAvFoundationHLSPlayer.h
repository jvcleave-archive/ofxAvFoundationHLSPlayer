#pragma once
#if !defined(TARGET_RASPBERRY_PI)
#include "ofMain.h"


#ifdef __OBJC__
    #import "AVFPlayer.h"
#endif

#if defined TARGET_OF_IOS || defined TARGET_OSX
#import <CoreVideo/CoreVideo.h>
#endif

class ofxAvFoundationHLSPlayer
{
    
public:
    
    ofxAvFoundationHLSPlayer();
    ~ofxAvFoundationHLSPlayer();
	   
    bool load(string name);

    void update();
    
    void drawDebug();
    void draw(float x, float y);
    float getWidth();
    float getHeight();
    float duration;
    float getCurrentTime();
    float getDuration();
    ofTexture& getTexture();
    unsigned char* pixels;
    ofPixels myPixels;
    void seekToTimeInSeconds(int);
    void togglePause();
    string getInfo();
    vector<string> errors;
    void mute();
    int pixelSize;
#ifdef __OBJC__
    AVFPlayer* videoPlayer;
#else
    void * videoPlayer;
#endif
    
};
#endif
