//
//  MKTagLabel.h
//  MKTagEditor
//
//  Created by milker on 16/5/12.
//  Copyright © 2016年 milker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKTagView.h"

@class MKTagLabel;

@interface MKTagItem : UIView
@property(nonatomic, strong) MKTagLabel *label;
@property(nonatomic, assign) MKTagStyle style;
@property(nonatomic) UIEdgeInsets padding;
@property(nonatomic, assign) id<MKTagViewDelegate> tagviewDelegate;
@property(nonatomic, copy) NSString *text;
@end

@interface MKTagLabel : UITextField<UITextFieldDelegate>
@property(nonatomic, assign) MKTagStyle style;
@property(nonatomic) UIEdgeInsets padding;
@property(nonatomic, assign) id<MKTagViewDelegate> tagviewDelegate;
- (void)deleteMe:(id)sender;
@end


@interface MKTabView : UIView

@end