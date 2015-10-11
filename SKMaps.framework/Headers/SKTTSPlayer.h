//
//  SKTTSPlayer.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SKDefinitions.h"

@class SKAdvisorTTSSettings;
@class SKTTSPlayer;

/** SKTTSPlayer delegate, inherits from AVSpeechSynthesizerDelegate, adding TTSPlayer:willPlayUtterance: callback.
 */
@protocol SKTTSPlayerDelegate <AVSpeechSynthesizerDelegate>

/** Called when the TTS player will begin playing an utterance.
 @oaram TTSPlayer The TTSPlayer instance.
 @param utterance The utterance to be played.
 */
-(void)TTSPlayer:(SKTTSPlayer*)TTSPlayer willPlayUtterance:(AVSpeechUtterance*)utterance;

@end

/** The actual TTS player. transforms strings into audio instructions.
 */
@interface SKTTSPlayer : NSObject

/** The delegate of the player.
 */
@property(nonatomic, weak) id<SKTTSPlayerDelegate> delegate;

/** Input for TTS configuration.
 */
@property(nonatomic, strong) SKAdvisorTTSSettings *textToSpeechConfig;

/** Returns the singleton SKTTSPlayer instance.
 */
+ (instancetype)sharedInstance;

/** Plays the given instruction in the given language.
 @param instruction The advice instruction to be spoken by the TTS.
 @param language The language of the instruction.
 */
- (void)playString:(NSString*)instruction forLanguage:(SKAdvisorLanguage)language;

/** Pause all playing instructions.
 */
- (void)pausePlayingInstructions;

/** Resume the next playing instruction.
 */
- (void)resumePlayingInstructions;

/** Cancel all playing instructions.
 @param immediately A boolean value indicating that the playing of the instructions should be stopped immediately. Passing NO as parameter will cause that the playing will be stopped after finishing the playing of the current word.
 */
- (void)cancelPlayingInstructionsImmediately:(BOOL)immediately;


@end
