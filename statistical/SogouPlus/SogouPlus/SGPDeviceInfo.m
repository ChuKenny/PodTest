//
//  ADJDeviceInfo.m
//  adjust
//
//  Created by Pedro Filipe on 17/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "SGPDeviceInfo.h"
#import "SGPUtilities.h"
#import "SGPMobileClick.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import <mach/machine.h>

@implementation SGPDeviceInfo

+ (SGPDeviceInfo *)deviceInfo {
    return [[SGPDeviceInfo alloc] init];
}


- (id)init {
    self = [super init];
    if (self){
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGFloat scale = [[UIScreen mainScreen] scale];
        NSInteger width = rect.size.width * scale;
        NSInteger height = rect.size.height * scale;
        self.resolution       = [NSString stringWithFormat:@"%ldx%ld", (long)width,(long)height];
        self.osName           = @"IOS";
        
        self.bundleVersion    = [SGPUtilities appVersion];
        self.clientSdk        = SGPUtilities.clientSdk;

        UIDevice *device = UIDevice.currentDevice;
        NSString *deviceName = [self plusDeviceName];
        self.deviceName       = deviceName!=nil ? deviceName : device.model;
        NSString *softId = [self plusSoftId];
        self.softId           = softId!=nil ? softId : @"null";
        NSString *deviceType = [self plusDeviceType];
        self.deviceType       = deviceType!=nil ? deviceType : @"null";
        self.systemVersion    = device.systemVersion!=nil ? device.systemVersion : @"null";
        
        NSBundle *bundle = NSBundle.mainBundle;
        NSDictionary *infoDictionary = bundle.infoDictionary;
        self.bundeIdentifier  = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey]!=nil? [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey] :@"null";
        
        NSLocale *locale = NSLocale.currentLocale;
        self.languageCode     = [locale objectForKey:NSLocaleLanguageCode]!=nil? [locale objectForKey:NSLocaleLanguageCode] :@"null";
        self.countryCode      = [locale objectForKey:NSLocaleCountryCode]!=nil? [locale objectForKey:NSLocaleCountryCode] :@"null";
        NSString *machineModel = [self machineModel];
        self.machineModel     = machineModel!=nil? machineModel :@"null";
        NSString *cpuSubtype = [self plusCpuSubtype];
        self.cpuSubtype       = cpuSubtype!=nil? cpuSubtype :@"null";
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    SGPDeviceInfo* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.softId = [self.softId copyWithZone:zone];
        copy.clientSdk = [self.clientSdk copyWithZone:zone];
        copy.bundeIdentifier = [self.bundeIdentifier copyWithZone:zone];
        copy.bundleVersion = [self.bundleVersion copyWithZone:zone];
        copy.deviceType = [self.deviceType copyWithZone:zone];
        copy.deviceName = [self.deviceName copyWithZone:zone];
        copy.osName = [self.osName copyWithZone:zone];
        copy.systemVersion = [self.systemVersion copyWithZone:zone];
        copy.languageCode = [self.languageCode copyWithZone:zone];
        copy.countryCode = [self.countryCode copyWithZone:zone];
        copy.machineModel = [self.machineModel copyWithZone:zone];
        copy.cpuSubtype = [self.cpuSubtype copyWithZone:zone];
        copy.resolution = [self.resolution copyWithZone:zone];
    }

    return copy;
}

#pragma mark - private
- (NSString*)machineModel
{
    return [self readSysctlbString:"hw.model" errorLog:@"Failed to obtain machine model"];
}

- (NSString*) readSysctlbString:(const char *)name
                       errorLog:(NSString*)errorLog
{
    int error = 0;
    size_t length = 0;
    error = sysctlbyname(name, NULL, &length, NULL, 0);
    
    if (error != 0) {
        NSLog(@"%@", errorLog);
        return nil;
    }
    
    char *p = malloc(sizeof(char) * length);
    if (p) {
        error = sysctlbyname(name, p, &length, NULL, 0);
    }
    
    if (error != 0) {
        NSLog(@"%@", errorLog);
        free(p);
        return nil;
    }
    
    NSString * result = [NSString stringWithUTF8String:p];
    free(p);
    return result;
}

