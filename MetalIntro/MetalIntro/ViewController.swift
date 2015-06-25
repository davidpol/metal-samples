import Metal
import UIKit

class ViewController: UIViewController {
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!

    var metalLayer: CAMetalLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        device = MTLCreateSystemDefaultDevice()

        commandQueue = device.newCommandQueue()

        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.frame = view.bounds
        view.layer.addSublayer(metalLayer)

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
        commandEncoder.endEncoding()

        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }
}