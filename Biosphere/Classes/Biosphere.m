#import "Biosphere.h"

#include <CommonCrypto/CommonDigest.h>

@implementation Biosphere

@synthesize sshKeyPopup, runBiosphereButton;
@synthesize installChefInfoLabel, installChefButton;
@synthesize validationDigestLabel, validationDeleteButton, biospherePathLabel, versionLabel;
@synthesize nodeNameTextField, chefserverURLTextField;
@synthesize nodeNameLabel, cheferverURLLabel;
@synthesize chefVersionLabel, spinner;

// Initialization

- (void) mainViewDidLoad {
  [self ensureAssets];
  [self setupUI];
  [self loadConfiguration:self];
  [self updateChefGemInfo:self];
  [NSTimer scheduledTimerWithTimeInterval:(3) target:self selector:@selector(loadConfiguration:) userInfo:nil repeats:YES];
  [NSTimer scheduledTimerWithTimeInterval:(1) target:self selector:@selector(updateChefGemInfo:) userInfo:nil repeats:YES];
  [self saveConfiguration:self];
}

- (void) setupUI {
  biospherePathLabel.stringValue = [self biosphereDirectory];
  versionLabel.stringValue = @"v0.2.0"; // Somehow BundleVersion always returns "11.0". So hardcode it.
  [self setupNodeName];
  [self setupChefserverURL];
}

- (void) setupNodeName {
  nodeNameTextField.stringValue = NSUserName();
}

- (void) setupChefserverURL {
  chefserverURLTextField.stringValue = @"chefserver.example.com";
}

- (void) updateChefGemInfo:sender {
  if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/chef-client"]) {
    chefVersionLabel.stringValue = [self chefGemVersion];
    chefVersionLabel.textColor = [NSColor controlTextColor];
    installChefInfoLabel.hidden = YES;
    installChefButton.hidden = YES;
  } else {
    chefVersionLabel.stringValue = @"Not found!";
    chefVersionLabel.textColor = [NSColor redColor];
    installChefInfoLabel.hidden = NO;
    installChefButton.hidden = NO;
  }
}

- (void) updateSSHKeys:sender {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *urls = [fileManager contentsOfDirectoryAtPath:[self sshKeysDirectory] error:&error];
  NSString *selectedTitle = [[sshKeyPopup selectedItem] title];
  for (NSURL *url in urls) {
    if (![[url pathExtension] isEqualToString:@"pub"] && ![[url lastPathComponent] isEqualToString:@"config"] && ![[url lastPathComponent] isEqualToString:@".DS_Store"] && ![[url lastPathComponent] isEqualToString:@"known_hosts"]) {
      [sshKeyPopup addItemWithTitle:[url lastPathComponent]];
    }
  }
  [sshKeyPopup selectItemWithTitle:selectedTitle];
}

- (NSString*) chefGemVersion {
  NSString *output = [self runCommand:@"/usr/bin/chef-client" withArguments:[NSArray arrayWithObjects: @"--version", nil]];
  return [output stringByReplacingOccurrencesOfString:@"Chef: " withString:@""];
}

- (NSString*) runCommand:(NSString*)command withArguments:(NSArray*)arguments {
  NSTask *task = [NSTask new];
  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *file = [pipe fileHandleForReading];
  [task setLaunchPath: command];
  [task setArguments: arguments];
  [task setStandardOutput: pipe];
  [task launch];
  return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

// Chef configuration

- (IBAction) chooseValidationKey:sender {
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseDirectories:NO];
  if ([panel runModal] == NSOKButton) {
    NSURL *url = [panel URL];
    [self installValidationKey:url];
    [self loadConfiguration:self];
  }
}

