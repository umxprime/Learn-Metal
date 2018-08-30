//
//  MetalView.swift
//  Learn Metal 01
//
//  Created by Maxime CHAPELET on 30/08/2018.
//  Copyright © 2018 Maxime CHAPELET. All rights reserved.
//

import Cocoa
import MetalKit

class MetalView: MTKView {
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
        colorPixelFormat = .bgra8Unorm
    }
    
    override func viewDidMoveToWindow() {
        redraw()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    private func redraw() {
        guard let metalLayer = self.layer as? CAMetalLayer else {return}
        guard let drawable = metalLayer.nextDrawable() else {return}
        guard let device = device else {return}
        let texture = drawable.texture
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 1.0, green: 0, blue: 0, alpha: 1.0)
        
        guard let commandQueue = device.makeCommandQueue() else {return}
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {return}
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
        commandEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
}
