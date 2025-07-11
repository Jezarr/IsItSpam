import Foundation
import Vision
import UIKit

struct TextRecognizer {
    static func recognizeText(in image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
            debugPrint(recognizedStrings)
            completion(recognizedStrings.joined(separator: "\n"))
        }
        request.recognitionLevel = .accurate
        DispatchQueue.global(qos: .userInitiated).async {
            try? requestHandler.perform([request])
        }
    }
}
