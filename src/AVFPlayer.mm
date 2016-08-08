#import "AVFPlayer.h"


@implementation AVFPlayer

@synthesize avPlayerItem = _avPlayerItem;
@synthesize avPlayer = _avPlayer;
@synthesize keyPaths = _keyPaths;
@synthesize playerItemVideoOutput = _playerItemVideoOutput;


static int KVOContext = 17;
static BOOL playing = NO;
static CVOpenGLTextureCacheRef videoTextureCache = nullptr;
static CVOpenGLTextureRef videoTextureRef = nullptr;
CVImageBufferRef imageBuffer = nil;
CMSampleBufferRef sampleBuffer=nil;

void uncaughtExceptionHandler(NSException *exception)
{
    NSLog(@"exception %@", exception);
}

-(unsigned char*) update
{
    CMTime currentTime = [self.avPlayer currentTime];
    double currentTimeSeconds = CMTimeGetSeconds(currentTime);
    unsigned char* pixels = NULL;
    if ([self.playerItemVideoOutput hasNewPixelBufferForItemTime:currentTime])
    {
        NSLog(@"new frame at currentTimeSeconds %f", currentTimeSeconds);
        
        CVPixelBufferRef pixelBuffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:NULL];
        if(pixelBuffer)
        {
            NSLog(@"buffer");
            
            CVPixelBufferLockBaseAddress( pixelBuffer, 0);
            
            size_t bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
            size_t bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
            pixels = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }

        
    }else
    {
        NSLog(@"NO new frame at currentTimeSeconds %f", currentTimeSeconds);

    }
    return pixels;
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

-(unsigned int)beginCreateTexture
{
    
    CMTime currentTime = [self.avPlayer currentTime];

    CMSampleTimingInfo sampleTimingInfo = {
        .duration = kCMTimeInvalid,
        .presentationTimeStamp = currentTime,
        .decodeTimeStamp = kCMTimeInvalid
    };
    
    CMVideoFormatDescriptionRef videoInfo;
    CVReturn error =0;
    
    CVPixelBufferRef buffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:NULL];
    
    error = CMVideoFormatDescriptionCreateForImageBuffer(NULL, buffer, &videoInfo);

    
    // create new sampleBuffer
    error = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,
                                                      buffer,
                                                      true,
                                                      NULL,
                                                      NULL,
                                                      videoInfo,
                                                      &sampleTimingInfo,
                                                      &sampleBuffer);
    
    
    imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    error = CVOpenGLTextureCacheCreateTextureFromImage(nullptr,
                                                     videoTextureCache,
                                                     imageBuffer,
                                                     nullptr,
                                                     &videoTextureRef);
    
    NSLog(@"CVOpenGLTextureCacheCreateTextureFromImage error: %d", error);
    
    unsigned int textureCacheID = CVOpenGLTextureGetName(videoTextureRef);
    return textureCacheID;
    
}

-(void)endCreateTexture
{
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
}


-(BOOL) isPlaying
{
    if(playing)
    {
#if 0
        switch(self.avPlayer.status)
        {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                break;
            }
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");

                break;
            }
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                break;
            }
        }
#endif
        

    }
    return playing;
}
-(id) init
{
    self = [super init];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    return self;
    
}

-(void) loadFromURL:(NSURL *)url
{
    

    /*
    NSDictionary* pixelBufferAttributes = @{
        (NSString*) kCVPixelBufferIOSurfacePropertiesKey : @{}, // generally want this especially on iOS
        (NSString *)kCVPixelBufferOpenGLCompatibilityKey : @YES, // should never be no.
        (NSString *)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithInt:kCVPixelFormatType_32ARGB]
        };
    */

    self.avPlayerItem = [[AVPlayerItem playerItemWithURL:url] retain];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    if(self.avPlayer != nil)
    {
        [self.avPlayerItem addObserver:self forKeyPath:@"status" options:0 context:&KVOContext];
        

    }
    NSArray* assetKeysRequiredToPlay = @[@"tracks"];
    
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSLog(@"createAssets");
    NSDictionary* pixelBufferAttributes = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    self.playerItemVideoOutput = [[[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttributes] autorelease];
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.avPlayerItem addOutput:self.playerItemVideoOutput];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem ];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew;
    
     self.keyPaths = @[@"player.currentItem",
                           @"player.rate",
                           @"currentItem.presentationSize",
                           @"currentItem.asset",
                           @"currentItem.duration",
                           @"currentItem.status"];
    for (NSString* keyPath in self.keyPaths)
    {
        [self.avPlayer addObserver:self
                        forKeyPath:keyPath
                           options:options
                           context:&KVOContext];
    }
    
