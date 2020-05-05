//
//  MTCollectionViewDialLayout.h
//  MTDailCollectionViewLayoutTest
//
//  Created by super mac on 2020/4/22.
//  Copyright © 2020 super mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTCollectionViewDialLayout : UICollectionViewFlowLayout

typedef enum MTDialLayoutDirectionType : NSInteger {
    MTDialLayoutDirectionTypeBottom,
    MTDialLayoutDirectionTypeLeft,
    MTDialLayoutDirectionTypeRight
} MTDialLayoutDirectionType;


- (instancetype)initWithRadius:(CGFloat)radius
   andAngularSpacing:(CGFloat)spacing
         andCellSize:(CGSize)cell
        andAlignment:(MTDialLayoutDirectionType)direction
       andItemHeight:(CGFloat)height
           andOffset:(CGFloat)Offset;

-(void)setShouldSnap:(BOOL)value;
@end

NS_ASSUME_NONNULL_END
