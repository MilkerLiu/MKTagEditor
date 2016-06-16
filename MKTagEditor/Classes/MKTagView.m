//
//  MKTagView.m
//  MKTagEditor
//
//  Created by milker on 16/5/12.
//  Copyright © 2016年 milker. All rights reserved.
//

#import "MKTagView.h"
#import "MKTagItem.h"

#define kMKDefaultColor [UIColor colorWithRed:0.38 green:0.72 blue:0.91 alpha:1]
#define kMKTextColor [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1]

@interface MKTagView()<UITextFieldDelegate, MKTagViewDelegate>

@end

@implementation MKTagView

- (instancetype)init {
    self = [super init];
    // default style, you can set new style
    self.tagFontSize = 12;
    self.tagSpace = 10; 
    self.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    self.tagTextPadding = UIEdgeInsetsMake(3, 5, 3, 5);
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(autoAddEdtingTag)]];
    return self;
}

- (void)addTag:(NSString *)tag {
    if([self isEmptyString:tag]) {
        return;
    }
    if([self isExistTag:tag]) {
        return;
    }
    CGRect frame = CGRectZero;
    if(self.subviews && self.subviews.count > 0) {
        frame = [self.subviews lastObject].frame;
    }
    MKTagItem *label = [self createTagWithStyle:(self.editable ? MKTagStyleEditable : MKTagStyleShow) tag:tag];
    label.frame = CGRectMake(frame.origin.x, frame.origin.y, label.frame.size.width, label.frame.size.height);
    if(self.editable) {
        [self insertSubview:label belowSubview:[self.subviews lastObject]];
    } else {
        [self addSubview:label];
    }
}

- (void)addTags:(NSArray *)tags {
    for(NSString *tag in tags) {
        [self addTag:tag];
    }
}

- (void)removeTag:(NSString *)tagString {
    for(MKTagLabel *tag in self.subviews) {
        if([self stringIsEquals:tag.text to:tagString]) {
            [tag removeFromSuperview];
            [self.delegate mkTagView:self onRemove:tag];
        }
    }
}

- (void)removeTags:(NSArray *)tags {
    for(NSString *tag in tags) {
        [self removeTag:tag];
    }
}

- (void)selectTag:(NSString *)tag {
    [self.subviews indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(MKTagItem *obj, NSUInteger idx, BOOL *stop) {
        if([self stringIsEquals:obj.text to:tag]) {
            [obj setStyle:self.editable ? MKTagStyleEditSelected : MKTagStyleShowSelected];
            return YES;
        }
        return NO;
    }];
}

- (void)selectTags:(NSArray *)tags {
    for(NSString *tag in tags) {
        [self selectTag:tag];
    }
}

- (void)unSelectTag:(NSString *)tag {
    [self.subviews indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(MKTagLabel *obj, NSUInteger idx, BOOL *stop) {
        if([self stringIsEquals:obj.text to:tag]) {
            [obj setStyle:self.editable ? MKTagStyleEditable : MKTagStyleShow];
            return YES;
        }
        return NO;
    }];
}

- (void)unSelectTags:(NSArray *)tags {
    for(NSString *tag in tags) {
        [self unSelectTag:tag];
    }
}

- (void)setEditable:(BOOL)editable {
    if(_editable == editable) {
        return;
    }
    _editable = editable;
    
    // update sub tags style
    for(MKTagItem *tagItem in self.subviews) {
        [tagItem setStyle:_editable ? MKTagStyleEditable : MKTagStyleShow];
    }
    
    if(_editable) {
        MKTagItem *v = [self.subviews lastObject];
        if(!v || v.style != MKTagStyleEditing) {
            // if has no edit style tag, add one
            MKTagItem *label = [self createTagWithStyle:MKTagStyleEditing tag:@"输入标签"];
            label.label.placeholder = @"输入标签";
            label.text = nil;
            [self addSubview:label];
        }
    } else {
        MKTagLabel *v = [self.subviews lastObject];
        if(v && v.style == MKTagStyleEditing) {
            [v removeFromSuperview];
        }
    }
}

- (MKTagItem *)createTagWithStyle:(MKTagStyle)style tag:(NSString *)tag {
    MKTagItem *label = [[MKTagItem alloc] init];
    label.tagviewDelegate = self;
    label.padding = self.tagTextPadding;
    label.text = tag;
    label.label.font = [UIFont systemFontOfSize:self.tagFontSize];
    [label sizeToFit];
    [label setStyle:style];
    return label;
}


- (void)layoutSubviews {
    [UIView beginAnimations:nil context:nil];
    CGFloat paddingRight = self.padding.right;
    CGFloat cellspace = 5;
    CGFloat y = self.padding.top;
    CGFloat x = self.padding.left;
    CGRect frame;
    for(UIView *tag in self.subviews) {
        frame = tag.frame;
        frame.origin.x = x;
        frame.origin.y = y;
        
        if(frame.origin.x + frame.size.width + paddingRight > self.frame.size.width) {
            // 换行
            frame.origin.x = self.padding.left;
            frame.origin.y = frame.origin.y + frame.size.height + cellspace;
            
            y = frame.origin.y;
        }
        
        if(frame.origin.x + frame.size.width > self.frame.size.width - paddingRight) {
            frame.size.width = self.frame.size.width - paddingRight - frame.origin.x;
        }
        
        x = frame.origin.x + frame.size.width + cellspace;
        tag.frame = frame;
    }
    CGFloat containerHeight = frame.origin.y + frame.size.height + self.padding.bottom;
    CGRect containerFrame = self.frame;
    containerFrame.size.height = containerHeight;
    self.frame = containerFrame;
    if([self.delegate respondsToSelector:@selector(mkTagView:sizeChange:)]) {
        [self.delegate mkTagView:self sizeChange:self.frame];
    }
    [UIView commitAnimations];
}