#if 0
    NSArray<AVPlayerItemTrack *>* tracks = self.avPlayerItem.tracks;
    CGSize presentationSize = self.avPlayerItem.presentationSize;
    CMTime duration = self.avPlayerItem.asset.duration;
    float preferredRate = self.avPlayerItem.asset.preferredRate;
    float preferredVolume = self.avPlayerItem.asset.preferredVolume;
    CGAffineTransform preferredTransform = self.avPlayerItem.asset.preferredTransform;
    NSArray<AVMetadataItem *>* timedMetadata = self.avPlayerItem.timedMetadata;
#endif
    
    [asset loadValuesAsynchronouslyForKeys:assetKeysRequiredToPlay completionHandler:^{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            /*
             This method is called when the `AVAsset` for our URL has
             completed the loading of the values of the specified array
             of keys.
             */
            
            /*
             Test whether the values of each of the keys we need have been
             successfully loaded.
             */
            for (NSString *key in assetKeysRequiredToPlay)
            {
                
                NSError *error = nil;
                AVKeyValueStatus status  = [asset statusOfValueForKey:key error:&error];
                switch(status)
                {
                    case AVKeyValueStatusUnknown :
                    {
                        NSLog(@"AVKeyValueStatusUnknown %@", key);
                        break;
                    };
                        
                    case AVKeyValueStatusLoading :
                    {
                        NSLog(@"AVKeyValueStatusLoading %@", key);
                        break;
                        
                    };
                    case AVKeyValueStatusLoaded :
                    {
                        NSLog(@"AVKeyValueStatusLoaded %@", key);
                        if([key isEqualToString:@"tracks"])
                        {
                            /*
                            NSLog(@"AVMediaCharacteristicVisual count %ld", (unsigned long)[[asset tracksWithMediaCharacteristic:AVMediaCharacteristicVisual] count]);
                            NSLog(@"AVMediaCharacteristicAudible count %ld", (unsigned long)[[asset tracksWithMediaCharacteristic:AVMediaCharacteristicAudible] count]);
                            NSLog(@"AVMediaCharacteristicLegible count %ld", (unsigned long)[[asset tracksWithMediaCharacteristic:AVMediaCharacteristicLegible] count]);
                            NSLog(@"AVMediaCharacteristicFrameBased count %ld", (unsigned long)[[asset tracksWithMediaCharacteristic:AVMediaCharacteristicFrameBased] count]);
                             */

                        }
                        break;
                        
                    };
                    case AVKeyValueStatusFailed :
                    {
                        NSLog(@"AVKeyValueStatusFailed %@", key);
                        break;
                        
                    };
                    case AVKeyValueStatusCancelled  :
                    {
                        NSLog(@"AVKeyValueStatusCancelled %@", key);
                        break;
                        
                    };
                    default:
                    {
                        NSLog(@"default");
                        break;
                    }
                }
                
                if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed)
                {
                    NSLog(@"Can't use this AVAsset because one of it's keys failed to load");
                    
                    return;
                }
            }
            
            // We can't play this asset.
            if (!asset.playable || asset.hasProtectedContent)
            {
                
                NSLog(@"Can't use this AVAsset because it isn't playable or has protected content");

                
                return;
            }
            
        });
    }];

    
    

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    
    for (NSString* KeyPath in self.keyPaths)
    {
        if([keyPath isEqualToString:KeyPath])
        {
            //NSLog(@"MATCH %@", keyPath);
        }
    }
    
    if ([keyPath isEqualToString:@"currentItem.duration"])
    {
        CMTime duration = self.avPlayerItem.asset.duration;
        double durationSeconds = CMTimeGetSeconds(duration);
        
        NSLog(@"durationSeconds %f", durationSeconds);
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
            NSLog(@"newStatus: %ld", newStatus);
        }

    }
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSLog(@"keyPathsForValuesAffectingValueForKey key: %@", key);

}

@end