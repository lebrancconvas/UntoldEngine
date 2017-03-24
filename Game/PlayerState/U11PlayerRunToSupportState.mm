//
//  U11PlayerRunToSupportState.cpp
//  UntoldEngine
//
//  Created by Harold Serrano on 3/20/17.
//  Copyright © 2017 Untold Game Studio. All rights reserved.
//

#include "U11PlayerRunToSupportState.h"
#include "U11PlayerDribbleState.h"
#include "U11PlayerSupportState.h"
#include "U11Team.h"

U11PlayerRunToSupportState* U11PlayerRunToSupportState::instance=0;

U11PlayerRunToSupportState::U11PlayerRunToSupportState(){
    
}

U11PlayerRunToSupportState::~U11PlayerRunToSupportState(){
    
}

U11PlayerRunToSupportState* U11PlayerRunToSupportState::sharedInstance(){
    
    if (instance==0) {
        instance=new U11PlayerRunToSupportState();
    }
    
    return instance;
    
}

void U11PlayerRunToSupportState::enter(U11Player *uPlayer){
    
    //set run animation
    uPlayer->setNextAnimationToPlay(uPlayer->getRunningAnimation());
    uPlayer->setPlayBlendedAnimation(true);
    uPlayer->setPlayNextAnimationContinuously(true);
    
}

void U11PlayerRunToSupportState::execute(U11Player *uPlayer, double dt){
    
    //get the team
    U11Team *team=uPlayer->getTeam();
    
    U11Player *controllingPlayer=team->getControllingPlayer();
   
    if(controllingPlayer->getCurrentState()==U11PlayerDribbleState::sharedInstance()) {
        
        U4DEngine::U4DVector3n playerHeading=controllingPlayer->getPlayerHeading();
        
        playerHeading.y=controllingPlayer->getAbsolutePosition().y;
        
        uPlayer->setPlayerHeading(playerHeading);
        
        //make the player run
        uPlayer->applyForceToPlayer(chasingSpeed, dt);
        
    }else{
        
        uPlayer->removeAllVelocities();
        uPlayer->removeKineticForces();
        
        uPlayer->changeState(U11PlayerSupportState::sharedInstance());
    }
    

    
}

void U11PlayerRunToSupportState::exit(U11Player *uPlayer){
    
}

bool U11PlayerRunToSupportState::isSafeToChangeState(U11Player *uPlayer){
    
    return true;
}

bool U11PlayerRunToSupportState::handleMessage(U11Player *uPlayer, Message &uMsg){
    
    return false;
}