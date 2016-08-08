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

-(unsigned int) update
{
    CMTime currentTime = [self.avPlayer currentTime];
    double currentTimeSeconds = CMTimeGetSeconds(currentTime);

    if ([self.playerItemVideoOutput hasNewPixelBufferForItemTime:currentTime])
    {
        NSLog(@"new frame at currentTimeSeconds %f", currentTimeSeconds);
        
        CVPixelBufferRef buffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:NULL];
        CVOpenGLTextureRef texture = NULL;
        CVPixelBufferLockBaseAddress(buffer,kCVPixelBufferLock_ReadOnly);
        CVReturn err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, videoTextureCache, buffer,0, &texture);
        unsigned long imageBufferPixelFormat = CVPixelBufferGetPixelFormatType(buffer);

        if (texture)
        {
            if (err != noErr)
            {
                NSLog(@"err: %d", err);
                //videoTextureCache = texture;
                unsigned int textureCacheID = CVOpenGLTextureGetName(texture);
                return textureCacheID;
            }
            
            CVOpenGLTextureRelease(texture);
        }
        
        CVOpenGLTextureCacheFlush(videoTextureCache, 0);
        CVPixelBufferUnlockBaseAddress(buffer,kCVPixelBufferLock_ReadOnly);
        CVPixelBufferRelease(buffer);


    }else
    {
        NSLog(@"NO new frame at currentTimeSeconds %f", currentTimeSeconds);

    }
    return 0;
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
        
#if 0
        if(self.avPlayer.status == AVPlayerStatusReadyToPlay)
        {
            CMTime currentTime = [self.avPlayerItem currentTime];
            double currentTimeSeconds = CMTimeGetSeconds(currentTime);
            
            

            
            
            NSLog(@"currentTimeSeconds %f", currentTimeSeconds);

            /*
            CVPixelBufferRef buffer = [self.playerItemVideoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
            
            
            err = CVOpenGLTextureCacheCreateTextureFromImage(nullptr,
                                                             _videoTextureCache,
                                                             imageBuffer,
                                                             nullptr,
                                                             &_videoTextureRef);
            
            textureCacheID = CVOpenGLTextureGetName(_videoTextureRef);
            
            */
            
            
            
#if 0
            if (buffer)
            {
                CVOpenGLTextureRef texture = NULL;
                CVPixelBufferLockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
                CVReturn err = CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, videoTextureCache, buffer,0, &texture);
                
                if (texture)
                {
                    if (err == noErr)
                    {
                        videoTextureCache = &texture;
                       
                    }
                    
                    CVOpenGLTextureRelease(texture);
                }
                
                CVOpenGLTextureCacheFlush(videoTextureCache, 0);
                CVPixelBufferUnlockBaseAddress(buffer,kCVPixelBufferLock_ReadOnly);
                CVPixelBufferRelease(buffer);
            }
#endif
            NSLog(@"self.avPlayer.status AVPlayerStatusReadyToPlay");
        }
#endif
        

    }
    return playing;
}
-(id) init
{
    self = [super init];
    self.avPlayer = [[AVPlayer alloc] init];
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
    //self.playerItemVideoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttributes];
    NSArray* assetKeysRequiredToPlay = @[@"tracks"];
    
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSLog(@"createAssets");
    NSDictionary* pixelBufferAttributes = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
    self.playerItemVideoOutput = [[[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttributes] autorelease];
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.avPlayerItem addOutput:self.playerItemVideoOutput];
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem ];
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial;
    
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

    NSArray<AVPlayerItemTrack *>* tracks = self.avPlayerItem.tracks;
    CGSize presentationSize = self.avPlayerItem.presentationSize;
    CMTime duration = self.avPlayerItem.asset.duration;
    float preferredRate = self.avPlayerItem.asset.preferredRate;
    float preferredVolume = self.avPlayerItem.asset.preferredVolume;
    CGAffineTransform preferredTransform = self.avPlayerItem.asset.preferredTransform;
    NSArray<AVMetadataItem *>* timedMetadata = self.avPlayerItem.timedMetadata;

    
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
                    NSString *stringFormat = NSLocalizedString(@"error.asset_%@_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load");
                                        
                    NSLog(@"error %@", [error localizedDescription]);
                    
                    return;
                }
            }
            
            // We can't play this asset.
            if (!asset.playable || asset.hasProtectedContent) {
                NSString *stringFormat = NSLocalizedString(@"error.asset_%@_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");
                
                
                NSLog(@"error %@", stringFormat);

                
                return;
            }
            
            NSMutableDictionary* loadedAssets = [NSMutableDictionary dictionary];
            
            //NSLog(@"loadedAssets %@", loadedAssets);
            //loadedAssets[title] = asset;

        });
