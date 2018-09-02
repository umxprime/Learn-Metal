//
//  MetalView.swift
//  Learn Metal 02
//
//  Created by Maxime CHAPELET on 02/09/2018.
//  Copyright © 2018 Maxime CHAPELET. All rights reserved.
//

import Cocoa
import MetalKit

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
    
    required init(coder:NSCoder) {
        super.init(coder: coder)
        buildDevice()
        buildVertexBuffers()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    private func buildDevice() {
        device = MTLCreateSystemDefaultDevice()
        let metalLayer = layer as? CAMetalLayer
        metalLayer?.pixelFormat = .bgra8Unorm
    }
    
    private func buildVertexBuffers() {
        guard let device = self.device else {return}
        var length = MemoryLayout.size(ofValue: MetalView.positions) * MetalView.positions.count
        positionsBuffer = device.makeBuffer(bytes: &MetalView.positions, length: length, options: .storageModeShared)
        
        length = MemoryLayout.size(ofValue: MetalView.colors) * MetalView.colors.count
        colorsBuffer = device.makeBuffer(bytes: &MetalView.colors, length: length, options: .storageModeShared)
    }
}
