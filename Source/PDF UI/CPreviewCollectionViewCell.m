//
//  CPreviewCollectionViewCell.m
//  PDFReader
//
//  Created by Jonathan Wight on 6/30/13.
//  Copyright (c) 2013 toxicsoftware.com. All rights reserved.
//

#import "CPreviewCollectionViewCell.h"

@implementation CPreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // size
        self.frame = CGRectMake(0, 0, 95, 134);
        
        // image view
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = self.frame;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.viewForLastBaselineLayout addSubview:self.imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = selected ? 2.0 : 0.0;
}

@end
