//
//  Settings.swift
//  Test
//
//  Created by 隋冬阳 on 2023/8/31.
//

import UIKit
import SnapKit

class ThemeButton: CalendarButton {
    
    @objc var color2View: UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init() {
        super.init()
        color2View = UIView()
        color2View.isUserInteractionEnabled = false
        if let imageView = self.imageView {
            insertSubview(color2View, belowSubview: imageView)
            color2View.snp.makeConstraints { make in
                make.left.right.bottom.equalTo(self)
                make.height.equalTo(self).multipliedBy(0.5)
            }
        }
    }
    
    
}

let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenWidth = UIScreen.main.bounds.size.width

class Theme: NSObject {
    @objc var color: String
    @objc var color2: String
    init(colors: [String]) {
        self.color = colors.first ?? ""
        self.color2 = colors.last ?? ""
    }
}

class Instrument: NSObject {
    var name: String
    init(name: String) {
        self.name = name
    }
}

class SettingsController: UIViewController {
    
    @objc weak var calendar: ViewController?
    
    var themeContainer: UIView!
    var instrumentContainer: UIView!
    var dateButtons: [UIButton] = []
    var buttonMark: UIView!
    
    @objc var themes: [Theme] { [
        ["#D14D72", "#F6BA6F"],
        ["#617143", "#FFB84C"],
        ["#B83B5E", "#3F72AF"],
        ["#3F72AF", "#BE9FE1"],
        ["#3F72AF", "#FFBCBC"],
        ["#F38BA0", "#609966"],
        ["#609966", "#F38BA0"],
        ["#495464", "#BBBFCA"],
        ["#645CAA", "#FF8DC7"],
        ["#6155A6", "#FFAAA5"],
        ["#7579E7", "#5B8A72"],
        ].map { Theme(colors: $0) }
    }
    
    @objc var instruments: [Instrument] { [
        Instrument(name: "木琴（Xylophone）"),
        Instrument(name: "马林巴琴（Marimba）"),
        Instrument(name: "钢琴（Yamaha Grand Piano）"),
        ]
    }
    
    @objc var themeIndex = UserDefaults.standard.integer(forKey: "themeIndex")
    @objc var instrumentIndex = UserDefaults.standard.integer(forKey: "instrumentIndex")
    
    @objc lazy var firstDayOfSchedule: Date? = {
        var dateString = UserDefaults.standard.string(forKey: "firstDayOfSchedule")
        if dateString == nil {
            dateString = "20230817"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: dateString!)
    }()
    
    var dateFormatter = DateFormatter()
    var dates: [Date] = []
    
