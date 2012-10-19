//
//  AccountOpenPhoto
//  Photo
//
//  Created by Patrick Santana on 06/03/12.
//  Copyright 2012 Photo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

@interface AccountOpenPhoto : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *clientToken;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *userToken;
@property (nonatomic, strong) NSString *userSecret;


- (void) saveToStandardUserDefaults;

@end
