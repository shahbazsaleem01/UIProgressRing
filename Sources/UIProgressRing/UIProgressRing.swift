
import UIKit

public class UIProgressRingView: UIView {
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addPurpleLayer()
  }
  
  private let centerPoint = CGPoint(x: 65, y: 65)
  private let radius = 60.0
  private let startAngle = 2.4
  private let endAngle = 6.9
  
  var purpleArc = CAShapeLayer()
  var whiteArc = CAShapeLayer()
  
  private var completion: (()->())?
  
  func onAnimation(completion: (()->())?) {
    self.isUserInteractionEnabled = false
    addWhiteLayer()
    onAnimationInternal()
    self.completion = completion
  }
  func offAnimation(completion: (()->())?) {
    self.isUserInteractionEnabled = false
    offAnimationInternal()
    self.completion = completion
  }
  
  private func addPurpleLayer() {
    purpleArc.path = UIBezierPath(arcCenter: centerPoint,
                                  radius: CGFloat(radius),
                                  startAngle: CGFloat(startAngle),
                                  endAngle: CGFloat(endAngle),
                                  clockwise: true).cgPath
    
    purpleArc.fillColor = UIColor.clear.cgColor
    purpleArc.strokeColor = UIColor.purple.cgColor
    purpleArc.lineWidth = 11.0
    purpleArc.strokeEnd = 1.0
    purpleArc.lineDashPattern = [3,6]
    purpleArc.lineDashPhase = 5.0
    
    purpleArc.shadowColor = UIColor.black.cgColor
    purpleArc.shadowRadius = 8.0
    purpleArc.shadowOpacity = 0.9
    purpleArc.shadowOffset = CGSize(width: 0, height: 0)
    self.layer.addSublayer(purpleArc)
  }
  
  private func addWhiteLayer() {
    whiteArc.path = UIBezierPath(arcCenter: centerPoint,
                                 radius: CGFloat(radius),
                                 startAngle: CGFloat(startAngle + 0.01),
                                 endAngle: CGFloat(endAngle),
                                 clockwise: true).cgPath
    
    whiteArc.fillColor = UIColor.clear.cgColor
    whiteArc.strokeColor = UIColor.white.cgColor
    whiteArc.lineWidth = 10.0
    whiteArc.strokeEnd = 1.0
    whiteArc.lineDashPattern = [2,7]
    whiteArc.lineDashPhase = 5.0
    
    
    self.layer.addSublayer(whiteArc)
  }
  
  private func onAnimationInternal() {
    whiteArc.removeAllAnimations()
    let anim = CABasicAnimation(keyPath: "strokeEnd")
    anim.delegate = self
    anim.duration = 1
    anim.fromValue = 0.0
    anim.toValue = 1.0
    anim.setValue("on", forKey: "anim")
    whiteArc.add(anim, forKey: nil)
  }
  
  private func offAnimationInternal() {
    whiteArc.removeAllAnimations()
    let anim = CABasicAnimation(keyPath: "strokeEnd")
    anim.delegate = self
    anim.duration = 1
    anim.fromValue = 1.0
    anim.toValue = 0.0
    anim.setValue("off", forKey: "anim")
    whiteArc.add(anim, forKey: nil)
  }
}

extension UIProgressRingView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if let value = anim.value(forKey: "anim") as? String, value == "on" {
    }
    
    if let value = anim.value(forKey: "anim") as? String, value == "off" {
      whiteArc.removeFromSuperlayer()
    }
    if let comp = completion {
      comp()
    }
    self.isUserInteractionEnabled = true
  }
}
