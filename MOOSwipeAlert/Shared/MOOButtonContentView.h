//
//  MOOButtonContentView.h
//  Demo Project
//
//  Created by Peyton Randolph on 3/3/13.
//  Copyright (c) 2013 Peyton Randolph. All rights reserved.
//

#import "MOOMessageContentView.h"

#import "MOOButtonSwipeAlert.h"

@interface MOOButtonContentView : MOOMessageContentView
{
    struct {
        BOOL needsButtonViews: 1;
    } _buttonContentViewFlags;
}

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) NSIndexSet *sideBySideIndices;
@property (nonatomic, unsafe_unretained) MOOButtonSwipeAlert *alert;

@end
