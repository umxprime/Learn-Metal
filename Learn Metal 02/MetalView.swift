//
//  MetalView.swift
//  Learn Metal 02
//
//  Created by Maxime CHAPELET on 02/09/2018.
//  Copyright © 2018 Maxime CHAPELET. All rights reserved.
//

import Cocoa
import MetalKit
import CoreVideo

class MetalView: MTKView {

    static var positions:[Float] = [
        0, 0.5, 0, 1,
        -0.5, -0.5, 0, 1,
        0.5, -0.5, 0, 1
    ]
    
    static var colors:[Float] = [
        1, 0, 0, 1,
        0, 1, 0, 1,
        0, 0, 1, 1
    ]
    
    var positionsBuffer:MTLBuffer?
    var colorsBuffer:MTLBuffer?
    var pipeline:MTLRenderPipelineState?
    var displayLink:CVDisplayLink?
    var commandQueue:MTLCommandQueue?
    
    required init(coder:NSCoder) {
        super.init(coder: coder)
        buildDevice()
        buildVertexBuffers()
        buildPipeline()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if self.superview != nil {
            let displayId = CGMainDisplayID()
            var err = kCVReturnSuccess
            err = CVDisplayLinkCreateWithCGDisplay(displayId, &self.displayLink)
            if err == kCVReturnSuccess, let displayLink = self.displayLink {
                CVDisplayLinkSetOutputHandler(displayLink) { [unowned self] (displayLink, inNow, inOutputTime, flagsIn, flagsOut) -> CVReturn in
                    DispatchQueue.main.async {
                        self.redraw()
                    }
                    return kCVReturnSuccess
                }
                CVDisplayLinkStart(displayLink);
            }
        } else {
            if let displayLink = self.displayLink {
                CVDisplayLinkStop(displayLink)
            }
            self.displayLink = nil
        }
    }
    
    private func buildDevice() {
        self.device = MTLCreateSystemDefaultDevice()
        let metalLayer = layer as? CAMetalLayer
        metalLayer?.pixelFormat = .bgra8Unorm
        guard let device = self.device else {return}
        commandQueue = device.makeCommandQueue()
    }
    
    private func buildVertexBuffers() {
        guard let device = self.device else {return}
        var length = MemoryLayout.size(ofValue: MetalView.positions) * MetalView.positions.count
        positionsBuffer = device.makeBuffer(bytes: &MetalView.positions, length: length, options: .storageModeShared)
        
        length = MemoryLayout.size(ofValue: MetalView.colors) * MetalView.colors.count
        colorsBuffer = device.makeBuffer(bytes: &MetalView.colors, length: length, options: .storageModeShared)
    }
    
    private func buildPipeline() {
        guard let library = self.device?.makeDefaultLibrary() else {return}
        guard let vertexFunction = library.makeFunction(name: "vertex_main") else {return}
        guard let fragmentFunction = library.makeFunction(name: "fragment_main") else {return}
        guard let metalLayer = layer as? CAMetalLayer else {return}
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat
        guard let pipeline = try? device?.makeRenderPipelineState(descriptor: renderPipelineDescriptor) else {return}
        self.pipeline = pipeline
    }
    
    private func redraw() {
        guard let metalLayer = layer as? CAMetalLayer else {return}
        guard let drawable = metalLayer.nextDrawable() else {return}
        guard let pipeline = self.pipeline else {return}
        let texture = drawable.texture
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        guard let commandQueue = self.commandQueue else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return}
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
        commandEncoder.setRenderPipelineState(pipeline)
        commandEncoder.setVertexBuffer(self.positionsBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(self.colorsBuffer, offset: 0, index: 1)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
