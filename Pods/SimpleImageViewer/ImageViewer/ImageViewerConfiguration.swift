import Foundation
import UIKit

public typealias ImageCompletion = (UIImage?) -> Void
public typealias ImageBlock = (@escaping ImageCompletion) -> Void

public final class ImageViewerConfiguration {
    public var image: UIImage?
    public var imageView: UIImageView?
    public var imageBlock: ImageBlock?

    public typealias ConfigurationClosure = (ImageViewerConfiguration) -> Void

    public init(configurationClosure: ConfigurationClosure) {
        configurationClosure(self)
    }
}
