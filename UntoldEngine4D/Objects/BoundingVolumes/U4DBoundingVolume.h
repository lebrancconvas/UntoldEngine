//
//  U4DBoundingVolume.h
//  UntoldEngine
//
//  Created by Harold Serrano on 7/10/13.
//  Copyright (c) 2013 Untold Story Studio. All rights reserved.
//

#ifndef __UntoldEngine__U4DBoundingVolume__
#define __UntoldEngine__U4DBoundingVolume__

#include <iostream>
#include <vector>
#include "Constants.h"
#include "U4DOpenGLGeometry.h"
#include "U4DVector3n.h"
#include "U4DIndex.h"
#include "U4DVertexData.h"
#include "U4DVisibleEntity.h"

namespace U4DEngine {
    
class U4DBoundingVolume:public U4DVisibleEntity{
  
private:
    
    BOUNDINGTYPE boundingType;
    
public:
    
   
    U4DBoundingVolume(){
    
        openGlManager=new U4DOpenGLGeometry(this);
        openGlManager->setShader("geometricShader");

        U4DVector4n color(1.0,0.0,0.0,1.0);
        addCustomUniform("Color", color);
    };
    
   
    ~U4DBoundingVolume(){};
    
   
    U4DBoundingVolume(const U4DBoundingVolume& value){};

  
    U4DBoundingVolume& operator=(const U4DBoundingVolume& value){
        
        return *this;
    
    };
    
    U4DVertexData bodyCoordinates;
    
  
    virtual void initBoundingVolume(float uRadius,int uRings, int uSectors){};
    
    virtual void initBoundingVolume(float uRadius,U4DVector3n& uOffset,int uRings, int uSectors){};
    
    virtual void initBoundingVolume(U4DVector3n& uMin,U4DVector3n& uMax){};
    
    virtual void initBoundingVolume(U4DVector3n& uHalfwidth){};
    
    virtual void update(double dt){};
    
    virtual void determineConvexHullOfModel(std::vector<U4DVector3n>& uVertices){};
    
    U4DPoint3n getSupportPointInDirection(U4DVector3n& uDirection);
    
    void setBoundingType(BOUNDINGTYPE uType);
    
    BOUNDINGTYPE getBoundingType();
    
    void setGeometry();
    
    void setGeometryColor(U4DVector4n& uColor);

    void draw();
    
};
    
}

#endif /* defined(__UntoldEngine__U4DBoundingVolume__) */
