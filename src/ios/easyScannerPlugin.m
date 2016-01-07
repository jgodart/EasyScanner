
/*
  EasyScannerPlugin.m
  Created by Godart Jeoffrey on 05/01/201§.
*/

#import <Cordova/CDV.h>
#import "EasyScannerPlugin.h"
#import "ScannerViewController.h" 
#import <Moodstocks/Moodstocks.h>


@implementation moodstocksScanner {
    MSScanner *__scanner;
}

// global objects are stored here so they can be responded to later
CDVInvokedUrlCommand *messageCommand;
CDVInvokedUrlCommand *scanCommand;
CDVPluginResult* messagePluginResult;
CDVPluginResult* syncPluginResult;
CDVPluginResult* scanPluginResult;

// Create A scanner View Controller 
ScannerViewController *scannerVC;

/*
    Open the scanner and define Parameters
*/
- (void)openScanner:(CDVInvokedUrlCommand*)command
{
    //deprecated in IOS 9.0
   [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    
    CDVPluginResult* pluginResult = nil;
    
    NSArray *arguments = command.arguments;

    NSString *db = @".db";
    NSString *api_Key    = [[arguments objectAtIndex:0] valueForKey:@"api_key"];
    NSString *api_Secret = [[arguments objectAtIndex:0] valueForKey:@"api_secret"];

    NSError *error = nil;

    // Create the name Of the Database With the Api_Key
    NSString *nameDb=[NSString stringWithFormat:@"%@%@", api_Key , db];
    NSLog((@" nameDb  : %@ ") , nameDb);

    NSString *path = [MSScanner cachesPathFor:nameDb];

    __scanner = [[MSScanner alloc] init];
    [__scanner openWithPath:path key:api_Key secret:api_Secret error:&error];
    NSLog((@"Error de path  : %@ ") , [error ms_message]);
    
    NSLog((@" Path  : %@ ") , path);
   
   
    BOOL bundleLoaded = NO;
    NSString* bundleName = [[arguments objectAtIndex:0] valueForKey:@"bundleName"];
      // remove the ".bundle" from the end of the bundleName
    if ([bundleName length] < 7) {
        // ".bundle" is 7 characters long. If the string's shorter than that, a bundle hasn't been defined properly
    }
    else {
        // trim bundle name (on Android it needs .bundle at the end, on iOS it doesn't)
        bundleName = [bundleName substringToIndex:[bundleName length]-7];
        
        // only load the bundle once per version
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ( ![userDefaults valueForKey:@"version"] )
        {
            // First run. Load Bundle.
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            NSError *error = nil;
            BOOL success = [__scanner importBundle:bundle error:&error];
            if (success == YES) {
                // Adding version number to NSUserDefaults for first version:
                [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
                NSLog(@"Moodstocks Bundle loaded successfully.");
                bundleLoaded = YES;
            }
            else {
                NSLog(@"Error loading Moodstocks bundle.");
            }
        }
        else {
            
            if ([[NSUserDefaults standardUserDefaults] floatForKey:@"version"] == [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] )
            {
                // Application has not been updated (same version) and the bundle has already been loaded. Don't load it again.
                NSLog(@"Bundle not loaded. It has previously been loaded and should only be used once per install.");
                bundleLoaded = YES;
            }
            else
            {
                // Application has been updated. It might have a new bundle, so load it again.
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MS4TOM.bundle" ofType:@"bundle"];
                NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
                NSError *error = nil;
                BOOL success = [__scanner importBundle:bundle error:&error];
                if (success == YES) {
                    // Adding version number to NSUserDefaults for first version:
                    [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
                    NSLog(@"Bundle loaded successfully.");
                    bundleLoaded = YES;
                }
                else {
                    NSLog(@"Error loading Moodstocks bundle.");
                }
            }
        }
    }
    
    // return whether the scanner opened succesfully or not
    if (__scanner != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:bundleLoaded ];
    }
    else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

/*
    Close the scanner  
*/
- (void)closeScanner:(CDVInvokedUrlCommand*)command
{
    
    NSError *errorClose = nil;

    //Stop Synchro
    [__scanner cancelSync];

    //Stop Api search
    [__scanner cancelApiSearches];

    // close the OpenWithPath
    bool reusltatCLose = [__scanner close:&errorClose];

    NSLog((@"Error Close = %@"),errorClose);
    NSLog((@"Result close   = %s"),reusltatCLose ? "true" : "false");
}


/*
    Synchronise the Moodstocks SB  with the _scanner db 
        - synchronization progress and completion
*/
- (void)synchroScanner:(CDVInvokedUrlCommand*)command
{
    // Create the progression and completion blocks:
    void (^completionBlock)(MSSync *, NSError *) = ^(MSSync *op, NSError *error) {
        if (error)
        {
            NSLog(@"Sync failed with error: %@", [error ms_message]);
        }
        else{
                NSLog(@"Sync succeeded (%li images(s))", (long)[__scanner count:nil]);
        }
        [self.commandDelegate sendPluginResult:syncPluginResult callbackId:command.callbackId];
        
    };

    void (^progressionBlock)(NSInteger) = ^(NSInteger percent) {
        NSLog(@"Sync progressing: %li%%", (long)percent);
    };

    // Launch the synchronization
    [__scanner syncInBackgroundWithBlock:completionBlock progressBlock:progressionBlock];

}

/*
    Start a event Scanning, retrieves options :
        - scanType : Auto or Manual
        - scanFormats : Image, QR code, EAN 13, EAN 8, Datamatrix
        - useDeviceOrientation : True or False 
        - noPartialMatching : True or False
        - smallTargetSupport : True or False
*/
- (void)Scan:(CDVInvokedUrlCommand*)command
{

    // register to receive notifications (which will deliver the result)
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(NotifScanResult:)
     name:@"scanResultNotification"
     object:nil];
    
    scanCommand = command; // save scanCommand to the result can be returned.
    
    //Retrieves items passed as parameters
    NSString* scanType = [[command.arguments objectAtIndex:0] valueForKey:@"scanType"];
    int scanFormats = [[[command.arguments objectAtIndex:0] valueForKey:@"scanFormats"] integerValue];
    BOOL useDeviceOrientation = [[[command.arguments objectAtIndex:0] valueForKey:@"useDeviceOrientation"] integerValue];
    BOOL noPartialMatching = [[[command.arguments objectAtIndex:0] valueForKey:@"noPartialMatching"] integerValue];
    BOOL smallTargetSupport = [[[command.arguments objectAtIndex:0] valueForKey:@"smallTargetSupport"] integerValue];
    
    // Alloc the parameters to the ScannerViewController 
    scannerVC = [[ScannerViewController alloc] initWithScanType:scanType
                                                     andFormats:scanFormats
                                                     noPartials:noPartialMatching
                                                    smallTarget:smallTargetSupport];
    
    // Create the ChildViewController scanner
    scannerVC.scanner = __scanner;
    [self.viewController addChildViewController:scannerVC];
    [self.viewController.view addSubview:scannerVC.view];
    [self.viewController.view sendSubviewToBack:scannerVC.view];
    NSLog(@"ScannerView Added as Child View Controller");

}
/*
    Notif if The result of the Scan 
        - Is Error = Send a error Message 
        - Else Ok 
*/
- (void)NotifScanResult:(NSNotification *)scanResult
{
    // Error message when the Scan didn't find any image 
    NSString *error = @"the scan didn't find any result";

    NSDictionary *dictionary = [scanResult userInfo];
    NSString *format = [dictionary valueForKey:@"format"];
    
    if([format  isEqual: @"false"]) {
        // special case where no result was found
        scanPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:error];
    }
    else {
        scanPluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dictionary];
    }
    [scanPluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
    [self.commandDelegate sendPluginResult:scanPluginResult callbackId:scanCommand.callbackId];
}
/*
    Notify when the state is update 
*/
- (void)postNotificationToUpdateState:(NSNotification *)scanAction
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:scanAction forKey:@"action"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeStateNotification" object:nil userInfo:dictionary];
}

- (void)stopScan:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    [scannerVC removeFromParentViewController];
    [scannerVC.view removeFromSuperview];
    NSLog(@"ScannerView removed as Child View Controller");
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
    Notify the Change of the State
*/
- (void)tapToScan:(CDVInvokedUrlCommand *)command
{
    [self postNotificationToUpdateState:@"tapToScan"];
}
- (void)pauseScan:(CDVInvokedUrlCommand*)command
{
    [self postNotificationToUpdateState:@"pause"];
}
- (void)resumeScan:(CDVInvokedUrlCommand*)command
{
    [self postNotificationToUpdateState:@"resume"];
}
@end


