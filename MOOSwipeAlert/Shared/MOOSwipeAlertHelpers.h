//
//  MOOSwipeAlertHelpers.h
//  MOOSwipeAlert
//
//  Created by Peyton Randolph on 2/20/13.
//


// Orientation helpers
CGFloat UIInterfaceOrientationAngle(UIInterfaceOrientation orientation);
UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation);

// Protocol proprety copying

void copyProtocolProperties(Protocol *proto, id fromObj, id toObj);

/**
 * Returns the set of all property names in a protocol, excluding a super-protocol's properties.
 */
NSSet *propertyNamesForProtocolExcludingProtocol(Protocol *proto, Protocol *toExclude);

/**
 * Returns the set of all property names in a protocol.
 */
NSSet *propertyNamesForProtocol(Protocol *proto);