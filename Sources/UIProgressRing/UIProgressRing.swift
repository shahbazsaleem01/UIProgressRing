
import UIKit

public typealias Degree = Double

public class RingShapeLayer: CAShapeLayer{
    
    var config = Config()
    
    public func setFrame(frame: CGRect){
        self.frame = frame
        setNeedsDisplay()
        
        configure(config: Config())
    }
    
    public func configure(config: Config){
        self.config = config
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        path = UIBezierPath(arcCenter: center,
                            radius: CGFloat((bounds.height/2) - CGFloat(config.lineWidth/2)),
                                      startAngle: CGFloat(config.startAngleNormalized.radian),
                                      endAngle: CGFloat(config.endAngleNormalized.radian),
                                      clockwise: true).cgPath
        
        fillColor = UIColor.clear.cgColor
        strokeColor = config.color.cgColor
        lineWidth = config.lineWidth
        strokeEnd = config.strokeEnd
        lineDashPattern = config.lineDashPattern
    }
    
    public struct Config{
        public var startAngle: Degree
        public var endAngle: Degree
        public var lineWidth: CGFloat
        public var color: UIColor
        public var strokeEnd: CGFloat
        public var lineDashPattern: [NSNumber]
        
        var startAngleNormalized: Degree{
            startAngle.normalizedAngle
        }
        
        var endAngleNormalized: Degree{
            var angle: Degree = endAngle.normalizedAngle
            if angle < startAngleNormalized{
                angle += 360
                return angle
            }else{
                return angle
            }
        }
        
        public init(startAngle: Degree = 120, endAngle: Degree = 60, lineWidth: CGFloat = 7.6, color: UIColor = UIColor.gray, strokeEnd: CGFloat = 1.0, lineDashPattern: [NSNumber] = [2.5,2.5]){
            self.startAngle = startAngle
            self.endAngle = endAngle
            self.lineWidth = lineWidth
            self.color = color
            self.strokeEnd = strokeEnd
            self.lineDashPattern = lineDashPattern
        }
    }
}

open class UIProgressRingView: UIView {
    
    private var timer: Timer?
    private var backgroundLayer = RingShapeLayer()
    private var foregroundLayer = RingShapeLayer()
    private var progressLabel = UILabel(frame: .zero)
    private var completion: (()->())?
    private var progress: Double = 0.0
    private var backgroundLayerConfig = RingShapeLayer.Config()
    private var foregroundLayerConfig = RingShapeLayer.Config(color: .blue)
    
    public var progressAnimationSpeedPerUnit = 0.05
    public var progressLabelFont: UIFont = UIFont.systemFont(ofSize: 15){
        didSet{
            progressLabel.font = progressLabelFont
        }
    }
    
    public var progressLabelColor: UIColor = .red{
        didSet{
            progressLabel.textColor = progressLabelColor
        }
    }

    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addBackgroundLayer()
        
        progressLabel.frame = bounds
        progressLabel.textColor = progressLabelColor
        progressLabel.font = progressLabelFont
        progressLabel.textAlignment = .center
        addSubview(progressLabel)
    }
    
    private func addBackgroundLayer() {
        backgroundLayer.setFrame(frame: self.bounds)
        backgroundLayer.configure(config: backgroundLayerConfig)
        layer.addSublayer(backgroundLayer)
    }
    
    private func addForegroundLayer() {
        foregroundLayer.removeFromSuperlayer()
        foregroundLayer.setFrame(frame: self.bounds)
        foregroundLayerConfig.endAngle = getEndAngleForProgress(progress: progress)
        foregroundLayerConfig.startAngle = backgroundLayerConfig.startAngle
        foregroundLayerConfig.lineWidth = backgroundLayerConfig.lineWidth
        foregroundLayerConfig.lineDashPattern = backgroundLayerConfig.lineDashPattern
        foregroundLayer.configure(config: foregroundLayerConfig)
        layer.addSublayer(foregroundLayer)
    }
    
    private func getEndAngleForProgress(progress: Double) -> Degree{
        var total: Double = backgroundLayer.config.endAngleNormalized - backgroundLayer.config.startAngleNormalized
        if total < 0{
            total = -total
        }
        
        return backgroundLayer.config.endAngleNormalized - (total - (total * progress*0.01))
    }
    
    public func setBackgroundConfig(config: RingShapeLayer.Config){
        backgroundLayerConfig = config
        backgroundLayer.configure(config: config)
    }
    
    public func setForeGroundConfig(config: RingShapeLayer.Config){
        var config = config
        config.startAngle = backgroundLayer.config.startAngle
        config.endAngle = getEndAngleForProgress(progress: progress)
        config.lineWidth = backgroundLayerConfig.lineWidth
        config.lineDashPattern = backgroundLayerConfig.lineDashPattern
        foregroundLayerConfig = config
        foregroundLayer.configure(config: config)
    }
    
    public func setProgress(progress: Double, animated: Bool = true){
        let previousProgress = self.progress
        self.progress = progress

        guard animated else{
            progressLabel.text = "\(Int(progress))%"
            addForegroundLayer()
            return
        }
        
        var isIncreamentInProgress: Bool{
            previousProgress < progress
        }
        
        var tempProgress = previousProgress
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: progressAnimationSpeedPerUnit, repeats: true) {[weak self] (timer) in
            
            if isIncreamentInProgress{
                tempProgress += 1.0
            }else {
                tempProgress -= 1
            }
            self?.progressLabel.text = "\(Int(tempProgress))%"
            
            if isIncreamentInProgress && tempProgress >= progress{
                timer.invalidate()
            }else if !isIncreamentInProgress && tempProgress <= progress{
                timer.invalidate()
            }
        }
        
        foregroundLayerConfig.endAngle = getEndAngleForProgress(progress: progress)
        
        
        var fromValue = 1.0
        var toValue = 1.0
        
        if isIncreamentInProgress{
            addForegroundLayer()
            fromValue = previousProgress / progress
        }else{
            toValue = progress / previousProgress
        }
        
        self.isUserInteractionEnabled = false
        foregroundLayer.removeAllAnimations()
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.delegate = self
        anim.duration = progressAnimationSpeedPerUnit * (isIncreamentInProgress ? progress - previousProgress : previousProgress - progress)
        anim.fromValue = fromValue
        anim.toValue = toValue
        foregroundLayer.add(anim, forKey: nil)
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}

extension UIProgressRingView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        addForegroundLayer()
        self.isUserInteractionEnabled = true
    }
}

extension Degree{
    var radian: Double{
        Double(self) * Double.pi / 180
    }
    
    var normalizedAngle : Degree{
        return self < 360 ? self : self.truncatingRemainder(dividingBy: 360)
    }
}
