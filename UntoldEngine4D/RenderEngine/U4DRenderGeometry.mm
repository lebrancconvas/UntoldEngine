//
//  U4DRenderGeometry.cpp
//  MetalRendering
//
//  Created by Harold Serrano on 7/13/17.
//  Copyright © 2017 Untold Engine Studios. All rights reserved.
//

#include "U4DRenderGeometry.h"
#include "U4DDirector.h"
#include "U4DShaderProtocols.h"
#include "U4DCamera.h"
#include "U4DNumerical.h"

namespace U4DEngine {
    
    U4DRenderGeometry::U4DRenderGeometry(U4DBoundingVolume *uU4DGeometricObject):uniformGeometryBuffer(nil){
        
        u4dObject=uU4DGeometricObject;
        
    }
    
    U4DRenderGeometry::~U4DRenderGeometry(){
        
        [uniformGeometryBuffer release];
        
        uniformGeometryBuffer=nil;
    }
    
    void U4DRenderGeometry::initMTLRenderLibrary(){
        
        mtlLibrary=[mtlDevice newDefaultLibrary];
        
        std::string vertexShaderName=u4dObject->getVertexShader();
        std::string fragmentShaderName=u4dObject->getFragmentShader();
        
        vertexProgram=[mtlLibrary newFunctionWithName:[NSString stringWithUTF8String:vertexShaderName.c_str()]];
        fragmentProgram=[mtlLibrary newFunctionWithName:[NSString stringWithUTF8String:fragmentShaderName.c_str()]];
        
    }
    
    void U4DRenderGeometry::initMTLRenderPipeline(){
        
        U4DDirector *director=U4DDirector::sharedInstance();
        
        mtlRenderPipelineDescriptor=[[MTLRenderPipelineDescriptor alloc] init];
        mtlRenderPipelineDescriptor.vertexFunction=vertexProgram;
        mtlRenderPipelineDescriptor.fragmentFunction=fragmentProgram;
        mtlRenderPipelineDescriptor.colorAttachments[0].pixelFormat=director->getMTLView().colorPixelFormat;
        mtlRenderPipelineDescriptor.depthAttachmentPixelFormat=director->getMTLView().depthStencilPixelFormat;
        
        //set the vertex descriptors
        
        vertexDesc=[[MTLVertexDescriptor alloc] init];
        
        vertexDesc.attributes[0].format=MTLVertexFormatFloat4;
        vertexDesc.attributes[0].bufferIndex=0;
        vertexDesc.attributes[0].offset=0;
        
        //stride
        vertexDesc.layouts[0].stride=4*sizeof(float);
        
        vertexDesc.layouts[0].stepFunction=MTLVertexStepFunctionPerVertex;
        
        
        mtlRenderPipelineDescriptor.vertexDescriptor=vertexDesc;
        mtlRenderPipelineDescriptor.vertexFunction=vertexProgram;
        
        
        depthStencilDescriptor=[[MTLDepthStencilDescriptor alloc] init];
        
        depthStencilDescriptor.depthCompareFunction=MTLCompareFunctionLess;
        
        depthStencilDescriptor.depthWriteEnabled=YES;
        
        depthStencilState=[mtlDevice newDepthStencilStateWithDescriptor:depthStencilDescriptor];
        
        //create the rendering pipeline object
        
        mtlRenderPipelineState=[mtlDevice newRenderPipelineStateWithDescriptor:mtlRenderPipelineDescriptor error:nil];
        
    }
    
    bool U4DRenderGeometry::loadMTLBuffer(){
        
        //Align the attribute data
        alignedAttributeData();
        
        if (attributeAlignedContainer.size()==0) {
            
            eligibleToRender=false;
            
            return false;
        }
        
        attributeBuffer=[mtlDevice newBufferWithBytes:&attributeAlignedContainer[0] length:sizeof(AttributeAlignedGeometryData)*attributeAlignedContainer.size() options:MTLResourceOptionCPUCacheModeDefault];
        
        //create the uniform
        uniformSpaceBuffer=[mtlDevice newBufferWithLength:sizeof(UniformSpace) options:MTLResourceStorageModeShared];
        
        //load the index into the buffer
        indicesBuffer=[mtlDevice newBufferWithBytes:&u4dObject->bodyCoordinates.indexContainer[0] length:sizeof(int)*3*u4dObject->bodyCoordinates.indexContainer.size() options:MTLResourceOptionCPUCacheModeDefault];
        
        eligibleToRender=true;
        
        return true;
    }

    void U4DRenderGeometry::updateRenderingInformation(){
        
        alignedAttributeData();
        
        memcpy(attributeBuffer.contents, (void*)&attributeAlignedContainer[0], sizeof(AttributeAlignedGeometryData)*attributeAlignedContainer.size());
        
        memcpy(indicesBuffer.contents, (void*)&u4dObject->bodyCoordinates.indexContainer[0], sizeof(int)*3*u4dObject->bodyCoordinates.indexContainer.size());
        
        clearModelAttributeData();
        
    }
        
    void U4DRenderGeometry::modifyRenderingInformation(){
        
        alignedAttributeData();
        
        attributeBuffer=[mtlDevice newBufferWithBytes:&attributeAlignedContainer[0] length:sizeof(AttributeAlignedGeometryData)*attributeAlignedContainer.size() options:MTLResourceOptionCPUCacheModeDefault];
        
        //load the index into the buffer
        indicesBuffer=[mtlDevice newBufferWithBytes:&u4dObject->bodyCoordinates.indexContainer[0] length:sizeof(int)*3*u4dObject->bodyCoordinates.indexContainer.size() options:MTLResourceOptionCPUCacheModeDefault];
        
        clearModelAttributeData();
        
    }
    