- (IBAction) removeValidationKey:sender {
NSLog(@"sss");
  NSString *empty = @"";
  [empty writeToFile:[self validationFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  [self loadConfiguration:self];
}

- (void) installValidationKey:(NSURL*)url {
  if ([[NSFileManager defaultManager] isReadableFileAtPath:[url path]]) {
    NSString* content = [NSString stringWithContentsOfFile:[url path] encoding:NSUTF8StringEncoding error:NULL];
    [content writeToFile:[self validationFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  }
}

// Chef gem

- (BOOL) isChefGemInstalled {
  return [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/chef-client"];
}

- (IBAction) installChefGem:sender {
  [spinner startAnimation:self];
  NSDictionary *error = [NSDictionary new];
  NSString *script =  @"do shell script \"gem install chef --no-ri --no-rdoc\" with administrator privileges";
  NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
  [appleScript executeAndReturnError:&error];
  [spinner stopAnimation:self];
}

// Chef run

- (IBAction) runChefClient:sender {
  NSDictionary *error = [NSDictionary new];
  NSString *command = [@"/usr/bin/chef-client --config " stringByAppendingString:[self knifeConfigFile]];
  NSString *script =  @"tell application \"Terminal\"\nactivate\ndo script \"COMMAND\"\nend tell\n";
  NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:[script stringByReplacingOccurrencesOfString:@"COMMAND" withString:command]];
  [appleScript executeAndReturnError:&error];
}

// Configuration

- (void) loadConfiguration:sender {
  [self updateSSHKeys:self];
  NSString *validationKeyContent = [NSString stringWithContentsOfFile:[self validationFile] encoding:NSUTF8StringEncoding error:nil];
  NSString *nodeName = [[NSString stringWithContentsOfFile:[self nodeNameFile] encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSString *chefServerURL = [[NSString stringWithContentsOfFile:[self chefserverURLFile] encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  NSString *sshKeyFilename = [[NSString stringWithContentsOfFile:[self sshKeyConfigFile] encoding:NSUTF8StringEncoding error:nil] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  if (nodeName) nodeNameTextField.stringValue = [nodeName stringByReplacingOccurrencesOfString:@".biosphere" withString:@""];
  if (chefServerURL) chefserverURLTextField.stringValue = [chefServerURL stringByReplacingOccurrencesOfString:@"https://" withString:@""];
  if (!validationKeyContent || [validationKeyContent isEqualToString:@""]) {
    validationDigestLabel.stringValue = @"";
    validationDeleteButton.hidden = YES;
  } else {
    NSString *validationDigest = [self sha1:validationKeyContent];
    validationDigestLabel.stringValue = validationDigest;
    validationDeleteButton.hidden = NO;
  }
  nodeNameLabel.stringValue = [self nodeName];
  cheferverURLLabel.stringValue = [self chefserverURL];
  [sshKeyPopup selectItemWithTitle:sshKeyFilename];
}

- (IBAction) saveConfiguration:sender {
  [self ensureAssets];
  [[self nodeName] writeToFile:[self nodeNameFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  [[self chefserverURL] writeToFile:[self chefserverURLFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
  [[[sshKeyPopup selectedItem] title] writeToFile:[self sshKeyConfigFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

// Reset defaults

- (IBAction) resetNodeName:sender {
  [self setupNodeName];
  [self saveConfiguration:self];
}

- (IBAction) resetChefserverURL:sender {
  [self setupChefserverURL];
  [self saveConfiguration:self];
}

// Derived values

- (NSString*) nodeName {
  return [[nodeNameTextField stringValue] stringByAppendingString:@".biosphere"];
}

- (NSString*) chefserverURL {
  NSString *protocol = @"https://";
  NSURL *url = [NSURL URLWithString: [protocol stringByAppendingString:[chefserverURLTextField stringValue]]];
  if (url && url.path) return [url absoluteString];
  return @"";
}

// Notifications

- (void) controlTextDidChange:(NSNotification*) notification {
  nodeNameLabel.stringValue = [self nodeName];
  if ([[self chefserverURL] isEqual:@""]) {
    cheferverURLLabel.stringValue = @"Invalid URL!";
  } else {
    cheferverURLLabel.stringValue = [self chefserverURL];
  }
  [self saveConfiguration:self];
}

// Directories

- (NSString*) biosphereDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@".biosphere"];
}

- (NSString*) biosphereConfigDirectory {
  return [[self biosphereDirectory] stringByAppendingPathComponent:@"config"];
}

- (NSString*) chefDirectory {
  return [[self biosphereDirectory] stringByAppendingPathComponent:@"chef"];
}

- (NSString*) chefClientKeysDirectory {
  return [[self chefDirectory] stringByAppendingPathComponent:@"client_keys"];
}

- (NSString*) sshKeysDirectory {
  return [NSHomeDirectory() stringByAppendingPathComponent:@".ssh"];
}

// Files

- (NSString*) nodeNameFile {
  return [[self biosphereConfigDirectory] stringByAppendingPathComponent:@"chef_node_name"];
}

- (NSString*) chefserverURLFile {
  return [[self biosphereConfigDirectory] stringByAppendingPathComponent:@"chef_server_url"];
}

- (NSString*) sshKeyConfigFile {
  return [[self biosphereConfigDirectory] stringByAppendingPathComponent:@"ssh_key_filename"];
}

- (NSString*) knifeConfigFile {
  return [[self chefDirectory] stringByAppendingPathComponent:@"knife.rb"];
}

- (NSString*) validationFile {
  return [[self chefDirectory] stringByAppendingPathComponent:@"validation.pem"];
}

// Directory handling

- (void) ensureDirectories {
  NSArray *paths = [NSArray arrayWithObjects:[self biosphereConfigDirectory], [self chefClientKeysDirectory], nil];
  BOOL isDirectory;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  for (NSString *path in paths) {
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) continue;
    if ([fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) continue;
    NSAssert(NO, ([NSString stringWithFormat:@"Failed to create directory %@ : %@", path, error]));
  }
}

- (void) ensureAssets {
  [self ensureDirectories];
  NSString *knifeConfig = @"chef_path = File.expand_path(File.dirname(__FILE__))\n\ndef config(name)\n  path = File.expand_path(%{../config/#{name.to_s}}, File.dirname(__FILE__))\n  File.exists?(path) ? File.read(path).chomp : nil\nend\n\nchef_server_url config(:chef_server_url)\nvalidation_key %{#{chef_path}/validation.pem}\nclient_key %{#{chef_path}/client_keys/#{config(:chef_node_name)}.pem}\nfile_cache_path  %{#{chef_path}/cache}\nfile_backup_path %{#{chef_path}/cache/backups}\ncache_options({ :path => %{#{chef_path}/cache/checksums}})\nnode_name config(:chef_node_name)\n";
  [knifeConfig writeToFile:[self knifeConfigFile] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

// Encryption Helper

- (NSString*) sha1:(NSString*)input {
 const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
 NSData *data = [NSData dataWithBytes:cstr length:input.length];
 uint8_t digest[CC_SHA1_DIGEST_LENGTH];
 CC_SHA1(data.bytes, data.length, digest);
 NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
 for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) [output appendFormat:@"%02x", digest[i]];
 return output;
}

@end
