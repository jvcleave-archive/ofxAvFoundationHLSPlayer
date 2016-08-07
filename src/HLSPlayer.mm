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

void HLSPlayer::update()
{

}

void HLSPlayer::draw()
{

}
void HLSPlayer::draw(float x, float y)
{

}