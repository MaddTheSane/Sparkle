//
//  NTSynchronousTask.m
//  CocoatechCore
//
//  Created by Steve Gehrman on 9/29/05.
//  Copyright 2005 Steve Gehrman. All rights reserved.
//

#import "SUUpdater.h"

#import "SUAppcast.h"
#import "SUAppcastItem.h"
#import "SUVersionComparisonProtocol.h"
#import "NTSynchronousTask.h"

@implementation NTSynchronousTask

//---------------------------------------------------------- 
//  task 
//---------------------------------------------------------- 
- (NSTask *)task
{
    return mv_task; 
}

- (void)setTask:(NSTask *)theTask
{
    if (mv_task != theTask) {
        mv_task = theTask;
    }
}

//---------------------------------------------------------- 
//  outputPipe 
//---------------------------------------------------------- 
- (NSPipe *)outputPipe
{
    return mv_outputPipe; 
}

- (void)setOutputPipe:(NSPipe *)theOutputPipe
{
    if (mv_outputPipe != theOutputPipe) {
        mv_outputPipe = theOutputPipe;
    }
}

//---------------------------------------------------------- 
//  inputPipe 
//---------------------------------------------------------- 
- (NSPipe *)inputPipe
{
    return mv_inputPipe; 
}

- (void)setInputPipe:(NSPipe *)theInputPipe
{
    if (mv_inputPipe != theInputPipe) {
        mv_inputPipe = theInputPipe;
    }
}

//---------------------------------------------------------- 
//  output 
//---------------------------------------------------------- 
- (NSData *)output
{
    return mv_output; 
}

- (void)setOutput:(NSData *)theOutput
{
    if (mv_output != theOutput) {
        mv_output = theOutput;
    }
}

//---------------------------------------------------------- 
//  done 
//---------------------------------------------------------- 
- (BOOL)done
{
    return mv_done;
}

- (void)setDone:(BOOL)flag
{
    mv_done = flag;
}

//---------------------------------------------------------- 
//  result 
//---------------------------------------------------------- 
- (int)result
{
    return mv_result;
}

- (void)setResult:(int)theResult
{
    mv_result = theResult;
}

- (void)taskOutputAvailable:(NSNotification*)note
{
	[self setOutput:[[note userInfo] objectForKey:NSFileHandleNotificationDataItem]];
	
	[self setDone:YES];
}

- (void)taskDidTerminate:(NSNotification*)note
{
    [self setResult:[[self task] terminationStatus]];
}

- (id)init;
{
    self = [super init];
	if (self)
	{
		[self setTask:[[NSTask alloc] init]];
		[self setOutputPipe:[[NSPipe alloc] init]];
		[self setInputPipe:[[NSPipe alloc] init]];
		
		[[self task] setStandardInput:[self inputPipe]];
		[[self task] setStandardOutput:[self outputPipe]];
		[[self task] setStandardError:[self outputPipe]];
	}
	
    return self;
}

//---------------------------------------------------------- 
// dealloc
//---------------------------------------------------------- 
- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];


}

- (void)run:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input
{
	BOOL success = NO;
	
	if (currentDirectory)
		[[self task] setCurrentDirectoryPath: currentDirectory];
	
	[[self task] setLaunchPath:toolPath];
	[[self task] setArguments:args];
				
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(taskOutputAvailable:)
												 name:NSFileHandleReadToEndOfFileCompletionNotification
											   object:[[self outputPipe] fileHandleForReading]];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(taskDidTerminate:)
												 name:NSTaskDidTerminateNotification
											   object:[self task]];	
	
	[[[self outputPipe] fileHandleForReading] readToEndOfFileInBackgroundAndNotifyForModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil]];
	
	@try
	{
		[[self task] launch];
		success = YES;
	}
	@catch (NSException *localException) { }
	
	if (success)
	{
		if (input)
		{
			// feed the running task our input
			[[[self inputPipe] fileHandleForWriting] writeData:input];
			[[[self inputPipe] fileHandleForWriting] closeFile];
		}
						
		// loop until we are done receiving the data
		if (![self done])
		{
			double resolution = 1;
			BOOL isRunning;
			NSDate* next;
			
			do {
				next = [NSDate dateWithTimeIntervalSinceNow:resolution]; 
				
				isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
													 beforeDate:next];
			} while (isRunning && ![self done]);
		}
	}
}

+ (NSData*)task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input
{
	// we need this wacky pool here, otherwise we run out of pipes, the pipes are internally autoreleased
	@autoreleasepool {
	NSData* result=nil;
	
	@try
	{
		NTSynchronousTask* task = [[NTSynchronousTask alloc] init];
		
		[task run:toolPath directory:currentDirectory withArgs:args input:input];
		
		if ([task result] == 0)
			result = [task output];
				
	}	
	@catch (NSException *localException) { }
	
	
    return result;
	}
}


+(int)	task:(NSString*)toolPath directory:(NSString*)currentDirectory withArgs:(NSArray*)args input:(NSData*)input output: (NSData**)outData
{
	// we need this wacky pool here, otherwise we run out of pipes, the pipes are internally autoreleased
	@autoreleasepool {
	int					taskResult = 0;
	if( outData )
		*outData = nil;
	
	NS_DURING
	{
		NTSynchronousTask* task = [[NTSynchronousTask alloc] init];
		
		[task run:toolPath directory:currentDirectory withArgs:args input:input];
		
		taskResult = [task result];
		if( outData )
			*outData = [task output];
				
	}	
	NS_HANDLER;
		taskResult = errCppGeneral;
	NS_ENDHANDLER;
		
    return taskResult;
	}
}

@end
