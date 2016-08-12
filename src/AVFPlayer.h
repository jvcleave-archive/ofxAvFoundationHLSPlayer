#if !defined(TARGET_RASPBERRY_PI)

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVPlayer.h>




@interface AVFPlayer : NSObject

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

-(unsigned char*) getPixels;
-(void)seekToTimeInSeconds:(int)seconds;
-(float) duration;
-(float) getCurrentTime;
-(void) update;
-(bool)isFrameNew;

-(void) togglePause;
-(void) pause;
-(void) resume;
-(void) mute;

@end

#endif