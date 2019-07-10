
import Foundation

//
// MARK: - Download
//
class Download {
  //
  // MARK: - Variables And Properties
  //
  var isDownloading = false
  var progress: Float = 0
  var resumeData: Data?
  var task: URLSessionDownloadTask?
  var track: Track
  
  //
  // MARK: - Initialization
  //
  init(track: Track) {
    self.track = track
  }
}
