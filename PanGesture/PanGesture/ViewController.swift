import UIKit
import AVFoundation

class ViewController: UIViewController {
  @IBOutlet var grassPan: UIPanGestureRecognizer!
  @IBOutlet var cowPan: UIPanGestureRecognizer!
  private var chompPlayer: AVAudioPlayer?
  private var laughPlayer: AVAudioPlayer?

  func createPlayer(from filename: String, fextension: String) -> AVAudioPlayer? {
    guard let url = Bundle.main.url(
      forResource: filename,
      withExtension: fextension
      ) else {
        return nil
    }
    var player = AVAudioPlayer()

    do {
      try player = AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
    } catch {
      print("Error loading \(url.absoluteString): \(error)")
    }

    return player
  }
    
  override func viewDidLoad() {
    super.viewDidLoad()

    let imageViews = view.subviews.filter {
      $0 is UIImageView
    }

    for imageView in imageViews {
      let tapGesture = UITapGestureRecognizer(
        target: self,
        action: #selector(handleTap)
      )

      tapGesture.delegate = self
      imageView.addGestureRecognizer(tapGesture)

      tapGesture.require(toFail: cowPan)
      tapGesture.require(toFail: grassPan)

      let tickleGesture = TickleGestureRecognizer(
        target: self,
        action: #selector(handleTickle)
      )
      tickleGesture.delegate = self
      imageView.addGestureRecognizer(tickleGesture)
    }

    chompPlayer = createPlayer(from: "CowMoo", fextension: "mp3")
    laughPlayer = createPlayer(from: "laugh", fextension: "caf")
  }

  @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: view)

    guard let gestureView = gesture.view else {
      return
    }

    gestureView.center = CGPoint(
      x: gestureView.center.x + translation.x,
      y: gestureView.center.y + translation.y
    )

    gesture.setTranslation(.zero, in: view)

    guard gesture.state == .ended else {
      return
    }

    let velocity = gesture.velocity(in: view)
    let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
    let slideMultiplier = magnitude / 200

    let slideFactor = 0.1 * slideMultiplier

    var finalPoint = CGPoint(
      x: gestureView.center.x + (velocity.x * slideFactor),
      y: gestureView.center.y + (velocity.y * slideFactor)
    )

    finalPoint.x = min(max(finalPoint.x, 0), view.bounds.width)
    finalPoint.y = min(max(finalPoint.y, 0), view.bounds.height)

    UIView.animate(
      withDuration: Double(slideFactor * 2),
      delay: 0,
      options: .curveEaseOut,
      animations: {
        gestureView.center = finalPoint
    })
  }
    
  @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
    guard let gestureView = gesture.view else {
      return
    }

    gestureView.transform = gestureView.transform.scaledBy(
      x: gesture.scale,
      y: gesture.scale
    )
    gesture.scale = 1
  }
  
  @IBAction func handleRotate(_ gesture: UIRotationGestureRecognizer) {
    guard let gestureView = gesture.view else {
      return
    }

    gestureView.transform = gestureView.transform.rotated(
      by: gesture.rotation
    )
    gesture.rotation = 0
  }
  
  @objc func handleTap(_ gesture: UITapGestureRecognizer) {
    chompPlayer?.play()
  }

  @objc func handleTickle(_ gesture: TickleGestureRecognizer) {
    laughPlayer?.play()
  }
}

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}
