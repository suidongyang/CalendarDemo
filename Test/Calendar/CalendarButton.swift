//
//  CalendarButton.swift
//  Test
//
//  Created by 隋冬阳 on 2023/8/26.
//

import UIKit
import LTMorphingLabel
import SnapKit


class MorphingLabel: LTMorphingLabel {

    override var text: String? {
        get {
            return super.text ?? ""
        }
        set {
            // 修复连续多次设置nil导致动画异常的问题
            if text == "" && newValue == nil {
                return
            }
            super.text = newValue
        }
    }
}


@objc enum ButtonStyle: Int {
    case normal
    case month
    case weekday
    case date
    case text
    case action
}

@objc class CalendarButton: UIButton {
    
    var label: MorphingLabel!
    var labelCenterY: Constraint!
    
    var indicator: UIImageView!
    var indicatorCenterY: Constraint!
    var isIndicatorShow: Bool = false
    
    @objc var hexColor: String!
    var colorAlpha: CGFloat = 0
    var timer: CADisplayLink?
    var flag: Int = 0
    
    @objc var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @objc var style: ButtonStyle = .normal {
        didSet {
            switch style {
            case .normal:
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            case .month:
                label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
                label.morphingEffect = .fall
            case .weekday:
                let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
                label.text = weekdays[tag - 14]
                label.textColor = UIColor(white: 1, alpha: 0.8)
                label.font = UIFont.systemFont(ofSize: 17)
            case .date:
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.morphingEffect = .pixelate
            case .text:
                label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
                label.morphingEffect = .evaporate
            case .action:
                tintColor = UIColor(white: 1, alpha: 0.7)
            default:
                break
            }
        }
    }
    
    @objc var image: String? {
        didSet {
            guard let imageName = image else {
                style = .normal
                UIView.animate {
                    self.imageView?.alpha = 0
                } completion: {
                    self.setImage(nil, for: .normal)
                    self.setImage(nil, for: .highlighted)
                }
                return
            }
            style = .action
            var image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
            if image == nil {
                image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
            }
            imageView?.alpha = 0;
            setImage(image, for: .normal)
            setImage(image, for: .highlighted)
            UIView.animate {
                self.imageView?.alpha = 1;
            }
        }
    }
    
    @objc var text: String? {
        didSet {
            if morphingEnabled {
                label.text = text
            }else {
                if text == nil {
                    UIView.animate {
                        self.label.alpha = 0
                    } completion: {
                        self.label.text = nil
                        self.label.alpha = 1
                    }
                }else {
                    label.text = text
                }
            }
        }
    }
    
    @objc var indicatorIndex: Int = 0 {
        didSet {
            if style != .date {
                return
            }
            let images = ["sun.max.fill", "moon.fill"]
            switch indicatorIndex {
            case let i where i >= 0 && i <= 1:
                if isIndicatorShow {
                    if indicator.image != nil {
                        if indicatorIndex == oldValue {
                            return
                        }
                        UIView.animate {
                            self.indicator.alpha = 0
                        } completion: {
                            self.indicator.image = UIImage(systemName: images[i])
                            UIView.animate {
                                self.indicator.alpha = 0.5
                            }
                        }
                    }else {
                        indicator.image = UIImage(systemName: images[i])
                        UIView.animate {
                            self.indicator.alpha = 0.5
                        }
                    }
                }else {
                    indicator.image = UIImage(systemName: images[i])
                }
            default:
                UIView.animate {
                    self.indicator.alpha = 0
                } completion: {
                    self.indicator.image = nil
                }
            }
        }
    }
    
    @objc var morphingEnabled: Bool = false {
        didSet {
            label.morphingEnabled = morphingEnabled
        }
    }
    
    @objc var date: Date?
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = false
        tintColor = .white
        layer.borderColor = UIColor.white.cgColor
        
        indicator = UIImageView()
        indicator.alpha = 0
        
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            self.indicatorCenterY = make.centerY.equalTo(self).constraint
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        label = MorphingLabel()
        label.textColor = .white // UIColor(hexString: "#DBE2EF")
        label.textAlignment = .center
        label.morphingEnabled = false
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            self.labelCenterY = make.centerY.equalTo(self).constraint
            make.width.equalTo(self)
            make.height.equalTo(self).multipliedBy(3)
        }
    }
    
    @objc func applyColor(_ color: String, alpha: CGFloat) {
        
        hexColor = color
        colorAlpha = alpha;
        backgroundColor = UIColor(hexString: hexColor, alpha: colorAlpha)
        
        /*
         if timer == nil {
             timer = CADisplayLink(target: self, selector: #selector(update))
             timer?.add(to: RunLoop.main, forMode: .common)
             flag = Int(arc4random_uniform(2))
         }*/
    }
    
    @objc func update() {
        // 0.5 - 0.9 5s  0.4 / 5 / 60
        if colorAlpha >= 0.7 && colorAlpha <= 0.9 {
            if flag == 0 {
                colorAlpha -= 0.002
            }else {
                colorAlpha += 0.002
            }
        }else if colorAlpha < 0.7 {
            flag = 1
            colorAlpha += 0.002
        }else if colorAlpha > 0.9 {
            flag = 0
            colorAlpha -= 0.002
        }
        backgroundColor = UIColor(hexString: hexColor, alpha: colorAlpha)
    }
    
    @objc func showIndicator(_ show: Bool) {
        isIndicatorShow = show
        UIView.animate {
            if show {
                self.indicator.alpha = 0.5
                self.labelCenterY.layoutConstraints.first?.constant -= 10
                self.indicatorCenterY.layoutConstraints.first?.constant += 10
            }else {
                self.indicator.alpha = 0
                self.labelCenterY.layoutConstraints.first?.constant += 10
                self.indicatorCenterY.layoutConstraints.first?.constant -= 10
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc func clear() {
        self.label.text = nil
        UIView.animate {
            self.indicator.alpha = 0
            self.layer.borderWidth = 0
        } completion: {
            self.indicator.image = nil
            self.layer.borderColor = UIColor.white.cgColor
        }
    }
    
}
