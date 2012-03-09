#import "NodeNameFormatter.h"

@implementation NodeNameFormatter


- (BOOL) getObjectValue:(id*)object forString:(NSString*)string errorDescription:(NSString**)error {
  *object = string;
  return YES;
}

- (NSString *)stringForObjectValue:(id) object {
  if ([object isKindOfClass:[NSString class]]) return object;
  return nil;
}

- (BOOL) isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error {
  NSRange foundRange;
  NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyz-_."] invertedSet];
  foundRange = [partialString rangeOfCharacterFromSet:disallowedCharacters];
  
  if(foundRange.location != NSNotFound) {
    *error = @"Node name contains invalid characters";
    NSBeep();
    return NO;
  }
  
  if([partialString length] > 30) {
    *error = @"Node name is too long.";
    NSBeep();
    return NO;
  }
  
  *newString = partialString; 
  return YES;
}

@end
