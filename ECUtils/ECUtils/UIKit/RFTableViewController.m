//
//  RFTableViewController.m
//  ECUtils
//
//  Created by kiri on 15/1/2.
//  Copyright (c) 2015年 kiri. All rights reserved.
//

#import "RFTableViewController.h"
#import "RFNibUtil.h"
#import "RFTableViewCell.h"
#import "RFTableViewCellDynamicHeight.h"
#import "ECLog.h"

@interface RFTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL privateLoadingMore;
@property (nonatomic) BOOL needReloadTable;
@property (nonatomic, strong) NSArray *innerTags;
@property (nonatomic, strong) NSArray *wrappedTags;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableDictionary *cacheForCalculatingMultilineCellHeight;

@end

@implementation RFTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.tableView == nil) {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                self.tableView = (UITableView *)view;
                break;
            }
        }
    }
    
    self.defersReloadTable = YES;
    
    if (self.tableView == nil && [self shouldCreateTableViewAutomatically]) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.f;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)_buildTags
{
    self.privateLoadingMore = NO;
    if (self.shouldLoadMore) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObjectsFromArray:self.sections];
        RFRow *loadMoreRow = [RFRow rowWithTag:kTagLoadMore data:nil className:@"RFLoadMoreCell"];
        loadMoreRow.dynamicHeight = NO;
        [array addObject:[RFSection sectionWithTag:kTagLoadMore rows:@[loadMoreRow]]];
        self.wrappedTags = array;
    } else {
        self.wrappedTags = [self.sections mutableCopy];
    }
}

- (void)reloadDataWithoutUI
{
    [self _buildTags];
    self.innerTags = [self.wrappedTags mutableCopy];
}

- (void)reloadData
{
    if (self.defersReloadTable && (self.tableView.isDragging || self.tableView.isDecelerating)) {
        self.needReloadTable = YES;
    } else {
        [self _buildTags];
        [self _reloadData];
    }
}

- (void)_reloadData
{
    self.needReloadTable = NO;
    self.innerTags = [self.wrappedTags mutableCopy];
    [self.tableView reloadData];
    [self tableViewDidReload];
}

- (void)setShouldLoadMore:(BOOL)shouldLoadMore
{
    if (shouldLoadMore != _shouldLoadMore) {
        _shouldLoadMore = shouldLoadMore;
        if (!shouldLoadMore && [(RFViewObject *)[self.sections lastObject] tag] == kTagLoadMore) {
            self.sections = [self.sections subarrayWithRange:NSMakeRange(0, self.sections.count - 1)];
        }
    }
}

- (void)tableViewDidReload
{
    
}

