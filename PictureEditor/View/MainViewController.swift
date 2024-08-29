//
//  ViewController.swift
//  PictureEditor
//
//  Created by Denis Raiko on 26.08.24.
//


import UIKit
import CoreImage

class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let addPhotoButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 50, height: 50)
        button.setTitle("+", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let frameView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.yellow.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private let filterSwitch: UISwitch = {
        let filterSwitch = UISwitch()
        filterSwitch.isOn = false
        filterSwitch.translatesAutoresizingMaskIntoConstraints = false
        return filterSwitch
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "Origin/BW"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var originalImage: UIImage?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupContainerView()
        setupViews()
        setupGestures()
        setupAddButton()
        setupFilterSwitch()
        
        frameView.isHidden = true
        filterSwitch.isHidden = true
        filterLabel.isHidden = true
        
    }
    
    // MARK: - Methods
    
    private func setupNavigationBar() {
        navigationItem.title = "Title"
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupAddButton() {
        containerView.addSubview(addPhotoButton)
        
        NSLayoutConstraint.activate([
            addPhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            addPhotoButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 50),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addPhotoButton.addTarget(self, action: #selector(openPhotoGalleryTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        containerView.addSubview(imageView)
        containerView.addSubview(frameView)
        
        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            frameView.widthAnchor.constraint(equalToConstant: 300),
            frameView.heightAnchor.constraint(equalToConstant: 300),
            
            imageView.topAnchor.constraint(equalTo: frameView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: frameView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: frameView.bottomAnchor)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        frameView.addGestureRecognizer(panGesture)
        
        let pinchGestureForImageView = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureForImageView))
        imageView.addGestureRecognizer(pinchGestureForImageView)
        
        let pinchGestureForFrameView = UIPinchGestureRecognizer(target: self, action: #selector(handleFrameViewPinchGesture))
        frameView.addGestureRecognizer(pinchGestureForFrameView)
    }
    
    private func setupFilterSwitch() {
        view.addSubview(filterSwitch)
        view.addSubview(filterLabel)
        
        NSLayoutConstraint.activate([
            filterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            filterLabel.trailingAnchor.constraint(equalTo: filterSwitch.leadingAnchor, constant: -10),
            
            filterSwitch.centerYAnchor.constraint(equalTo: filterLabel.centerYAnchor),
            filterSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        filterSwitch.addTarget(self, action: #selector(filterSwitchChanged), for: .valueChanged)
    }
    
    private func applyFilter(to image: UIImage) -> UIImage? {
        if filterSwitch.isOn {
            let context = CIContext()
            let ciImage = CIImage(image: image)
            let filter = CIFilter(name: "CIPhotoEffectNoir")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter?.outputImage {
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return image
    }
    
    private func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else {
            print("Error: Couldn't crop image.")
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    private func updateImageViewMask() {
        imageView.layer.mask?.removeFromSuperlayer()
        
        let maskLayer = CAShapeLayer()
        
        let frameViewInImageViewCoordinates = imageView.convert(frameView.frame, from: containerView)
        
        let path = UIBezierPath(rect: frameViewInImageViewCoordinates)
        maskLayer.path = path.cgPath
        
        imageView.layer.mask = maskLayer
    }
    
    // MARK: - Actions
    
    @objc private func openPhotoGalleryTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func saveTapped() {
        guard let image = imageView.image else {
            print("Error: No image to save.")
            return
        }
        
        guard let filteredImage = applyFilter(to: image) else {
            print("Error: Couldn't apply filter.")
            return
        }
        
        let scale = filteredImage.size.width / imageView.frame.width
        let cropRect = CGRect(
            x: (frameView.frame.origin.x - imageView.frame.origin.x) * scale,
            y: (frameView.frame.origin.y - imageView.frame.origin.y) * scale,
            width: frameView.frame.width * scale,
            height: frameView.frame.height * scale
        ).integral
        
        if let croppedImage = cropImage(image: filteredImage, toRect: cropRect) {
            UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        } else {
            print("Error: Couldn't crop image.")
        }
    }
    
    @objc private func filterSwitchChanged() {
        guard let image = originalImage else { return }
        imageView.image = applyFilter(to: image)
        updateImageViewMask()
    }
    
    @objc private func handlePinchGestureForImageView(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let scale = gesture.scale
        
        view.transform = view.transform.scaledBy(x: scale, y: scale)
        
        updateImageViewMask()
        
        gesture.scale = 1
    }
    
    @objc private func handleFrameViewPinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let scale = gesture.scale
        imageView.transform = imageView.transform.scaledBy(x: scale, y: scale)
        gesture.scale = 1
        updateImageViewMask()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: containerView)
        if let frame = gesture.view {
            var newCenter = CGPoint(x: frame.center.x + translation.x, y: frame.center.y + translation.y)
            
            newCenter.x = max(newCenter.x, frame.frame.width / 2)
            newCenter.x = min(newCenter.x, containerView.bounds.width - frame.frame.width / 2)
            newCenter.y = max(newCenter.y, frame.frame.height / 2)
            newCenter.y = min(newCenter.y, containerView.bounds.height - frame.frame.height / 2)
            
            frame.center = newCenter
            
            updateImageViewMask()

            gesture.setTranslation(.zero, in: containerView)
        }
    }
}

// MARK: - Extensions

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            originalImage = selectedImage
            imageView.image = applyFilter(to: selectedImage)
            updateImageViewMask()
        }
        picker.dismiss(animated: true)
        
        frameView.isHidden = false
        addPhotoButton.isHidden = true
        filterSwitch.isHidden = false
        filterLabel.isHidden = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


