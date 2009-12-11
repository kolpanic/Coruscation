#import "PreferencesController.h"

// TODO: use the agent...
// - add prefs UI to control scheduled update checks - never, weekly or monthly
// - (un)install & (un)load plist in ~/Library/LaunchAgents/ based on user prefs

@implementation PreferencesController

- (id) init {
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (IBAction) installAgent:(id)sender {
	NSString *agentPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"CoruscationAgent.app"];
	NSBundle *agentBundle = [NSBundle bundleWithPath:agentPath];
	NSString *identifier = [agentBundle bundleIdentifier];
	
	agentPath = [agentPath stringByAppendingPathComponent:@"Contents"];
	agentPath = [agentPath stringByAppendingPathComponent:@"MacOS"];
	agentPath = [agentPath stringByAppendingPathComponent:@"CoruscationAgent"];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:identifier forKey:@"Label"];
	[dict setObject:@"Aqua" forKey:@"LimitLoadToSessionType"];
	[dict setObject:[NSArray arrayWithObjects:agentPath, nil] forKey:@"ProgramArguments"];
	[dict setObject:[NSNumber numberWithUnsignedInteger:60] forKey:@"StartInterval"];
		
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryFolder = [searchPaths objectAtIndex:0];
	NSString *agentsPath = [[[libraryFolder stringByAppendingPathComponent:@"LaunchAgents"] stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"plist"];
	NSLog(@"%@\n%@", agentsPath, dict);
//	[dict writeToFile:agentsPath atomically:YES];
}

@end
