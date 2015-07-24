import Metal
import UIKit

class ViewController: UIViewController {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var library: MTLLibrary!
    var pipelineState: MTLRenderPipelineState!

    var positionBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!

    var metalLayer: CAMetalLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.newCommandQueue()
        library = device.newDefaultLibrary()

        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.frame = view.bounds
        view.layer.addSublayer(metalLayer)

        let vertexShader = library.newFunctionWithName("vertexShader")
        let fragmentShader = library.newFunctionWithName("fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexShader!
        pipelineDescriptor.fragmentFunction = fragmentShader!
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat

        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch {
            print("Error building pipeline state.")
        }

        let positions: [Float] = [
            0,  0.5, 0, 1,
            -0.5, -0.5, 0, 1,
            0.5, -0.5, 0, 1
        ]

        let colors: [Float] = [
            1, 0, 0, 1,
            0, 1, 0, 1,
            0, 0, 1, 1
        ]

        positionBuffer = device.newBufferWithBytes(positions,
            length: sizeofValue(positions) * positions.count, options: .CPUCacheModeDefaultCache)

        colorBuffer = device.newBufferWithBytes(colors,
            length: sizeofValue(colors) * colors.count, options: .CPUCacheModeDefaultCache)

        render()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func render() {
        guard let drawable = metalLayer.nextDrawable() else {
            print("Error obtaining drawable.")
            return
        }

        let framebuffer = drawable.texture

        let cornflowerBlue = MTLClearColorMake(100/255.0, 149/255.0, 237/255.0, 1.0)

        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = framebuffer
        passDescriptor.colorAttachments[0].loadAction = MTLLoadAction.Clear
        passDescriptor.colorAttachments[0].clearColor = cornflowerBlue
        passDescriptor.colorAttachments[0].storeAction = MTLStoreAction.Store

        let commandBuffer = commandQueue.commandBuffer()

        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(passDescriptor)
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(positionBuffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(colorBuffer, offset: 0, atIndex: 1)
        commandEncoder.drawPrimitives(MTLPrimitiveType.Triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
}