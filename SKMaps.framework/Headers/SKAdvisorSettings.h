//
//  SKAdvisorSettings.h
//  SKMaps
//
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKDefinitions.h"

/** SKAdvisorSettings stores information about the audio advisor settings that will be used during a navigation.
 */
@interface SKAdvisorSettings : NSObject

/** The voice folder name, located in the resourcesPath. The default is "en_us" .
 */
@property(nonatomic, strong) NSString *advisorVoice;

/** The absolute path to the advisor files resource folder. The default is SKMaps.bundle/AdvisorConfigs/Languages, located in the main bundle.
 */
@property(nonatomic, strong) NSString *resourcesPath;

/** The language of the advice. The default is SKAdvisorLanguageEN_US.
 */
@property(nonatomic, assign) SKAdvisorLanguage language;

/** The type of the advisor. It can be Text to Speech or audio file based.
 */
@property(nonatomic, assign) SKAdvisorType advisorType;

/** A newly initialized SKAdvisorSettings.
 */
+ (instancetype)advisorSettings;

@end
