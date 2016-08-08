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
            //ofTextureData& texData = videoTexture.getTextureData();
            //texData.tex_t = 1.0f; // these values need to be reset to 1.0 to work properly.
            //texData.tex_u = 1.0f; // assuming this is something to do with the way ios creates the texture cache.
            
            
            textureCacheID = [videoPlayer beginCreateTexture];
            
            videoTexture.setUseExternalTextureID(textureCacheID);
            videoTexture.setTextureMinMagFilter(GL_LINEAR, GL_LINEAR);
            videoTexture.setTextureWrap(GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE);
            if(ofIsGLProgrammableRenderer() == false) {
                videoTexture.bind();
                glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
                videoTexture.unbind();
            }
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
                ofImage image;
                image.setFromPixels(pixels, videoWidth, videoHeight, OF_IMAGE_COLOR_ALPHA);
                videoTexture = image.getTexture();
            }
        }
    }
}

void HLSPlayer::draw()
{
    if(videoTexture.isAllocated())
    {
        videoTexture.draw(0, 0);
    }

}
void HLSPlayer::draw(float x, float y)
{

}