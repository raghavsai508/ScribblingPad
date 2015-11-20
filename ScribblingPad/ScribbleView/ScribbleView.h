//
//  ScribbleView.h
//  ScribblingPad
//
//  Created by Raghav Sai Cheedalla on 7/18/15.
//  Copyright (c) 2015 Raghav Sai Cheedalla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScribbleView : UIView
{
    UIImage *incrementalImage;
}

@property (nonatomic, strong) UIImage *imageToBeDisplayed;

- (void)clearView;
- (void)activateErase;

@end
