
#import <AppKit/AppKit.h>
#import "SUInstaller.h"
#import "SUHost.h"
#import "SUStandardVersionComparator.h"
#import "SUStatusController.h"
#import "SUPlainInstallerInternals.h"
#import "SULog.h"

#include <unistd.h>

#define	LONG_INSTALLATION_TIME			5				// If the Installation takes longer than this time the Application Icon is shown in the Dock so that the user has some feedback.
#define	CHECK_FOR_PARENT_TO_QUIT_TIME	.5				// Time this app uses to recheck if the parent has already died.
										
@interface TerminationListener : NSObject
{
	const char		*hostpath;
	const char		*executablepath;
	pid_t			parentprocessid;
	const char		*folderpath;
	NSString		*selfPath;
    NSString        *installationPath;
	NSTimer			*watchdogTimer;
	NSTimer			*longInstallationTimer;
	SUHost			*host;
    BOOL            shouldRelaunch;
	BOOL			shouldShowUI;
}

- (void) parentHasQuit;

- (void) relaunch;
- (void) install;

- (void) showAppIconInDock:(NSTimer *)aTimer;
- (void) watchdog:(NSTimer *)aTimer;

@end

@implementation TerminationListener

- (id) initWithHostPath:(const char *)inhostpath executablePath:(const char *)execpath parentProcessId:(pid_t)ppid folderPath:(const char*)infolderpath shouldRelaunch:(BOOL)relaunch shouldShowUI:(BOOL)showUI selfPath:(NSString*)inSelfPath
{
	if( !(self = [super init]) )
		return nil;
	
	hostpath		= inhostpath;
	executablepath	= execpath;
	parentprocessid	= ppid;
	folderpath		= infolderpath;
	selfPath		= inSelfPath;
    shouldRelaunch  = relaunch;
	shouldShowUI	= showUI;
	
	BOOL	alreadyTerminated = (getppid() == 1); // ppid is launchd (1) => parent terminated already
	
	if( alreadyTerminated )
		[self parentHasQuit];
	else
		watchdogTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_FOR_PARENT_TO_QUIT_TIME target:self selector:@selector(watchdog:) userInfo:nil repeats:YES];

	return self;
}


-(void)	dealloc
{
	[longInstallationTimer invalidate];
}


-(void)	parentHasQuit
{
	[watchdogTimer invalidate];
	longInstallationTimer = [NSTimer scheduledTimerWithTimeInterval: LONG_INSTALLATION_TIME
								target: self selector: @selector(showAppIconInDock:)
								userInfo:nil repeats:NO];

	if( folderpath )
		[self install];
	else
		[self relaunch];
}

- (void) watchdog:(NSTimer *)aTimer
{
	ProcessSerialNumber psn;
	if (GetProcessForPID(parentprocessid, &psn) == procNotFound)
		[self parentHasQuit];
}

- (void)showAppIconInDock:(NSTimer *)aTimer;
{
	ProcessSerialNumber		psn = { 0, kCurrentProcess };
	TransformProcessType( &psn, kProcessTransformToForegroundApplication );
}


- (void) relaunch
{
    if (shouldRelaunch)
    {
        NSString	*appPath = nil;
        if( !folderpath || strcmp(executablepath, hostpath) != 0 )
            appPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:executablepath length:strlen(executablepath)];
        else
            appPath = installationPath;
        [[NSWorkspace sharedWorkspace] openFile: appPath];
    }

    if (folderpath)
    {
        NSError *theError = nil;
        if( ![SUPlainInstaller _removeFileAtPath: [SUInstaller updateFolder] error: &theError] )
            SULog( @"Couldn't remove update folder: %@.", theError );
    }
    [[NSFileManager defaultManager] removeItemAtPath: selfPath error: NULL];

	exit(EXIT_SUCCESS);
}


- (void) install
{
	NSBundle			*theBundle = [NSBundle bundleWithPath: [[NSFileManager defaultManager] stringWithFileSystemRepresentation: hostpath length:strlen(hostpath)]];
	host = [[SUHost alloc] initWithBundle: theBundle];
    installationPath = [[host installationPath] copy];
	
    if (shouldShowUI) {
        SUStatusController*	statusCtl = [[SUStatusController alloc] initWithHost: host];	// We quit anyway after we've installed, so leak this for now.
        [statusCtl setButtonTitle: SULocalizedString(@"Cancel Update",@"") target: nil action: Nil isDefault: NO];
        [statusCtl beginActionWithTitle: SULocalizedString(@"Installing update...",@"")
                        maxProgressValue: 0 statusText: @""];
        [statusCtl showWindow: self];
    }
	
	[SUInstaller installFromUpdateFolder: [[NSFileManager defaultManager] stringWithFileSystemRepresentation: folderpath length: strlen(folderpath)]
					overHost: host
            installationPath: installationPath
					delegate: self synchronously: NO
					versionComparator: [SUStandardVersionComparator defaultComparator]];
}

- (void) installerFinishedForHost:(SUHost *)aHost
{
	[self relaunch];
}

- (void) installerForHost:(SUHost *)host failedWithError:(NSError *)error
{
    if (shouldShowUI)
        NSRunAlertPanel( @"", @"%@", @"OK", @"", @"", [error localizedDescription] );
	exit(EXIT_FAILURE);
}

@end

int main (int argc, const char * argv[])
{
	@autoreleasepool {
		
	if( argc < 5 || argc > 7 )
		return EXIT_FAILURE;
	
	#if 0	// Cmdline tool
	NSString*	selfPath = nil;
	if( argv[0][0] == '/' )
		selfPath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: argv[0] length: strlen(argv[0])];
	else
	{
		selfPath = [[NSFileManager defaultManager] currentDirectoryPath];
		selfPath = [selfPath stringByAppendingPathComponent: [[NSFileManager defaultManager] stringWithFileSystemRepresentation: argv[0] length: strlen(argv[0])]];
	}
	#else
		NSString*	selfPath = [[NSBundle mainBundle] bundlePath];
		#endif
		
		BOOL shouldShowUI = (argc > 6) ? atoi(argv[6]) : 1;
		if (shouldShowUI)
		{
			[[NSApplication sharedApplication] activateIgnoringOtherApps: YES];
		}
		
		[NSApplication sharedApplication];
		TerminationListener *termList = [[TerminationListener alloc] initWithHostPath: (argc > 1) ? argv[1] : NULL
                                    executablePath: (argc > 2) ? argv[2] : NULL
                                   parentProcessId: (argc > 3) ? atoi(argv[3]) : 0
                                        folderPath: (argc > 4) ? argv[4] : NULL
                                    shouldRelaunch: (argc > 5) ? atoi(argv[5]) : 1
                                      shouldShowUI: shouldShowUI
                                          selfPath: selfPath];
		[[NSApplication sharedApplication] run];
		
		termList = nil;
		
		return EXIT_SUCCESS;
		
	}
	
}
