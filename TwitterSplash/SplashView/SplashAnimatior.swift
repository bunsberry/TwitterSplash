//
//  SplashAnimatior.swift
//  TwitterSplash
//

import UIKit
import QuartzCore

protocol SplashAnimatorDescription: AnyObject {
    func animateAppearance()
    func animateDisappearance(completion: @escaping () -> Void)
}

final class SplashAnimator: SplashAnimatorDescription {
    
    // MARK: - Properties
    
    private unowned let foregroundSplashWindow: UIWindow
    private unowned let backgroundSplashWindow: UIWindow
    
    private unowned let foregroundSplashViewController: SplashViewController
    private unowned let backgroundSplashViewController: SplashViewController
    
    // MARK: - Initialization
    
    init(foregroundSplashWindow: UIWindow, backgroundSplashWindow: UIWindow) {
        self.foregroundSplashWindow = foregroundSplashWindow
        self.backgroundSplashWindow = backgroundSplashWindow
        
        guard
            let foregroundSplashViewController = foregroundSplashWindow.rootViewController as? SplashViewController,
            let backgroundSplashViewController = backgroundSplashWindow.rootViewController as? SplashViewController else {
                fatalError("Splash window doesn't have splash root view controller!")
        }
        
        self.foregroundSplashViewController = foregroundSplashViewController
        self.backgroundSplashViewController = backgroundSplashViewController
    }
    
    // MARK: - Appearance
    
    func animateAppearance() {
        foregroundSplashWindow.isHidden = false
    }
    
    // MARK: - Disappearance
    
    func animateDisappearance(completion: @escaping () -> Void) {
        guard let window = UIApplication.shared.delegate?.window, let mainWindow = window else {
            fatalError("Application doesn't have a window!")
        }
        
        // Background splash window provides splash behind the animated logo image instead of black screen
        backgroundSplashWindow.isHidden = false
        foregroundSplashWindow.alpha = 0
        
        // This mask provides hole in window with shape of logo image
        let mask = CALayer()
        mask.frame = foregroundSplashViewController.logoImageView.frame
        mask.contents = SplashViewController.logoImageBig.cgImage
        mask.contentsGravity = .resizeAspect
        mainWindow.layer.mask = mask
        
        // Fading UIView
        let maskBackgroundView = UIView()
        maskBackgroundView.frame = mainWindow.frame
        maskBackgroundView.backgroundColor = .white
        mainWindow.addSubview(maskBackgroundView)
        mainWindow.bringSubviewToFront(maskBackgroundView)
        
        CATransaction.setCompletionBlock {
            mainWindow.layer.mask = nil
            completion()
        }
        
        CATransaction.begin()
        
        mainWindow.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.4, animations: {
            mainWindow.transform = .identity
        })
        
        addScalingAnimation(to: mask, duration: 0.4)
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {
            maskBackgroundView.alpha = 0
        }) { _ in
            maskBackgroundView.removeFromSuperview()
        }
        
        CATransaction.commit()
    }
    
    private func addScalingAnimation(to layer: CALayer, duration: TimeInterval, delay: CFTimeInterval = 0) {
        let animation = CAKeyframeAnimation(keyPath: "bounds")
        
        let width = layer.frame.size.width
        let height = layer.frame.size.height
        let coeficient: CGFloat = 36 / 667
        let finalScale = UIScreen.main.bounds.height * coeficient
        let scales = [1, 0.75, finalScale]
        
        animation.beginTime = CACurrentMediaTime() + delay
        animation.duration = duration
        animation.keyTimes = [0, 0.4, 1]
        animation.values = scales.map { NSValue(cgRect: CGRect(x: 0, y: 0, width: width * $0, height: height * $0)) }
        animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut),
                                     CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        layer.add(animation, forKey: "scaling")
    }
    
}
