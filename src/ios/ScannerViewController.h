/*
  ScannerViewController.h
 Created by Godart jeoffrey on 06/01/2016.
*/

#import <UIKit/UIKit.h>
#import <Moodstocks/Moodstocks.h>
#import "EasyScannerPlugin.h"

@interface ScannerViewController : UIViewController

@property MSScanner *scanner;
@property (nonatomic,strong) moodstocksScanner *moodstocksscanner;
- (void)postNotificationOfScanResult:(NSString *)scanResult;
- (void)useNotificationToChangeState:(NSNotification *)scanAction;
-(id)initWithScanType:(NSString *)desiredScanType andFormats:(int) scanFormats noPartials:(bool) partialsFlag smallTarget:(bool) smallTargetFlag;
@end