- (NSString*)plusCpuSubtype
{
    int error = 0;
    
    int cputype = -1;
    size_t length = sizeof(cputype);
    error = sysctlbyname("hw.cputype", &cputype, &length, NULL, 0);
    
    if (error != 0) {
        NSLog(@"Failed to obtain CPU type");
        return nil;
    }
    
    int cpuSubtype = -1;
    length = sizeof(cpuSubtype);
    error = sysctlbyname("hw.cpusubtype", &cpuSubtype, &length, NULL, 0);
    
    if (error != 0) {
        NSLog(@"Failed to obtain CPU subtype");
        return nil;
    }
    
    
    NSString * cpuSubtypeString = [self readCpuTypeSubtype:cputype readSubType:YES cpusubtype:cpuSubtype];
    
    if (cpuSubtypeString != nil) {
        return cpuSubtypeString;
    }
    
    NSString * unknowCpuSubtype = [NSString stringWithFormat:@"Unknown CPU subtype %d", cpuSubtype];
    NSLog(@"%@", unknowCpuSubtype);
    return unknowCpuSubtype;
}

- (NSString*) readCpuTypeSubtype:(int)cputype
                     readSubType:(BOOL)readSubType
                      cpusubtype:(int)cpusubtype
{
    switch (cputype)
    {
        case CPU_TYPE_ANY:
            if (!readSubType) return @"CPU_TYPE_ANY";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_MULTIPLE:
                return @"CPU_SUBTYPE_MULTIPLE";
            case CPU_SUBTYPE_LITTLE_ENDIAN:
                return @"CPU_SUBTYPE_LITTLE_ENDIAN";
            case CPU_SUBTYPE_BIG_ENDIAN:
                return @"CPU_SUBTYPE_BIG_ENDIAN";
        }
            break;
        case CPU_TYPE_VAX:
            if (!readSubType) return @"CPU_TYPE_VAX";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_VAX_ALL:
                return @"CPU_SUBTYPE_VAX_ALL";
            case CPU_SUBTYPE_VAX780:
                return @"CPU_SUBTYPE_VAX780";
            case CPU_SUBTYPE_VAX785:
                return @"CPU_SUBTYPE_VAX785";
            case CPU_SUBTYPE_VAX750:
                return @"CPU_SUBTYPE_VAX750";
            case CPU_SUBTYPE_VAX730:
                return @"CPU_SUBTYPE_VAX730";
            case CPU_SUBTYPE_UVAXI:
                return @"CPU_SUBTYPE_UVAXI";
            case CPU_SUBTYPE_UVAXII:
                return @"CPU_SUBTYPE_UVAXII";
            case CPU_SUBTYPE_VAX8200:
                return @"CPU_SUBTYPE_VAX8200";
            case CPU_SUBTYPE_VAX8500:
                return @"CPU_SUBTYPE_VAX8500";
            case CPU_SUBTYPE_VAX8600:
                return @"CPU_SUBTYPE_VAX8600";
            case CPU_SUBTYPE_VAX8650:
                return @"CPU_SUBTYPE_VAX8650";
            case CPU_SUBTYPE_VAX8800:
                return @"CPU_SUBTYPE_VAX8800";
            case CPU_SUBTYPE_UVAXIII:
                return @"CPU_SUBTYPE_UVAXIII";
        }
            break;
        case CPU_TYPE_MC680x0:
            if (!readSubType) return @"CPU_TYPE_MC680x0";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_MC680x0_ALL:
                return @"CPU_SUBTYPE_MC680x0_ALL";
            case CPU_SUBTYPE_MC68040:
                return @"CPU_SUBTYPE_MC68040";
            case CPU_SUBTYPE_MC68030_ONLY:
                return @"CPU_SUBTYPE_MC68030_ONLY";
        }
            break;
        case CPU_TYPE_X86_64:
            if (!readSubType) return @"CPU_TYPE_X86_64";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_X86_64_ALL:
                return @"CPU_SUBTYPE_X86_64_ALL";
            case CPU_SUBTYPE_X86_ARCH1:
                return @"CPU_SUBTYPE_X86_ARCH1";
            case CPU_SUBTYPE_X86_64_H:
                return @"CPU_SUBTYPE_X86_64_H";
        }
            break;
        case CPU_TYPE_X86:
            if (!readSubType) return @"CPU_TYPE_X86";
            switch (cpusubtype) {
                case CPU_SUBTYPE_386:
                    return @"CPU_SUBTYPE_386";
                case CPU_SUBTYPE_486:
                    return @"CPU_SUBTYPE_486";
                case CPU_SUBTYPE_486SX:
                    return @"CPU_SUBTYPE_486SX";
                case CPU_SUBTYPE_PENT:
                    return @"CPU_SUBTYPE_PENT";
                case CPU_SUBTYPE_PENTPRO:
                    return @"CPU_SUBTYPE_PENTPRO";
                case CPU_SUBTYPE_PENTII_M3:
                    return @"CPU_SUBTYPE_PENTII_M3";
                case CPU_SUBTYPE_PENTII_M5:
                    return @"CPU_SUBTYPE_PENTII_M5";
                case CPU_SUBTYPE_CELERON:
                    return @"CPU_SUBTYPE_CELERON";
                case CPU_SUBTYPE_CELERON_MOBILE:
                    return @"CPU_SUBTYPE_CELERON_MOBILE";
                case CPU_SUBTYPE_PENTIUM_3:
                    return @"CPU_SUBTYPE_PENTIUM_3";
                case CPU_SUBTYPE_PENTIUM_3_M:
                    return @"CPU_SUBTYPE_PENTIUM_3_M";
                case CPU_SUBTYPE_PENTIUM_3_XEON:
                    return @"CPU_SUBTYPE_PENTIUM_3_XEON";
                case CPU_SUBTYPE_PENTIUM_M:
                    return @"CPU_SUBTYPE_PENTIUM_M";
                case CPU_SUBTYPE_PENTIUM_4:
                    return @"CPU_SUBTYPE_PENTIUM_4";
                case CPU_SUBTYPE_PENTIUM_4_M:
                    return @"CPU_SUBTYPE_PENTIUM_4_M";
                case CPU_SUBTYPE_ITANIUM:
                    return @"CPU_SUBTYPE_ITANIUM";
                case CPU_SUBTYPE_ITANIUM_2:
                    return @"CPU_SUBTYPE_ITANIUM_2";
                case CPU_SUBTYPE_XEON:
                    return @"CPU_SUBTYPE_XEON";
                case CPU_SUBTYPE_XEON_MP:
                    return @"CPU_SUBTYPE_XEON_MP";
            }
            break;
        case CPU_TYPE_MC98000:
            if (!readSubType) return @"CPU_TYPE_MC98000";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_MC98000_ALL:
                return @"CPU_SUBTYPE_MC98000_ALL";
            case CPU_SUBTYPE_MC98601:
                return @"CPU_SUBTYPE_MC98601";
        }
            break;
        case CPU_TYPE_HPPA:
            if (!readSubType) return @"CPU_TYPE_HPPA";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_HPPA_7100:
                return @"CPU_SUBTYPE_HPPA_7100";
            case CPU_SUBTYPE_HPPA_7100LC:
                return @"CPU_SUBTYPE_HPPA_7100LC";
        }
            break;
        case CPU_TYPE_ARM64:
            if (!readSubType) return @"CPU_TYPE_ARM64";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_ARM64_ALL:
                return @"CPU_SUBTYPE_ARM64_ALL";
            case CPU_SUBTYPE_ARM64_V8:
                return @"CPU_SUBTYPE_ARM64_V8";
        }
            break;
        case CPU_TYPE_ARM:
            if (!readSubType) return @"CPU_TYPE_ARM";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_ARM_ALL:
                return @"CPU_SUBTYPE_ARM_ALL";
            case CPU_SUBTYPE_ARM_V4T:
                return @"CPU_SUBTYPE_ARM_V4T";
            case CPU_SUBTYPE_ARM_V6:
                return @"CPU_SUBTYPE_ARM_V6";
            case CPU_SUBTYPE_ARM_V5TEJ:
                return @"CPU_SUBTYPE_ARM_V5TEJ";
            case CPU_SUBTYPE_ARM_XSCALE:
                return @"CPU_SUBTYPE_ARM_XSCALE";
            case CPU_SUBTYPE_ARM_V7:
                return @"CPU_SUBTYPE_ARM_V7";
            case CPU_SUBTYPE_ARM_V7F:
                return @"CPU_SUBTYPE_ARM_V7F";
            case CPU_SUBTYPE_ARM_V7S:
                return @"CPU_SUBTYPE_ARM_V7S";
            case CPU_SUBTYPE_ARM_V7K:
                return @"CPU_SUBTYPE_ARM_V7K";
            case CPU_SUBTYPE_ARM_V6M:
                return @"CPU_SUBTYPE_ARM_V6M";
            case CPU_SUBTYPE_ARM_V7M:
                return @"CPU_SUBTYPE_ARM_V7M";
            case CPU_SUBTYPE_ARM_V7EM:
                return @"CPU_SUBTYPE_ARM_V7EM";
            case CPU_SUBTYPE_ARM_V8:
                return @"CPU_SUBTYPE_ARM_V8";
        }
            break;
        case CPU_TYPE_MC88000:
            if (!readSubType) return @"CPU_TYPE_MC88000";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_MC88000_ALL:
                return @"CPU_SUBTYPE_MC88000_ALL";
            case CPU_SUBTYPE_MC88100:
                return @"CPU_SUBTYPE_MC88100";
            case CPU_SUBTYPE_MC88110:
                return @"CPU_SUBTYPE_MC88110";
        }
            break;
        case CPU_TYPE_SPARC:
            if (!readSubType) return @"CPU_TYPE_SPARC";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_SPARC_ALL:
                return @"CPU_SUBTYPE_SPARC_ALL";
        }
            break;
        case CPU_TYPE_I860:
            if (!readSubType) return @"CPU_TYPE_I860";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_I860_ALL:
                return @"CPU_SUBTYPE_I860_ALL";
            case CPU_SUBTYPE_I860_860:
                return @"CPU_SUBTYPE_I860_860";
        }
            break;
        case CPU_TYPE_POWERPC64:
            if (!readSubType) return @"CPU_TYPE_POWERPC64";
            break;
        case CPU_TYPE_POWERPC:
            if (!readSubType) return @"CPU_TYPE_POWERPC";
            switch (cpusubtype)
        {
            case CPU_SUBTYPE_POWERPC_ALL:
                return @"CPU_SUBTYPE_POWERPC_ALL";
            case CPU_SUBTYPE_POWERPC_601:
                return @"CPU_SUBTYPE_POWERPC_601";
            case CPU_SUBTYPE_POWERPC_602:
                return @"CPU_SUBTYPE_POWERPC_602";
            case CPU_SUBTYPE_POWERPC_603:
                return @"CPU_SUBTYPE_POWERPC_603";
            case CPU_SUBTYPE_POWERPC_603e:
                return @"CPU_SUBTYPE_POWERPC_603e";
            case CPU_SUBTYPE_POWERPC_603ev:
                return @"CPU_SUBTYPE_POWERPC_603ev";
            case CPU_SUBTYPE_POWERPC_604:
                return @"CPU_SUBTYPE_POWERPC_604";
            case CPU_SUBTYPE_POWERPC_604e:
                return @"CPU_SUBTYPE_POWERPC_604e";
            case CPU_SUBTYPE_POWERPC_620:
                return @"CPU_SUBTYPE_POWERPC_620";
            case CPU_SUBTYPE_POWERPC_750:
                return @"CPU_SUBTYPE_POWERPC_750";
            case CPU_SUBTYPE_POWERPC_7400:
                return @"CPU_SUBTYPE_POWERPC_7400";
            case CPU_SUBTYPE_POWERPC_7450:
                return @"CPU_SUBTYPE_POWERPC_7450";
            case CPU_SUBTYPE_POWERPC_970:
                return @"CPU_SUBTYPE_POWERPC_970";
        }
            break;
    }
    return nil;
}

- (NSString *)plusSoftId {
    NSString *udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *softId = nil;
    if (udid==nil) {
        softId = [self randomUUID];
    }else{
        softId = udid;
    }
    softId = [softId stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return softId;
}

- (NSString *)randomUUID {
    if(NSClassFromString(@"NSUUID")) {
        return [[NSUUID UUID] UUIDString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return uuid;
}

- (NSString *)plusDeviceType {
    NSString *type = [[UIDevice currentDevice].model stringByReplacingOccurrencesOfString:@" " withString:@""];
    return type;
}

- (NSString *)plusDeviceName {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = malloc(size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [NSString stringWithUTF8String:name];
    free(name);
    return machine;
}
@end
