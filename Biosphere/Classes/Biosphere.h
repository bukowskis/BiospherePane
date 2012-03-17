#import <PreferencePanes/PreferencePanes.h>

@interface Biosphere : NSPreferencePane <NSTextFieldDelegate> {
  
  __strong NSTextField *biospherePathLabel;
  __strong NSTextField *versionLabel;
  __strong NSTextField *validationDigestLabel;
  __strong NSButton *validationDeleteButton;
  __strong NSButton *validationImportButton;
  __strong NSTextField *sshHeaderLabel;
  __strong NSTextField *nodeNameLabel;
  __strong NSTextField *nodeNameTextField;
  __strong NSTextField *chefserverURLTextField;
  __strong NSTextField *cheferverURLLabel;
  __strong NSTextField *cheferverURLHeaderLabel;
  __strong NSTextField *chefVersionLabel;
  __strong NSTextField *knifeCommandLabel;
  __strong NSButton *installChefButton;
  __strong NSProgressIndicator *spinner;
  __strong NSTextField *installChefInfoLabel;
  __strong NSButton *runBiosphereButton;
  __strong NSPopUpButton *sshKeyPopup;
  __strong NSButton *helpButton;
  __strong NSPopover *digestHelpPopover;
  __strong NSPopover *importHelpPopover;
  __strong NSTextField *importHelpPath;
  __strong NSTextField *sshHelpPath;
  __strong NSPopover *sshHelpPopover;
  __strong NSPopover *subscriptionHelpPopover;
  
}

@property (strong) IBOutlet NSTextField *biospherePathLabel;
@property (strong) IBOutlet NSTextField *versionLabel;
@property (strong) IBOutlet NSTextField *nodeNameLabel;
@property (strong) IBOutlet NSTextField *validationDigestLabel;
@property (strong) IBOutlet NSButton *validationDeleteButton;
@property (strong) IBOutlet NSButton *validationImportButton;
@property (strong) IBOutlet NSTextField *sshHeaderLabel;
@property (strong) IBOutlet NSTextField *nodeNameTextField;
@property (strong) IBOutlet NSTextField *chefserverURLTextField;
@property (strong) IBOutlet NSTextField *cheferverURLLabel;
@property (strong) IBOutlet NSTextField *cheferverURLHeaderLabel;
@property (strong) IBOutlet NSTextField *chefVersionLabel;
@property (strong) IBOutlet NSTextField *knifeCommandLabel;
@property (strong) IBOutlet NSProgressIndicator *spinner;
@property (strong) IBOutlet NSButton *installChefButton;
@property (strong) IBOutlet NSTextField *installChefInfoLabel;
@property (strong) IBOutlet NSButton *runBiosphereButton;
@property (strong) IBOutlet NSPopUpButton *sshKeyPopup;
@property (strong) IBOutlet NSButton *helpButton;
@property (strong) IBOutlet NSPopover *digestHelpPopover;
@property (strong) IBOutlet NSPopover *importHelpPopover;
@property (strong) IBOutlet NSTextField *importHelpPath;
@property (strong) IBOutlet NSTextField *sshHelpPath;
@property (strong) IBOutlet NSPopover *sshHelpPopover;
@property (strong) IBOutlet NSPopover *subscriptionHelpPopover;

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
- (IBAction) installChefGem:sender;
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
- (IBAction)toggleHelp:sender;

@end
