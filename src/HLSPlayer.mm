#include "HLSPlayer.h"


HLSPlayer::HLSPlayer()
{
    videoPlayer = NULL;
    
}


bool HLSPlayer::load(string name)
{
    
    videoPlayer = [[AVFPlayer alloc] init];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:name.c_str()]];
    
    [videoPlayer loadFromURL:url];
    //

    

}

unsigned int textureCacheID;

void HLSPlayer::update()
{

    if(!videoTexture.isAllocated())
    {
        
        if([videoPlayer isReady])
        {
            videoWidth = videoPlayer.avPlayerItem.presentationSize.width;
            videoHeight = videoPlayer.avPlayerItem.presentationSize.height;
            ofLog() << "videoWidth: " << videoWidth << " videoHeight: " << videoHeight;
            videoTexture.allocate(videoWidth, videoHeight, GL_RGBA);

            
            //Even though videoTexture is later assigned to the ofImage texture these calls need to be made?
            
            textureCacheID = [videoPlayer beginCreateTexture];
            videoTexture.setUseExternalTextureID(textureCacheID);
            [videoPlayer endCreateTexture];
        }
    }
    
    
    if([videoPlayer isPlaying])
    {
        ofLog() << "videoPlayer is Playing";
        if([videoPlayer isReady])
        {
            unsigned char* pixels = [videoPlayer update];
            if(pixels)
            {
                videoImage.setFromPixels(pixels, videoWidth, videoHeight, OF_IMAGE_COLOR_ALPHA);
                videoTexture = videoImage.getTexture();
            }
        }
    }
}

void HLSPlayer::draw()
{
    if(videoImage.isAllocated())
    {
        videoImage.draw(0, 0);
    }
    if(videoTexture.isAllocated())
    {
        int scaledWidth = videoWidth*.25;
        int scaledHeight = videoHeight*.25;
        videoTexture.draw(ofGetWidth()-scaledWidth, ofGetHeight()-scaledHeight, scaledWidth, scaledHeight);
    }

    
    

}
void HLSPlayer::draw(float x, float y)
{

}