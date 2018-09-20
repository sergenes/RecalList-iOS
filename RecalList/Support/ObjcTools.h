//
//  ObjcTools.h
//  RecalList
//
//  Created by Serge Nes on 9/20/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjcTools : NSObject
+ (void) setupAudioSession;
+ (void) chooseSource:(int)source;
@end

NS_ASSUME_NONNULL_END
