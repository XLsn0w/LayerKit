//
//  ViewController.swift
//  Draw
//
//  Created by HL on 2018/8/7.
//  Copyright © 2018年 XL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var isOpen:Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label);
        label.layer.addSublayer(shape);

//      let v:DrawView = DrawView.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
//      view.addSubview(v)
        
        let contentsImg = UIView.init(frame: CGRect.init(x: 100, y: 50, width: 200, height: 200))
        view.addSubview(contentsImg)
        contentsImg.layer.contents = UIImage.init(named: "contents.jpg")?.cgImage

//      view.layer.contents = UIImage.init(named: "contents.jpg")?.cgImage
///我们利用CALayer在一个普通的UIView中显示了一张图片。这不是一个UIImageView，它不是我们通常用来展示图片的方法。通过直接操作图层，我们使用了一些新的函数，使得UIView更加有趣了。
        
        
        let model = Model();
        let dic = [String : String]()
        model.setValuesForKeys(dic)
//        在swift3中，编译器自动推断@objc，它自动添加@objc
//        在swift4中，编译器不再自动推断，必须显式添加@objc
    }

    private lazy var label:UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: 100, y: 300, width: 100, height: 100));
        label.text = "UILabel";
        label.textAlignment = .center;
        return label;
    }()
    
    private lazy var shape:CAShapeLayer = {
        let path = UIBezierPath.init(roundedRect: self.label.bounds, byRoundingCorners: .allCorners , cornerRadii: self.label.bounds.size);
        let layer = CAShapeLayer.init();
        layer.path = path.cgPath;
        layer.lineWidth = 5;
        layer.lineCap = kCALineCapRound;
        layer.strokeColor = UIColor.red.cgColor;
        //  注意直接填充layer的颜色，不需要设置控件view的backgroundColor
//        layer.fillColor = UIColor.yellow.cgColor;
//        shape.contents = (__bridge id)[UIImage imageNamed:@"contents.jpg"].CGImage;
//        shape.contentsGravity = kCAGravityResizeAspect;
        layer.contents = UIImage.init(named: "contents.jpg")?.cgImage
        
        return layer;
    }()

}

