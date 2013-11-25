
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


- (id)init {
    self = [super init];
    
    if (self) {
        bn.set_number_of_nodes(numberOfNodes);
        [self setupBayesianNetwork];
    }
    return self;
}

- (void)setupBayesianNetwork {
    
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
    
    // node: energy, no parents
    parent_state.clear();
    set_node_probability(bn, node.energy.ident, node.energy.states.low, parent_state, 0.33);
    set_node_probability(bn, node.energy.ident, node.energy.states.medium, parent_state, 0.33);
    set_node_probability(bn, node.energy.ident, node.energy.states.high, parent_state, 0.34);
    
    // node: travelingDistanceToPercept
    parent_state.clear();
    set_node_probability(bn, node.travelingDistanceToPercept.ident, node.travelingDistanceToPercept.states.walkRange, parent_state, 0.33);
    set_node_probability(bn, node.travelingDistanceToPercept.ident, node.travelingDistanceToPercept.states.sprintRange, parent_state, 0.33);
    set_node_probability(bn, node.travelingDistanceToPercept.ident, node.travelingDistanceToPercept.states.outOfRange, parent_state, 0.34);
    
    // node: strategy, parents:energy&hearsPlayer&seesPlayer&travelingDistanceToPercept
    parent_state.clear();
    parent_state.add(node.travelingDistanceToPercept.ident, node.travelingDistanceToPercept.states.sprintRange);
    parent_state.add(node.seesPlayer.ident, node.seesPlayer.states.yes);
    parent_state.add(node.hearsPlayer.ident, node.hearsPlayer.states.yes);
    parent_state.add(node.energy.ident, node.energy.states.high);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 1.0);
    parent_state[node.seesPlayer.ident] = node.seesPlayer.states.no;
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.5);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.75);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.25);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.8);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.1);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.1);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    //
    parent_state[node.travelingDistanceToPercept.ident] = node.travelingDistanceToPercept.states.walkRange;
    parent_state[node.seesPlayer.ident] = node.seesPlayer.states.yes;
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.8);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.2);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.8);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.2);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.seesPlayer.ident] = node.seesPlayer.states.no;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.9);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.1);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.7);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.3);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    //
    parent_state[node.travelingDistanceToPercept.ident] = node.travelingDistanceToPercept.states.outOfRange;
    parent_state[node.seesPlayer.ident] = node.seesPlayer.states.yes;
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.1);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.9);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.1);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.9);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.seesPlayer.ident] = node.seesPlayer.states.no;
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.yes;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.75);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.25);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.1);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.9);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.hearsPlayer.ident] = node.hearsPlayer.states.no;
    parent_state[node.energy.ident] = node.energy.states.high;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.medium;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 0.5);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
    parent_state[node.energy.ident] = node.energy.states.low;
    set_node_probability(bn, node.strategy.ident, node.strategy.states.roam, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.walk, parent_state, 0.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.idle, parent_state, 1.0);
    set_node_probability(bn, node.strategy.ident, node.strategy.states.sprint, parent_state, 0.0);
}

- (NSInteger)selectStrategy {
    try
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
            set_node_value(bn, node.hearingSkill.ident, node.hearingSkill.states.deaf);
            set_node_as_evidence(bn, node.dayOrNight.ident);
            set_node_as_evidence(bn, node.visibilityDistance.ident);
            set_node_as_evidence(bn, node.zombieFacingPercept.ident);
            set_node_as_evidence(bn, node.obstacleInBetween.ident);
            set_node_as_evidence(bn, node.visionSkill.ident);
            set_node_as_evidence(bn, node.hearingSkill.ident);
            ALog(@"");
            bayesian_network_join_tree solution(bn, join_tree);
            ALog(@"");
            // now print out the probabilities for each node
            cout << "Using the join tree algorithm:\n";
            cout << "roam = " << solution.probability(node.strategy.ident)(node.strategy.states.roam) << endl;
            cout << "walk = " << solution.probability(node.strategy.ident)(node.strategy.states.walk) << endl;
            cout << "idle = " << solution.probability(node.strategy.ident)(node.strategy.states.idle) << endl;
            cout << "walk = " << solution.probability(node.strategy.ident)(node.strategy.states.sprint) << endl;
            cout << "\n\n\n";
        
        double probRoam = solution.probability(node.strategy.ident)(node.strategy.states.roam);
        double probWalk = solution.probability(node.strategy.ident)(node.strategy.states.walk);
        double probIdle = solution.probability(node.strategy.ident)(node.strategy.states.idle);
        double probSprint = solution.probability(node.strategy.ident)(node.strategy.states.sprint);
        
        // Return the highest probability.
        if (probRoam >= probWalk && probRoam >= probIdle && probRoam >= probSprint)
            return node.strategy.states.roam;
        if (probWalk >= probIdle && probWalk >= probSprint)
            return node.strategy.states.walk;
        if (probIdle >= probSprint)
            return node.strategy.states.walk;
        return node.strategy.states.sprint;
        
    }
    catch (std::exception& e)
    {
        cout << "exception thrown: " << endl;
        cout << e.what() << endl;
        cout << "hit enter to terminate" << endl;
        cin.get();
    }
    
    return -1;
    
}

@end