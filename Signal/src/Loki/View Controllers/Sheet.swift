
class Sheet : BaseVC {
    private(set) var bottomConstraint: NSLayoutConstraint!

    // MARK: Settings
    let overshoot: CGFloat = 40

    // MARK: Components
    lazy var contentView: UIView = {
        let result = UIView()
        result.backgroundColor = Colors.modalBackground
        result.layer.cornerRadius = 24
        result.layer.masksToBounds = false
        result.layer.borderColor = Colors.modalBorder.cgColor
        result.layer.borderWidth = Values.borderThickness
        result.layer.shadowColor = UIColor.black.cgColor
        result.layer.shadowRadius = 8
        result.layer.shadowOpacity = 0.64
        return result
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0x000000).withAlphaComponent(Values.modalBackgroundOpacity)
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(close))
        swipeGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeGestureRecognizer)
        setUpViewHierarchy()
    }

    private func setUpViewHierarchy() {
        view.addSubview(contentView)
        contentView.pin(.leading, to: .leading, of: view, withInset: -Values.borderThickness)
        contentView.pin(.trailing, to: .trailing, of: view, withInset: Values.borderThickness)
        bottomConstraint = contentView.pin(.bottom, to: .bottom, of: view, withInset: overshoot)
        populateContentView()
    }

    /// To be overridden by subclasses.
    func populateContentView() {
        preconditionFailure("populateContentView() is abstract and must be overridden.")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Animate
//        bottomConstraint.constant = contentView.height()
//        view.layoutIfNeeded()
//        bottomConstraint.constant = overshoot
//        UIView.animate(withDuration: 0.25) {
//            self.view.layoutIfNeeded()
//        }
    }

    // MARK: Interaction
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: view)
        if contentView.frame.contains(location) {
            super.touchesBegan(touches, with: event)
        } else {
            close()
        }
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
