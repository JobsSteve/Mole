//
//  GameCore.m
//  Mole
//
//  Created by James Kong on 18/5/13.
//
//

#import "GameCore.h"
#include <sys/utsname.h>
#import <Social/Social.h>
#define  NUM_MOLE 10
@interface GameCore ()
-(void) postFacebook;
- (void)onButtonTriggered:(SPEvent *)event;

@end
@implementation GameCore
{
    //    SPSprite *_contents;
    SPSprite *_face;
    SPSprite *_mole;
    
    SPSprite *_moleMenu;
    
    SPButton *_confirmButton;
    SPButton *_fbButton;
    SPButton *_saveButton;
    BOOL _canCapScreen;
    BOOL _canPostFB;
    BOOL _isConfirm;
    
}
- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    if(_confirmButton!=nil)
    {
        [_confirmButton removeFromParent];
    }
    if(_fbButton!=nil)
    {
        [_fbButton removeFromParent];
    }
    if(_confirmButton!=nil)
    {
        [_saveButton removeFromParent];
    }
    if(_face!=nil)
    {
        [_face removeFromParent];
    }
    if(_mole!=nil)
    {
        [_mole removeFromParent];
    }
}

- (void)setup
{
    
    
    _face = [SPSprite sprite];
    _moleMenu = [SPSprite sprite];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fileName = [defaults objectForKey:@"TargetFaceFile"];
    NSString *name = [defaults objectForKey:@"UserName"];
    
    /*
     * _moleMenu add button
     * minusbtn
     * scroll
     *
     *
     */
    
    SPImage * spImage = [[SPImage alloc] initWithContentsOfFile:fileName];
    
    spImage.x = 0;
    spImage.y = 0;
    [_face addChild:spImage];
    
    
    [self addChild:_face];
    
    _mole = [SPSprite sprite];
    [_face addChild:_mole];
    // to find out how to react to touch events have a look at the TouchSheet class!
    // It's part of the demo.
    for(int i = 0 ; i< NUM_MOLE ; i++)
    {
        
        SPImage *sparrow = [SPImage imageWithContentsOfFile:@"mole01.png"];
        TouchSheet *sheet = [[TouchSheet alloc] initWithQuad:sparrow];
        sheet.x = (i*30)+30;
        sheet.y = Sparrow.stage.height-10;
        
        [_mole addChild:sheet];
    }
    
    _confirmButton = [self createButton:@"Confirm" :@"button_short.png"];
    _confirmButton.x = 20;
    _confirmButton.y = _confirmButton.height;
    [self addChild:_confirmButton];
    
    _fbButton = [self createButton:@"Facebook" :@"button_short.png"];
    _fbButton.x = 20;
    _fbButton.enabled = NO;
    _fbButton.y = _confirmButton.y + _fbButton.height;
    [self addChild:_fbButton];
    
    _saveButton = [self createButton:@"Save" :@"button_short.png"];
    _saveButton.x = 20;
    _saveButton.enabled = NO;
    _saveButton.y = _fbButton.y + _saveButton.height;
    [self addChild:_saveButton];
    
    [self addChild: [self childByName:@"back"]];
    
    
    SPTextField * _userNameTF = [SPTextField textFieldWithWidth:100 height:25
                                                           text:name];
    _userNameTF.x = (Sparrow.stage.width*0.5)-(_userNameTF.width*0.5);
    _userNameTF.y = 50;
    _userNameTF.hAlign = SPHAlignCenter ;
    _userNameTF.vAlign = SPVAlignCenter ;
    _userNameTF.border = NO;
    _userNameTF.color = 0x000000;
    [self addChild:_userNameTF];
    
    _isConfirm = _canCapScreen = _canPostFB = NO;
    
    
}

// callback for CGDataProviderCreateWithData
void releaseData(void *info, const void *data, size_t dataSize) {
	//	NSLog(@"releaseData\n");
	free((void*)data);		// free the
}
- (UIImage *)screenshot :(SPRectangle*)rectangle{
    
	int myWidth = 640;
	int myHeight = 960;
    int myX = 0;
    int myY = 0;
    if ([[self platformString] isEqualToString:@"iPhone 3G"] ||
        [[self platformString] isEqualToString:@"iPhone 3GS"])
    {
        myWidth = 320;
        myHeight = 480;
    }
    else if ([[self platformString] isEqualToString:@"iPhone 4"] ||
             [[self platformString] isEqualToString:@"Verizon iPhone 4"] ||
             [[self platformString] isEqualToString:@"iPhone 4S"])
    {
        myWidth = 640;
        myHeight = 960;
    }
    else if ([[self platformString] isEqualToString:@"iPhone 5 (GSM)"] ||
             [[self platformString] isEqualToString:@"iPhone 5 (GSM+CDMA)"])
    {
        myWidth = 640;
        myHeight = 960;
        myX = 0;
        myY = (1136-960)/2;
    }
    else{
        myWidth = 640;
        myHeight = 960;
    }
    
    
    NSInteger myDataLength = myWidth * myHeight * 4;
    NSMutableData * buffer= [NSMutableData dataWithLength :myDataLength];
    
	glReadPixels(myX, myY, myWidth, myHeight, GL_RGBA, GL_UNSIGNED_BYTE, [buffer mutableBytes]);
    
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, [buffer mutableBytes], myDataLength, NULL);
	CGImageRef iref = CGImageCreate(myWidth,myHeight,8,32,myWidth*4,CGColorSpaceCreateDeviceRGB(),
									kCGBitmapByteOrderDefault,ref,NULL, true, kCGRenderingIntentDefault);
	uint32_t* pixels = (uint32_t *)malloc(myDataLength);
	CGContextRef context = CGBitmapContextCreate(pixels, myWidth, myHeight, 8, myWidth*4, CGImageGetColorSpace(iref),
												 kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Big);
	CGContextTranslateCTM(context, 0.0, myHeight);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, myWidth, myHeight), iref);
	CGImageRef outputRef = CGBitmapContextCreateImage(context);
	UIImage *image = [UIImage imageWithCGImage:outputRef];
    CGImageRelease(outputRef);
    CGImageRelease(iref);
    CGContextRelease(context);
	free(pixels);
	return image;
    //    [image release];
}

