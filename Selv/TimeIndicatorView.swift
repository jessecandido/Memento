import UIKit

class TimeIndicatorView: UIView {
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
    label.textColor = .black
    label.numberOfLines = 0
    
    addSubview(label)
  }
  
  func updateSize() {
    // size the label based on the font
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.frame = CGRect(x: 0, y: 0, width: .max, height: .max)
    label.sizeToFit()
    
    // set the frame to be large enough to accomodate the circle that surrounds the text
    
    // center the label within this circle
    // offset the center of this view to ... erm ... can I just draw you a picture?
    // You know the story - the designer provides a mock-up with some static data, leaving
    // you to work out the complex calculations required to accomodate the variability of real-world
    // data. C'est la vie!
    let padding: CGFloat = 5.0
    center = CGPoint(x: center.x + label.frame.origin.x - padding, y: center.y - label.frame.origin.y + padding)
  }


  

}
