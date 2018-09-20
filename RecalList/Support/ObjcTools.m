//
//  ObjcTools.m
//  RecalList
//
//  Created by Serge Nes on 9/20/18.
//  Copyright © 2018 Serge Nes. All rights reserved.
//  [session setCategory: is not accesible from swift in xcode 10 09/20/2018
//

#import <AVFoundation/AVFoundation.h>
#import "ObjcTools.h"

@implementation ObjcTools
    

+ (void) setupAudioSession {
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
}
    
+ (void) chooseSource:(int)source {
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    if (source == 1){
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    }else{
      [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    }
    
    if(error) {
        NSLog(@"%@", error);
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