// callback for UIImageWriteToSavedPhotosAlbum
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	NSLog(@"Save finished");
    
}

- (void)postFacebook
{
    //    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    //    if ([touches anyObject]) [Media playSound:@"sound.caf"];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        // Initialize Compose View Controller
        SLComposeViewController *vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        // Configure Compose View Controller
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *name = [defaults objectForKey:@"UserName"];
        NSString *content = [[NSString alloc] initWithFormat:@"%@ : %@",name,@"bla bla bla bla bla bla bla bla bla bla \nbla bla bla bla bla bla bla bla " ];
        [vc setInitialText:content];
        UIImage * img = [self screenshot:[[SPRectangle alloc] initWithX:
                                          0 y:0
                                                                  width:GAME_WIDTH height:GAME_HEIGHT]];
        [vc addImage: img];
        //        [name release];
        // Present Compose View Controller
        [Sparrow.currentController presentViewController:vc animated:YES completion:nil];
    } else {
        NSString *message = @"It seems that we cannot talk to Facebook at the moment or you have not yet added your Facebook account to this device. Go to the Settings application to add your Facebook account to this device.";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
-(SPButton*) createButton:(NSString*) _text : (NSString*)filePath
{
    SPTexture *buttonTexture = [SPTexture textureWithContentsOfFile:filePath];
    
    SPButton *newButton = [[SPButton alloc] initWithUpState:buttonTexture text:_text];
    
    newButton.name = _text;
    newButton.enabled = YES;
    
    [newButton addEventListener:@selector(onButtonTriggered:) atObject:self
                        forType:SP_EVENT_TYPE_TRIGGERED];
    return newButton;
}
- (void)onButtonTriggered:(SPEvent *)event
{
    [Media playSound:@"sound.caf"];
    SPButton* button =  (SPButton*)event.target;
    if([button.name isEqualToString:@"Confirm"])
    {
        _fbButton.enabled = YES;
        _saveButton.enabled = YES;
        [self checkMolePosition];
        
    }else if([button.name isEqualToString:@"Facebook"])
    {
        [self removeChild: _confirmButton];
        [self removeChild: _fbButton];
        [self removeChild: _saveButton];
        [self removeChild: [self backButton]];
        
        [self flatten];
        //allow render loop do scapscreeen function
        _canPostFB = YES;
    }else if([button.name isEqualToString:@"Save"])
    {
        [self removeChild: _confirmButton];
        [self removeChild: _fbButton];
        [self removeChild: _saveButton];
        [self removeChild: [self backButton]];
        
        
        [self flatten];
        //allow render loop do scapscreeen function
        _canCapScreen = YES;
    }
    
}

- (void)onSceneClosing:(SPEvent *)event
{
    [_confirmButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [_fbButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [_saveButton removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [super onSceneClosing:event];
}
-(void) checkMolePosition
{
    int numMole = [_mole numChildren];
    NSLog(@"checkMolePosition : %i",numMole);
    for( int i = 0 ; i < numMole ; i++)
    {
        TouchSheet *sheet = (TouchSheet *)[_mole childAtIndex:i];
        NSLog(@"TouchSheet : %i at %f %f",i,sheet.x+sheet.width*0.5,sheet.y+sheet.height*0.5);
    }
}
- (void)render:(SPRenderSupport*)support
{
    //should do super render before the cap screen
    [super render:support];
    if (_canCapScreen || _canPostFB) {
        if(_canPostFB)
        {
            [self postFacebook];
        }else{
            UIImage * img = [self screenshot :[[SPRectangle alloc] initWithX:
                                               0 y:0 width:GAME_WIDTH height:GAME_HEIGHT]];
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
        }
        _canCapScreen = NO;
        _canPostFB = NO;
        [self addChild: _confirmButton];
        [self addChild: _fbButton];
        [self addChild: _saveButton];
        [self addChild: [self backButton]];
        //should use unflatten here
        //dont know why
        [self unflatten];
    }
    
}
- (NSString *) platformString{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* platform =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //    NSLog(@"Current Devie Model %@",_platform);//[[UIDevice currentDevice] localizedModel]);
    //    NSString *platform = [Sparrow.currentController.parentViewController _platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
@end
