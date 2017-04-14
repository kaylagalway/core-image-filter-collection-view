//
//  ImageFiltersViewController.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageFiltersViewController.h"
#import <Photos/Photos.h>

NSString *const FilterTitle_Monochrome = @"Monochrome";
NSString *const FilterTitle_Invert = @"Invert";
NSString *const FilterTitle_Noir = @"Noir";
NSString *const FilterTitle_Sepia = @"Sepia";
NSString *const FilterTitle_Fade = @"Fade";
NSString *const ActionTitle_Cancel = @"Cancel";
NSString *const ActionTitle_Filter = @"Filters";
NSString *const Cell_Identifier = @"cellIdentifier";
NSString *const BarButtonItem_AddFilter = @"Add Filter";
NSString *const BarButtonItem_RemoveFilter = @"Remove Filter";

@interface ImageFiltersViewController ()

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) ImageCollectionViewModel *viewModel;
@property (strong, nonatomic) UILabel *noAccessLabel;

@end

@implementation ImageFiltersViewController

//MARK: Lifecycle

- (void)viewDidLoad {
   [super viewDidLoad];
   self.view.backgroundColor = [UIColor whiteColor];
   [self setUpCollectionView];
   [self setUpFlowLayout];
   [self setUpViewModel];
   [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
   [self addBarButtons];
}

//MARK: Imperitives

- (void)setUpViewModel {
   if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
      self.noAccessLabel.alpha = 0;
      self.viewModel = [[ImageCollectionViewModel alloc]init];
      self.viewModel.delegate = self;
      [self.viewModel fetchAllImageAssets];
   } else {
      [self showNoAccessLabel];
   }
}

- (void)setUpCollectionView {
   self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
   self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
   self.collectionView.backgroundColor = [UIColor whiteColor];
   [self.collectionView setDataSource:self];
   [self.collectionView setDelegate:self];
   [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:Cell_Identifier];
   [self.view addSubview:self.collectionView];
}

- (void)setUpFlowLayout {
   CGFloat halvedWidthOfCollection = floor(self.collectionView.frame.size.width / 2);
   CGFloat itemPadding = 10.0;
   CGFloat collectionItemSize = halvedWidthOfCollection - itemPadding;
   self.flowLayout.itemSize = CGSizeMake(collectionItemSize, collectionItemSize);
   CGFloat margin = (self.collectionView.frame.size.width - (collectionItemSize * 2)) / 3;
   self.flowLayout.minimumInteritemSpacing = margin;
   self.flowLayout.minimumLineSpacing = margin;
   self.flowLayout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
}

- (void)addBarButtons {
   UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:BarButtonItem_AddFilter style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTapped:)];
   [self.navigationItem setRightBarButtonItem:filterButton animated:YES];
   self.navigationController.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
   
   UIBarButtonItem *removeFilterButton = [[UIBarButtonItem alloc]initWithTitle:BarButtonItem_RemoveFilter style:UIBarButtonItemStylePlain target:self action:@selector(removeAllFilters:)];
   [self.navigationItem setLeftBarButtonItem:removeFilterButton animated:YES];
}

- (void)removeAllFilters:(id)sender {
   self.viewModel.selectedFilter = noFilter;
   [self.collectionView reloadData];
}

- (void)showFilterActionSheet {
   UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle: ActionTitle_Filter message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   [actionSheet addAction:[UIAlertAction actionWithTitle: ActionTitle_Cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
   }]];
   NSArray *filterTitles = @[FilterTitle_Monochrome, FilterTitle_Invert, FilterTitle_Noir, FilterTitle_Sepia, FilterTitle_Fade];
   for (NSInteger i = 0; i < [filterTitles count]; i++) {
      [actionSheet addAction:[UIAlertAction actionWithTitle:filterTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         [self.viewModel didSelectFilterAtIndex:i];
         [self.collectionView reloadData];
      }]];
   }
   [self presentViewController:actionSheet animated:true completion:nil];
}

- (void)showNoAccessLabel {
   self.noAccessLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
   self.noAccessLabel.text = @"Allow Photo Access in Settings";
   self.noAccessLabel.textAlignment = NSTextAlignmentCenter;
   self.noAccessLabel.lineBreakMode = NSLineBreakByWordWrapping;
   self.noAccessLabel.translatesAutoresizingMaskIntoConstraints = NO;
   [self.view addSubview:self.noAccessLabel];
}

//MARK: ImageCollectionViewModel Delegate

- (void)didFetchPhotoAssets {
   [self.collectionView reloadData];
}

- (void)didFetchImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath {
   ImageCollectionCell *cell = (ImageCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
   [cell.activityIndicator stopAnimating];
   cell.imageView.image = image;
}

//MARK: PHPhotoLibraryChangeObserver delegate

-(void)photoLibraryDidChange:(PHChange *)changeInstance {
   [self setUpViewModel];
}

//MARK: Interaction

- (void)filterButtonTapped:(id)sender {
   [self showFilterActionSheet];
}

//MARK: Collection View Data Source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: Cell_Identifier forIndexPath:indexPath];
   return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return [self.viewModel numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

//MARK: Collection View Delegate

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
   CGFloat screenScale = UIScreen.mainScreen.scale;
   CGSize cellSize = self.flowLayout.itemSize;
   self.viewModel.thumbnailSize = CGSizeMake(cellSize.width * screenScale, cellSize.height * screenScale);
   [self.viewModel imageForIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
   [self.viewModel cancelFilterApplicationToImageAtIndexPath:indexPath];
}

@end

