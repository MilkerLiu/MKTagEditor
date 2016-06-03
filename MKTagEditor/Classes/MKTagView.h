//
//  MKTagView.h
//  MKTagEditor
//
//  Created by milker on 16/5/12.
//  Copyright © 2016年 milker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKTagView;
@class MKTagLabel;

typedef NS_ENUM(NSInteger, MKTagStyle) {
    MKTagStyleEditable,     // tag editor can edit, normal status
    MKTagStyleEditing,      // tag editor can edit, input status
    MKTagStyleEditSelected, // tag editor can edit, select status
    MKTagStyleShow,         // tag editor can't edit, normal status
    MKTagStyleShowSelected  // tag editor can't edit, select stauts
};

@protocol MKTagViewDelegate <NSObject>
@optional
// tagview size changed
- (void)mkTagView:(MKTagView *)tagview sizeChange:(CGRect)newSize;
// onselect tag, use tagLabel.style to judge label status
- (void)mkTagView:(MKTagView *)tagview onSelect:(MKTagLabel *)tagLabel;
// onremove a tag from tag view
- (void)mkTagView:(MKTagView *)tagview onRemove:(MKTagLabel *)tagLabel;

// custome label style
// MKTagView can edit, normal style
- (void)mkTagView:(MKTagView *)tagview editableStyle:(MKTagLabel *)tagLabel;
// MKTagView can edit, editing style
- (void)mkTagView:(MKTagView *)tagview editingStyle:(MKTagLabel *)tagLabel;
// MKTagView can edit, selected style
- (void)mkTagView:(MKTagView *)tagview editSelectedStyle:(MKTagLabel *)tagLabel;
// MKTagView can't edit, normal style
- (void)mkTagView:(MKTagView *)tagview showStyle:(MKTagLabel *)tagLabel;
// MKTagView can't edit, selected style
- (void)mkTagView:(MKTagView *)tagview showSelectedStyle:(MKTagLabel *)tagLabel;

// tag is empty & keyboard press DELETE, !!don't rewrite!!
- (void)mkTagView:(MKTagView *)tagview deleteOnEmpty:(MKTagLabel *)tagLabel;
// tag not empty & keyboard press RETURN !!don't rewrite!!
- (void)mkTagView:(MKTagView *)tagview returnOnNotEmpty:(MKTagLabel *)tagLabel;
@end

#pragma mark - MKTagView

@interface MKTagView : UIView

@property(nonatomic, assign) BOOL editable;// default is false, if true, editor has a input label, can delete
@property(nonatomic, assign) CGFloat tagSpace;// space between two tag, default is 10
@property(nonatomic, assign) CGFloat tagFontSize; // default is 12
@property(nonatomic) UIEdgeInsets padding; // container inner spacing, default is {10, 10, 10, 10}
@property(nonatomic) UIEdgeInsets tagTextPadding; // tag text inner spaces, default is {3, 5, 3, 5}

@property(nonatomic, assign) id<MKTagViewDelegate> delegate;

- (void)addTag:(NSString *)tag;
- (void)addTags:(NSArray *)tags;

- (void)removeTag:(NSString *)tag;
- (void)removeTags:(NSArray *)tags;

- (void)selectTag:(NSString *)tag;
- (void)selectTags:(NSArray *)tags;

- (void)unSelectTag:(NSString *)tag;
- (void)unSelectTags:(NSArray *)tags;

// you can monitor viewcontroller's view's tab event, call this function, and auto add the editing tag
- (void)autoAddEdtingTag;
- (NSArray *)allTags;

@end
