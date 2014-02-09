//
//  SUAppcastItem.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAPPCASTITEM_H
#define SUAPPCASTITEM_H

@interface SUAppcastItem : NSObject
{
@private
	NSDictionary *propertiesDictionary;

	NSURL *infoURL;	// UK 2007-08-31
}
@property (copy, readonly) NSString *title;
@property (copy, readonly) NSDate *date;
@property (copy, readonly) NSString *itemDescription;
@property (strong, readonly) NSURL *releaseNotesURL;
@property (copy, readonly) NSString *DSASignature;
@property (copy, readonly) NSString *minimumSystemVersion;
@property (copy, readonly) NSString *maximumSystemVersion;
@property (strong, readonly) NSURL *fileURL;
@property (copy, readonly) NSString *versionString;
@property (copy, readonly) NSString *displayVersionString;
@property (copy, readonly) NSDictionary *deltaUpdates;
@property (strong, readonly) NSURL *infoURL;

// Initializes with data from a dictionary provided by the RSS class.
- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict failureReason:(NSString**)error;

- (BOOL)isDeltaUpdate;
- (BOOL)isCriticalUpdate;

// Returns the dictionary provided in initWithDictionary; this might be useful later for extensions.
- (NSDictionary *)propertiesDictionary;

- (NSURL *)infoURL;						// UK 2007-08-31

@end

#endif
