//
//  CGPathViewController.swift
//  LayerKit
//
//  Created by HL on 2018/8/13.
//  Copyright © 2018年 XL. All rights reserved.
//

import UIKit

class CGPathViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //    一、 CGMutablePath 的使用。
        
        // 设置绘制的路径
        let mutablePath = CGMutablePath.init()
        
        // 设置起始点
        mutablePath.move(to: CGPoint.init(x: 10, y: 10))
        
        // 添加路径
        mutablePath.addLine(to: CGPoint.init(x: 100, y: 10))
        
        // 闭合路径（路径最后一点到起始点）
        mutablePath.closeSubpath()
    }

    // MARK: 绘制虚线
    func drawDottedLine(rect:CGRect,context:CGContext) -> Void {
        // 设置绘制路径
        let paths = CGMutablePath.init()
        paths.move(to: CGPoint.init(x: 120, y: 100))
        paths.addLine(to: CGPoint.init(x: 320, y: 100))
        // 添加路径到上下文
        context.addPath(paths)
        // 设置颜色
        UIColor.green.set()
        // 设置画笔的宽度
        context.setLineWidth(5)
        /**
         设置间隔虚线
         */
        var lengthArray:[CGFloat]!
        // 先绘制16像素，在跳过8像素，在绘制16像素，在跳过8像素这样一直循环。
        lengthArray = [16,8]
        
        // 先绘制20像素，在跳过10像素，在绘制5像素，在跳过20像素，在绘制10像素，在跳过5像素，在绘制20像素...这样循环下去。
        lengthArray = [20,10,5]
        
        //  phase 是指先绘制的差值。 这个是先绘制 legth.first -  phase 像素，在跳过5像素，在绘制20像素，在跳过5像素，这样循环。
        lengthArray = [20, 5]
        context.setLineDash(phase: 10, lengths: lengthArray)
        // 绘制路径
        context.strokePath()
    }

    
    // MARK: 单点和两点控制曲线绘制
    func drawQuadCurve(rect:CGRect,context:CGContext) -> Void {
        // 设置绘制路径
        let paths = CGMutablePath.init()
        paths.move(to: CGPoint.init(x: 20, y: 100))
        /**
         /**
         单点控制曲线
         
         to: CGPoint :曲线的绘制结束点。
         control: CGPoint : 曲线绘制的控制点。
         transform : 曲线绘制的旋转角度。
         */
         paths.addQuadCurve(to: CGPoint.init(x: 220, y: 200), control: CGPoint.init(x: 120, y: 100), transform: .identity)
         */
        /**
         双点控制
         
         to: CGPoint :曲线的绘制结束点。
         control1: CGPoint : 曲线绘制的控制点一。
         control2: CGPoint : 曲线绘制的控制点二。
         transform : 曲线绘制的旋转角度。
         */
        paths.addCurve(to: CGPoint.init(x: 220, y: 300), control1: CGPoint.init(x: 80, y: 220), control2: CGPoint.init(x: 160, y: 150), transform: .identity)
        // 添加路径到上下文
        context.addPath(paths)
        // 设置颜色
        UIColor.green.set()
        // 设置画笔的宽度
        context.setLineWidth(5)
        // 绘制路径
        context.strokePath()
    }

    
    // MARK: 绘制圆弧曲线
    func drawCircularArc(rect:CGRect,context:CGContext)  {
        let paths = CGMutablePath.init()
        /**
         /**
         画一个简单的圆弧
         
         center: 圆弧的中心点。
         radius: 圆弧的半径。
         startAngle: 圆弧开始角度。
         endAngle: 结束圆弧的角度。
         clockwise: 是顺时针还是逆时针绘制圆弧。true为顺、false为逆。
         */
         paths.addArc(center: self.center, radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: true)
         
         /**
         绘制一个圆弧，没有结束的角度。
         
         center: 圆弧的中心点。
         radius: 圆弧的半径。
         startAngle: 圆弧开始角度。
         delta: 向前或者向后绘制弧度的大小。
         */
         paths.addRelativeArc(center: self.center, radius: 40, startAngle: 0, delta: .pi * 2)
         
         */
        // 设置画笔的起始点
        paths.move(to: CGPoint.init(x: 10, y: 10))
        /**
         有两个切点和半径绘制特定的圆弧
         
         tangent1End : 切点一。
         tangent2End : 切点二。
         radius : 圆的半径。
         */
        paths.addArc(tangent1End: CGPoint.init(x: 300, y: 100), tangent2End: CGPoint.init(x: 1, y: 200), radius: 40)
        context.addPath(paths)
        UIColor.red.set()
        context.setLineWidth(1)
        context.strokePath()
    }

    
    // MARK: 给定区域绘制椭圆
    func drawEllipse(rect:CGRect,context:CGContext) -> Void {
        let paths = CGMutablePath.init()
        /**
         绘制椭圆的函数
         
         CGRect: 绘制椭圆的大小。
         */
        paths.addEllipse(in: CGRect.init(x: 10, y: 20, width: 130, height: 200))
        context.addPath(paths)
        context.setLineWidth(2)
        UIColor.red.set()
        context.strokePath()
    }

    
    // MARK: 绘制四边形
    func drawAddRects(rect:CGRect,context:CGContext) -> Void {
        let paths = CGMutablePath.init()
        /**
         绘制函数
         // 另一种函数：
         public func addRects(_ rects: [CGRect], transform: CGAffineTransform = default)
         
         CGRect : 绘制四边形的大小。
         CGAffineTransform : 是指四边形绘制后的旋转。
         */
        paths.addRect(CGRect.init(x: 10, y: 10, width: 100, height: 200))
        context.addPath(paths)
        context.setLineWidth(2)
        UIColor.red.set()
        context.strokePath()
    }

    
    // MARK: 点之间绘制线段
    func drawAddLines(rect:CGRect,context:CGContext) -> Void {
        let paths = CGMutablePath.init()
        /**
         绘制的函数
         
         between : 是一个数组，里面存放的是多个点。
         */
        paths.addLines(between: [CGPoint.init(x: 40, y: 100),CGPoint.init(x: 100, y: 200)])
        context.addPath(paths)
        context.setLineWidth(2)
        UIColor.red.set()
        context.strokePath()
    }

    
    // MARk: 绘制带切角的四边形
    func drawAddRoundedRect(rect:CGRect,context:CGContext) -> Void {
        let paths = CGMutablePath.init()
        /**
         绘制函数
         
         CGRect: 绘制四边形的大小
         cornerWidth : 切角的宽
         cornerHeight: 切角的高
         
         注意： cornerWidth 的宽度的 2 倍不能超过 CGRect 的宽度。
         */
        paths.addRoundedRect(in: CGRect.init(x: 10, y: 20, width: 100, height: 100), cornerWidth: 3, cornerHeight: 2)
        context.addPath(paths)
        context.setLineWidth(2)
        UIColor.red.set()
        context.strokePath()
    }

    
    // MARK: 通过拷贝路径绘制虚线
    func pathCopys(rect:CGRect,context:CGContext) -> Void {
        let paths1 = CGMutablePath.init()
        paths1.move(to: CGPoint.init(x: 10, y: 10))
        paths1.addLine(to: CGPoint.init(x: 200, y: 200))
        paths1.closeSubpath()
        /**
         路径拷贝函数
         
         dashingWithPhase: 差度绘制。
         lengths: 绘制长度集合数组。
         */
        let path2 = paths1.copy(dashingWithPhase: 20, lengths: [20,30,80])
        print(path2)
        /**
         
         路径拷贝绘制
         
         strokingWithWidth : 绘制路径的宽度。
         lineCap : 绘制路径的尾端形状。
         lineJoin : 绘制路径拐弯点的形状。
         miterLimit : 路径绘制的切角最低限制。
         */
        let path3 = paths1.copy(strokingWithWidth: 10, lineCap: .round, lineJoin: .miter, miterLimit: 10)
        // 判断路径内是否包含某点。
        let isContent = path3.contains(CGPoint.init(x: 60, y: 60))
        print(isContent)
        context.addPath(path3)
        context.setLineWidth(5)
        UIColor.red.set()
        context.strokePath()
    }

    
    func pathKnowledge() -> Void {
        // 创建一个路径
        let paths = CGMutablePath.init()
        // 判断路径是否为空
        print(paths.isEmpty)
        // 添加路径
        paths.move(to: CGPoint.init(x: 10, y: 200))
        paths.addLine(to: CGPoint.init(x: 20, y: 100))
        paths.addLine(to: CGPoint.init(x: 30, y: 50))
        // 判断路径是否为空
        print(paths.isEmpty)
        // 获取路径当前的点
        print(paths.currentPoint)
        // 返回包含路径的最小矩形（包含二次曲线）
        print(paths.boundingBox)
        // 返回包含路径的最小矩形（不包含二次曲线）
        print(paths.boundingBoxOfPath)
        // 清楚路径
        paths.closeSubpath()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
