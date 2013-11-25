
//
//  Created by Pétur Ingi Egilsson on 17/11/13.
//  Copyright (c) 2013 Pétur Ingi Egilsson. All rights reserved.
//

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#include "Bayesian.h"

#import "dlib/bayes_utils.h"
#import "dlib/graph_utils.h"
#import "dlib/graph.h"
#import "dlib/directed_graph.h"
using namespace dlib;
using namespace std;
using namespace bayes_node_utils;

@implementation Bayesian

- (void)run {
    try
    {
        // A representation of possible nodes in the Bayesian Network.
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
        
        // Creates a Bayesian Network.
        directed_graph<bayes_node>::kernel_1a_c bn;
        bn.set_number_of_nodes(numberOfNodes);
        assignment parent_state;
        
        /**
         *  Set up the edges in the graph.
         *  Directed edge (parent,child)
         */
        // node: soundReachesZombie
        bn.add_edge(node.soundLevel.ident,          node.soundReachesZombie.ident);
        bn.add_edge(node.distanceToPlayer.ident,    node.soundReachesZombie.ident);
        // node: hearsPlayer
        bn.add_edge(node.soundReachesZombie.ident,  node.hearsPlayer.ident);
        bn.add_edge(node.dayOrNight.ident,          node.hearsPlayer.ident);
        bn.add_edge(node.hearingSkill.ident,        node.hearsPlayer.ident);
        // node: visualReachesZombie
        bn.add_edge(node.dayOrNight.ident,          node.visualReachesZombie.ident);
        bn.add_edge(node.visibilityDistance.ident,  node.visualReachesZombie.ident);
        bn.add_edge(node.zombieFacingPercept.ident, node.visualReachesZombie.ident);
        bn.add_edge(node.obstacleInBetween.ident,   node.visualReachesZombie.ident);
         // node: seesPlayer
         bn.add_edge(node.hearsPlayer.ident, node.seesPlayer.ident);
         bn.add_edge(node.visionSkill.ident, node.seesPlayer.ident);
         bn.add_edge(node.visualReachesZombie.ident, node.seesPlayer.ident);
        
         // node: strategy
         bn.add_edge(node.energy.ident, node.strategy.ident);
         bn.add_edge(node.travelingDistanceToPercept.ident, node.strategy.ident);
         bn.add_edge(node.hearsPlayer.ident, node.strategy.ident);
         bn.add_edge(node.seesPlayer.ident, node.strategy.ident);
        ALog(@"");
        /**
         *  Specify the number of states each node has.
         *  This equals the number of rows in its' Joint Distribution Table. <-- is this correct?
         */
        set_node_num_values(bn, node.soundLevel.ident,          sizeof(node.soundLevel.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.distanceToPlayer.ident,    sizeof(node.distanceToPlayer.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.soundReachesZombie.ident,  sizeof(node.soundReachesZombie.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.hearingSkill.ident,        sizeof(node.hearingSkill.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.dayOrNight.ident,          sizeof(node.dayOrNight.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.hearsPlayer.ident,         sizeof(node.hearsPlayer.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.visibilityDistance.ident,  sizeof(node.visibilityDistance.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.zombieFacingPercept.ident, sizeof(node.zombieFacingPercept.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.obstacleInBetween.ident,   sizeof(node.obstacleInBetween.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.visualReachesZombie.ident, sizeof(node.visualReachesZombie.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.visionSkill.ident,         sizeof(node.visionSkill.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.seesPlayer.ident,          sizeof(node.seesPlayer.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.energy.ident,              sizeof(node.energy.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.strategy.ident,            sizeof(node.strategy.states) / sizeof(NSInteger));
        set_node_num_values(bn, node.travelingDistanceToPercept.ident, sizeof(node.travelingDistanceToPercept.states) / sizeof(NSInteger));
        
        /**
         *  Construct the probability tables.
         The probability of a value, depends on the state of the parent of the object owning the value.
         */
        // node: soundLevel , node without parents.
        parent_state.clear();
        set_node_probability(bn, node.soundLevel.ident, node.soundLevel.states.still,   parent_state, 0.333);
        set_node_probability(bn, node.soundLevel.ident, node.soundLevel.states.walking, parent_state, 0.333);
        set_node_probability(bn, node.soundLevel.ident, node.soundLevel.states.running, parent_state, 0.334);
        
        // node: distanceToPlayer , node without parents.
        parent_state.clear();
        set_node_probability(bn, node.distanceToPlayer.ident, node.distanceToPlayer.states.close,   parent_state, 0.333);
        set_node_probability(bn, node.distanceToPlayer.ident, node.distanceToPlayer.states.medium,  parent_state, 0.333);
        set_node_probability(bn, node.distanceToPlayer.ident, node.distanceToPlayer.states.far,     parent_state, 0.334);
        
        // node: soundReachesZombie , parents: soundLevel & distanceToPlayer
        parent_state.clear();
        parent_state.add(node.distanceToPlayer.ident, node.distanceToPlayer.states.close);  //add
        parent_state.add(node.soundLevel.ident, node.soundLevel.states.still);          // add
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.25);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no,  parent_state, 0.75);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.walking;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.0);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.running;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.0);
        //
        parent_state[node.distanceToPlayer.ident] = node.distanceToPlayer.states.medium;    // change
        parent_state[node.soundLevel.ident] = node.soundLevel.states.still;             // change
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.0625);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no,  parent_state, 0.9375);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.walking;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.5);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.5);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.running;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.0);
        //
        parent_state[node.distanceToPlayer.ident] = node.distanceToPlayer.states.far;    // change
        parent_state[node.soundLevel.ident] = node.soundLevel.states.still;          // change
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no,  parent_state, 1.0);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.walking;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.125);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.875);
        parent_state[node.soundLevel.ident] = node.soundLevel.states.running;
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.yes, parent_state, 0.25);
        set_node_probability(bn, node.soundReachesZombie.ident, node.soundReachesZombie.states.no, parent_state,  0.75);
        
        // node: dayOrNight, node without parents
        parent_state.clear();
        set_node_probability(bn, node.dayOrNight.ident, node.dayOrNight.states.day,   parent_state, 0.5);
        set_node_probability(bn, node.dayOrNight.ident, node.dayOrNight.states.night, parent_state, 0.5);
        
        // node: hearingSkill, node without parents
        parent_state.clear();
        set_node_probability(bn, node.hearingSkill.ident, node.hearingSkill.states.deaf,    parent_state, 0.02);
        set_node_probability(bn, node.hearingSkill.ident, node.hearingSkill.states.poor,    parent_state, 0.14);
        set_node_probability(bn, node.hearingSkill.ident, node.hearingSkill.states.medium,  parent_state, 0.34);
        set_node_probability(bn, node.hearingSkill.ident, node.hearingSkill.states.good,    parent_state, 0.50);
        
        // node: hearsPlayer, parents: soundReachesZombie & hearingSkill & dayOrNight
        parent_state.clear();
        parent_state.add(node.dayOrNight.ident, node.dayOrNight.states.day);
        parent_state.add(node.soundReachesZombie.ident, node.soundReachesZombie.states.yes);
        parent_state.add(node.hearingSkill.ident, node.hearingSkill.states.deaf);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.poor;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.5);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.5);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.medium;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.75);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.25);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.good;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.0);
        //
        parent_state[node.soundReachesZombie.ident] = node.soundReachesZombie.states.no;
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.deaf;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.poor;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.medium;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.good;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        //
        parent_state[node.dayOrNight.ident] = node.dayOrNight.states.night;
        parent_state[node.soundReachesZombie.ident] = node.soundReachesZombie.states.yes;
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.deaf;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.poor;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.6);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.4);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.medium;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.9);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.1);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.good;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  0.0);
        //
        parent_state[node.soundReachesZombie.ident] = node.soundReachesZombie.states.no;
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.deaf;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.poor;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.medium;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        parent_state[node.hearingSkill.ident] = node.hearingSkill.states.good;
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.hearsPlayer.ident, node.hearsPlayer.states.no, parent_state,  1.0);
        
        // node: visibilityDistance , no parent
        parent_state.clear();
        set_node_probability(bn, node.visibilityDistance.ident, node.visibilityDistance.states.close, parent_state, 0.33);
        set_node_probability(bn, node.visibilityDistance.ident, node.visibilityDistance.states.medium, parent_state, 0.33);
        set_node_probability(bn, node.visibilityDistance.ident, node.visibilityDistance.states.far, parent_state, 0.34);
        
        // node: zombieFacingPercept , no parent
        parent_state.clear();
        set_node_probability(bn, node.zombieFacingPercept.ident, node.zombieFacingPercept.states.yes, parent_state, 0.33);
        set_node_probability(bn, node.zombieFacingPercept.ident, node.zombieFacingPercept.states.no, parent_state, 0.67);
        
        // node: obstacleInBetween , no parent
        parent_state.clear();
        set_node_probability(bn, node.obstacleInBetween.ident, node.obstacleInBetween.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.obstacleInBetween.ident, node.obstacleInBetween.states.no, parent_state, 1.0);
        
        // node: visualReachesZombie , parents: dayOrNight & visibilityDistance & zombieFacingPercept & obstacleInBetween
        parent_state.clear();
        parent_state.add(node.dayOrNight.ident, node.dayOrNight.states.day);
        parent_state.add(node.obstacleInBetween.ident, node.obstacleInBetween.states.yes);
        parent_state.add(node.visibilityDistance.ident, node.visibilityDistance.states.close);
        parent_state.add(node.zombieFacingPercept.ident, node.zombieFacingPercept.states.yes);  // day, obstacle, close, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.medium;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // day, obstacle, medium, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;     // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.far;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // day, obstacle, far, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.obstacleInBetween.ident] = node.obstacleInBetween.states.no;
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.close;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // day, no obstacle, close, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 1.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.medium;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // day, no obstacle, medium, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.5);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.5);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.far;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // day, no obstacle, far, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.22);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.78);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.dayOrNight.ident] = node.dayOrNight.states.night; // night
        parent_state[node.obstacleInBetween.ident] = node.obstacleInBetween.states.yes;
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.close;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;  // night, obstacle, close, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.medium;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // night, obstacle, medium, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;     // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.far;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // night, obstacle, far, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.obstacleInBetween.ident] = node.obstacleInBetween.states.no;
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.close;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // night, no obstacle, close, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.5);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.5);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.medium;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // night, no obstacle, medium, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.25);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.75);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        parent_state[node.visibilityDistance.ident] = node.visibilityDistance.states.far;
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.yes;     // night, no obstacle, far, facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.12);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 0.88);
        parent_state[node.zombieFacingPercept.ident] = node.zombieFacingPercept.states.no;      // ... not-facing
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.visualReachesZombie.ident, node.visualReachesZombie.states.no, parent_state, 1.0);
        
        // node: visionSkills , node without parents
        parent_state.clear();
        set_node_probability(bn, node.visionSkill.ident, node.visionSkill.states.blind, parent_state, 0.005);
        set_node_probability(bn, node.visionSkill.ident, node.visionSkill.states.impaired, parent_state, 0.034);
        set_node_probability(bn, node.visionSkill.ident, node.visionSkill.states.normal, parent_state, 0.961);
        
        // node: seesPlayer , parents:hearsPlayer&visionSkill&visualReachesZombie
        parent_state.clear();
        parent_state.add(node.visionSkill.ident, node.visionSkill.states.blind);
            parent_state.add(node.visualReachesZombie.ident, node.visualReachesZombie.states.yes);
                parent_state.add(node.hearsPlayer.ident, node.hearsPlayer.states.yes);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
            parent_state[node.visualReachesZombie.ident] = node.visualReachesZombie.states.no; // blind, not reaches, hears
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
        parent_state[node.visionSkill.ident] = node.visionSkill.states.impaired;
            parent_state[node.visualReachesZombie.ident] = node.visualReachesZombie.states.yes;
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.46);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 0.54);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.3);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 0.7);
            parent_state[node.visualReachesZombie.ident] = node.visualReachesZombie.states.no;
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
        parent_state[node.visionSkill.ident] = node.visionSkill.states.normal;
            parent_state[node.visualReachesZombie.ident] = node.visualReachesZombie.states.yes;
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.9);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 0.1);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.6);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 0.4);
            parent_state[node.visualReachesZombie.ident] = node.visualReachesZombie.states.no;
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
                parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.yes, parent_state, 0.0);
        set_node_probability(bn, node.seesPlayer.ident, node.seesPlayer.states.no, parent_state, 1.0);
        
        // node: strategy, parents:energy&hearsPlayer&seesPlayer&travelingDistanceToPercept
        
        
        {
            /* test code */
            typedef dlib::set<unsigned long>::compare_1b_c set_type;
            typedef graph<set_type, set_type>::kernel_1a_c join_tree_type;
            join_tree_type join_tree;
            create_moral_graph(bn, join_tree);
            create_join_tree(join_tree, join_tree);
            ALog(@"");
            set_node_value(bn, node.dayOrNight.ident, node.dayOrNight.states.night);
            set_node_value(bn, node.visibilityDistance.ident, node.visibilityDistance.states.far);
            set_node_value(bn, node.zombieFacingPercept.ident, node.zombieFacingPercept.states.yes);
            set_node_value(bn, node.obstacleInBetween.ident, node.obstacleInBetween.states.no);
            set_node_value(bn, node.visionSkill.ident, node.visionSkill.states.impaired);
            set_node_as_evidence(bn, node.dayOrNight.ident);
            set_node_as_evidence(bn, node.visibilityDistance.ident);
            set_node_as_evidence(bn, node.zombieFacingPercept.ident);
            set_node_as_evidence(bn, node.obstacleInBetween.ident);
            set_node_as_evidence(bn, node.visionSkill.ident);
            ALog(@"");
            bayesian_network_join_tree solution(bn, join_tree);
            ALog(@"");
            // now print out the probabilities for each node
            cout << "Using the join tree algorithm:\n";
            cout << "p(soundReachesZombie = yes) = " << solution.probability(node.seesPlayer.ident)(node.seesPlayer.states.yes) << endl;
            cout << "p(soundReachesZombie = no) = " << solution.probability(node.seesPlayer.ident)(node.seesPlayer.states.no) << endl;
            cout << "\n\n\n";
        }
        
        /*
         #define LUCK    0
         #define LOW     0
         #define MEDIUM  1
         #define HIGH    2
         
         #define BET     1
         #define LOOSE   0
         #define WIN     1
         
         bn.set_number_of_nodes(2);
         
         bn.add_edge(LUCK, BET);
         
         set_node_num_values(bn, LUCK, 3);
         set_node_num_values(bn, BET, 2);
         
         assignment parent_state;
         
         // P(A=low) = 0.3 etc...
         set_node_probability(bn, LUCK, 0, parent_state, 0.33334);
         set_node_probability(bn, LUCK, 1, parent_state, 0.33333);
         set_node_probability(bn, LUCK, 2, parent_state, 0.33333);
         
         // This is our first node that has parents. So we set the parent_state
         // object to reflect that B has A as parents.
         parent_state.add(LUCK, BET);
         
         parent_state[LUCK] = LOW;
         set_node_probability(bn, BET, LOOSE, parent_state, 0.75);
         set_node_probability(bn, BET, WIN, parent_state, 0.25);
         
         parent_state[LUCK] = MEDIUM;
         set_node_probability(bn, BET, LOOSE, parent_state, 0.50);
         set_node_probability(bn, BET, WIN, parent_state, 0.50);
         
         parent_state[LUCK] = HIGH;
         set_node_probability(bn, BET, LOOSE, parent_state, 0.25);
         set_node_probability(bn, BET, WIN, parent_state, 0.75);
         
         // First we need to create an undirected graph which contains set objects at each node and
         // edge.  This long declaration does the trick.
         typedef dlib::set<unsigned long>::compare_1b_c set_type;
         typedef graph<set_type, set_type>::kernel_1a_c join_tree_type;
         join_tree_type join_tree;
         
         // Now we need to populate the join_tree with data from our bayesian network.  The next
         // function calls do this.  Explaining exactly what they do is outside the scope of this
         // example.  Just think of them as filling join_tree with information that is useful
         // later on for dealing with our bayesian network.
         create_moral_graph(bn, join_tree);
         create_join_tree(join_tree, join_tree);
         
         set_node_value(bn, LUCK, HIGH);
         set_node_as_evidence(bn, LUCK);
         
         // Now that we have a proper join_tree we can use it to obtain a solution to our
         // bayesian network.  Doing this is as simple as declaring an instance of
         // the bayesian_network_join_tree object as follows:
         bayesian_network_join_tree solution(bn, join_tree);
         
         // now print out the probabilities for each node
         cout << "Using the join tree algorithm:\n";
         cout << "p(BET = WIN) = " << solution.probability(BET)(WIN) << endl;
         cout << "p(BET = LOOSE) = " << solution.probability(BET)(LOOSE) << endl;
         cout << "\n\n\n";
         */
    }
    catch (std::exception& e)
    {
        cout << "exception thrown: " << endl;
        cout << e.what() << endl;
        cout << "hit enter to terminate" << endl;
        cin.get();
    }
}

@end