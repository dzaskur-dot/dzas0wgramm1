import UIKit

/// Анимированная заставка запуска dzas0wGRAMM.
/// Чёрный фон, иконка-цветок рисуется линией, буквы названия выезжают по очереди,
/// затем заставка плавно исчезает и удаляется из иерархии.
public final class SplashAnimationView: UIView {
    public var onFinish: (() -> Void)?

    private let content = UIView()
    private let iconView = UIView()
    private let flowerLayer = CAShapeLayer()
    private let nameStack = UIStackView()
    private var letterLabels: [UILabel] = []

    public init(frame: CGRect, appName: String = "dzas0wGRAMM") {
        super.init(frame: frame)
        backgroundColor = .black
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setup(appName: appName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Цветок из шести лепестков (контуром), нарисован в квадрате 100x100.
    private static func flowerPath() -> UIBezierPath {
        let result = UIBezierPath()
        let center = CGPoint(x: 50, y: 50)
        for i in 0..<6 {
            let petal = UIBezierPath(ovalIn: CGRect(x: 41, y: 10, width: 18, height: 38))
            var t = CGAffineTransform(translationX: center.x, y: center.y)
            t = t.rotated(by: CGFloat(i) * .pi / 3)
            t = t.translatedBy(x: -center.x, y: -center.y)
            petal.apply(t)
            result.append(petal)
        }
        return result
    }

    private func setup(appName: String) {
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(iconView)

        flowerLayer.path = SplashAnimationView.flowerPath().cgPath
        flowerLayer.fillColor = UIColor.clear.cgColor
        flowerLayer.strokeColor = UIColor.white.cgColor
        flowerLayer.lineWidth = 2.5
        flowerLayer.lineCap = .round
        flowerLayer.lineJoin = .round
        flowerLayer.strokeEnd = 0
        iconView.layer.addSublayer(flowerLayer)

        nameStack.translatesAutoresizingMaskIntoConstraints = false
        nameStack.axis = .horizontal
        nameStack.alignment = .center
        nameStack.spacing = 0
        content.addSubview(nameStack)

        let nameFont = UIFont(name: "Georgia", size: 22) ?? UIFont.systemFont(ofSize: 22)
        for ch in appName {
            let label = UILabel()
            label.text = String(ch)
            label.textColor = .white
            label.font = nameFont
            label.alpha = 0
            nameStack.addArrangedSubview(label)
            letterLabels.append(label)
        }

        NSLayoutConstraint.activate([
            content.centerXAnchor.constraint(equalTo: centerXAnchor),
            content.centerYAnchor.constraint(equalTo: centerYAnchor),

            iconView.topAnchor.constraint(equalTo: content.topAnchor),
            iconView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),

            nameStack.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 22),
            nameStack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            nameStack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            nameStack.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])
    }

    /// Запускает анимацию. Вызывать после добавления view в окно.
    public func start() {
        layoutIfNeeded()

        for label in letterLabels {
            label.alpha = 0
            label.transform = CGAffineTransform(translationX: 0, y: 10)
        }

        let draw = CABasicAnimation(keyPath: "strokeEnd")
        draw.fromValue = 0
        draw.toValue = 1
        draw.duration = 1.4
        draw.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        flowerLayer.strokeEnd = 1
        flowerLayer.add(draw, forKey: "draw")

        for (index, label) in letterLabels.enumerated() {
            UIView.animate(withDuration: 0.5, delay: 1.2 + 0.06 * Double(index), options: [.curveEaseOut], animations: {
                label.alpha = 1
                label.transform = .identity
            }, completion: nil)
        }

        UIView.animate(withDuration: 0.5, delay: 3.2, options: [.curveEaseIn], animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
            self.onFinish?()
        })
    }
}
