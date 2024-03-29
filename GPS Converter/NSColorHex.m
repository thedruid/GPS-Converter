#import <Cocoa/Cocoa.h>

@interface NSColor (Hex)

- (NSString *)hexadecimalValue;
+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex;

@end

//#import "NSColor+Hex.h"

@implementation NSColor (Hex)

- (NSString *)hexadecimalValue {
    
    double redFloatValue, greenFloatValue, blueFloatValue, alphaFloatValue;
    int redIntValue, greenIntValue, blueIntValue, alphaIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue, *alphaHexValue;
    
    NSColor *convertedColor = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if(convertedColor) {
        [convertedColor getRed:&redFloatValue green:&greenFloatValue blue:&blueFloatValue alpha:&alphaFloatValue];
        
        redIntValue = redFloatValue*255.99999f;
        greenIntValue = greenFloatValue*255.99999f;
        blueIntValue = blueFloatValue*255.99999f;
        alphaIntValue = alphaFloatValue*255.99999f;
        
        redHexValue = [NSString stringWithFormat:@"%02x", redIntValue]; 
        greenHexValue = [NSString stringWithFormat:@"%02x", greenIntValue];
        blueHexValue = [NSString stringWithFormat:@"%02x", blueIntValue];
        alphaHexValue = [NSString stringWithFormat:@"%02x", alphaIntValue];

        
        return [NSString stringWithFormat:@"%@%@%@%@",alphaHexValue, redHexValue, greenHexValue, blueHexValue];
    }
    
    return nil;
}

+ (NSColor *)colorFromHexadecimalValue:(NSString *)hex {
    
    if ([hex hasPrefix:@"#"]) {
        hex = [hex substringWithRange:NSMakeRange(1, [hex length] - 1)];
    }
    
	unsigned int colorCode = 0;
	
	if (hex) {
		NSScanner *scanner = [NSScanner scannerWithString:hex];
		(void)[scanner scanHexInt:&colorCode];
	}
    
	return [NSColor colorWithDeviceRed:((colorCode>>16)&0xFF)/255.0 green:((colorCode>>8)&0xFF)/255.0 blue:((colorCode)&0xFF)/255.0 alpha:1.0];
}

@end


