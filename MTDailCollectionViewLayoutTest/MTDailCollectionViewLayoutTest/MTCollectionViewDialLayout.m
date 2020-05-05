//
//  MTCollectionViewDialLayout.m
//  MTDailCollectionViewLayoutTest
//
//  Created by super mac on 2020/4/22.
//  Copyright © 2020 super mac. All rights reserved.
//

#import "MTCollectionViewDialLayout.h"

@interface MTCollectionViewDialLayout()

@property (nonatomic, assign) int cellCount;
@property (nonatomic, assign) MTDialLayoutDirectionType directionType;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGFloat yOffset;       // 用于MTDialLayoutDirectionTypeLeft、MTDialLayoutDirectionTypeRight
@property (nonatomic, assign) CGFloat xOffset;       // 用于MTDialLayoutDirectionTypeBottom
@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, assign) CGFloat AngularSpacing;
@property (nonatomic, assign) CGFloat dialRadius;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) NSInteger selectedItem;
@property (nonatomic, assign) BOOL shouldSnap;       // 是否需要回正

@end

@implementation MTCollectionViewDialLayout

- (id)init
{
    if ((self = [super init]) != NULL)
    {
        [self setup];
        self.shouldSnap = NO;
    }
    return self;
}

- (instancetype)initWithRadius:(CGFloat)radius
  andAngularSpacing:(CGFloat)spacing
        andCellSize:(CGSize)cell
       andAlignment:(MTDialLayoutDirectionType)direction
      andItemHeight:(CGFloat)height
         andOffset:(CGFloat)offset {
    if ((self = [super init]) != NULL)
    {
        self.shouldSnap = NO;

        self.dialRadius = radius;
        self.cellSize = cell;
        self.itemSize = cell;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.itemHeight = height;
        self.AngularSpacing = spacing;
        if (direction == MTDialLayoutDirectionTypeBottom) {
            self.yOffset = offset;
            self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            self.xOffset = offset;
            self.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        self.directionType = direction;
        self.sectionInset = UIEdgeInsetsZero;
        
        [self setup];
    }
    return self;
}

-(void)setShouldSnap:(BOOL)value{
    _shouldSnap = value;
}

- (void)setup
{
    self.offset = 0.0f;
}

- (void)prepareLayout
{
    [super prepareLayout];
    self.cellCount = (self.collectionView.numberOfSections > 0)? (int)[self.collectionView numberOfItemsInSection:0] : 0;
    if (self.directionType == MTDialLayoutDirectionTypeBottom) {
        self.offset = -self.collectionView.contentOffset.x / self.itemHeight;
    } else {
        self.offset = -self.collectionView.contentOffset.y / self.itemHeight;
    }
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *theLayoutAttributes = [[NSMutableArray alloc] init];
    

    int maxVisiblesHalf = 180 / (self.AngularSpacing);
    
    int lastIndex = -1;
    for( int i = 0; i < self.cellCount; i++ ){
        CGRect itemFrame = [self getRectForItem:i];
        if(CGRectIntersectsRect(rect, itemFrame) && i > (-1*self.offset - maxVisiblesHalf) && i < (-1*self.offset + maxVisiblesHalf)){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [theLayoutAttributes addObject:theAttributes];
            lastIndex = i;
        }
    }
    
    return theLayoutAttributes;
}

-(CGRect)getRectForItem:(int)item{
    
    CGRect itemFrame = CGRectZero;
    double newIndex = (item + self.offset);
    float scaleFactor = fmax(0.6, 1 - fabs( newIndex *0.25));
    float deltaX = self.cellSize.width/2;
    
    float rX = 0.0;
    float rY = 0.0;
    float oY = 0.0;
    float oX = 0.0;
    
    switch (self.directionType) {
        case MTDialLayoutDirectionTypeBottom: {
            rX = cosf((self.AngularSpacing* newIndex - 90) *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor));
            rY = sinf((self.AngularSpacing* newIndex - 90) *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor));
            oX = self.collectionView.bounds.size.width/2 + self.collectionView.contentOffset.x - (0.5 * self.cellSize.width);
            oY = self.collectionView.bounds.size.height - self.yOffset;
            break;
        }
        case MTDialLayoutDirectionTypeLeft: {
            rX = cosf(self.AngularSpacing* newIndex *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor));
            rY = sinf(self.AngularSpacing* newIndex *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor));
            oX = -self.dialRadius + self.xOffset - (0.5 * self.cellSize.width);
            oY = self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y - (0.5 * self.cellSize.height);
            break;
        }
        case MTDialLayoutDirectionTypeRight: {
            rX = cosf(self.AngularSpacing* newIndex *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor)) * -1;
            rY = sinf(self.AngularSpacing* newIndex *M_PI/180) * (self.dialRadius + (deltaX*scaleFactor));
            oX = self.collectionView.frame.size.width + self.dialRadius - self.xOffset - (0.5 * self.cellSize.width);
            oY = self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y - (0.5 * self.cellSize.height);
            break;
        }
        default:
            break;
    }
    
    itemFrame = CGRectMake(oX + rX, oY + rY, self.cellSize.width, self.cellSize.height);
    
    return itemFrame;
}



