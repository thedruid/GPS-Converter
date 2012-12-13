//
//  AppDelegate.h
//  GPS Converter
//
//  Created by David Lindmark on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate> {
    IBOutlet NSTextField *inputLabel;
    IBOutlet NSPopUpButton *formatButton;
    IBOutlet NSPopUpButton *activityButton;
    IBOutlet NSButton *saveButton;
    
    /* KML Format */
    IBOutlet NSColorWell *colorWell;
    IBOutlet NSPopUpButton *sizeButton;
    IBOutlet NSTextField *options;
    IBOutlet NSTextField *sizeLabel;
    IBOutlet NSTextField *colorLabel;
    NSString *currentData;

}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)doOpen:(id)sender;
-(IBAction)save:(id)sender;
-(void)exportFile:(NSURL*)savePath;

@end