    void U4DRenderGeometry::loadMTLAdditionalInformation(){
        
        //create the uniform
        uniformGeometryBuffer=[mtlDevice newBufferWithLength:sizeof(UniformGeometryProperty) options:MTLResourceStorageModeShared];

        U4DVector4n defaultLineColor(0.0,1.0,0.0,1.0);
        
        setGeometryLineColor(defaultLineColor);
    }
    
    U4DDualQuaternion U4DRenderGeometry::getEntitySpace(){
        
        return u4dObject->getAbsoluteSpace();
        
    }
    
    U4DDualQuaternion U4DRenderGeometry::getEntityLocalSpace(){
        
        return u4dObject->getLocalSpace();
        
    }
    
    U4DVector3n U4DRenderGeometry::getEntityAbsolutePosition(){
        
        
        return u4dObject->getAbsolutePosition();
        
    }
    
    U4DVector3n U4DRenderGeometry::getEntityLocalPosition(){
        
        return u4dObject->getLocalPosition();
        
    }
    
    void U4DRenderGeometry::setGeometryLineColor(U4DVector4n &uGeometryLineColor){
        
        U4DNumerical numerical;
        
        geometryLineColor=uGeometryLineColor;
        
        UniformGeometryProperty uniformGeometryProperty;
        
        vector_float4 geometryLineColorSIMD=numerical.convertToSIMD(geometryLineColor);
        
        uniformGeometryProperty.lineColor=geometryLineColorSIMD;
        
        memcpy(uniformGeometryBuffer.contents, (void*)&uniformGeometryProperty, sizeof(UniformGeometryProperty));
        
    }
    
    void U4DRenderGeometry::updateSpaceUniforms(){
        
        U4DCamera *camera=U4DCamera::sharedInstance();
        U4DDirector *director=U4DDirector::sharedInstance();
        
        U4DMatrix4n modelSpace=getEntitySpace().transformDualQuaternionToMatrix4n();
        
        U4DMatrix4n worldSpace(1,0,0,0,
                               0,1,0,0,
                               0,0,1,0,
                               0,0,0,1);
        
        //YOU NEED TO MODIFY THIS SO THAT IT USES THE U4DCAMERA Position
        U4DEngine::U4DMatrix4n viewSpace=camera->getLocalSpace().transformDualQuaternionToMatrix4n();
        viewSpace.invert();
        
        U4DMatrix4n modelWorldSpace=worldSpace*modelSpace;
        
        U4DMatrix4n modelWorldViewSpace=viewSpace*modelWorldSpace;
        
        U4DMatrix4n perspectiveProjection=director->getPerspectiveSpace();
        
        U4DMatrix4n mvpSpace=perspectiveProjection*modelWorldViewSpace;
        
        U4DNumerical numerical;
        
        matrix_float4x4 mvpSpaceSIMD=numerical.convertToSIMD(mvpSpace);
        
        
        UniformSpace uniformSpace;
        uniformSpace.modelViewProjectionSpace=mvpSpaceSIMD;
        
        memcpy(uniformSpaceBuffer.contents, (void*)&uniformSpace, sizeof(UniformSpace));
        
    }
    
    void U4DRenderGeometry::render(id <MTLRenderCommandEncoder> uRenderEncoder){
        
        if (eligibleToRender==true) {
        
            updateSpaceUniforms();
            
            //encode the pipeline
            [uRenderEncoder setRenderPipelineState:mtlRenderPipelineState];
            
            [uRenderEncoder setDepthStencilState:depthStencilState];
            
            //encode the buffers
            [uRenderEncoder setVertexBuffer:attributeBuffer offset:0 atIndex:0];
            
            [uRenderEncoder setVertexBuffer:uniformSpaceBuffer offset:0 atIndex:1];
            
            [uRenderEncoder setFragmentBuffer:uniformGeometryBuffer offset:0 atIndex:0];
            
            //set the draw command
            [uRenderEncoder drawIndexedPrimitives:MTLPrimitiveTypeLineStrip indexCount:[indicesBuffer length]/sizeof(int) indexType:MTLIndexTypeUInt32 indexBuffer:indicesBuffer indexBufferOffset:0];
            
        }
        
    }
    
    void U4DRenderGeometry::alignedAttributeData(){
        
        U4DNumerical numerical;
        
        //create the structure that contains the align data
        AttributeAlignedGeometryData attributeAlignedData;
        
        //initialize the container to a temp container
        std::vector<AttributeAlignedGeometryData> attributeAlignedContainerTemp(u4dObject->bodyCoordinates.getVerticesDataFromContainer().size(),attributeAlignedData);
        
        //copy the temp containter to the actual container. I wanted to initialize the container directly without using the temp container
        //but it kept giving me errors. I think there is a better way to do this.
        attributeAlignedContainer=attributeAlignedContainerTemp;
        
        for(int i=0;i<attributeAlignedContainer.size();i++){
            
            //align vertex data
            U4DVector3n vertexData=u4dObject->bodyCoordinates.verticesContainer.at(i);
            attributeAlignedContainer.at(i).position.xyz=numerical.convertToSIMD(vertexData);
            attributeAlignedContainer.at(i).position.w=1.0;
            
            
        }
        
    }
    
    
    void U4DRenderGeometry::clearModelAttributeData(){
        
        //clear the attribute data contatiner
        attributeAlignedContainer.clear();
        
        u4dObject->bodyCoordinates.verticesContainer.clear();
        
    }
    
    
}
