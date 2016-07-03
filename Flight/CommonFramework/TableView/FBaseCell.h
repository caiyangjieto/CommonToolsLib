//
//  FBaseCell.h
//  Pods
//
//  Created by caiyangjieto on 16/2/23.
//
//

#import <UIKit/UIKit.h>

@class FBaseCellModel;

@interface FBaseCell : UITableViewCell

@property (nonatomic ,strong) FBaseCellModel  *displayInfo;

@end



@interface FBaseCellModel : NSObject

@property (nonatomic, strong) NSString  *cellType;
@property (nonatomic ,assign) CGFloat   cellHeight;
@property (nonatomic, assign) BOOL      hasRead;      //是否已读

@property (nonatomic, weak)   id		modelClass;   //本model数据从哪个ModelClass来

@end