- (NSArray *)allTags {
    NSMutableArray *tags = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for(MKTagItem *tagItem in self.subviews) {
        if(tagItem.style != MKTagStyleEditing) {
            [tags addObject:tagItem.text];
        }
    }
    return tags;
}

- (void)autoAddEdtingTag {
    MKTagItem *tag = [self.subviews lastObject];
    if(tag.style == MKTagStyleEditing) {
        NSString *tagString = tag.text;
        if(![self isEmptyString:tagString]) {
            [self addTag:tagString];
            tag.text = nil;
        }
    }
}

#pragma mark - self delegate

// default style, if user don't implement style deledate
- (void)mkTagView:(MKTagView *)tag editableStyle:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:editableStyle:)]) {
        [self.delegate mkTagView:self editableStyle:tagLabel];
    } else {
        tagLabel.backgroundColor = [UIColor whiteColor];
        tagLabel.textColor = kMKDefaultColor;
        tagLabel.layer.borderColor = [kMKDefaultColor CGColor];
        tagLabel.layer.borderWidth = 1;
        tagLabel.layer.cornerRadius = tagLabel.frame.size.height / 2;
    }
}
- (void)mkTagView:(MKTagView *)tag editingStyle:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:editableStyle:)]) {
        [self.delegate mkTagView:self editingStyle:tagLabel];
    } else {
        tagLabel.backgroundColor = [UIColor clearColor];
        tagLabel.textColor = [UIColor blackColor];
        tagLabel.layer.borderColor = [[UIColor clearColor] CGColor];
        tagLabel.layer.borderWidth = 0;
        tagLabel.layer.cornerRadius = 0;
    }
}
- (void)mkTagView:(MKTagView *)tag editSelectedStyle:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:editableStyle:)]) {
        [self.delegate mkTagView:self editSelectedStyle:tagLabel];
    } else {
        tagLabel.backgroundColor = kMKDefaultColor;
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.layer.borderColor = [kMKDefaultColor CGColor];
        tagLabel.layer.borderWidth = 1;
        tagLabel.layer.cornerRadius = tagLabel.frame.size.height / 2;
    }
}
- (void)mkTagView:(MKTagView *)tag showSelectedStyle:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:editableStyle:)]) {
        [self.delegate mkTagView:self showSelectedStyle:tagLabel];
    } else {
        tagLabel.backgroundColor = kMKDefaultColor;
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.layer.borderColor = [kMKDefaultColor CGColor];
        tagLabel.layer.borderWidth = 1;
        tagLabel.layer.cornerRadius = tagLabel.frame.size.height / 2;
    }
}
- (void)mkTagView:(MKTagView *)tag showStyle:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:editableStyle:)]) {
        [self.delegate mkTagView:self showStyle:tagLabel];
    } else {
        tagLabel.backgroundColor = [UIColor whiteColor];
        tagLabel.textColor = kMKTextColor;
        tagLabel.layer.borderColor = [kMKTextColor CGColor];
        tagLabel.layer.borderWidth = 1;
        tagLabel.layer.cornerRadius = 10;
    }
}
// default style end

- (void)mkTagView:(MKTagView *)tag deleteOnEmpty:(MKTagLabel *)tagLabel {
    if(self.subviews.count == 1) {
        return;
    }
    MKTagLabel *selectedTag = [self.subviews objectAtIndex:self.subviews.count - 2];
    if(selectedTag.style == MKTagStyleEditable) {
        selectedTag.style = MKTagStyleEditSelected;
    } else if(selectedTag.style == MKTagStyleEditSelected) {
        NSString *tagString = selectedTag.text;
        [self removeTag:tagString];
        if([self.delegate respondsToSelector:@selector(mkTagView:onRemove:)]) {
            [self.delegate mkTagView:self onRemove:tagLabel];
        }
    }
}

- (void)mkTagView:(MKTagView *)tagview returnOnNotEmpty:(MKTagLabel *)tagLabel {
    [self autoAddEdtingTag];
}

- (void)mkTagView:(MKTagView *)tagview onSelect:(MKTagLabel *)tagLabel {
    if([self.delegate respondsToSelector:@selector(mkTagView:onSelect:)]) {
        [self.delegate mkTagView:self onSelect:tagLabel];
    }
}

- (void)mkTagView:(MKTagView *)tagview onRemove:(MKTagLabel *)tagLabel {
    [self removeTag:tagLabel.text];
    if([self.delegate respondsToSelector:@selector(mkTagView:onRemove:)]) {
        [self.delegate mkTagView:self onRemove:tagLabel];
    }
}

#pragma mark - Tool Functions

- (BOOL)isExistTag:(NSString *)tag {
    if(!self.subviews || self.subviews.count == 0) {
        return NO;
    }
    __block BOOL isExist = NO;
    NSUInteger len = self.editable ? (self.subviews.count - 1) : self.subviews.count;
    [[self.subviews subarrayWithRange:NSMakeRange(0, len)] indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(MKTagLabel *obj, NSUInteger idx, BOOL *stop) {
        isExist = [self stringIsEquals:obj.text to:tag];
        return isExist;
    }];
    return isExist;
}

- (BOOL)isEmptyString:(NSString *)string {
    if(!string){
        return NO;
    }
    string = [string stringByTrimmingCharactersInSet:
              [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string.length == 0;
}

- (BOOL)stringIsEquals:(NSString *)string to:(NSString *)string2 {
    return [string isEqualToString:string2];
}

@end