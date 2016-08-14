//
//  RFTableViewController.h
//  ECUtils
//
//  Created by kiri on 15/1/2.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFViewController.h"
#import "RFSection.h"

#define kTagLoadMore    -1

@interface RFTableViewController : RFViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

// drag to refresh
@property (nonatomic) BOOL showRefreshControl;
@property (strong, readonly, nonatomic) UIRefreshControl *refreshControl;

// Default is YES. If YES, tableView will not reload until scoll stopped.
@property (nonatomic) BOOL defersReloadTable;

#pragma mark - LoadMore
@property (nonatomic) BOOL shouldLoadMore;
- (void)loadMore;

#pragma mark - Reload
// for custom table animation.
- (void)reloadDataWithoutUI;
// build tags and reload tableview.
- (void)reloadData;

#pragma mark - Tag Operations
@property (strong, nonatomic) NSArray *sections;
- (RFSection *)setRows:(NSArray *)rows forSection:(NSInteger)section;
- (RFSection *)sectionAtIndex:(NSInteger)index;
- (RFRow *)rowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - for code generated Util
- (BOOL)shouldCreateTableViewAutomatically;

#pragma mark - Delegate Implementation
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - for override
- (void)tableViewDidReload;

#pragma mark - Refresh
- (IBAction)tableViewDidRefresh:(id)sender;
- (void)endRefreshing;

#pragma mark - MultiTableView
- (RFRow *)rowAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
- (NSArray<RFSection *> *)sectionsForTableView:(UITableView *)tableView;

@end
