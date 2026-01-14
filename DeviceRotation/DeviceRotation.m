#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AdSupport/AdSupport.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// Storage keys for rotated device IDs
#define kRotatedUDIDKey @"RotatedUDID"
#define kRotatedIDFVKey @"RotatedIDFV"
#define kRotatedIDFAKey @"RotatedIDFA"
#define kRotatedSerialKey @"RotatedSerial"
#define kRotatedModelKey @"RotatedModel"

// Forward declarations
@interface DeviceRotationManager : NSObject
+ (instancetype)sharedManager;
- (void)rotateDeviceIDs;
- (NSString *)getRotatedUDID;
- (NSString *)getRotatedIDFV;
- (NSString *)getRotatedIDFA;
- (NSString *)getRotatedSerial;
- (NSString *)getRotatedModel;
@end

// Original function pointers
static CFTypeRef (*original_MGCopyAnswer)(CFStringRef key) = NULL;
static NSUUID* (*original_identifierForVendor)(id self, SEL _cmd) = NULL;
static NSUUID* (*original_advertisingIdentifier)(id self, SEL _cmd) = NULL;

// Device Rotation Manager Implementation
@implementation DeviceRotationManager

+ (instancetype)sharedManager {
    static DeviceRotationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSString *)generateRandomUUID {
    return [[NSUUID UUID] UUIDString];
}

- (NSString *)generateRandomSerial {
    // Format: C02XXXXX (like real Apple serial numbers)
    NSString *chars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *serial = [NSMutableString stringWithString:@"C02"];
    for (int i = 0; i < 8; i++) {
        int index = arc4random_uniform((uint32_t)[chars length]);
        [serial appendFormat:@"%C", [chars characterAtIndex:index]];
    }
    return serial;
}

- (NSString *)generateRandomModel {
    // Common iPhone models
    NSArray *models = @[@"iPhone12,1", @"iPhone13,2", @"iPhone14,2", @"iPhone14,5", @"iPhone15,2"];
    return models[arc4random_uniform((uint32_t)[models count])];
}

- (void)rotateDeviceIDs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Generate new IDs
    NSString *newUDID = [self generateRandomUUID];
    NSString *newIDFV = [self generateRandomUUID];
    NSString *newIDFA = [self generateRandomUUID];
    NSString *newSerial = [self generateRandomSerial];
    NSString *newModel = [self generateRandomModel];
    
    // Store in UserDefaults
    [defaults setObject:newUDID forKey:kRotatedUDIDKey];
    [defaults setObject:newIDFV forKey:kRotatedIDFVKey];
    [defaults setObject:newIDFA forKey:kRotatedIDFAKey];
    [defaults setObject:newSerial forKey:kRotatedSerialKey];
    [defaults setObject:newModel forKey:kRotatedModelKey];
    [defaults synchronize];
    
    NSLog(@"[DeviceRotation] Device IDs rotated successfully!");
    NSLog(@"[DeviceRotation] New UDID: %@", newUDID);
    NSLog(@"[DeviceRotation] New IDFV: %@", newIDFV);
    NSLog(@"[DeviceRotation] New IDFA: %@", newIDFA);
    NSLog(@"[DeviceRotation] New Serial: %@", newSerial);
    NSLog(@"[DeviceRotation] New Model: %@", newModel);
}

- (NSString *)getRotatedUDID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *udid = [defaults stringForKey:kRotatedUDIDKey];
    if (!udid) {
        [self rotateDeviceIDs];
        udid = [defaults stringForKey:kRotatedUDIDKey];
    }
    return udid;
}

- (NSString *)getRotatedIDFV {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idfv = [defaults stringForKey:kRotatedIDFVKey];
    if (!idfv) {
        [self rotateDeviceIDs];
        idfv = [defaults stringForKey:kRotatedIDFVKey];
    }
    return idfv;
}

- (NSString *)getRotatedIDFA {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idfa = [defaults stringForKey:kRotatedIDFAKey];
    if (!idfa) {
        [self rotateDeviceIDs];
        idfa = [defaults stringForKey:kRotatedIDFAKey];
    }
    return idfa;
}

- (NSString *)getRotatedSerial {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serial = [defaults stringForKey:kRotatedSerialKey];
    if (!serial) {
        [self rotateDeviceIDs];
        serial = [defaults stringForKey:kRotatedSerialKey];
    }
    return serial;
}

- (NSString *)getRotatedModel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *model = [defaults stringForKey:kRotatedModelKey];
    if (!model) {
        [self rotateDeviceIDs];
        model = [defaults stringForKey:kRotatedModelKey];
    }
    return model;
}

