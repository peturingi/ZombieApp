
//
//  Created by Pétur Ingi Egilsson on 17/11/13.
//  Copyright (c) 2013 Pétur Ingi Egilsson. All rights reserved.
//



#include <Foundation/Foundation.h>

#import "../dlib/bayes_utils.h"
#import "../dlib/graph_utils.h"
#import "../dlib/graph.h"
#import "../dlib/directed_graph.h"
using namespace dlib;
using namespace std;
using namespace bayes_node_utils;

typedef dlib::set<unsigned long>::compare_1b_c set_type;
typedef graph<set_type, set_type>::kernel_1a_c join_tree_type;

struct {
    struct {
        NSInteger ident                     = 0;
        struct {
            NSInteger still                 = 0;
            NSInteger walking               = 1;
            NSInteger running               = 2;
        } states;
    } soundLevel;
    
    struct {
        NSInteger ident                     = 1;
        struct {
            NSInteger close                 = 0;
            NSInteger medium                = 1;
            NSInteger far                   = 2;
        } states;
    } distanceToPlayer;
    
    struct {
        NSInteger ident                     = 2;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } soundReachesZombie;
    
    struct {
        NSInteger ident                     = 3;
        struct {
            NSInteger deaf                  = 0;
            NSInteger poor                  = 1;
            NSInteger medium                = 2;
            NSInteger good                  = 3;
        } states;
    } hearingSkill;
    
    struct {
        NSInteger ident                     = 4;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } hearsPlayer;
    
    struct {
        NSInteger ident                     = 5;
        struct {
            NSInteger day                   = 0;
            NSInteger night                 = 1;
        } states;
    } dayOrNight;
    
    struct {
        NSInteger ident                     = 6;
        struct {
            NSInteger close                 = 0;
            NSInteger medium                = 1;
            NSInteger far                   = 2;
        } states;
    } visibilityDistance;
    
    struct {
        NSInteger ident                     = 7;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } zombieFacingPercept;
    
    struct {
        NSInteger ident                     = 8;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } obstacleInBetween;
    
    struct {
        NSInteger ident                     = 9;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } visualReachesZombie;
    
    struct {
        NSInteger ident                     = 10;
        struct {
            NSInteger yes                   = 0;
            NSInteger no                    = 1;
        } states;
    } seesPlayer;
    
    struct {
        NSInteger ident                     = 11;
        struct {
            NSInteger blind                 = 0;
            NSInteger normal                = 1;
            NSInteger impaired              = 2;
        } states;
    } visionSkill;
    
    struct {
        NSInteger ident                     = 12;
        struct {
            NSInteger low                   = 0;
            NSInteger medium                = 1;
            NSInteger high                  = 2;
        } states;
    } energy;
    
    struct {
        NSInteger ident                     = 13;
        struct {
            NSInteger idle                  = 0;
            NSInteger roam                  = 1;
            NSInteger walk                  = 2;
            NSInteger sprint                = 3;
        } states;
    } strategy;
    
    struct {
        NSInteger ident                     = 14;
        struct {
            NSInteger sprintRange           = 0;
            NSInteger walkRange             = 1;
            NSInteger outOfRange            = 2;
        } states;
    } travelingDistanceToPercept;
} node;
static NSInteger numberOfNodes = 15;

@interface Bayesian : NSObject {
    assignment parent_state;
    directed_graph<bayes_node>::kernel_1a_c bn;
}

- (void)createOfflineTable;

// Store the number of processed entries.
@property (atomic) NSUInteger process;

@end