//  UIImage+Resize.swift
//  BeMeChallenge

import UIKit

extension UIImage {
    /// 지정한 최대 픽셀 길이를 넘지 않도록 비율에 맞춰 리사이즈
    func resized(maxPixel: CGFloat) -> UIImage {
        let widthRatio  = maxPixel / size.width
        let heightRatio = maxPixel / size.height
        let ratio = min(widthRatio, heightRatio)

        // 이미 최대 크기 이하라면 그대로 반환
        guard ratio < 1 else { return self }

        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )

        // 그래픽 컨텍스트에서 리사이즈
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
