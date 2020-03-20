
final class SeedReminderView : UIView {
    private let hasContinueButton: Bool
    var title = NSAttributedString(string: "") { didSet { titleLabel.attributedText = title } }
    var subtitle = "" { didSet { subtitleLabel.text = subtitle } }
    var delegate: SeedReminderViewDelegate?
    
    // MARK: Components
    private lazy var progressIndicatorView: UIProgressView = {
        let result = UIProgressView()
        result.progressViewStyle = .bar
        result.progressTintColor = Colors.accent
        result.backgroundColor = isLightMode ? UIColor(hex: 0x000000).withAlphaComponent(0.1) : UIColor(hex: 0xFFFFFF).withAlphaComponent(0.1)
        result.set(.height, to: Values.progressBarThickness)
        return result
    }()
    
    lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = .boldSystemFont(ofSize: Values.smallFontSize)
        result.lineBreakMode = .byTruncatingTail
        return result
    }()
    
    lazy var subtitleLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text.withAlphaComponent(Values.unimportantElementOpacity)
        result.font = .systemFont(ofSize: Values.verySmallFontSize)
        result.lineBreakMode = .byWordWrapping
        result.numberOfLines = 0
        return result
    }()
    
    // MARK: Lifecycle
    init(hasContinueButton: Bool) {
        self.hasContinueButton = hasContinueButton
        super.init(frame: CGRect.zero)
        setUpViewHierarchy()
    }
    
    override init(frame: CGRect) {
        preconditionFailure("Use init(hasContinueButton:) instead.")
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("Use init(hasContinueButton:) instead.")
    }
    
    private func setUpViewHierarchy() {
        // Set background color
        backgroundColor = Colors.cellBackground
        // Set up label stack view
        let labelStackView = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel ])
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        // Set up button
        let button = Button(style: .prominentOutline, size: .small)
        button.setTitle(NSLocalizedString("Continue", comment: ""), for: UIControl.State.normal)
        button.set(.width, to: 80)
        button.addTarget(self, action: #selector(handleContinueButtonTapped), for: UIControl.Event.touchUpInside)
        // Set up content stack view
        let contentStackView = UIStackView(arrangedSubviews: [ labelStackView ])
        if hasContinueButton {
            contentStackView.addArrangedSubview(UIView.hStretchingSpacer())
            contentStackView.addArrangedSubview(button)
        }
        contentStackView.axis = .horizontal
        contentStackView.spacing = 4
        contentStackView.alignment = .center
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, leading: Values.mediumSpacing + Values.accentLineThickness, bottom: 0, trailing: Values.mediumSpacing)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        // Set up separator
        let separator = UIView()
        separator.set(.height, to: Values.separatorThickness)
        separator.backgroundColor = Colors.separator
        // Set up stack view
        let stackView = UIStackView(arrangedSubviews: [ progressIndicatorView, contentStackView, separator ])
        stackView.axis = .vertical
        stackView.spacing = Values.mediumSpacing
        addSubview(stackView)
        stackView.pin(to: self)
    }
    
    // MARK: Updating
    func setProgress(_ progress: Float, animated isAnimated: Bool) {
        progressIndicatorView.setProgress(progress, animated: isAnimated)
    }
    
    // MARK: Updating
    @objc private func handleContinueButtonTapped() {
        delegate?.handleContinueButtonTapped(from: self)
    }
}
