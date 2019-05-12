import UIKit

class TickleGestureRecognizer: UIGestureRecognizer {
  
  private let requiredTickles = 2
  private let distanceForTickleGesture: CGFloat = 25

 
  enum TickleDirection {
    case unknown
    case left
    case right
  }

  
  private var tickleCount = 0
  private var tickleStartLocation: CGPoint = .zero
  private var latestDirection: TickleDirection = .unknown

  override func reset() {
    tickleCount = 0
    latestDirection = .unknown
    tickleStartLocation = .zero

    if state == .possible {
      state = .failed
    }
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    guard let touch = touches.first else {
      return
    }

    tickleStartLocation = touch.location(in: view)
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    guard let touch = touches.first else {
      return
    }

    let tickleLocation = touch.location(in: view)

    let horizontalDifference = tickleLocation.x - tickleStartLocation.x

    if abs(horizontalDifference) < distanceForTickleGesture {
      return
    }

    let direction: TickleDirection

    if horizontalDifference < 0 {
      direction = .left
    } else {
      direction = .right
    }

    if latestDirection == .unknown ||
      (latestDirection == .left && direction == .right) ||
      (latestDirection == .right && direction == .left) {

      tickleStartLocation = tickleLocation
      latestDirection = direction
      tickleCount += 1

      if state == .possible && tickleCount > requiredTickles {
        state = .ended
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    reset()
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    reset()
  }
}
