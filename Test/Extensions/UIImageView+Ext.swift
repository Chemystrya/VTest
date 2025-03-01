//
//  UIImageView+Ext.swift
//  Test
//
//  Created by Fedorova Maria on 01.03.2025.
//

import UIKit

private class ImageCache {

    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    func image(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func save(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

}

extension UIImageView {

    private static var taskKey = 0
    private static var urlKey = 0

    private var currentTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &Self.taskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &Self.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var currentURL: String? {
        get { objc_getAssociatedObject(self, &Self.urlKey) as? String }
        set { objc_setAssociatedObject(self, &Self.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func setImage(stringUrl: String?, placeholder: UIImage? = nil) {
        currentTask?.cancel()
        currentTask = nil

        image = placeholder

        guard let stringUrl, let url = URL(string: stringUrl) else { return }

        currentURL = url.absoluteString

        if let cachedImage = ImageCache.shared.image(for: url.absoluteString) {
            self.image = cachedImage
            return
        }

        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self, let data = data, let image = UIImage(data: data) else { return }

            ImageCache.shared.save(image, for: url.absoluteString)

            DispatchQueue.main.async {
                if self.currentURL == url.absoluteString {
                    UIView.transition(
                        with: self,
                        duration: 0.3,
                        options: .transitionCrossDissolve,
                        animations: { self.image = image },
                        completion: nil
                    )
                }
            }
        }
        currentTask?.resume()
    }
    
}
