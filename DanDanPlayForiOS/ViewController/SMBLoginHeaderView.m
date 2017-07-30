//
//  SMBLoginHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBLoginHeaderView.h"

@interface SMBLoginHeaderView ()

@end

@implementation SMBLoginHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(10);
        }];
        
        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
        }];
    }
    return self;
}

- (void)touchAddButton:(UIButton *)sender {
    if (self.touchAddButtonCallback) {
        self.touchAddButtonCallback();
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [_addButton addTarget:self action:@selector(touchAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
    }
    return _addButton;
}

@end
