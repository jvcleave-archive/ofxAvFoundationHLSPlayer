#include "ofMain.h"

#if !defined(TARGET_RASPBERRY_PI)

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVPlayer.h>




@interface AVFPlayer : NSObject
{
    ofPixels* myPixels;
    unsigned char* pixels;
    ofTexture outputTexture;
    int width;
    int height;
    int pixelSize;
}

@property(nonatomic, retain) AVPlayerItem* avPlayerItem;
@property(nonatomic, retain) AVPlayer* avPlayer;
@property(nonatomic, retain) NSArray* keyPaths;
@property(nonatomic, retain) AVPlayerItemVideoOutput* playerItemVideoOutput;
@property(nonatomic, retain) NSMutableArray* errorStrings;

-(void) loadFromURL:(NSURL *)url;
-(BOOL) isPlaying;
-(BOOL) isReady;
-(BOOL) hasErrors;
-(void) clearErrors;

-(void) updatePixels;
-(void) releasePixels;
-(void)seekToTimeInSeconds:(int)seconds;
-(float) duration;
-(float) getCurrentTime;
-(void) update;
-(bool)isFrameNew;

-(void) togglePause;
-(void) pause;
-(void) resume;
-(void) mute;
-(void) draw;

@end

#endif