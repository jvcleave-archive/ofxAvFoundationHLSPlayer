#if !defined(TARGET_RASPBERRY_PI)

#include "ofxAvFoundationHLSPlayer.h"


ofxAvFoundationHLSPlayer::ofxAvFoundationHLSPlayer()
{
    videoPlayer = NULL;
    pixels = NULL;
    duration = 0;
    pixelSize = 0;
}

ofxAvFoundationHLSPlayer::~ofxAvFoundationHLSPlayer()
{
    if (videoPlayer) {
        
        if(pixels)
        {
            pixels = NULL;
        }
        
        [videoPlayer release];
        videoPlayer = NULL;
    }
}



bool ofxAvFoundationHLSPlayer::load(string name)
{
    
    videoPlayer = [[AVFPlayer alloc] init];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:name.c_str()]];
    
    [videoPlayer loadFromURL:url];

}

float ofxAvFoundationHLSPlayer::getDuration()
{
    return [videoPlayer duration];
}

void ofxAvFoundationHLSPlayer::update()
{

    
    if([videoPlayer isPlaying])
    {
        if([videoPlayer isReady])
        {
            [videoPlayer update];
    
            
            if([videoPlayer hasErrors])
            {
                for (NSString* errorString in videoPlayer.errorStrings)
                {
                    const char *cString = [errorString UTF8String];
                    errors.push_back(cString);
                }
                [videoPlayer clearErrors];
            }
        }
    }
}

void ofxAvFoundationHLSPlayer::drawDebug()
{
    [videoPlayer draw];
#if 0
    if(videoPlayer->outputTexture.isAllocated())
    {
        videoPlayer->outputTexture.draw(0, 0);
    }
    if(videoPlayer->outputTexture.isAllocated())
    {
        int scaledWidth = width*.25;
        int scaledHeight = height*.25;
        outputTexture.draw(ofGetWidth()-scaledWidth, ofGetHeight()-scaledHeight, scaledWidth, scaledHeight);
    }
#endif
}


void ofxAvFoundationHLSPlayer::draw(float x, float y)
{
    /*
    if(outputTexture.isAllocated())
    {
        outputTexture.draw(x, y);
    }
     */
    [videoPlayer draw];
}

float ofxAvFoundationHLSPlayer::getCurrentTime()
{
    if(![videoPlayer isPlaying])
    {
        return 0;
    }
    return [videoPlayer getCurrentTime];
}

void ofxAvFoundationHLSPlayer::seekToTimeInSeconds(int seconds)
{
    [videoPlayer seekToTimeInSeconds:seconds];
}


void ofxAvFoundationHLSPlayer::togglePause()
{
    [videoPlayer togglePause];

}

void ofxAvFoundationHLSPlayer::mute()
{
    [videoPlayer mute];
    
}
string ofxAvFoundationHLSPlayer::getInfo()
{
    
    if(![videoPlayer isPlaying])
    {
        return "NOT PLAYING";
    }
    
    if(![videoPlayer isReady])
    {
        return "NOT READY";
    }
    stringstream info;
    //info << "width: " << width << endl;
    //info << "height: " << height << endl;
    info << "currentTime: " << getCurrentTime() << endl;
    info << "duration: " << duration << endl;
    info << "isFrameNew: " << [videoPlayer isFrameNew] << endl;

    
    
    return info.str();
}
#endif
