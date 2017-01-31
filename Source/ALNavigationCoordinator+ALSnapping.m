//
//  ALNavigationCoordinator+ALSnapping.m
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALNavigationCoordinator+ALSnapping.h"

#import "ALUtils.h"

@interface ALSnapLocationWrapper : NSObject

@property (nonatomic) CGPoint point;
@property (nonatomic) ALNavigationCoordinatorSnapLocation snapLocation;

@end

@implementation ALSnapLocationWrapper

@end

@implementation ALNavigationCoordinator (ALSnapping)

- (ALNavigationCoordinatorSnapLocation)al_snapLocationNearestPoint:(CGPoint)point
{
    ALNavigationCoordinatorSnapLocation snapLocations = self.viewModel.snapLocations;

    if (snapLocations == ALNavigationCoordinatorSnapLocationNone)
    {
        return ALNavigationCoordinatorSnapLocationNone;
    }

    NSArray<ALSnapLocationWrapper *> *wrappers = [self al_wrappersForSnapLocations:snapLocations];

    ALNavigationCoordinatorSnapLocation location = ALNavigationCoordinatorSnapLocationNone;
    CGFloat shortestDistance = CGFLOAT_MAX;

    for (ALSnapLocationWrapper *wrapper in wrappers)
    {
        CGPoint locationPoint = wrapper.point;
        CGFloat distance = hypot(point.x - locationPoint.x, point.y - locationPoint.y);
        if (distance < shortestDistance)
        {
            shortestDistance = distance;
            location = wrapper.snapLocation;
        }
    }

    return location;
}

- (CGPoint)al_pointForSnapLocation:(ALNavigationCoordinatorSnapLocation)location
{
    ALNavigationCoordinatorSnapLocation snapLocations __unused = self.viewModel.snapLocations;
    NSParameterAssert(AL_OPTION_SET(snapLocations, location));
    
    NSArray<ALSnapLocationWrapper *> *wrappers = [self al_wrappersForSnapLocations:location];
    NSParameterAssert(wrappers.count == 1);

    return wrappers[0].point;
}

#pragma mark - Internal methods

- (NSArray<ALSnapLocationWrapper *> *)al_wrappersForSnapLocations:(ALNavigationCoordinatorSnapLocation)locations
{
    if (locations == ALNavigationCoordinatorSnapLocationNone)
    {
        return @[[self al_wrapperForLocation:ALNavigationCoordinatorSnapLocationNone withPoint:CGPointZero]];
    }

    CGRect frame = self.navigationController.view.frame;

    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    frame.origin.y += statusBarHeight;
    frame.size.height -= statusBarHeight;

    if ([self.navigationController isNavigationBarHidden] == NO)
    {
        CGFloat navBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
        frame.origin.y += navBarHeight;
        frame.size.height -= navBarHeight;
    }

    CGFloat snapPadding = self.viewModel.snapPadding;

    CGPoint topLeft = CGPointMake(CGRectGetMinX(frame) + snapPadding, CGRectGetMinY(frame) + snapPadding);
    CGPoint top = CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame) + snapPadding);
    CGPoint topRight = CGPointMake(CGRectGetMaxX(frame) - snapPadding, CGRectGetMinY(frame) + snapPadding);
    CGPoint right = CGPointMake(CGRectGetMaxX(frame) - snapPadding, CGRectGetMidY(frame));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(frame) - snapPadding, CGRectGetMaxY(frame) - snapPadding);
    CGPoint bottom = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame) - snapPadding);
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(frame) + snapPadding, CGRectGetMaxY(frame) - snapPadding);
    CGPoint left = CGPointMake(CGRectGetMinX(frame) + snapPadding, CGRectGetMidY(frame));
    CGPoint middle = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

    NSMutableArray<ALSnapLocationWrapper *> *points = [[NSMutableArray alloc] init];

    void (^addPointIfNecessary)(ALNavigationCoordinatorSnapLocation, CGPoint) = ^(ALNavigationCoordinatorSnapLocation location, CGPoint point) {

        if (AL_OPTION_SET(locations, location))
        {
            [points addObject:[self al_wrapperForLocation:location withPoint:point]];
        }

    };

    addPointIfNecessary(ALNavigationCoordinatorSnapLocationTopLeft, topLeft);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationTop, top);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationTopRight, topRight);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationRight, right);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationBottomRight, bottomRight);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationBottom, bottom);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationBottomLeft, bottomLeft);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationLeft, left);
    addPointIfNecessary(ALNavigationCoordinatorSnapLocationMiddle, middle);

    return [points copy];
}

- (ALSnapLocationWrapper *)al_wrapperForLocation:(ALNavigationCoordinatorSnapLocation)location withPoint:(CGPoint)point
{
    ALSnapLocationWrapper *wrapper = [[ALSnapLocationWrapper alloc] init];
    wrapper.snapLocation = location;
    wrapper.point = point;
    return wrapper;
}

@end
