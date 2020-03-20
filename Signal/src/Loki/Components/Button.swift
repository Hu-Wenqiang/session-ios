
final class Button : UIButton {
    private let style: Style
    private let size: Size
    
    enum Style {
        case unimportant, regular, prominentOutline, prominentFilled, regularBorderless
    }
    
    enum Size {
        case medium, large, small
    }
    
    init(style: Style, size: Size) {
        self.style = style
        self.size = size
        super.init(frame: .zero)
        setUpStyle()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(style:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(style:) instead.")
    }
    
    private func setUpStyle() {
        let fillColor: UIColor
        switch style {
        case .unimportant: fillColor = Colors.unimportantButtonBackground
        case .regular: fillColor = UIColor.clear
        case .prominentOutline: fillColor = UIColor.clear
        case .prominentFilled: fillColor = Colors.accent
        case .regularBorderless: fillColor = UIColor.clear
        }
        let borderColor: UIColor
        switch style {
        case .unimportant: borderColor = isLightMode ? Colors.text : Colors.unimportantButtonBackground
        case .regular: borderColor = Colors.text
        case .prominentOutline: borderColor = Colors.accent
        case .prominentFilled: borderColor = Colors.accent
        case .regularBorderless: borderColor = UIColor.clear
        }
        let textColor: UIColor
        switch style {
        case .unimportant: textColor = Colors.text
        case .regular: textColor = Colors.text
        case .prominentOutline: textColor = Colors.accent
        case .prominentFilled: textColor = Colors.text
        case .regularBorderless: textColor = Colors.text
        }
        let height: CGFloat
        switch size {
        case .small: height = Values.smallButtonHeight
        case .medium: height = Values.mediumButtonHeight
        case .large: height = Values.largeButtonHeight
        }
        set(.height, to: height)
        layer.cornerRadius = height / 2
        backgroundColor = fillColor
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = Values.borderThickness
        let fontSize = (size == .small) ? Values.smallFontSize : Values.mediumFontSize
        titleLabel!.font = .boldSystemFont(ofSize: fontSize)
        setTitleColor(textColor, for: UIControl.State.normal)
    }
}