    var isUpdateTheme: Bool = false
    var isUpdateSchedule: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexString: "#f7f7f7")
        buildUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isUpdateTheme {
            calendar?.update(themes[themeIndex])
        }
        if isUpdateSchedule {
            calendar?.updateSchedule()
        }
    }
    
    func buildUI() {
        
        // 主题
        let themeTitle = titleLabel("主题")
        view.addSubview(themeTitle)
        themeTitle.snp.makeConstraints { make in
            make.top.equalTo(view).inset(40)
            make.left.equalTo(view).inset(20)
            make.height.equalTo(30)
        }
        
        themeContainer = UIView()
        view.addSubview(themeContainer)
        themeContainer.snp.makeConstraints { make in
            make.top.equalTo(themeTitle.snp.bottom).offset(10)
            make.left.right.equalTo(view)
        }
        
        let edge: CGFloat = 20
        let padding: CGFloat = 6
        let count: Int = 6
        let width: CGFloat = (ScreenWidth - edge * 2.0 - padding * (CGFloat(count) - 1.0)) / CGFloat(count)
        
        for i in 0..<themes.count {

            let x: CGFloat = edge +  CGFloat(i % count) * (width + padding)
            let y: CGFloat = CGFloat(i / count) * (width + padding)

            let button = ThemeButton()
            button.backgroundColor = UIColor(hexString: themes[i].color)
            button.color2View.backgroundColor = UIColor(hexString: themes[i].color2)
            button.addTarget(self, action: #selector(touchDownThemeAction), for: .touchDown)
            button.addTarget(self, action: #selector(touchCancelThemeAction), for: .touchCancel)
            button.addTarget(self, action: #selector(selectThemeAction), for: .touchUpInside)
            if i == themeIndex {
                button.image = "checkmark"
            }
            
            themeContainer.addSubview(button)
            button.snp.makeConstraints { make in
                make.left.equalTo(themeContainer).inset(x)
                make.top.equalTo(themeContainer).inset(y)
                make.size.equalTo(CGSize(width: width, height: width))
                if i == themes.count - 1 {
                    make.bottom.equalTo(themeContainer)
                }
            }
        }
        
        // 乐器
        let instrumentTitle = titleLabel("乐器")
        view.addSubview(instrumentTitle)
        instrumentTitle.snp.makeConstraints { make in
            make.top.equalTo(themeContainer.snp.bottom).offset(30)
            make.left.equalTo(view).inset(20)
            make.height.equalTo(30)
        }
        
        instrumentContainer = UIView()
        view.addSubview(instrumentContainer)
        instrumentContainer.snp.makeConstraints { make in
            make.top.equalTo(instrumentTitle.snp.bottom).offset(10)
            make.left.right.equalTo(view)
        }
        
        for (i, I) in instruments.enumerated() {
            
            let cell = Bundle.main.loadNibNamed("InstrumentCell", owner: nil)?.first as! InstrumentCell
            cell.titleLabel.text = I.name
            if i == instrumentIndex {
                cell.imageView.image = UIImage(systemName: "checkmark")
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectInstrumentAction))
            cell.addGestureRecognizer(tap)
            
            instrumentContainer.addSubview(cell)
            cell.snp.makeConstraints { make in
                make.top.equalTo(instrumentContainer).inset(i * 44)
                make.left.right.equalTo(instrumentContainer).inset(20)
                make.height.equalTo(44)
                if i == instruments.count - 1 {
                    make.bottom.equalTo(instrumentContainer)
                }
            }
        }
        
        // 排班计划
        let schedulingTitle = titleLabel("排班计划")
        view.addSubview(schedulingTitle)
        schedulingTitle.snp.makeConstraints { make in
            make.top.equalTo(instrumentContainer.snp.bottom).offset(30)
            make.left.equalTo(view).inset(20)
            make.height.equalTo(30)
        }
        
        let description = UILabel()
        description.font = UIFont.systemFont(ofSize: 16)
        description.textColor = UIColor(hexString: "#999999")
        description.text = "新的排班计划中哪天是白班？"
        
        view.addSubview(description)
        description.snp.makeConstraints { make in
            make.top.equalTo(schedulingTitle.snp.bottom).offset(10)
            make.left.equalTo(schedulingTitle)
        }
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateFormatter.dateFormat = "dd日"
        dates.removeAll()
        
        var buttonIndex: Int = 0
        var anchorView: UIView?
        for i in 0...3 {
            let button = UIButton()
            button.tag = i
            dateButtons.append(button)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.setTitleColor(UIColor(hexString: "333333"), for: .normal)
            button.addTarget(self, action: #selector(selectDateAction), for: .touchUpInside)
            
            if let date = Calendar.current.date(from: components) {
                button.setTitle(dateFormatter.string(from: date), for: .normal)
                dates.append(date)
                let delta = Calendar.current.dateComponents([.day], from: firstDayOfSchedule!, to: date).day ?? 0
                let index = delta >= 0 ? delta % 4 : ((delta % 4 + 4) % 4)
                if index == 0 {
                    buttonIndex = i
                }
            }
            if let day = components.day {
                components.setValue(day + 1, for: .day)
            }
            
            
            view.addSubview(button)
            button.snp.makeConstraints { make in
                if anchorView == nil {
                    make.left.equalTo(view).inset(20)
                }else if let anchorView = anchorView {
                    make.left.equalTo(anchorView.snp.right).offset(10)
                }
                make.top.equalTo(description.snp.bottom).offset(16)
                make.height.equalTo(44)
                anchorView = button
            }
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        buttonMark = UIView()
        buttonMark.backgroundColor = UIColor(hexString: "#FFE5E5")
        buttonMark.cornerRadius = 8
        
        view.insertSubview(buttonMark, belowSubview: description)
        buttonMark.size = CGSize(width: 50, height: 50)
        buttonMark.center = dateButtons[buttonIndex].center
        
        
        
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor(hexString: "#333333")
        label.text = text
        return label
    }
    
    @objc func touchDownThemeAction(_ sender: CalendarButton) {
        UIView.animate {
            sender.layer.setAffineTransform(CGAffineTransformMakeScale(0.8, 0.8))
        }
    }
    
    @objc func touchCancelThemeAction(_ sender: CalendarButton) {
        UIView.animate {
            sender.layer.setAffineTransform(CGAffineTransform.identity)
        }
    }
    
    @objc func selectThemeAction(_ sender: CalendarButton) {
        UIView.animate {
            sender.layer.setAffineTransform(CGAffineTransform.identity)
        }
        impactFeedback()
        let index = themeContainer.subviews.firstIndex(of: sender) ?? 0
        if index == themeIndex {
            return
        }
        isUpdateTheme = true
        themeIndex = index
        UserDefaults.standard.set(themeIndex, forKey: "themeIndex")
        
        themeContainer.subviews.forEach {
            if $0 !== sender {
                ($0 as! CalendarButton).image = nil
            }else {
                sender.image = "checkmark"
            }
        }
    }
    
    @objc func selectInstrumentAction(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? InstrumentCell,
              let index = instrumentContainer.subviews.firstIndex(of: view) else {
            return
        }
        if index == instrumentIndex {
            return
        }
        instrumentIndex = index
        UserDefaults.standard.set(instrumentIndex, forKey: "instrumentIndex")
        
        instrumentContainer.subviews.forEach { ($0 as! InstrumentCell).image = nil }
        view.image = "checkmark"
        
        calendar?.updateInstrument(index)
        calendar?.audioTool.playInstrumentSelectionSound()
    }
    
    @objc func selectDateAction(_ sender: UIButton) {
        
        UIView.animate {
            self.buttonMark.center = sender.center
        }
        firstDayOfSchedule = dates[sender.tag]
        dateFormatter.dateFormat = "yyyyMMdd"
        UserDefaults.standard.set(dateFormatter.string(from: firstDayOfSchedule!), forKey: "firstDayOfSchedule")
        
        isUpdateSchedule = true
    }
    
    func impactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
}
