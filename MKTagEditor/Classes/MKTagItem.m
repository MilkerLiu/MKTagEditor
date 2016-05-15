//
//  MKTagLabel.m
//  MKTagEditor
//
//  Created by milker on 16/5/12.
//  Copyright © 2016年 mikler. All rights reserved.
//

#import "MKTagItem.h"

@implementation MKTagItem {
    UIView *eventHolder;
}

- (instancetype)init {
    self = [super init];
    
    self.label = [[MKTagLabel alloc] init];
    [self addSubview:self.label];
    
    eventHolder = [MKTabView new];
    [eventHolder setBackgroundColor:[UIColor clearColor]];
    [self addSubview:eventHolder];
    
    [eventHolder addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTabEvent)]];
    
    return self;
}

- (void)handleTabEvent {
    if(self.style == MKTagStyleEditable) {
        [eventHolder becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:eventHolder.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        [self.label.tagviewDelegate mkTagView:nil onSelect:self.label];
    }
}

- (void)delete:(id)sender {
    if(self.style == MKTagStyleEditing) {
        return;
    }
    [self.label deleteMe:sender];
}

- (void)setTagviewDelegate:(id<MKTagViewDelegate>)tagviewDelegate {
    self.label.tagviewDelegate = tagviewDelegate;
}

- (void)setPadding:(UIEdgeInsets)padding {
    self.label.padding = padding;
}

- (MKTagStyle)style {
    return self.label.style;
}

- (void)setStyle:(MKTagStyle)style {
    self.label.style = style;
    if(self.label.style == MKTagStyleEditing) {
        [eventHolder removeFromSuperview];
    }
}

- (NSString *)text {
    return self.label.text;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect labelFrame = self.label.frame;
    labelFrame.size = frame.size;
    self.label.frame = labelFrame;
}

- (void)sizeToFit {
    [self.label sizeToFit];
    CGRect frame = self.label.frame;
    CGRect myFrame = self.frame;
    myFrame.size = frame.size;
    self.frame = myFrame;
    eventHolder.frame = frame;
}

@end

#pragma mark - DDTagLabel

@implementation MKTagLabel

- (instancetype)init {
    self = [super init];
    self.textAlignment = NSTextAlignmentCenter;
    self.enabled = NO;
    self.delegate = self;
    return self;
}

- (void)setStyle:(MKTagStyle)style {
    _style = style;
    switch (style) {
        case MKTagStyleEditable: {
            [self.tagviewDelegate mkTagView:nil editableStyle:self];
            break;
        }
        case MKTagStyleEditing: {
            self.enabled = YES;
            [self.tagviewDelegate mkTagView:nil editingStyle:self];
            break;
        }
        case MKTagStyleEditSelected: {
            [self.tagviewDelegate mkTagView:nil editSelectedStyle:self];
            break;
        }
        case MKTagStyleShow: {
            [self.tagviewDelegate mkTagView:nil showStyle:self];
            break;
        }
        case MKTagStyleShowSelected: {
            [self.tagviewDelegate mkTagView:nil showSelectedStyle:self];
            break;
        }
    }
}

- (void)deleteBackward {
    [super deleteBackward];
    if(!self.text || self.text.length == 0) {
        [self.tagviewDelegate mkTagView:nil deleteOnEmpty:self];
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.padding.left,
                      bounds.origin.y + self.padding.top,
                      bounds.size.width - self.padding.right - self.padding.left,
                      bounds.size.height - self.padding.bottom - self.padding.bottom);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.text) {
        [self.tagviewDelegate mkTagView:nil returnOnNotEmpty:self];
    }
    return YES;
}

- (void)deleteMe:(id)sender {
    [self.tagviewDelegate mkTagView:nil onRemove:self];
}
@end

@implementation MKTabView
- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end