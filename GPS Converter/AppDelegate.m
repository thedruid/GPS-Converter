//
//  AppDelegate.m
//  GPS Converter
//
//  Created by David Lindmark on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "NSColorHex.m"
@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [formatButton removeAllItems];
    [sizeButton removeAllItems];
    [formatButton addItemWithTitle:@"GPX"];
    [formatButton addItemWithTitle:@"KML"];
    
    [activityButton removeAllItems];
    [activityButton addItemWithTitle:@"Running"];
    [activityButton addItemWithTitle:@"Hiking"];
    [activityButton addItemWithTitle:@"Walking"];
    [activityButton addItemWithTitle:@"Cycling"];
    [activityButton addItemWithTitle:@"Cross-Country Skiing"];
    [activityButton addItemWithTitle:@"Downhill Skiing"];
    [activityButton addItemWithTitle:@"Snowboarding"];
    [activityButton addItemWithTitle:@"Skateing"];
    [activityButton addItemWithTitle:@"Swimming"];
    //[[formatButton menu] setDelegate:self];
    
    for (float i = 1; i < 10.5f; i = i+0.5f) {
        [sizeButton addItemWithTitle:[NSString stringWithFormat:@"%.1f",i]];
        if (i == 6) {
            [sizeButton selectItemAtIndex:i];
        }
    }
    
    // Insert code here to initialize your application
}

-(IBAction)didChangeFormat:(id)sender {
    if ([formatButton.selectedItem.title isEqualToString:@"KML"]) {
        [options setStringValue:@"Line layout"];
        [activityButton setHidden:YES];
        [sizeButton setHidden:NO];
        [colorWell setHidden:NO];
        [colorLabel setHidden:NO];
        [sizeLabel setHidden:NO];
    } else if ([formatButton.selectedItem.title isEqualToString:@"GPX"]) {
        [options setStringValue:@"Activity"];
        [activityButton setHidden:NO];
        [sizeButton setHidden:YES];
        [colorWell setHidden:YES];
        [colorLabel setHidden:YES];
        [sizeLabel setHidden:YES];
    }
}

-(IBAction)doOpen:(id)sender {
    int i;
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray *fileTypesArray;
    fileTypesArray = [NSArray arrayWithObjects:@"gps", nil];
    [openDlg setCanChooseFiles:YES];    
    [openDlg setAllowedFileTypes:fileTypesArray];
    [openDlg setAllowsMultipleSelection:NO];
    if ( [openDlg runModal] == NSOKButton ) {
        NSArray *files = [openDlg URLs];
        for( i = 0; i < [files count]; i++ ) {
            NSLog(@"%@",[files objectAtIndex:i]);
            NSError *error;
            NSString *stringFromFileAtPath = [[NSString alloc]
                                              initWithContentsOfFile:[[files objectAtIndex:i] path]
                                              encoding:NSUTF8StringEncoding
                                              error:&error];
            if (stringFromFileAtPath == nil) {
                // an error occurred
                NSLog(@"Error reading file at %@\n%@",[files objectAtIndex:i],[error localizedFailureReason]);
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Can't open file. Try to browse for it again..."];
                [alert runModal];
                return;
                [saveButton setEnabled:NO];
            } else {
                currentData = stringFromFileAtPath;
                [inputLabel setStringValue:[[files objectAtIndex:i] lastPathComponent]];
                [saveButton setEnabled:YES];
            }
        }
    }
}

-(IBAction)save:(id)sender {
    NSSavePanel* openDlg = [NSSavePanel savePanel];
    [openDlg setCanCreateDirectories:YES];
    if ( [openDlg runModal] == NSOKButton ) {
        [self exportFile:[openDlg URL]];
        NSLog(@"%@",[openDlg URL]);
        
    }
}

