import UIKit

class TimeIndicatorView: UIView {
  let fillColor = UIColor(red: 0.329, green: 0.584, blue: 0.898, alpha: 1)
  var label = UILabel()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(date: Date) {
    super.init(frame: CGRect.zero)
    
    // Initialization code
    backgroundColor = .clear
    clipsToBounds = false
    
    // format and style the date
    let formatter = DateFormatter()
    formatter.dateFormat = "dd\rMMMM\ryyyy"
    let formattedDate = formatter.string(from: date)
    label.text = formattedDate.uppercased()
    label.textAlignment = .center
    label.textColor = .white
    label.numberOfLines = 0
    
    addSubview(label)
  }
  
  func updateSize() {
    // size the label based on the font
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.frame = CGRect(x: 0, y: 0, width: .max, height: .max)
    label.sizeToFit()
    
    // set the frame to be large enough to accomodate the circle that surrounds the text
    let radius = radiusToSurroundFrame(label.frame)
    frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
    
    // center the label within this circle
    label.center = center
    
    // offset the center of this view to ... erm ... can I just draw you a picture?
    // You know the story - the designer provides a mock-up with some static data, leaving
    // you to work out the complex calculations required to accomodate the variability of real-world
    // data. C'est la vie!
    let padding: CGFloat = 5.0
    center = CGPoint(x: center.x + label.frame.origin.x - padding, y: center.y - label.frame.origin.y + padding)
  }
  
  // calculates the radius of the circle that surrounds the label
  func radiusToSurroundFrame(_ frame: CGRect) -> CGFloat {
    return max(frame.width, frame.height) * 0.5 + 20.0
  }
  
  func curvePathWithOrigin(_ origin: CGPoint) -> UIBezierPath {
    return UIBezierPath(arcCenter: origin, radius: radiusToSurroundFrame(label.frame), startAngle: -.pi, endAngle: .pi, clockwise: true)
  }
  
  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    context?.setShouldAntialias(true)
    let path = curvePathWithOrigin(label.center)
    fillColor.setFill()
    path.fill()
  }
}
