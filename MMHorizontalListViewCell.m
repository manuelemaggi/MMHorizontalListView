//
//  MMHorizontalListViewCell.m
//  MMHorizontalListView
//
// Version 1.0
//
// Created by Manuele Maggi on 02/08/13.
// email: manuele.maggi@gmail.com
// Copyright (c) 2013-present Manuele Maggi. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MMHorizontalListViewCell.h"

@interface MMHorizontalListViewCell ()
@property (nonatomic, readwrite, assign) NSInteger index;
@property (nonatomic, readwrite, assign) BOOL selected;
@property (nonatomic, readwrite, assign) BOOL highlighted;
@end

@implementation MMHorizontalListViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    self.selected = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    self.highlighted = highlighted;
}

@end
