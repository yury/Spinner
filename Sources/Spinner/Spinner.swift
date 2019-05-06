import Foundation
import Dispatch

public class Spinner {
    
    var pattern: Pattern {
        didSet {
            self.frameIndex = 0
        }
    }
    var text: String
    
    var running: Bool
    var frameIndex: Int
    var speed: Double
    var queue: DispatchQueue

    public init(pattern: Pattern, text: String = "", speed: Double? = nil) {
        self.pattern = pattern
        self.text = text
        self.speed = speed ?? pattern.defaultSpeed

        self.frameIndex = 0
        self.running = false
        self.queue = DispatchQueue(label: "io.Swift.Spinner")
    }

    public func start() {
        self.running = true
        self.queue.async { [weak self] in

            guard let `self` = self else { return }

            while self.running {
                self.renderSpinner()
                self.sleep(seconds: self.speed)
            }
        }
    }

    public func stop(frame: String? = nil, text: String? = nil, terminator: String = "\n") {
        if let frame = frame {
            self.pattern = Pattern(singleFrame: frame)
        }
        if let text = text {
            self.text = text
        }
        self.running = false
        self.renderSpinner()
        print(terminator: terminator)
    }

    public func success(text: String? = nil) {
        self.stop(frame: "✔", text: text)
    }

    public func fail(text: String? = nil) {
        self.stop(frame: "✖", text: text)
    }

    public func warning(text: String? = nil) {
        self.stop(frame: "⚠", text: text)
    }

    public func information(text: String? = nil) {
        self.stop(frame: "ℹ", text: text)
    }

    func sleep(seconds: Double) {
        usleep(useconds_t(seconds * 1_000_000))
    }

    func currentFrame() -> String {

        let currentFrame = self.pattern.frames[self.frameIndex]

        self.frameIndex = (self.frameIndex + 1) % self.pattern.frames.count

        return currentFrame
    }

    func renderSpinner() {

        // Reset cursor to start of line
        print("\r", terminator: "")
        // Print the spinner frame and text
        print("\(self.currentFrame()) \(self.text)", terminator: "")
        // Flush STDOUT
        fflush(stdout)

    }
}