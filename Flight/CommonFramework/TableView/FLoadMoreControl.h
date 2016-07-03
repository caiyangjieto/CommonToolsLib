//
//  FLoadMoreControl.h
//



#import <UIKit/UIKit.h>

@interface FLoadMoreControl : UIButton

@property (nonatomic, strong) NSString *normalText;      // 还未触发默认文案
@property (nonatomic, strong) NSString *loadingText;     // 加载中...文案
@property (nonatomic, strong) NSString *pullingtext;     // 拖动到达触发时文案

- (id)initWithFrame:(CGRect)frame attachedView:(UITableView *)tableView;

- (void)startLoading;
- (void)stopLoading;
- (void)failLoading;

@end