@end

// Hooked MGCopyAnswer function
CFTypeRef hooked_MGCopyAnswer(CFStringRef key) {
    if (key == NULL) {
        return original_MGCopyAnswer(key);
    }
    
    NSString *keyStr = (__bridge NSString *)key;
    DeviceRotationManager *manager = [DeviceRotationManager sharedManager];
    
    // Hook UDID
    if ([keyStr isEqualToString:@"UniqueDeviceID"]) {
        NSString *rotatedUDID = [manager getRotatedUDID];
        NSLog(@"[DeviceRotation] MGCopyAnswer(UniqueDeviceID) -> %@", rotatedUDID);
        return (__bridge_retained CFTypeRef)rotatedUDID;
    }
    
    // Hook Serial Number
    if ([keyStr isEqualToString:@"SerialNumber"]) {
        NSString *rotatedSerial = [manager getRotatedSerial];
        NSLog(@"[DeviceRotation] MGCopyAnswer(SerialNumber) -> %@", rotatedSerial);
        return (__bridge_retained CFTypeRef)rotatedSerial;
    }
    
    // Hook Hardware Model
    if ([keyStr isEqualToString:@"HWModelStr"] || [keyStr isEqualToString:@"ProductType"]) {
        NSString *rotatedModel = [manager getRotatedModel];
        NSLog(@"[DeviceRotation] MGCopyAnswer(%@) -> %@", keyStr, rotatedModel);
        return (__bridge_retained CFTypeRef)rotatedModel;
    }
    
    // Default behavior for other keys
    return original_MGCopyAnswer(key);
}

// Hooked identifierForVendor
NSUUID* hooked_identifierForVendor(id self, SEL _cmd) {
    DeviceRotationManager *manager = [DeviceRotationManager sharedManager];
    NSString *rotatedIDFV = [manager getRotatedIDFV];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:rotatedIDFV];
    NSLog(@"[DeviceRotation] identifierForVendor -> %@", rotatedIDFV);
    return uuid;
}

// Hooked advertisingIdentifier
NSUUID* hooked_advertisingIdentifier(id self, SEL _cmd) {
    DeviceRotationManager *manager = [DeviceRotationManager sharedManager];
    NSString *rotatedIDFA = [manager getRotatedIDFA];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:rotatedIDFA];
    NSLog(@"[DeviceRotation] advertisingIdentifier -> %@", rotatedIDFA);
    return uuid;
}

// MSHookFunction for hooking C functions
void MSHookFunction(void *symbol, void *replace, void **result) {
    *result = symbol;
    
    // Use fishhook or manual hooking
    // For simplicity, we'll use method swizzling where possible
    // For C functions like MGCopyAnswer, we need to use dyld_interpose
}

// --- Jailbreak Detection Bypass Hooks ---

// Hook for canOpenURL to hide jailbreak apps
static BOOL (*original_canOpenURL)(id self, SEL _cmd, NSURL *url) = NULL;
BOOL hooked_canOpenURL(id self, SEL _cmd, NSURL *url) {
    if (!url) return NO;
    
    NSString *urlStr = [url absoluteString];
    NSArray *jbSchemes = @[@"cydia://", @"undecimus://", @"sileo://", @"zbra://", @"filza://", @"activator://"];
    
    for (NSString *scheme in jbSchemes) {
        if ([urlStr hasPrefix:scheme]) {
            NSLog(@"[DeviceRotation] Bypassing canOpenURL for: %@", urlStr);
            return NO;
        }
    }
    
    return original_canOpenURL(self, _cmd, url);
}

// Hook for fileExistsAtPath to hide jailbreak files
static BOOL (*original_fileExistsAtPath)(id self, SEL _cmd, NSString *path) = NULL;
BOOL hooked_fileExistsAtPath(id self, SEL _cmd, NSString *path) {
    if (!path) return NO;
    
    NSArray *jbPaths = @[
        @"/Applications/Cydia.app",
        @"/Applications/FakeCarrier.app",
        @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app",
        @"/Applications/MxTube.app",
        @"/Applications/RockApp.app",
        @"/Applications/SBSettings.app",
        @"/Applications/WinterBoard.app",
        @"/usr/sbin/sshd",
        @"/usr/bin/sshd",
        @"/usr/libexec/sftp-server",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/bin/sh",
        @"/etc/apt",
        @"/usr/bin/ssh",
        @"/private/var/lib/apt",
        @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log",
        @"/private/var/stencil/jailbreak.json"
    ];
    
    for (NSString *jbPath in jbPaths) {
        if ([path containsString:jbPath]) {
            NSLog(@"[DeviceRotation] Bypassing fileExistsAtPath for: %@", path);
            return NO;
        }
    }
    
    return original_fileExistsAtPath(self, _cmd, path);
}

