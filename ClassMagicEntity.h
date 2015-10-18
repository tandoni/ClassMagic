//
//  ClassMagicEntity.h
//  ClassMagic
//
//  Created by Ishank Tandon on 10/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ClassMagicEntity : NSManagedObject

@property (nonatomic, retain) NSDate * lastTouchDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString* notes;

@end
