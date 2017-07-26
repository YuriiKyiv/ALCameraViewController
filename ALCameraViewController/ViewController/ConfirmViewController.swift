//
//  ALConfirmViewController.swift
//  ALCameraViewController
//
//  Created by Alex Littlejohn on 2015/06/30.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import Photos

public class ConfirmViewController: UIViewController, UIScrollViewDelegate {
    
    let imageView = UIImageView()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cropOverlay: CropOverlay!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var centeringView: UIView!

    var verticalPadding: CGFloat = 30
    var horizontalPadding: CGFloat = 30
    
    public var onComplete: CameraViewCompletion?
    
    var image: UIImage!
    
    public init(image: UIImage) {
        self.image = image
        super.init(nibName: "ConfirmViewController", bundle: CameraGlobals.shared.bundle)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        
        cropOverlay.isHidden = true
        
        self.configureWithImage(image)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let scale = calculateMinimumScale(view.frame.size)

        scrollView.contentInset = calculateScrollViewInsets(view.bounds)
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        centerScrollViewContents()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let scale = calculateMinimumScale(size)
        var frame = view.bounds
        frame.size = size

        let insets = calculateScrollViewInsets(frame)

        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.scrollView.contentInset = insets
            self?.scrollView.minimumZoomScale = scale
            self?.scrollView.zoomScale = scale
            self?.centerScrollViewContents()
            }, completion: nil)
    }
    
    private func configureWithImage(_ image: UIImage) {
        cropOverlay.isHidden = true
        
        buttonActions()
        
        imageView.image = image
        imageView.sizeToFit()
        view.setNeedsLayout()
    }
    
    private func calculateMinimumScale(_ size: CGSize) -> CGFloat {
        let _size = size
        
        guard let image = imageView.image else {
            return 1
        }
        
        let scaleWidth = _size.width / image.size.width
        let scaleHeight = _size.height / image.size.height
        
        var scale: CGFloat
        
        scale = min(scaleWidth, scaleHeight)
        
        return scale
    }
    
    private func calculateScrollViewInsets(_ frame: CGRect) -> UIEdgeInsets {
        let bottom = view.frame.height - (frame.origin.y + frame.height)
        let right = view.frame.width - (frame.origin.x + frame.width)
        let insets = UIEdgeInsets(top: frame.origin.y, left: frame.origin.x, bottom: bottom, right: right)
        return insets
    }
    
    private func centerScrollViewContents() {
        let size = scrollView.frame.size
        let imageSize = imageView.frame.size
        var imageOrigin = CGPoint.zero
        
        if imageSize.width < size.width {
            imageOrigin.x = (size.width - imageSize.width) / 2
        }
        
        if imageSize.height < size.height {
            imageOrigin.y = (size.height - imageSize.height) / 2
        }
        
        imageView.frame.origin = imageOrigin
    }
    
    private func buttonActions() {
        confirmButton.action = { [weak self] in self?.confirmPhoto() }
        cancelButton.action = { [weak self] in self?.cancel() }
    }
    
    internal func cancel() {
        onComplete?(nil)
    }
    
    internal func confirmPhoto() {
        imageView.isHidden = true

        self.onComplete?(image)
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func showSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.activityIndicatorViewStyle = .white
        spinner.center = view.center
        spinner.startAnimating()
        
        view.addSubview(spinner)
        view.bringSubview(toFront: spinner)
        
        return spinner
    }
    
    func hideSpinner(_ spinner: UIActivityIndicatorView) {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    func disable() {
        confirmButton.isEnabled = false
    }
    
    func enable() {
        confirmButton.isEnabled = true
    }
    
    func showNoImageScreen(_ error: NSError) {
        let permissionsView = PermissionsView(frame: view.bounds)
        
        let desc = localizedString("error.cant-fetch-photo.description")
        
        permissionsView.configureInView(view, title: error.localizedDescription, description: desc, completion: { [weak self] in self?.cancel() })
    }
    
}
