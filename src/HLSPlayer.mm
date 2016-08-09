#include "HLSPlayer.h"


HLSPlayer::HLSPlayer()
{
    videoPlayer = NULL;
    pixels = NULL;
    width = 0;
    height = 0;
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

    if(!outputTexture.isAllocated())
    {
        
        if([videoPlayer isReady])
        {
            width = videoPlayer.avPlayerItem.presentationSize.width;
            height = videoPlayer.avPlayerItem.presentationSize.height;
            
            duration = [videoPlayer duration];
            outputTexture.allocate(width, height, GL_RGBA);
            
        }
    }
    
    
    if([videoPlayer isPlaying])
    {
        if([videoPlayer isReady])
        {
            [videoPlayer update];
            pixels = [videoPlayer getPixels];
            if(pixels)
            {
                outputTexture.loadData(pixels, width, height, GL_BGRA);
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
        int scaledWidth = width*.25;
        int scaledHeight = height*.25;
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
    info << "width: " << width << endl;
    info << "height: " << height << endl;
    info << "currentTime: " << getCurrentTime() << endl;
    info << "duration: " << duration << endl;
    info << "isFrameNew: " << [videoPlayer isFrameNew] << endl;

    
    
    return info.str();
}

