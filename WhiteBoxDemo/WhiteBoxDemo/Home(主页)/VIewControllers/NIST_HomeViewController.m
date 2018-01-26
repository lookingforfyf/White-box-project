//
//  NIST_HomeViewController.m
//  WhiteBoxDemo
//
//  Created by 范云飞 on 2017/10/17.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_HomeViewController.h"

static  NSString * const KHomePageCollectionViewCell = @"HomePageCollectionViewCell";
static  NSString * const KcollectionHeaderView       = @"collectionHeaderView";

@interface NIST_HomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView           * collectionView;          /* 列表 */
@property (strong, nonatomic) UICollectionViewFlowLayout * layout;                  /* layout */
@property (strong, nonatomic) NSArray        <NSString *>* dataArray;               /* 数据源 */
@property (strong, nonatomic) UICollectionReusableView   * collectionHeaderView;    /* collection的头视图 */
@property (strong, nonatomic) NIST_HeadView              * headView;                /* 头视图 */
@end

@implementation NIST_HomeViewController
#pragma mark - LifeStyle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"功能列表";
    [self setNavigationLeftButtonImage:@"icon_nav_back_white"];
    [self Create_collectionView];
    [self Create_data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI
- (void)Create_collectionView
{
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view).offset(0);
        make.top.mas_equalTo(self.view).offset(20);
    }];
    
    /* 注册collectionView头视图 */
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:KcollectionHeaderView];
}

#pragma mark - Data
- (void)Create_data
{
    self.dataArray = @[@"绑卡",
                       @"转账",
                       @"支付",
                       @"充值"
                       ];
}

#pragma mark - UICollectionViewDelegate&&DataSourceDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     NIST_HomeCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:KHomePageCollectionViewCell forIndexPath:indexPath];
    cell.titleLab.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NIST_TiedCardController * tiedCard_VC = [[NIST_TiedCardController alloc]init];
        [self.navigationController pushViewController:tiedCard_VC animated:YES];
    }
    if (indexPath.row == 1)
    {
        NIST_TransferController * transfer_VC = [[NIST_TransferController alloc]init];
        transfer_VC.User_ID = self.user_name;
        [self.navigationController pushViewController:transfer_VC animated:YES];
    }
    if (indexPath.row == 2)
    {
        NIST_PayController * pay_VC = [[NIST_PayController alloc]init];
        [self.navigationController pushViewController:pay_VC animated:YES];
    }
    if (indexPath.row == 3)
    {
        NIST_RechargeController * recharge_VC = [[NIST_RechargeController alloc]init];
        [self.navigationController pushViewController:recharge_VC animated:YES];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView * reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:KcollectionHeaderView forIndexPath:indexPath];
        reusableView.backgroundColor = [UIColor whiteColor];
        self.collectionHeaderView = reusableView;
        [self Connection];
        return reusableView;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Private
- (void)Connection
{
    NIST_HeadView * headView = [[NIST_HeadView alloc]init];
    [self.collectionHeaderView addSubview:headView];
    self.headView = headView;
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-40);
    }];
}

#pragma mark - Lazy

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        /* 初始化layout */
        _layout = [[UICollectionViewFlowLayout alloc]init];
        /* 内边距 */
        _layout.sectionInset = UIEdgeInsetsMake(30, (SCREEN_WIDTH - 160)/3, 30, (SCREEN_WIDTH - 160)/3);
        /* 设置单元格宽度和高度 */
        _layout.itemSize = CGSizeMake(80, 80);
        /* 设置layout头视图 */
        _layout.headerReferenceSize=CGSizeMake(self.view.frame.size.width, 100);
        /* 设置滑动方向 */
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        /* 初始化collectionview */
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
        /* 代理 */
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        /* 背景色 */
        _collectionView.backgroundColor = [UIColor whiteColor];
        /* 注册cell */
        [_collectionView registerClass:[NIST_HomeCollectionCell class] forCellWithReuseIdentifier:KHomePageCollectionViewCell];
    }
    return _collectionView;
}

@end
