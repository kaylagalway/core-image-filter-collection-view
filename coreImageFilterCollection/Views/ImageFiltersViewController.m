//
//  ImageFiltersViewController.m
//  coreImageFilterCollection
//
//  Created by Kayla Galway on 4/12/17.
//  Copyright © 2017 Kayla Galway. All rights reserved.
//

#import "ImageFiltersViewController.h"
#import <Photos/Photos.h>

@interface ImageFiltersViewController ()

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) ImageCollectionViewModel *viewModel;

@end

@implementation ImageFiltersViewController

- (void)viewDidLoad {
   [super viewDidLoad];
   self.view.backgroundColor = [UIColor whiteColor];
   [self setUpCollectionView];
   [self setUpFlowLayout];
   [self setUpViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
   [self addBarButtons];
}

//add change observers?

- (void)addBarButtons {
   UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Filter" style:UIBarButtonItemStylePlain target:self action:@selector(filterButtonTapped:)];
   [self.navigationItem setRightBarButtonItem:filterButton animated:YES];
   self.navigationController.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
   
   UIBarButtonItem *removeFilterButton = [[UIBarButtonItem alloc]initWithTitle:@"Remove Filter" style:UIBarButtonItemStylePlain target:self action:@selector(removeAllFilters:)];
   [self.navigationItem setLeftBarButtonItem:removeFilterButton animated:YES];
}

//triggered when right bar button item tapped
- (void)filterButtonTapped:(id)sender {
   [self showFilterActionSheet];
}

//triggered when left bar button item tapped
- (void)removeAllFilters:(id)sender {
   self.viewModel.selectedFilter = noFilter;
   [self.collectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   ImageCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
   return cell;
}

//ImageCollectionViewModel delegate method
//fired with image loaded from image manager
- (void)didFetchImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath {
   ImageCollectionCell *cell = (ImageCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
   cell.imageView.image = image;
   [cell.activityIndicator stopAnimating];
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
   CGFloat screenScale = UIScreen.mainScreen.scale;
   CGSize cellSize = self.flowLayout.itemSize;
   self.viewModel.thumbnailSize = CGSizeMake(cellSize.width * screenScale, cellSize.height * screenScale);
   [self.viewModel imageForIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
   [self.viewModel cancelFilterApplicationToImageAtIndexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return [self.viewModel numberOfItemsInSection:section];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
   return 1;
}

- (void)setUpCollectionView {
   self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
   self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.flowLayout];
   self.collectionView.backgroundColor = [UIColor whiteColor];
   [self.collectionView setDataSource:self];
   [self.collectionView setDelegate:self];
   [self.collectionView registerClass:[ImageCollectionCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
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

- (void)setUpViewModel {
   self.viewModel = [[ImageCollectionViewModel alloc]init];
   [self.viewModel fetchAllImages];
   self.viewModel.delegate = self;
}

- (void)showFilterActionSheet {
   UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Filters" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
   [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
   }]];
   NSArray *filterTitles = @[@"Monochrome", @"Invert", @"Noir", @"Sepia", @"Fade"];
   for (NSInteger i = 0; i < [filterTitles count]; i++) {
      [actionSheet addAction:[UIAlertAction actionWithTitle:filterTitles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         switch (i) {
            case 0:
               self.viewModel.selectedFilter = monochrome;
               break;
            case 1:
               self.viewModel.selectedFilter = invert;
               break;
            case 2:
               self.viewModel.selectedFilter = noir;
               break;
            case 3:
               self.viewModel.selectedFilter = sepia;
               break;
            case 4:
               self.viewModel.selectedFilter = fade;
               break;
            default:
               break;
         }
         [self.collectionView reloadData];
      }]];
   }
   [self presentViewController:actionSheet animated:true completion:nil];
}




@end
