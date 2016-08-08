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
-(unsigned int)beginCreateTexture;
-(void)endCreateTexture;
-(BOOL) isPlaying;
-(BOOL) isReady;
-(void) update;
@end