#pragma mark - Build UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return self.innerTags.count;
    } else {
        NSArray *sections = [self sectionsForTableView:tableView];
        return sections ? sections.count : 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self innerTagAtSection:section].rows.count;
    } else {
        NSArray *sections = [self sectionsForTableView:tableView];
        return section < sections.count ? [sections[section] rows].count : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RFRow *row = tableView == self.tableView ? [self innerTagAtIndexPath:indexPath] : [self rowAtIndexPath:indexPath forTableView:tableView];
    if (row.reuseIdentifier) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier];
        if (!cell) {
            cell = [self createCellWithRow:row];
        }
        [self prepareCell:cell withRow:row indexPath:indexPath];
        return cell;
    }
    ECLogDebug(@"nil!!!!!!\nindexPath = %@", indexPath);
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self innerTagAtSection:section].header;
    } else {
        NSArray<RFSection *> *sections = [self sectionsForTableView:tableView];
        if (section < sections.count) {
            return sections[section].header;
        }
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [self innerTagAtSection:section].footer;
    } else {
        NSArray<RFSection *> *sections = [self sectionsForTableView:tableView];
        if (section < sections.count) {
            return sections[section].footer;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (fabs(tableView.rowHeight) < __FLT_EPSILON__  && fabs(tableView.estimatedRowHeight) < __FLT_EPSILON__) {
        // not use autolayout.
        RFRow *row = [self innerTagAtIndexPath:indexPath];
        if (row.dynamicHeight) {
            return [self multilineCellHeightWithTableView:tableView indexPath:indexPath];
        } else {
            return 44.f;
        }
    }
    
    // autolayout
    if ([UIDevice currentDevice].systemVersion.floatValue < 8) {
        // in iOS7.x, autolayout has some problems.
        RFRow *row = [self innerTagAtIndexPath:indexPath];
        if (row.dynamicHeight) {
            return [self multilineCellHeightWithTableView:tableView indexPath:indexPath];
        }
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - Private
- (RFSection *)innerTagAtSection:(NSInteger)section
{
    if (section >= 0 && section < self.innerTags.count) {
        return [self.innerTags objectAtIndex:section];
    }
    return nil;
}

- (RFRow *)innerTagAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        return nil;
    }
    
    RFSection *sectionTag = [self innerTagAtSection:indexPath.section];
    NSInteger row = indexPath.row;
    if (sectionTag && row >= 0 && row < sectionTag.rows.count) {
        return [sectionTag.rows objectAtIndex:indexPath.row];
    }
    return nil;
}

#pragma mark - UITableView Actions
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Utils
- (RFSection *)sectionAtIndex:(NSInteger)section
{
    if (section >= 0 && section < self.sections.count) {
        return [self.sections objectAtIndex:section];
    }
    return nil;
}

- (RFRow *)rowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        return nil;
    }
    
    RFSection *sectionTag = [self sectionAtIndex:indexPath.section];
    NSInteger row = indexPath.row;
    if (sectionTag && row >= 0 && row < sectionTag.rows.count) {
        return [sectionTag.rows objectAtIndex:indexPath.row];
    }
    return nil;
}

- (RFSection *)setRows:(NSArray *)rowTags forSection:(NSInteger)section
{
    if (self.sections == nil) {
        self.sections = [NSMutableArray array];
    }
    
    if (self.sections.count <= section) {
        NSMutableArray *tags = [NSMutableArray array];
        [tags addObjectsFromArray:self.sections];
        for (NSInteger i = self.sections.count; i < section + 1; i++) {
            [tags addObject:[RFSection new]];
        }
        self.sections = tags;
    }
    
    RFSection *sectionTag = [self sectionAtIndex:section];
    sectionTag.rows = rowTags;
    return sectionTag;
}

#pragma mark - Load More
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        [self checkLoadMore];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        if (self.needReloadTable) {
            [self reloadData];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && scrollView == self.tableView) {
        if (self.needReloadTable) {
            [self reloadData];
        }
    }
}

- (void)checkLoadMore
{
    if (!self.shouldLoadMore) {
        self.privateLoadingMore = NO;
        return;
    }
    
    RFRow *lastVisibleTag = [self innerTagAtIndexPath:[self.tableView.indexPathsForVisibleRows lastObject]];
    
    if (lastVisibleTag && lastVisibleTag.tag == kTagLoadMore) {
        if (!self.privateLoadingMore) {
            self.privateLoadingMore = YES;
            [self loadMore];
        }
    } else {
        self.privateLoadingMore = NO;
    }
}

- (void)loadMore
{
    
}

#pragma mark - multiline
- (CGFloat)multilineCellHeightWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    RFRow *row = [self innerTagAtIndexPath:indexPath];
    NSString *reuseIdentifier = row.reuseIdentifier;
    
    // Use the dictionary of offscreen cells to get a cell for the reuse identifier, creating a cell and storing
    // it in the dictionary if one hasn't already been added for the reuse identifier.
    // WARNING: Don't call the table view's dequeueReusableCellWithIdentifier: method here because this will result
    // in a memory leak as the cell is created but never returned from the tableView:cellForRowAtIndexPath: method!
    RFTableViewCell *cell = [self.cacheForCalculatingMultilineCellHeight objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [self createCellWithRow:row];
        if (self.cacheForCalculatingMultilineCellHeight == nil) {
            self.cacheForCalculatingMultilineCellHeight = [NSMutableDictionary dictionary];
        }
        if (reuseIdentifier) {
            [self.cacheForCalculatingMultilineCellHeight setObject:cell forKey:reuseIdentifier];
        }
    }
    [self prepareCell:cell withRow:row indexPath:indexPath];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    // NOTE: if you are displaying a section index (e.g. alphabet along the right side of the table view), or
    // if you are using a grouped table view style where cells have insets to the edges of the table view,
    // you'll need to adjust the cell.bounds.size.width to be smaller than the full width of the table view we just
    // set it to above. See http://stackoverflow.com/questions/3647242 for discussion on the section index width.
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = cell.contentView.frame.size.height;// [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    if ([cell conformsToProtocol:@protocol(RFTableViewCellDynamicHeight)]) {
        height = [(id<RFTableViewCellDynamicHeight>)cell contentHeightAfterLayout];
    }
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    if (tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
        height += 1;
    }
    
    return height;
}

