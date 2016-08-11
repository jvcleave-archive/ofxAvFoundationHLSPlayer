#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVPlayer.h>




@interface AVFPlayer : NSObject
{
    AVPlayerItem* _avPlayerItem;
    AVPlayer* _avPlayer;
    NSArray* _keyPaths;
    AVPlayerItemVideoOutput* _playerItemVideoOutput;
    
}
@property(nonatomic, retain) AVPlayerItem* avPlayerItem;
@property(nonatomic, retain) AVPlayer* avPlayer;
@property(nonatomic, retain) NSArray* keyPaths;
@property(nonatomic, retain) AVPlayerItemVideoOutput* playerItemVideoOutput;

-(void) loadFromURL:(NSURL *)url;
-(BOOL) isPlaying;
-(BOOL) isReady;
-(unsigned char*) getPixels;
-(void)seekToTimeInSeconds:(int)seconds;
-(float) duration;
-(float) getCurrentTime;
-(void) update;
-(bool)isFrameNew;

-(void) togglePause;
-(void) pause;
-(void) resume;
@end

