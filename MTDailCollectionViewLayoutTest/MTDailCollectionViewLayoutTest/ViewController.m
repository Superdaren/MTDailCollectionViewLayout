//
//  ViewController.m
//  MTDailCollectionViewLayoutTest
//
//  Created by super mac on 2020/4/21.
//  Copyright © 2020 super mac. All rights reserved.
//

#import "ViewController.h"
#import "MTTestCell.h"
#import "MTCollectionViewDialLayout.h"

static NSString *cellId = @"MTTestCell";

#define itemHeight  100

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MTCollectionViewDialLayout *dialLayout = [[MTCollectionViewDialLayout alloc] initWithRadius:self.view.bounds.size.width/2 andAngularSpacing:20 andCellSize:CGSizeMake(itemHeight, itemHeight) andAlignment:MTDialLayoutDirectionTypeBottom andItemHeight:itemHeight andOffset:0];
    [dialLayout setShouldSnap:YES];
    [self.collectionView setCollectionViewLayout:dialLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MTTestCell" bundle:nil] forCellWithReuseIdentifier:cellId];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell;
    cell = [cv dequeueReusableCellWithReuseIdentifier:cellId
                                              forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.collectionView setContentOffset:CGPointMake(indexPath.item * itemHeight, 0) animated:YES];
}

@end
