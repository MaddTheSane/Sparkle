//
//  SUBasicUpdateDriver.h
//  Sparkle,
//
//  Created by Andy Matuschak on 4/23/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUBASICUPDATEDRIVER_H
#define SUBASICUPDATEDRIVER_H

#import <Cocoa/Cocoa.h>
#import "SUUpdateDriver.h"
#import "SUUnarchiver.h"

@class SUAppcastItem, SUAppcast, SUUnarchiver, SUHost;
@interface SUBasicUpdateDriver : SUUpdateDriver<NSURLDownloadDelegate, SUUnarchiverDelegate> {
	SUHost *host;
	SUAppcastItem *updateItem;
	SUAppcastItem *nonDeltaUpdateItem;
	
	NSURLDownload *download;
	NSString *downloadPath;
	NSString *tempDir;
	
	NSString *relaunchPath;
}

- (void)checkForUpdatesAtURL:(NSURL *)URL host:(SUHost *)host;

- (void)appcastDidFinishLoading:(SUAppcast *)ac;
- (void)appcast:(SUAppcast *)ac failedToLoadWithError:(NSError *)error;

- (BOOL)isItemNewer:(SUAppcastItem *)ui;
- (BOOL)hostSupportsItem:(SUAppcastItem *)ui;
- (BOOL)itemContainsSkippedVersion:(SUAppcastItem *)ui;
- (BOOL)itemContainsValidUpdate:(SUAppcastItem *)ui;
- (void)didFindValidUpdate;
- (void)didNotFindUpdate;

- (void)downloadUpdate;
- (void)download:(NSURLDownload *)d decideDestinationWithSuggestedFilename:(NSString *)name;
- (void)downloadDidFinish:(NSURLDownload *)d;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;

- (void)extractUpdate;
- (void)unarchiverDidFinish:(SUUnarchiver *)ua;
- (void)unarchiverDidFail:(SUUnarchiver *)ua;
- (void)failedToApplyDeltaUpdate;

- (void)installWithToolAndRelaunch:(BOOL)relaunch;
- (void)installWithToolAndRelaunch:(BOOL)relaunch displayingUserInterface:(BOOL)showUI;
- (void)installerForHost:(SUHost *)host failedWithError:(NSError *)error;

- (void)cleanUpDownload;

- (void)abortUpdate;
- (void)abortUpdateWithError:(NSError *)error;

@end

#endif
