//
//  TextToAudioSDK.h
//  Audio2FA
//
//  Created by Shrey Gupta on 26/10/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioQueue.h>


#define NUM_BUFFERS 3

@class TextToAudioSDK;

typedef struct
{
    int ggwaveId;
    bool isCapturing;
    AudioQueueRef queue;
    AudioStreamBasicDescription dataFormat;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
} StateInp;

typedef struct
{
    bool isPlaying;
    int ggwaveId;
    int offset;
    int totalBytes;
    NSMutableData * waveform;
    
    AudioQueueRef queue;
    AudioStreamBasicDescription dataFormat;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
} StateOut;


@protocol TextToAudioSDKDelegate <NSObject>
- (void)textToAudio: (TextToAudioSDK *)player didUpdatePlayingProgress: (float)progress;
- (void)textToAudio: (TextToAudioSDK *)player didUpdatePlayingStatus: (bool)playing;
@end

@interface TextToAudioSDK : NSObject
{
    StateInp stateInp;
    StateOut stateOut;
}

- (void)stopPlayback;
- (void)startPlayback: (const char *) message;
- (void) stopCapturing;
- (void)startCapture;

@property (weak, nonatomic) id <TextToAudioSDKDelegate> delegate;
@end

