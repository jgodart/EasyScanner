/*
  EasyScannerPlugin.h
  Created by Godart Jeoffrey on 05/01/201§.
*/

#import <Cordova/CDV.h>
#import <Moodstocks/Moodstocks.h>

@interface moodstocksScanner: CDVPlugin

@property MSScanner *_scanner;

- (void)NotifScanResult:(NSNotification *)scanResult;
- (void)postNotificationToUpdateState:(NSString *)scanAction;


- (void)Scan:(CDVInvokedUrlCommand*)command;
- (void)stopScan:(CDVInvokedUrlCommand*)command;
- (void)tapToScan:(CDVInvokedUrlCommand*)command;
- (void)pauseScan:(CDVInvokedUrlCommand*)command;
- (void)resumeScan:(CDVInvokedUrlCommand*)command;

@end