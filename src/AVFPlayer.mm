#if !defined(TARGET_RASPBERRY_PI)

#import "AVFPlayer.h"


@implementation AVFPlayer

static int KVOContext = 17;
static BOOL playing = NO;
static BOOL doLoop = YES;
static BOOL hasNewFrame = NO;
static BOOL paused = NO;

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"exception %@", exception);
}

-(id) init
{
    self = [super init];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    self.errorStrings = [[NSMutableArray alloc] init];
    self->pixels = NULL;
    self->width = 0;
    self->height = 0;
    self->pixelSize = 0;
    self->myPixels = NULL;
    return self;
    
}


-(void)dealloc {
    //delete obj;
    
    //[self.avPlayerItem removeObserver:self forKeyPath:@"status" context:&KVOContext];

    for (NSString* keyPath in self.keyPaths)
    {
        [self.avPlayer removeObserver:self forKeyPath:keyPath context:&KVOContext];
    }
    
    playing = NO;
    hasNewFrame = NO;
    [self.avPlayerItem release];
    [self.avPlayer release];
    [self.playerItemVideoOutput release];
    [self.keyPaths release];
    if(self->outputTexture.isAllocated())
    {
        self->outputTexture.clear();
        
    }
    [super dealloc];
}

-(void) togglePause
{
    if(paused)
    {
        [self resume];
    }else
    {
        [self pause];
    }
}

-(void) pause
{
    self.avPlayer.rate = 0.0;
    paused = YES;
}

-(void) resume
{
    self.avPlayer.rate = 1.0;
    paused = NO;
}

-(void) mute
{
    self.avPlayer.volume = 0.0;
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
    [self updatePixels];
}
-(bool)isFrameNew
{
    return hasNewFrame;
}
-(void) draw
{
    if(self->outputTexture.isAllocated())
    {
        self->outputTexture.draw(0, 0);

    }
}
-(void) updatePixels
{
    CGSize presentationSize = self.avPlayerItem.presentationSize;
    NSLog(@"presentationSize.width %f, presentationSize.height, %f", presentationSize.width, presentationSize.height);
#if 0
    BOOL needsResize = NO;
    int pixelSize = 0;
    if(self->width != presentationSize.width)
    {
        needsResize = YES;
    }
    if(self->height != presentationSize.height)
    {
        needsResize = YES;
    }
    if(needsResize)
    {
        
        self->width = presentationSize.width;
        self->height = presentationSize.height;
        pixelSize = self->width*self->width*4;
        
        if(self->pixels)
        {
            delete[] self->pixels;
            self->pixels = NULL;
        }
        if(!pixelSize)
        {
            return;
        }
        self->pixels = new unsigned char[pixelSize];
        self->myPixels.allocate(self->width, self->height, 4);
        self->outputTexture.clear();
        self->outputTexture.allocate(self->width, self->height, GL_RGBA);
        
    }
    if(!self->pixels)
    {
        return;
    }
#endif
    CMTime currentTime = [self.avPlayer currentTime];

    BOOL hasNewPixels = [self.playerItemVideoOutput hasNewPixelBufferForItemTime:currentTime];
    if (hasNewPixels)
    {
        
        
        
        self->width = presentationSize.width;
        self->height = presentationSize.height;
        //NSLog(@"new frame at currentTimeSeconds %f", currentTimeSeconds);
        
        CVPixelBufferRef pixelBuffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:NULL];
        int DataSize = CVPixelBufferGetDataSize(pixelBuffer);
        ofLog() << "DataSize: " << DataSize;
        if(!DataSize)
        {
            return;

        }
        if(DataSize != pixelSize)
        {
            if(self->pixels)
            {
                delete[] self->pixels;
                self->pixels = NULL;
            }
            if(self->myPixels)
            {
                delete self->myPixels;
                self->myPixels = NULL;
            }
            ofLogError () << "crash ? " << DataSize << " != " << pixelSize;
            //return;
        }
        if(pixelBuffer)
        {
            CVPixelBufferLockBaseAddress( pixelBuffer, 0);
            if(!self->pixels)
            {
                pixelSize = DataSize;
                self->pixels = new unsigned char[DataSize];
                
            }
            if(!self->myPixels)
            {
                self->myPixels = new ofPixels();
                self->myPixels->allocate(self->width, self->height, 4);
                
            }
            memcpy(self->pixels, (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer), pixelSize); 
            
            self->myPixels->setFromPixels(self->pixels, self->width, self->height, OF_PIXELS_BGRA);
            if(self->myPixels->getData())
            {
                self->outputTexture.loadData(*self->myPixels);
            }
            
            
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }
        
        CVPixelBufferRelease(pixelBuffer);
        pixelBuffer = nil;
        hasNewFrame = true;
    }else
    {
        hasNewFrame = false;
        //NSLog(@"NO new frame at currentTimeSeconds %f", currentTimeSeconds);

    }
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
        NSLog(@"presentationSize.width %f, presentationSize.height, %f", presentationSize.width, presentationSize.height);
        if(presentationSize.width > 0)
        {
            if(presentationSize.height > 0)
            {
                CMTime currentTime = [self.avPlayer currentTime];
                if(currentTime.value>0)
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

#if 1
    for (NSString* KeyPath in self.keyPaths)
    {
        if([keyPath isEqualToString:KeyPath])
        {
            NSLog(@"MATCH %@", keyPath);
        }
    }
#endif
    if ([keyPath isEqualToString:@"currentItem.duration"])
    {
        NSLog(@"durationSeconds %f", CMTimeGetSeconds(self.avPlayerItem.asset.duration));
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
            
            [self.errorStrings addObject:self.avPlayer.currentItem.error.localizedDescription];
        }else
        {
            NSLog(@"newStatus: %ld", newStatus);
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

-(BOOL) hasErrors
{
    BOOL result = [self.errorStrings count] > 0;
    return result;
}
-(void) clearErrors
{
    [self.errorStrings removeAllObjects];
}
-(BOOL) isPlaying
{
    return playing;
}


@end
#endif