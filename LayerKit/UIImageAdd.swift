//
//  UIImageAdd.swift
//  LayerKit
//
//  Created by HL on 2018/8/14.
//  Copyright © 2018年 XL. All rights reserved.
//

import Foundation

//extension UIImage {
//                  func kt_drawRectWithRoundedCorner(radius radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
//                                        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
//        
//                                        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
//                                        CGContextAddPath(UIGraphicsGetCurrentContext(),
//                                                                                                                                         UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners,
//                                                                                                                                                                                                                                                                      cornerRadii: CGSize(width: radius, height: radius)).CGPath)
//                                        CGContextClip(UIGraphicsGetCurrentContext())
//        
//                                        self.drawInRect(rect)
//                                        CGContextDrawPath(UIGraphicsGetCurrentContext(), .FillStroke)
//                                        let output = UIGraphicsGetImageFromCurrentImageContext();
//                                        UIGraphicsEndImageContext();
//        
//                                        return output
//                        }
//}
