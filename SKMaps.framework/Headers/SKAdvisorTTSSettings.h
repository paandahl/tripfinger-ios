//
//  SKAdvisorTTSSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>

/** The SKAdvisorTTSSettings is used to store information about the text to speach settings.
 */
@interface SKAdvisorTTSSettings : NSObject

/** Speed rate of TTS. For iOS 9 (using Xcode 6.4), use lower values for the rate.
 */
@property(nonatomic, assign) float rate;

/** Pitch multiplier for the TTS.
 */
@property(nonatomic, assign) float pitchMultiplier;

/** Volume of TTS.
 */
@property(nonatomic, assign) float volume;

/** Delay before the string is spoken.
 */
@property(nonatomic, assign) NSTimeInterval preUtteranceDelay;

/** Delay after the string is spoken.
 */
@property(nonatomic, assign) NSTimeInterval postUtteranceDelay;

/** A newly initialized SKAdvisorTTSSettings.
 */
+ (instancetype)advisorTTSSettings;

@end
