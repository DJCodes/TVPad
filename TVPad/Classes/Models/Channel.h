//
//  Channel.h
//  TVPad
//
//  Created by Alain Jiang on 2013-02-24.
//  Copyright (c) 2013 DJ Codes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;

@end
