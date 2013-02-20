//
//  MOOSwipeAlertHelpers.c
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 2/20/13.
//

#import "MOOSwipeAlertHelpers.h"

#import <objc/runtime.h>

#pragma mark - Orientation support
CGFloat UIInterfaceOrientationAngle(UIInterfaceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0f;
            break;
    }
    
    return angle;
}

UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
{
    return 1 << orientation;
}

#pragma mark - Protocol property copying methods

void copyProtocolProperties(Protocol *proto, NSObject *fromObj, NSObject *toObj)
{
    NSSet *propertyNames = propertyNamesForProtocolExcludingProtocol(proto, @protocol(NSObject));
    
    for (NSString *propertyName in propertyNames)
    {
        [toObj setValue:[fromObj valueForKey:propertyName] forKey:propertyName];
    }
}

// Returns the set of all property names in a protocol excluding properties of another protocol.
NSSet *propertyNamesForProtocolExcludingProtocol(Protocol *proto, Protocol *toExclude)
{
    NSSet *propertyList = propertyNamesForProtocol(proto);
    
    // Strip excluded properties.
    if (protocol_conformsToProtocol(proto, toExclude))
    {
        static NSSet *nsObjectProperties;
        if (!nsObjectProperties)
            nsObjectProperties = propertyNamesForProtocol(toExclude);
        
        propertyList = [propertyList objectsPassingTest:^BOOL(id obj, BOOL *stop) {
                        return ![nsObjectProperties containsObject:obj];
                        }];
    }
    
    return propertyList;
}

// Returns the set of all property names in a protocol.
NSSet *propertyNamesForProtocol(Protocol *proto)
{
    unsigned int propertyListCount;
    objc_property_t *propertyList = protocol_copyPropertyList(proto, &propertyListCount);
    objc_property_t *incPropertyList = propertyList;
    NSMutableSet *propertyNames = [NSMutableSet setWithCapacity:propertyListCount];
    
    while (propertyListCount)
    {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(*incPropertyList)];
        [propertyNames addObject:propertyName];
        
        ++incPropertyList;
        --propertyListCount;
    }
    
    free(propertyList);
    return propertyNames;
}