-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    if (self.directionType == MTDialLayoutDirectionTypeBottom) {
        if(self.shouldSnap){
            int index =(int)floor(proposedContentOffset.x / self.itemHeight);
            int off = ((int)proposedContentOffset.x % (int)self.itemHeight);
            
            CGFloat targetX = (off > self.cellSize.width * 0.5 && index <= self.cellCount)? (index+1) * self.cellSize.width: index * self.cellSize.width;
            return CGPointMake(targetX, proposedContentOffset.y );
        }else{
            return proposedContentOffset;
        }
    } else {
        if(self.shouldSnap){
            int index =(int)floor(proposedContentOffset.y / self.itemHeight);
            int off = ((int)proposedContentOffset.y % (int)self.itemHeight);
            
            CGFloat targetY = (off > self.itemHeight * 0.5 && index <= self.cellCount)? (index+1) * self.itemHeight: index * self.itemHeight;
            return CGPointMake(proposedContentOffset.x, targetY );
        }else{
            return proposedContentOffset;
        }
    }
}

-(NSIndexPath *)targetIndexPathForInteractivelyMovingItem:(NSIndexPath *)previousIndexPath withPosition:(CGPoint)position{
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (CGSize)collectionViewContentSize
{
    if (self.directionType == MTDialLayoutDirectionTypeBottom) {
        const CGSize theSize = {
            .width = (self.cellCount-1) * self.itemHeight + self.collectionView.bounds.size.width,
            .height = self.collectionView.bounds.size.height,
        };
        return(theSize);
    } else {
        const CGSize theSize = {
            .width = self.collectionView.bounds.size.width,
            .height = (self.cellCount-1) * self.itemHeight + self.collectionView.bounds.size.height,
        };
        return(theSize);
    }
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double newIndex = (indexPath.item + self.offset);
    
    UICollectionViewLayoutAttributes *theAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    theAttributes.size = self.cellSize;
    
    float scaleFactor;
    CGAffineTransform rotationT;
    switch (self.directionType) {
        case MTDialLayoutDirectionTypeBottom:
            rotationT = CGAffineTransformMakeRotation((self.AngularSpacing* newIndex - 90) *M_PI/180);
            break;
        case MTDialLayoutDirectionTypeLeft:
            rotationT = CGAffineTransformMakeRotation((self.AngularSpacing* newIndex) *M_PI/180);
        break;
        case MTDialLayoutDirectionTypeRight:
            rotationT = CGAffineTransformMakeRotation(-(self.AngularSpacing* newIndex) *M_PI/180);
        break;
        default:
            break;
    }

    CGFloat minRange = -self.AngularSpacing / 2.0;
    CGFloat maxRange = self.AngularSpacing / 2.0;
    CGFloat currentAngle = self.AngularSpacing*newIndex;
    
    if ((currentAngle > minRange) && (currentAngle < maxRange)) {
        self.selectedItem = indexPath.item;
    }
    
    scaleFactor = fmax(0.6, 1 - fabs( newIndex *0.25));
    CGRect newFrame = [self getRectForItem:(int)indexPath.item];
    theAttributes.frame = CGRectMake(newFrame.origin.x , newFrame.origin.y, newFrame.size.width, newFrame.size.height);
    
    CGAffineTransform scaleT = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    theAttributes.alpha = scaleFactor;
    theAttributes.hidden = NO;

    theAttributes.transform = CGAffineTransformConcat(scaleT, rotationT);
    
    return(theAttributes);
}

@end
