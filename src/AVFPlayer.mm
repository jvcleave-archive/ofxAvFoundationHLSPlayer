#import "AVFPlayer.h"


@implementation AVFPlayer

@synthesize avPlayerItem = _avPlayerItem;
@synthesize avPlayer = _avPlayer;
@synthesize keyPaths = _keyPaths;
@synthesize playerItemVideoOutput = _playerItemVideoOutput;


static int KVOContext = 17;
static BOOL playing = NO;
static BOOL doLoop = YES;
static BOOL hasNewFrame = NO;


void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"exception %@", exception);
}

-(id) init
{
    self = [super init];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return self;
    
}

-(void) update
{
    CMTime currentTime = [self.avPlayer currentTime];
    double currentTimeSeconds = CMTimeGetSeconds(currentTime);
    double durationTimeSeconds = CMTimeGetSeconds(self.avPlayerItem.asset.duration);
    if(currentTimeSeconds >= durationTimeSeconds)
    {
        if(doLoop)
        {
            NSLog(@"looping at %f", (float)currentTime.value);
            [self seekToTimeInSeconds:0];
        }
    }
}
-(bool)isFrameNew
{
    return hasNewFrame;
}
-(unsigned char*) getPixels
{
    CMTime currentTime = [self.avPlayer currentTime];
    double currentTimeSeconds = CMTimeGetSeconds(currentTime);
    unsigned char* pixels = NULL;
    
    hasNewFrame = [self.playerItemVideoOutput hasNewPixelBufferForItemTime:currentTime];
    if (hasNewFrame)
    {
        //NSLog(@"new frame at currentTimeSeconds %f", currentTimeSeconds);
        
        CVPixelBufferRef pixelBuffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:NULL];
        if(pixelBuffer)
        {
            CVPixelBufferLockBaseAddress( pixelBuffer, 0);
            pixels = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }

        
    }else
    {
        //NSLog(@"NO new frame at currentTimeSeconds %f", currentTimeSeconds);

    }
    return pixels;
}


-(void)seekToTimeInSeconds:(int)seconds
{
    CMTime newCurrentTime = CMTimeMakeWithSeconds(seconds, 1000);
    [self.avPlayer seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


-(BOOL) isReady
{
    BOOL value = NO;
    
    if(self.avPlayer.status == AVPlayerStatusReadyToPlay)
    {
        CGSize presentationSize = self.avPlayerItem.presentationSize;
        if(presentationSize.width > 0)
        {
            if(presentationSize.height > 0)
            {
                CMTime currentTime = [self.avPlayer currentTime];
                double currentTimeSeconds = CMTimeGetSeconds(currentTime);

                if(currentTimeSeconds>0)
                {
                    value = YES;
                }
                
            }
        }

    }
    return value;
}


-(void) loadFromURL:(NSURL *)url
{
    self.avPlayerItem = [[AVPlayerItem playerItemWithURL:url] retain];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    [self.avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:&KVOContext];

    NSArray* assetKeysRequiredToPlay = @[@"tracks"];
    
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    //kCVPixelFormatType_32RGBA
    //kCVPixelFormatType_32BGRA
    //kCVPixelFormatType_32ARGB
    //kCVPixelFormatType_32ABGR
    NSDictionary* pixelBufferAttributes = @{
                                            (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                            };
    self.playerItemVideoOutput = [[[AVPlayerItemVideoOutput alloc]
                                    initWithPixelBufferAttributes:pixelBufferAttributes]
                                    autorelease];
    
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.avPlayerItem addOutput:self.playerItemVideoOutput];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
    
     self.keyPaths = @[@"player.currentItem",
                           @"player.rate",
                           @"currentItem.presentationSize",
                           @"currentItem.asset",
                           @"currentItem.duration",
                           @"currentItem.status"];
    for (NSString* keyPath in self.keyPaths)
    {
        [self.avPlayer addObserver:self forKeyPath:keyPath options:options context:&KVOContext];
    }
    [asset loadValuesAsynchronouslyForKeys:assetKeysRequiredToPlay completionHandler:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

#if 0
    for (NSString* KeyPath in self.keyPaths)
    {
        if([keyPath isEqualToString:KeyPath])
        {
            //NSLog(@"MATCH %@", keyPath);
        }
    }
#endif
    if ([keyPath isEqualToString:@"currentItem.duration"])
    {
        //NSLog(@"durationSeconds %f", CMTimeGetSeconds(self.avPlayerItem.asset.duration));
        if(!playing)
        {
            playing = YES;
            [self.avPlayer play];
        }
    }
    
    if ([keyPath isEqualToString:@"currentItem.status"])
    {
        NSNumber *kindStatusAsNumber = change[NSKeyValueChangeKindKey];
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = AVPlayerItemStatusUnknown;
        if([newStatusAsNumber isKindOfClass:[NSNumber class]])
        {
            newStatus = (AVPlayerItemStatus)newStatusAsNumber.integerValue;
        }
       
        
        if (newStatus == AVPlayerItemStatusFailed)
        {
            NSLog(@"status error %@", self.avPlayer.currentItem.error.localizedDescription);
        }else
        {
            //NSLog(@"newStatus: %ld", newStatus);
        }

    }
}

-(float) getCurrentTime
{
    CMTime currentTime = [self.avPlayer currentTime];
    return CMTimeGetSeconds(currentTime);
}

-(float) duration
{
    CMTime duration = self.avPlayerItem.asset.duration;
    double durationSeconds = CMTimeGetSeconds(duration);
    return durationSeconds;

}

-(BOOL) isPlaying
{
    return playing;
}


@end