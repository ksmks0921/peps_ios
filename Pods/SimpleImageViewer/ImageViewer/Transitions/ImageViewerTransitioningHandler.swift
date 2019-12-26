import UIKit

final class ImageViewerTransitioningHandler: NSObject {
    fileprivate let presentationTransition: ImageViewerPresentationTransition
    fileprivate let dismissalTransition: ImageViewerDismissalTransition

    let dismissalInteractor: ImageViewerDismissalInteractor

    var dismissInteractively = false

    init(fromImageView: UIImageView, toImageView: UIImageView) {
        presentationTransition = ImageViewerPresentationTransition(fromImageView: fromImageView)
        dismissalTransition = ImageViewerDismissalTransition(fromImageView: toImageView, toImageView: fromImageView)
        dismissalInteractor = ImageViewerDismissalInteractor(transition: dismissalTransition)
        super.init()
    }
}

extension ImageViewerTransitioningHandler: UIViewControllerTransitioningDelegate {
    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentationTransition
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissalTransition
    }

    func interactionControllerForDismissal(using _: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractively ? dismissalInteractor : nil
    }
}
