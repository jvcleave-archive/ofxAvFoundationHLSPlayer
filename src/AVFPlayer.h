#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVPlayer.h>




@interface AVFPlayer : NSObject
{
    AVPlayerItem* _avPlayerItem;
    AVPlayer* _avPlayer;
}
@property(nonatomic, retain) AVPlayerItem* avPlayerItem;
@property(nonatomic, retain) AVPlayer* avPlayer;
-(void) loadFromURL:(NSURL *)url;

@end

