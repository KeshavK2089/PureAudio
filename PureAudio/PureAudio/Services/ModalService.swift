//
//  ModalService.swift
//  PureAudio
//
//  Service for communicating with Modal API
//

import Foundation

/// Errors that can occur during Modal API communication
enum ModalServiceError: LocalizedError {
    case invalidURL
    case uploadFailed(String)
    case processingFailed(String)
    case invalidResponse
    case timeout
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .timeout:
            return "Request timed out. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Result from Modal processing
struct ProcessingResult {
    let outputURL: URL
    let processingTime: TimeInterval?
}

/// Actor for thread-safe Modal API communication
actor ModalService {
    
    // MARK: - Main Processing Method
    
    /// Process audio file with Modal API
    /// - Parameters:
    ///   - audioData: Raw audio file data
    ///   - prompt: Text description of sound to process
    ///   - mode: Processing mode (isolate or remove)
    /// - Returns: ProcessingResult with output URL
    func processAudio(
        audioData: Data,
        prompt: String,
        mode: ProcessingMode
    ) async throws -> ProcessingResult {
        
        // Build request URL (Modal API is at root /)
        guard let url = URL(string: Config.modalAPIBase + "/") else {
            throw ModalServiceError.invalidURL
        }
        
        // Convert audio to base64
        let base64Audio = audioData.base64EncodedString()
        let dataURL = "data:audio/wav;base64,\(base64Audio)"
        
        // Create JSON request matching Modal backend format
        let requestBody: [String: Any] = [
            "input": [
                "audio": dataURL,
                "prompt": prompt,
                "mode": mode.rawValue
            ]
        ]
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = Config.uploadTimeoutSeconds
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Perform request
        let startTime = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ModalServiceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ModalServiceError.processingFailed("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse response
        let result = try parseResponse(data: data)
        
        let processingTime = Date().timeIntervalSince(startTime)
        return ProcessingResult(outputURL: result, processingTime: processingTime)
    }
    
    // MARK: - Helper Methods
    
    /// Parse response to extract output or decode base64 audio
    private func parseResponse(data: Data) throws -> URL {
        // Log raw response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Raw response: \(responseString.prefix(200))...")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse JSON")
            throw ModalServiceError.invalidResponse
        }
        
        print("📦 Parsed JSON: \(json)")
        
        // Check status
        if let status = json["status"] as? String {
            print("📊 Status: \(status)")
            if status == "succeeded" {
                // Get output (base64 audio from Modal)
                if let output = json["output"] as? String {
                    print("✅ Found output, length: \(output.count)")
                    return try decodeBase64Audio(output)
                } else {
                    print("❌ No 'output' field in response")
                }
            }
        }
        
        // Check for error
        if let error = json["error"] as? String {
            print("❌ Backend error: \(error)")
            throw ModalServiceError.processingFailed(error)
        }
        
        print("❌ Invalid response structure")
        throw ModalServiceError.invalidResponse
    }
    
    /// Decode base64 audio and save to temporary file
    private func decodeBase64Audio(_ dataURL: String) throws -> URL {
        // Extract base64 data
        var base64String = dataURL
        if dataURL.contains("base64,") {
            let parts = dataURL.split(separator: ",")
            if parts.count > 1 {
                base64String = String(parts[1])
            }
        }
        
        // Decode base64
        guard let audioData = Data(base64Encoded: base64String) else {
            throw ModalServiceError.processingFailed("Failed to decode audio data")
        }
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("processed_\(UUID().uuidString).wav")
        
        try audioData.write(to: tempURL)
        return tempURL
    }
}
