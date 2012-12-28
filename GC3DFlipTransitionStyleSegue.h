//
//  This code is distributed under the terms and conditions of the zlib license.
//
//  Copyright (c) 2013 Glenn Chiu
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <UIKit/UIKit.h>

#define IMAGE_NAME  @"wood"
#define IMAGE_TYPE  @"jpg"

extern float kGC3DFlipTransitionStyle_Horizontal;
extern float kGC3DFlipTransitionStyle_iTunesU;
extern float kGC3DFlipTransitionStyle_iBooks;

@interface GC3DFlipTransitionStyleSegue : UIStoryboardSegue

@property (assign, nonatomic) float depth;
@property (assign, nonatomic) BOOL disableLightEffect;
@property (assign, nonatomic) BOOL disableMultisampling;

@end
