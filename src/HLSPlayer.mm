#include "HLSPlayer.h"


HLSPlayer::HLSPlayer()
{
    videoPlayer = NULL;
    textureCacheID = -1;
    videoWidth = 0;
    videoHeight = 0;
    duration = 0;
}


bool HLSPlayer::load(string name)
{
    
    videoPlayer = [[AVFPlayer alloc] init];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:name.c_str()]];
    
    [videoPlayer loadFromURL:url];

}


void HLSPlayer::update()
{

    if(!videoTexture.isAllocated())
    {
        
        if([videoPlayer isReady])
        {
            videoWidth = videoPlayer.avPlayerItem.presentationSize.width;
            videoHeight = videoPlayer.avPlayerItem.presentationSize.height;
            
            duration = [videoPlayer duration];
            videoTexture.allocate(videoWidth, videoHeight, GL_RGBA);
            outputTexture.allocate(videoWidth, videoHeight, GL_RGBA);
            
            textureCacheID = [videoPlayer beginCreateTexture];
            videoTexture.setUseExternalTextureID(textureCacheID);
            [videoPlayer endCreateTexture];
        }
    }
    
    
    if([videoPlayer isPlaying])
    {
        if([videoPlayer isReady])
        {
            [videoPlayer update];
            unsigned char* pixels = [videoPlayer getPixels];
            if(pixels)
            {
                outputTexture.loadData(pixels, videoWidth, videoHeight, GL_BGRA);

            }
        }
    }
}

void HLSPlayer::drawDebug()
{
    if(outputTexture.isAllocated())
    {
        outputTexture.draw(0, 0);
    }
    if(outputTexture.isAllocated())
    {
        int scaledWidth = videoWidth*.25;
        int scaledHeight = videoHeight*.25;
        outputTexture.draw(ofGetWidth()-scaledWidth, ofGetHeight()-scaledHeight, scaledWidth, scaledHeight);
    }
}


void HLSPlayer::draw(float x, float y)
{
    if(outputTexture.isAllocated())
    {
        outputTexture.draw(x, y);
    }
}

float HLSPlayer::getCurrentTime()
{
    if(![videoPlayer isPlaying])
    {
        return 0;
    }
    return [videoPlayer getCurrentTime];
}

void HLSPlayer::seekToTimeInSeconds(int seconds)
{
    [videoPlayer seekToTimeInSeconds:seconds];
}

string HLSPlayer::getInfo()
{
    if(![videoPlayer isPlaying])
    {
        return "NOT READY";
    }
    stringstream info;
    info << "width: " << videoWidth << endl;
    info << "height: " << videoHeight << endl;
    info << "currentTime: " << getCurrentTime() << endl;
    info << "duration: " << duration << endl;
    info << "isFrameNew: " << [videoPlayer isFrameNew] << endl;

    
    
    return info.str();
}

