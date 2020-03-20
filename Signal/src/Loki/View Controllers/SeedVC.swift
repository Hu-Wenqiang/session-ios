
final class SeedVC : BaseVC {
    
    private let mnemonic: String = {
        let identityManager = OWSIdentityManager.shared()
        let databaseConnection = identityManager.value(forKey: "dbConnection") as! YapDatabaseConnection
        var hexEncodedSeed: String! = databaseConnection.object(forKey: "LKLokiSeed", inCollection: OWSPrimaryStorageIdentityKeyStoreCollection) as! String?
        if hexEncodedSeed == nil {
            hexEncodedSeed = identityManager.identityKeyPair()!.hexEncodedPrivateKey // Legacy account
        }
        return Mnemonic.encode(hexEncodedString: hexEncodedSeed)
    }()
    
    private lazy var redactedMnemonic: NSAttributedString = {
        var mnemonic = self.mnemonic
        let regex = try! NSRegularExpression(pattern: "\\w*", options: [])
        let matches = regex.matches(in: mnemonic, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: mnemonic.count))
        let result = NSMutableAttributedString(string: mnemonic)
        matches.forEach { match in
            result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.thick.rawValue, range: match.range)
            result.addAttribute(.strikethroughColor, value: Colors.accent, range: match.range)
        }
        return result
    }()
    
    // MARK: Components
    private lazy var seedReminderView: SeedReminderView = {
        let result = SeedReminderView(hasContinueButton: false)
        let title = "You're almost finished! 90%"
        let attributedTitle = NSMutableAttributedString(string: title)
        attributedTitle.addAttribute(.foregroundColor, value: Colors.accent, range: (title as NSString).range(of: "90%"))
        result.title = attributedTitle
        result.subtitle = NSLocalizedString("Tap and hold the redacted words to reveal your recovery phrase, then store it safely to secure your Session ID.", comment: "")
        result.setProgress(0.9, animated: false)
        return result
    }()
    
    private lazy var mnemonicLabel: UILabel = {
        let result = UILabel()
        result.textColor = Colors.text
        result.font = Fonts.spaceMono(ofSize: Values.mediumFontSize)
        result.numberOfLines = 0
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        return result
    }()
    
    private lazy var copyButton: Button = {
        let result = Button(style: .prominentOutline, size: .large)
        result.setTitle(NSLocalizedString("Copy", comment: ""), for: UIControl.State.normal)
        result.addTarget(self, action: #selector(copyMnemonic), for: UIControl.Event.touchUpInside)
        return result
    }()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set gradient background
        view.backgroundColor = .clear
        let gradient = Gradients.defaultLokiBackground
        view.setGradient(gradient)
        // Set up navigation bar
        let navigationBar = navigationController!.navigationBar
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = Colors.navigationBarBackground
        // Customize title
        let navigationBarTitleLabel = UILabel()
        navigationBarTitleLabel.text = NSLocalizedString("Your Recovery Phrase", comment: "")
        navigationBarTitleLabel.textColor = Colors.text
        let titleLabelFontSize = isSmallScreen ? Values.largeFontSize : Values.veryLargeFontSize
        navigationBarTitleLabel.font = .boldSystemFont(ofSize: titleLabelFontSize)
        navigationItem.titleView = navigationBarTitleLabel
        // Set up navigation bar buttons
        let closeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "X"), style: .plain, target: self, action: #selector(close))
        closeButton.tintColor = Colors.text
        navigationItem.leftBarButtonItem = closeButton
        // Set up title label
        let titleLabel = UILabel()
        titleLabel.textColor = Colors.text
        titleLabel.font = .boldSystemFont(ofSize: isSmallScreen ? Values.largeFontSize : Values.veryLargeFontSize)
        titleLabel.text = NSLocalizedString("Meet your recovery phrase", comment: "")
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        // Set up explanation label
        let explanationLabel = UILabel()
        explanationLabel.textColor = Colors.text
        explanationLabel.font = .systemFont(ofSize: Values.smallFontSize)
        explanationLabel.text = NSLocalizedString("Your recovery phrase is the master key to your Session ID — you can use it to restore your Session ID if you lose access to your device. Store your recovery phrase in a safe place, and don’t give it to anyone. To restore your Session ID, launch Session and tap Continue your Session.", comment: "")
        explanationLabel.numberOfLines = 0
        explanationLabel.lineBreakMode = .byWordWrapping
        // Set up mnemonic label
        mnemonicLabel.attributedText = redactedMnemonic
        let mnemonicLabelGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealMnemonic))
        mnemonicLabel.addGestureRecognizer(mnemonicLabelGestureRecognizer)
        mnemonicLabel.isUserInteractionEnabled = true
        mnemonicLabel.isEnabled = true
        // Set up mnemonic label container
        let mnemonicLabelContainer = UIView()
        mnemonicLabelContainer.addSubview(mnemonicLabel)
        mnemonicLabel.pin(to: mnemonicLabelContainer, withInset: isSmallScreen ? Values.smallSpacing : Values.mediumSpacing)
        mnemonicLabelContainer.layer.cornerRadius = Values.textFieldCornerRadius
        mnemonicLabelContainer.layer.borderWidth = Values.borderThickness
        mnemonicLabelContainer.layer.borderColor = Colors.text.cgColor
        // Set up call to action label
        let callToActionLabel = UILabel()
        callToActionLabel.textColor = Colors.text.withAlphaComponent(Values.unimportantElementOpacity)
        callToActionLabel.font = .systemFont(ofSize: isSmallScreen ? Values.smallFontSize : Values.mediumFontSize)
        callToActionLabel.text = NSLocalizedString("Hold to reveal", comment: "")
        callToActionLabel.textAlignment = .center
        let callToActionLabelGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealMnemonic))
        callToActionLabel.addGestureRecognizer(callToActionLabelGestureRecognizer)
        callToActionLabel.isUserInteractionEnabled = true
        callToActionLabel.isEnabled = true
        // Set up spacers
        let topSpacer = UIView.vStretchingSpacer()
        let bottomSpacer = UIView.vStretchingSpacer()
        // Set up copy button container
        let copyButtonContainer = UIView()
        copyButtonContainer.addSubview(copyButton)
        copyButton.pin(.leading, to: .leading, of: copyButtonContainer, withInset: Values.massiveSpacing)
        copyButton.pin(.top, to: .top, of: copyButtonContainer)
        copyButtonContainer.pin(.trailing, to: .trailing, of: copyButton, withInset: Values.massiveSpacing)
        copyButtonContainer.pin(.bottom, to: .bottom, of: copyButton)
        // Set up top stack view
        let topStackView = UIStackView(arrangedSubviews: [ titleLabel, explanationLabel, mnemonicLabelContainer, callToActionLabel ])
        topStackView.axis = .vertical
        topStackView.spacing = isSmallScreen ? Values.smallSpacing : Values.largeSpacing
        topStackView.alignment = .fill
        // Set up top stack view container
        let topStackViewContainer = UIView()
        topStackViewContainer.addSubview(topStackView)
        topStackView.pin(.leading, to: .leading, of: topStackViewContainer, withInset: Values.veryLargeSpacing)
        topStackView.pin(.top, to: .top, of: topStackViewContainer)
        topStackViewContainer.pin(.trailing, to: .trailing, of: topStackView, withInset: Values.veryLargeSpacing)
        topStackViewContainer.pin(.bottom, to: .bottom, of: topStackView)
        // Set up seed reminder view
        view.addSubview(seedReminderView)
        seedReminderView.pin(.leading, to: .leading, of: view)
        seedReminderView.pin(.top, to: .top, of: view)
        seedReminderView.pin(.trailing, to: .trailing, of: view)
        // Set up main stack view
        let mainStackView = UIStackView(arrangedSubviews: [ topSpacer, topStackViewContainer, bottomSpacer, copyButtonContainer ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.layoutMargins = UIEdgeInsets(top: 0, leading: 0, bottom: Values.mediumSpacing, trailing: 0)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(mainStackView)
        mainStackView.pin(.leading, to: .leading, of: view)
        mainStackView.pin(.top, to: .bottom, of: seedReminderView)
        mainStackView.pin(.trailing, to: .trailing, of: view)
        mainStackView.pin(.bottom, to: .bottom, of: view)
        topSpacer.heightAnchor.constraint(equalTo: bottomSpacer.heightAnchor, multiplier: 1).isActive = true
    }
    
    // MARK: General
    @objc private func enableCopyButton() {
        copyButton.isUserInteractionEnabled = true
        UIView.transition(with: copyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyButton.setTitle(NSLocalizedString("Copy", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
    }
    
    // MARK: Interaction
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func revealMnemonic() {
        UIView.transition(with: mnemonicLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.mnemonicLabel.attributedText = NSAttributedString(string: self.mnemonic)
        }, completion: nil)
        UIView.transition(with: seedReminderView.titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            let title = "Account Secured! 100%"
            let attributedTitle = NSMutableAttributedString(string: title)
            attributedTitle.addAttribute(.foregroundColor, value: Colors.accent, range: (title as NSString).range(of: "100%"))
            self.seedReminderView.title = attributedTitle
        }, completion: nil)
        UIView.transition(with: seedReminderView.subtitleLabel, duration: 1, options: .transitionCrossDissolve, animations: {
            self.seedReminderView.subtitle = NSLocalizedString("Make sure to store your recovery phrase in a safe place", comment: "")
        }, completion: nil)
        seedReminderView.setProgress(1, animated: true)
        UserDefaults.standard[.hasViewedSeed] = true
        NotificationCenter.default.post(name: .seedViewed, object: nil)
    }
    
    @objc private func copyMnemonic() {
        revealMnemonic()
        UIPasteboard.general.string = mnemonic
        copyButton.isUserInteractionEnabled = false
        UIView.transition(with: copyButton, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.copyButton.setTitle(NSLocalizedString("Copied", comment: ""), for: UIControl.State.normal)
        }, completion: nil)
        Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(enableCopyButton), userInfo: nil, repeats: false)
    }
}
