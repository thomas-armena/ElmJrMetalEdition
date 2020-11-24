//
//  Renderable.swift
//  ElmJrMetalEdition
//
//  Created by Michael Le on 2020-11-18.
//  Copyright © 2020 Thomas Armena. All rights reserved.
//

import MetalKit

class Renderable: RGNode {
    var mesh: Mesh
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var triangleFillMode: MTLTriangleFillMode = .fill
    
    var modelConstants = ModelConstants(color: simd_float4(1, 1, 1, 1))
    var transform = RTransform()
    var color = RColor()
    
    init(mesh: Mesh) {
        self.mesh = mesh
        super.init()
    }
    
    override func createBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(
            bytes: mesh.vertices,
            length: mesh.vertices.count * MemoryLayout<Vertex>.stride,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: mesh.indices,
            length: mesh.indices.count * MemoryLayout<UInt16>.size,
            options: []
        )
    }

    private func updateModelConstants(sceneProps: SceneProps) {
        let transformationMatrix = transform.getTransformationMatrix(sceneProps: sceneProps)
        
        modelConstants.modelViewMatrix = sceneProps.projectionMatrix *
            sceneProps.viewMatrix * transformationMatrix
        
        let rgba = color.evaluate(sceneProps)
        modelConstants.color = rgba
    }
    
    override func draw(commandEncoder: MTLRenderCommandEncoder,
                       pipelineState: MTLRenderPipelineState, sceneProps: SceneProps)
    {
        guard let indexBuffer = indexBuffer,
              let vertexBuffer = vertexBuffer else { return }
        
        updateModelConstants(sceneProps: sceneProps)
      
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setTriangleFillMode(triangleFillMode)
        commandEncoder.setVertexBytes(
            &modelConstants,
            length: MemoryLayout<ModelConstants>.stride,
            index: 1
        )
        commandEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: mesh.indices.count,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0
        )
    }
}
