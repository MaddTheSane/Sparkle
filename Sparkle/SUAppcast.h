//
//  SUAppcast.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAPPCAST_H
#define SUAPPCAST_H

#import <Foundation/Foundation.h>
#import "SUExport.h"
#import <Foundation/NSObject.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSError.h>
#import <Foundation/NSURLDownload.h>

@class SUAppcastItem;
SU_EXPORT @interface SUAppcast : NSObject<NSURLDownloadDelegate>

@property (copy) NSString *userAgentString;
@property (copy) NSDictionary *httpHeaders;

- (void)fetchAppcastFromURL:(NSURL *)url completionBlock:(void (^)(NSError *))err;

@property (readonly, copy) NSArray *items;
@end

#endif
