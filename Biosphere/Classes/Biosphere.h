#import <PreferencePanes/PreferencePanes.h>

@interface Biosphere : NSPreferencePane <NSTextFieldDelegate> {
  
  __strong NSTextField *biospherePathLabel;
  __strong NSTextField *versionLabel;
  __strong NSTextField *validationDigestLabel;
  __strong NSButton *validationDeleteButton;
  __strong NSTextField *nodeNameLabel;
  __strong NSTextField *nodeNameTextField;
  __strong NSTextField *chefserverURLTextField;
  __strong NSTextField *cheferverURLLabel;
  __strong NSTextField *chefVersionLabel;
  __strong NSButton *installChefButton;
  __strong NSProgressIndicator *spinner;
  __strong NSTextField *installChefInfoLabel;
  __strong NSButton *runBiosphereButton;
  __strong NSPopUpButton *sshKeyPopup;
  
}

@property (strong) IBOutlet NSTextField *biospherePathLabel;
@property (strong) IBOutlet NSTextField *versionLabel;
@property (strong) IBOutlet NSTextField *nodeNameLabel;
@property (strong) IBOutlet NSTextField *validationDigestLabel;
@property (strong) IBOutlet NSButton *validationDeleteButton;
@property (strong) IBOutlet NSTextField *nodeNameTextField;
@property (strong) IBOutlet NSTextField *chefserverURLTextField;
@property (strong) IBOutlet NSTextField *cheferverURLLabel;
@property (strong) IBOutlet NSTextField *chefVersionLabel;
@property (strong) IBOutlet NSProgressIndicator *spinner;
@property (strong) IBOutlet NSButton *installChefButton;
@property (strong) IBOutlet NSTextField *installChefInfoLabel;
@property (strong) IBOutlet NSButton *runBiosphereButton;
@property (strong) IBOutlet NSPopUpButton *sshKeyPopup;

- (void) mainViewDidLoad;
- (void) setupUI;
- (void) setupNodeName;
- (void) setupChefserverURL;
- (void) updateChefGemInfo:sender;
- (void) updateSSHKeys:sender;
- (NSString*) chefGemVersion;
- (NSString*) runCommand:(NSString*)command withArguments:(NSArray*)arguments;
- (IBAction)chooseValidationKey:sender;
- (IBAction) removeValidationKey:sender;
- (BOOL) isChefGemInstalled;
- (IBAction) runChefClient:sender;
- (void) loadConfiguration:sender;
- (IBAction) saveConfiguration:sender;
- (IBAction) resetNodeName:sender;
- (IBAction) resetChefserverURL:sender;
- (NSString*) nodeName;
- (NSString*) chefserverURL;
- (NSString*) biosphereDirectory;
- (NSString*) biosphereConfigDirectory;
- (NSString*) chefDirectory;
- (NSString*) chefClientKeysDirectory;
- (NSString*) sshKeysDirectory;
- (NSString*) nodeNameFile;
- (NSString*) chefserverURLFile;
- (NSString*) sshKeyConfigFile;
- (NSString*) knifeConfigFile;
- (NSString*) validationFile;
- (void) ensureDirectories;
- (void) ensureAssets;

@end