- (id)createCellWithRow:(RFRow *)row
{
    UITableViewCell *cell = nil;
    switch (row.source) {
        case RFRowSourceNib:
        {
            cell = [RFNibUtil loadObjectWithClass:[UITableViewCell class] fromNib:row.reuseIdentifier];
            break;
        }
        case RFRowSourceCreating:
        {
            cell = [[NSClassFromString(row.reuseIdentifier) alloc] initWithStyle:row.style reuseIdentifier:row.reuseIdentifier];
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)prepareCell:(UITableViewCell *)cell withRow:(RFRow *)row indexPath:(NSIndexPath *)indexPath
{
    if (cell == nil) {
        return;
    }
    
    if (row.accessoryType != RFRowAccessoryTypeNotDetermined) {
        cell.accessoryType = row.accessoryType;
    }
    if (row.selectionStyle != RFRowSelectionStyleNotDetermined) {
        cell.selectionStyle = row.selectionStyle;
    }
    
    if ([row isKindOfClass:[RFNativeRow class]]) {
        RFNativeRow *nativeRow = (RFNativeRow *)row;
        cell.textLabel.text = nativeRow.text;
        cell.detailTextLabel.text = nativeRow.detailText;
        cell.imageView.image = nativeRow.image;
    }
    
    if ([cell isKindOfClass:[RFTableViewCell class]]) {
        RFTableViewCell *actualCell = (RFTableViewCell *)cell;
        actualCell.indexPath = indexPath;
        actualCell.tableView = self.tableView;
        actualCell.row = row;
        if ([cell respondsToSelector:@selector(setDelegate:)] && [cell respondsToSelector:@selector(delegate)]) {
            id delegate = [cell performSelector:@selector(delegate)];
            if (delegate == nil) {
                [cell performSelector:@selector(setDelegate:) withObject:self];
            }
        }
        [actualCell prepareWithRow:row];
    }
}

#pragma mark - Code Support
- (BOOL)shouldCreateTableViewAutomatically
{
    return YES;
}

- (void)setShowRefreshControl:(BOOL)showRefreshControl
{
    if (_showRefreshControl != showRefreshControl) {
        _showRefreshControl = showRefreshControl;
        if (showRefreshControl) {
            self.refreshControl = [UIRefreshControl new];
            [self.refreshControl addTarget:self action:@selector(tableViewDidRefresh:) forControlEvents:UIControlEventValueChanged];
            [self.tableView addSubview:self.refreshControl];
            [self.tableView sendSubviewToBack:self.refreshControl];
        } else {
            [self.refreshControl removeFromSuperview];
            self.refreshControl = nil;
        }
    }
}

- (IBAction)tableViewDidRefresh:(id)sender
{
}

- (void)endRefreshing
{
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
    }
}

- (RFRow *)rowAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    if (indexPath == nil) {
        return nil;
    }
    
    if (tableView == self.tableView) {
        return [self rowAtIndexPath:indexPath];
    }
    
    NSArray *sections = [self sectionsForTableView:tableView];
    RFSection *sectionTag = indexPath.section < sections.count ? sections[indexPath.section] : nil;
    NSInteger row = indexPath.row;
    if (sectionTag && row >= 0 && row < sectionTag.rows.count) {
        return [sectionTag.rows objectAtIndex:indexPath.row];
    }
    return nil;
}

- (NSArray<RFSection *> *)sectionsForTableView:(UITableView *)tableView
{
    return tableView == self.tableView ? self.sections : nil;
}

@end
