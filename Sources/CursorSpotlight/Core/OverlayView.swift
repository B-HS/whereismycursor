import AppKit
import QuartzCore

final class OverlayView: NSView {
    private let fillLayer = CAShapeLayer()
    private let imageLayer = CALayer()
    private var cursorPoint: CGPoint = .zero
    private var radius: CGFloat = 50
    private var useImage = false

    override var isFlipped: Bool { false }
    override var wantsUpdateLayer: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        let root = CALayer()
        root.frame = bounds
        root.addSublayer(imageLayer)
        root.mask = fillLayer
        layer = root

        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = NSColor.black.cgColor
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.frame = bounds
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func apply(color: NSColor, opacity: CGFloat, image: NSImage?, useImage: Bool) {
        self.useImage = useImage
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if useImage, let image {
            imageLayer.contents = image
            imageLayer.backgroundColor = NSColor.clear.cgColor
            layer?.backgroundColor = NSColor.clear.cgColor
            imageLayer.opacity = Float(opacity)
        } else {
            imageLayer.contents = nil
            imageLayer.opacity = 1.0
            let srgb = color.usingColorSpace(.sRGB) ?? color
            let combined = srgb.alphaComponent * opacity
            layer?.backgroundColor = srgb.withAlphaComponent(combined).cgColor
        }
        imageLayer.frame = bounds
        CATransaction.commit()
    }

    func update(cursorPoint: CGPoint, radius: CGFloat) {
        self.cursorPoint = cursorPoint
        self.radius = radius
        rebuildMask()
    }

    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        imageLayer.frame = bounds
        fillLayer.frame = bounds
        CATransaction.commit()
        rebuildMask()
    }

    private func rebuildMask() {
        let path = CGMutablePath()
        path.addRect(bounds)
        let hole = CGRect(
            x: cursorPoint.x - radius,
            y: cursorPoint.y - radius,
            width: radius * 2,
            height: radius * 2,
        )
        path.addEllipse(in: hole)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.frame = bounds
        fillLayer.path = path
        CATransaction.commit()
    }
}
