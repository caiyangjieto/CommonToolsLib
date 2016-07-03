//
//  FLoadMoreControl.m
//
//

#import "FLoadMoreControl.h"

#define kTriggerOffset                              20.0
#define kFPullUpGetMoreTriggerHeight                20						// 触发上拉刷新的告诉

typedef enum
{
    LoadMoreControlStatusError = 0,  //错误状态
    LoadMoreControlStatusNormal = 1,
    LoadMoreControlStatusLoading,
    LoadMoreControlStatusPulling,
    
} SNLoadMoreControlStatus;


@interface FLoadMoreControl ()
{
    SNLoadMoreControlStatus  _status;
 
    CGFloat _lastOffset;
    BOOL _isDragged;
}

@property (nonatomic, weak) UITableView  *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end


@implementation FLoadMoreControl

- (id)initWithFrame:(CGRect)frame attachedView:(UITableView *)tableView
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _status = LoadMoreControlStatusNormal;
        _normalText = @"查看更多...";
        _pullingtext = @"松开立即加载";
        _loadingText = @"努力加载中...";
        
        _lastOffset = 0.0;
        _isDragged = NO;
        
        _tableView = tableView;
        
        [self setTitle:_normalText forState:UIControlStateNormal];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin;
        _indicatorView.hidesWhenStopped = YES;
        [_indicatorView stopAnimating];
        
        CGFloat x = CGRectGetWidth(self.bounds)/2.0/2.0-CGRectGetWidth(_indicatorView.bounds)/2.0;
        _indicatorView.center = CGPointMake(x, CGRectGetMidY(self.bounds));
        [self addSubview:_indicatorView];
        
        [self setTitleColor:[UIColor flightThemeColor] forState:UIControlStateNormal];
    }
    
    return self;
}

- (void)setNormalText:(NSString *)normalText
{
    _normalText = normalText;
    [self setTitle:normalText forState:UIControlStateNormal];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil)
    {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
    else
    {
        [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)startLoading
{
    if (_status == LoadMoreControlStatusLoading)
    {
        return;
    }
    
    [self setStatus:LoadMoreControlStatusLoading];
}

- (void)stopLoading
{
    [self setStatus:LoadMoreControlStatusNormal];
}

- (void)failLoading
{
    //仅仅改变文案为失败，逻辑走Normal
    [self stopLoading];
    
    [self setTitle:@"加载失败，请点击重试" forState:UIControlStateNormal];
}

- (void)setStatus:(SNLoadMoreControlStatus)status
{
    if (_status == status)
    {
        return;
    }
    
    _status = status;
    
    switch (_status)
    {
        case LoadMoreControlStatusNormal:
        {
            [self setTitle:_normalText forState:UIControlStateNormal];
            [_indicatorView stopAnimating];
        }
            break;
            
        case LoadMoreControlStatusLoading:
        {
            [self setTitle:_loadingText forState:UIControlStateNormal];
            [_indicatorView startAnimating];
        }
            break;
        case LoadMoreControlStatusPulling:
        {
            [self setTitle:_pullingtext forState:UIControlStateNormal];

        }
            break;
        default:
            break;
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    if (controlEvents == UIControlEventValueChanged)
    {
        [super addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [super addTarget:target action:action forControlEvents:controlEvents];
    }
}

- (void)setOffset:(CGFloat)offset isDragging:(BOOL)isDragging
{
    CGFloat triggerOffset = kFPullUpGetMoreTriggerHeight;
    CGFloat adjustedOffset = offset;
    CGFloat lastAdjustOffset = _lastOffset;
    if (_tableView.contentSize.height > CGRectGetHeight(_tableView.bounds))
    {
        adjustedOffset += CGRectGetHeight(_tableView.bounds);
        lastAdjustOffset += CGRectGetHeight(_tableView.bounds);
        triggerOffset += _tableView.contentSize.height;
    }
    
    if (adjustedOffset <= triggerOffset && lastAdjustOffset <= triggerOffset)
    {
        _isDragged = NO;
        _lastOffset = 0.0;
        
        [self setStatus:LoadMoreControlStatusNormal];
        return;
    }
    
    if (isDragging)
    {
        _lastOffset = offset;
        _isDragged = YES;
        [self setStatus:LoadMoreControlStatusPulling];
    }
    else if (_isDragged)
    {
        if (lastAdjustOffset > triggerOffset)
        {
            //[self setStatus:LoadMoreControlStatusLoading];
            //告诉action
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        else
        {
            [self setStatus:LoadMoreControlStatusNormal];
        }
        _lastOffset = 0.0;
        _isDragged = NO;
    }
    else
    {
        [self setStatus:LoadMoreControlStatusNormal];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"] && _status != LoadMoreControlStatusLoading && self.superview)
    {
        CGFloat newOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue].y;
        [self setOffset:newOffset isDragging:_tableView.isDragging];
    }
}


- (void)dealloc
{
    _tableView = nil;
}


@end
