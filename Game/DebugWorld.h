//
//  DebugWorld.hpp
//  UntoldEngine
//
//  Created by Harold Serrano on 8/13/20.
//  Copyright © 2020 Untold Engine Studios. All rights reserved.
//

#ifndef DebugWorld_hpp
#define DebugWorld_hpp

#include <stdio.h>
#include "U4DWorld.h"
#include "U4DGameObject.h"
#include "U4DShaderEntity.h"

class DebugWorld:public U4DEngine::U4DWorld {
    
private:
    
    U4DEngine::U4DGameObject *ground;
    U4DEngine::U4DShaderEntity *playerIndicatorShader;
    
public:
    
    DebugWorld();
    
    ~DebugWorld();
    
    void init();
    
    void update(double dt);

    //Sets the configuration for the engine: Perspective view, shadows, light
    void setupConfiguration();
    
};
#endif /* DebugWorld_hpp */