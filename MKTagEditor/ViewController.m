//
//  ViewController.m
//  MKTagEditor
//
//  Created by milker on 16/5/14.
//  Copyright © 2016年 milker. All rights reserved.
//

#import "ViewController.h"
#import "MKTagView.h"
#import "MKTagItem.h"

#define kMKScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMKScreenHeight [UIScreen mainScreen].bounds.size.height

static NSInteger EditorViewTag = 1;
static NSInteger SelectViewTag = 2;

@interface ViewController ()<MKTagViewDelegate>

@property(nonatomic, strong) MKTagView *tagEditor;
@property(nonatomic, strong) MKTagView *tagForSelect;

@property(nonatomic, strong) UIView *tagForSelectContainer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.tagEditor = [[MKTagView alloc] init];
    self.tagEditor.editable = YES;
    self.tagEditor.delegate = self;
    self.tagEditor.tag = EditorViewTag;
    self.tagEditor.backgroundColor = [UIColor whiteColor];
    self.tagEditor.frame = CGRectMake(0, 20, kMKScreenWidth, 0);
    [self.tagEditor addTags:@[@"111", @"222", @"333"]];
    [self.view addSubview:self.tagEditor];
    
    self.tagForSelectContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMKScreenWidth, kMKScreenHeight)];
    self.tagForSelectContainer.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    [self.view addSubview:self.tagForSelectContainer];

    self.tagForSelect = [[MKTagView alloc] init];
    self.tagForSelect.frame = CGRectMake(0, 0, kMKScreenWidth, 0);
    self.tagForSelect.delegate = self;
    self.tagForSelect.tag = SelectViewTag;
    self.tagForSelect.backgroundColor = [UIColor whiteColor];
    [self.tagForSelect addTags:@[@"777", @"888", @"999"]];
    [self.tagForSelectContainer addSubview:self.tagForSelect];

    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMKScreenWidth, 1)];
    divider.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    [self.tagForSelectContainer addSubview:divider];
}

#pragma mark - delegate functions

- (void)mkTagView:(MKTagView *)tagview sizeChange:(CGRect)newSize {
    CGRect frame = self.tagForSelectContainer.frame;
    frame.origin.y = tagview.frame.origin.y + tagview.frame.size.height;
    frame.size.height = kMKScreenHeight - frame.origin.y;
    self.tagForSelectContainer.frame = frame;
}

- (void)mkTagView:(MKTagView *)tagview onSelect:(MKTagLabel *)tagLabel {
    if(tagview.tag == SelectViewTag) {
        // please judge label status by yourself
        if(tagLabel.style == MKTagStyleShowSelected) {
            [self.tagEditor removeTag:tagLabel.text];
            [tagview unSelectTag:tagLabel.text];
        } else {
            [self.tagEditor addTag:tagLabel.text];
            [tagview selectTag:tagLabel.text];
        }
    }
}

- (void)mkTagView:(MKTagView *)tagview onRemove:(MKTagLabel *)tagLabel {
    if(tagview.tag == EditorViewTag) {
        [self.tagForSelect unSelectTag:tagLabel.text];
    }
}

// you can custom label style by youself, rewrite delegate functions
//- (void)mkTagView:(MKTagView *)tagview editableStyle:(MKTagLabel *)tagLabel {}
//- (void)mkTagView:(MKTagView *)tagview editingStyle:(MKTagLabel *)tagLabel {}
//- (void)mkTagView:(MKTagView *)tagview editSelectedStyle:(MKTagLabel *)tagLabel {}
//- (void)mkTagView:(MKTagView *)tagview showStyle:(MKTagLabel *)tagLabel {}
//- (void)mkTagView:(MKTagView *)tagview showSelectedStyle:(MKTagLabel *)tagLabel {}

@end