// Hook for IOSSecuritySuite (if present)
void hookIOSSecuritySuite() {
    Class securityClass = NSClassFromString(@"IOSSecuritySuite");
    if (securityClass) {
        NSLog(@"[DeviceRotation] IOSSecuritySuite found, applying hooks...");
        
        // Example: amIJailbroken
        Method jbMethod = class_getClassMethod(securityClass, NSSelectorFromString(@"amIJailbroken"));
        if (jbMethod) {
            method_setImplementation(jbMethod, imp_implementationWithBlock(^BOOL(id self) {
                NSLog(@"[DeviceRotation] IOSSecuritySuite.amIJailbroken -> NO");
                return NO;
            }));
        }
        
        // Example: amIDebugged
        Method debugMethod = class_getClassMethod(securityClass, NSSelectorFromString(@"amIDebugged"));
        if (debugMethod) {
            method_setImplementation(debugMethod, imp_implementationWithBlock(^BOOL(id self) {
                NSLog(@"[DeviceRotation] IOSSecuritySuite.amIDebugged -> NO");
                return NO;
            }));
        }
        
        // Example: amIReverseEngineered
        Method reMethod = class_getClassMethod(securityClass, NSSelectorFromString(@"amIReverseEngineered"));
        if (reMethod) {
            method_setImplementation(reMethod, imp_implementationWithBlock(^BOOL(id self) {
                NSLog(@"[DeviceRotation] IOSSecuritySuite.amIReverseEngineered -> NO");
                return NO;
            }));
        }
    }
}

// Constructor - runs when dylib is loaded
__attribute__((constructor))
static void initialize() {
    NSLog(@"[DeviceRotation] Initializing Device Rotation & Bypass Hooks...");
    
    // --- Device Rotation Hooks ---
    
    // Hook MGCopyAnswer
    void *libMobileGestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_NOW);
    if (libMobileGestalt) {
        original_MGCopyAnswer = (CFTypeRef (*)(CFStringRef))dlsym(libMobileGestalt, "MGCopyAnswer");
    }
    
    // Hook UIDevice.identifierForVendor
    Class deviceClass = [UIDevice class];
    Method idfvMethod = class_getInstanceMethod(deviceClass, @selector(identifierForVendor));
    if (idfvMethod) {
        original_identifierForVendor = (NSUUID* (*)(id, SEL))method_getImplementation(idfvMethod);
        method_setImplementation(idfvMethod, (IMP)hooked_identifierForVendor);
    }
    
    // Hook ASIdentifierManager.advertisingIdentifier
    Class identifierClass = NSClassFromString(@"ASIdentifierManager");
    if (identifierClass) {
        Method adMethod = class_getInstanceMethod(identifierClass, NSSelectorFromString(@"advertisingIdentifier"));
        if (adMethod) {
            original_advertisingIdentifier = (NSUUID* (*)(id, SEL))method_getImplementation(adMethod);
            method_setImplementation(adMethod, (IMP)hooked_advertisingIdentifier);
        }
    }
    
    // --- Bypass Hooks ---
    
    // Hook UIApplication.canOpenURL:
    Class appClass = [UIApplication class];
    Method canOpenMethod = class_getInstanceMethod(appClass, @selector(canOpenURL:));
    if (canOpenMethod) {
        original_canOpenURL = (BOOL (*)(id, SEL, NSURL*))method_getImplementation(canOpenMethod);
        method_setImplementation(canOpenMethod, (IMP)hooked_canOpenURL);
        NSLog(@"[DeviceRotation] Hooked canOpenURL:");
    }
    
    // Hook NSFileManager.fileExistsAtPath:
    Class fmClass = [NSFileManager class];
    Method existsMethod = class_getInstanceMethod(fmClass, @selector(fileExistsAtPath:));
    if (existsMethod) {
        original_fileExistsAtPath = (BOOL (*)(id, SEL, NSString*))method_getImplementation(existsMethod);
        method_setImplementation(existsMethod, (IMP)hooked_fileExistsAtPath);
        NSLog(@"[DeviceRotation] Hooked fileExistsAtPath:");
    }
    
    // Hook Dynamic Libraries (IOSSecuritySuite, etc.)
    hookIOSSecuritySuite();
    
    NSLog(@"[DeviceRotation] Initialization complete!");
}

// Export the rotation function for UI access
extern "C" void rotateDeviceIdentifiers() {
    [[DeviceRotationManager sharedManager] rotateDeviceIDs];
}
