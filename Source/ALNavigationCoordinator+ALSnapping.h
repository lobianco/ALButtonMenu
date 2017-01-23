//
//  ALNavigationCoordinator+ALSnapping.h
//  ALButtonMenu
//
//  Copyright © 2016 Anthony Lobianco. All rights reserved.
//

#import "ALNavigationCoordinator.h"

@interface ALNavigationCoordinator (ALSnapping)

// these methods take into account only the available snapLocations provided by view model
- (ALNavigationCoordinatorSnapLocation)al_snapLocationNearestPoint:(CGPoint)point;
- (CGPoint)al_pointForSnapLocation:(ALNavigationCoordinatorSnapLocation)location;

@end