-(void)exportFile:(NSURL*)savePath {
    /* assuming data is in UTF8 */
    /* Remove breaks and all other non valid text */
    NSMutableArray *validLines = [[NSMutableArray alloc] init];
    NSMutableArray *lines = [[currentData componentsSeparatedByString:@"\n"] mutableCopy];
    for (int i = 0; i < [lines count]; i++) {
        NSString *line = [lines objectAtIndex:i];
        line = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        if ([line length] > 0) {
            if(isdigit([line characterAtIndex:0])) {
                [validLines addObject: line];
                // NSLog(@"Valid Line: %@",line);
            } else if ([line characterAtIndex:0] == '-' && isdigit([line characterAtIndex:1])) {
                [validLines addObject: line];
               // NSLog(@"Valid Line: %@",line);
            } else {
                NSLog(@"Found non valid Line: %@",line);
            }
        }
    }
    

    NSMutableString *exportData = [[NSMutableString alloc] init];
    if ([formatButton.selectedItem.title isEqualToString:@"GPX"]) {
         /* Creates Header */
        [exportData appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<gpx\n\tversion=\"1.1\"\n\tcreator=\"David Lindmark - http://www.denacode.se\"\n\txmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n\txmlns=\"http://www.topografix.com/GPX/1/1\"\n\txsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\"\n\txmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\">\n"];
        
        
        /* Breaks down each component */
       // NSLog(@"%@",validLines);
        for (int i = 0; i < [validLines count]; i++) {
            NSMutableArray *values = [[[validLines objectAtIndex:i] componentsSeparatedByString:@","] mutableCopy];
            if ([values count] >= 4) {
                NSString *latitude = [values objectAtIndex:0];
                NSString *longitude = [values objectAtIndex:1];
                NSString *elevation = [values objectAtIndex:2];
                NSString *time = [values objectAtIndex:4];
                
                /* Change Time Format */
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                NSString *formattedDateString = [dateFormatter stringFromDate:date];
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd/MM/yy HH:mm a"];
                NSString *amDateString = [dateFormatter stringFromDate:date];
                // Output for locale en_US: "formattedDateString: Jan 2, 2001"
                if (i == 0) {
                    [exportData appendFormat:@"<trk>\n\t<name><![CDATA[%@ %@]]></name>\n\t<time>%@</time>\n<trkseg>\n",activityButton.selectedItem.title,amDateString,formattedDateString];
                }
                [exportData appendFormat:@"<trkpt lat=\"%@\" lon=\"%@\"><ele>%@</ele><time>%@</time></trkpt>\n",latitude,longitude,elevation,formattedDateString];
            }
        }
        [exportData appendFormat:@"</trkseg>\n</trk>\n</gpx>"];
       // NSLog(@"%@",exportData);
        
        
        NSString *fullPath = [savePath absoluteString];
        if ([fullPath hasSuffix:@".GPX"] || [fullPath hasSuffix:@".gpx"] || [fullPath hasSuffix:@".Gpx"] || [fullPath hasSuffix:@".GPx"] || [fullPath hasSuffix:@".GpX"] || [fullPath hasSuffix:@".gPx"]) {
        } else {
            savePath = [savePath URLByAppendingPathExtension:@"gpx"];
        }
        NSError *error = nil;
        BOOL ok = [exportData writeToURL:savePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        //[exportData writeToFile:save atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!ok) {
            NSLog(@"Error writing file at %@\n%@",fullPath, [error localizedFailureReason]);
        }
        
    } else if ([formatButton.selectedItem.title isEqualToString:@"KML"]) {
        /* Creates Header */
        [exportData appendFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n<Document>\n<name>Paths</name>\n<Style id=\"line\">\n<LineStyle>\n<color>%@</color>\n<width>%@</width>\n</LineStyle>\n</Style>\n<Placemark>\n<styleUrl>#line</styleUrl>\n<LineString>\n<extrude>1</extrude>\n<tessellate>1</tessellate>\n<altitudeMode>clampToGround</altitudeMode>\n<coordinates>\n",colorWell.color.hexadecimalValue,sizeButton.selectedItem.title];
        
        /* Breaks down each component */
       // NSLog(@"%@",validLines);
        for (int i = 0; i < [validLines count]; i++) {
            NSMutableArray *values = [[[validLines objectAtIndex:i] componentsSeparatedByString:@","] mutableCopy];
            if ([values count] >= 4) {
                NSString *latitude = [values objectAtIndex:0];
                NSString *longitude = [values objectAtIndex:1];
                
                [exportData appendFormat:@"%@,%@\n",longitude,latitude];
            }
        }
        [exportData appendFormat:@"</coordinates>\n</LineString>\n</Placemark>\n</Document>\n</kml>\n"];
       // NSLog(@"%@",exportData);
        
        
        NSString *fullPath = [savePath absoluteString];
        if ([fullPath hasSuffix:@".KML"] || [fullPath hasSuffix:@".kml"] || [fullPath hasSuffix:@".Kml"] || [fullPath hasSuffix:@".KMl"] || [fullPath hasSuffix:@".KmL"] || [fullPath hasSuffix:@".kMl"]) {
        } else {
            savePath = [savePath URLByAppendingPathExtension:@"kml"];
        }
        NSError *error = nil;
        BOOL ok = [exportData writeToURL:savePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        //[exportData writeToFile:save atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!ok) {
            NSLog(@"Error writing file at %@\n%@",fullPath, [error localizedFailureReason]);
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Export completed!"];
            [alert runModal];
        }

    }

}

@end