#if 0
        if (status == AVKeyValueStatusLoaded)
        {
            NSDictionary* settings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] };
            AVPlayerItemVideoOutput* output = [[[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings] autorelease];
            self.avPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
            [self.avPlayerItem addOutput:output];
            self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
            
            NSArray<AVPlayerItemTrack *>* tracks = self.avPlayerItem.tracks;
            CGSize presentationSize = self.avPlayerItem.presentationSize;
            CMTime duration = self.avPlayerItem.asset.duration;
            float preferredRate = self.avPlayerItem.asset.preferredRate;
            float preferredVolume = self.avPlayerItem.asset.preferredVolume;
            CGAffineTransform preferredTransform = self.avPlayerItem.asset.preferredTransform;
            NSArray<AVMetadataItem *>* timedMetadata = self.avPlayerItem.timedMetadata;
            
         
            
            [self.avPlayer replaceCurrentItemWithPlayerItem:self.avPlayerItem];
            //[playerItemVideoOutput setSuppressesPlayerRendering:YES];
            [self.avPlayer.currentItem addOutput:playerItemVideoOutput];

            [self.avPlayerItem seekToTime:CMTimeMake(5000, 1000)];
            
            CMTime currentTime = self.avPlayerItem.currentTime;

            CVPixelBufferRef buffer = [playerItemVideoOutput copyPixelBufferForItemTime:[self.avPlayerItem currentTime] itemTimeForDisplay:nil];
            
            AVPlayerItemAccessLog* accessLog = self.avPlayerItem.accessLog;
            NSString* accessLogOutput = [[NSString alloc]
                                         initWithData:[accessLog extendedLogData]
                                         encoding:[accessLog extendedLogDataStringEncoding]];
            
            AVPlayerItemErrorLog* errorLog = self.avPlayerItem.errorLog;
            NSString* errorLogOutput = [[NSString alloc]
                                        initWithData:[errorLog extendedLogData]
                                        encoding:[errorLog extendedLogDataStringEncoding]];
            
            NSLog(@"accessLogOutput %@", accessLogOutput);
            NSLog(@"errorLogOutput %@", errorLogOutput);

            //[self.avPlayerItem removeObserver:self forKeyPath:@"status"];
        }
        else
        {
            NSLog(@"%@ Failed to load the tracks.", self);
        }
#endif
    }];
    
    // Now at any later point in time, you can get a pixel buffer
    // that corresponds to the current AVPlayer state like this:
    
    

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
       // NSLog(@"duration");
       // NSLog(@"duration object: %@", object);
       // NSLog(@"duration change: %@", change);

    }
    if ([keyPath isEqualToString:@"currentItem.status"])
    {
        NSLog(@"status");
        NSLog(@"status object: %@", object);
        NSLog(@"status change: %@", change);
        
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
    
#if 0
    if ([keyPath isEqualToString:@"player.currentItem.presentationSize"]) {
    
        //NSLog(@"currentItem.presentationSize");
        CGSize presentationSize = self.avPlayerItem.presentationSize;
        NSLog(@"width: %f %f", presentationSize.width, presentationSize.height);
        
    }else
    {
        NSLog(@"else keyPath: %@", keyPath);
        NSLog(@"else object: %@", object);
        NSLog(@"else change: %@", change);
    }
#endif
    //NSLog(@"context: %@", (NSString *)context);
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSLog(@"keyPathsForValuesAffectingValueForKey key: %@", key);

}

@end