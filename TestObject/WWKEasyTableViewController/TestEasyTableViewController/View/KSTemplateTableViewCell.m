//
//  KSTemplateTableViewCell.m
//  gifMerchantModule
//
//  Created by fengchiwei on 2020/11/16.
//  Copyright © 2020年 tencent. All rights reserved.
//

#import "KSTemplateTableViewCell.h"

@interface KSTemplateTableViewCell ()

@property (nonatomic, strong) UILabel *customNameLabel;

@end

//------------------------------------------------------------------------------------------------
@implementation KSTemplateTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor blueColor];

        _customNameLabel = [[UILabel alloc] init];
        _customNameLabel.backgroundColor = [UIColor clearColor];
        _customNameLabel.font = [UIFont systemFontOfSize:15];
        _customNameLabel.textColor = [UIColor redColor];
        [self.contentView addSubview:_customNameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [_customNameLabel sizeToFit];
    _customNameLabel.frame = CGRectMake(0, 0, _customNameLabel.bounds.size.width, _customNameLabel.bounds.size.height);
}

- (void)updateWithData:(KSTemplateListItem *)item {
    NSMutableString *roomName = [NSMutableString stringWithFormat:@"%d", item.customId];
    roomName = [NSMutableString stringWithFormat:@"小店 %@", roomName];

    _customNameLabel.text = roomName;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}



+ (CGFloat)cellHeight{
    return 80.0;
}

@end
