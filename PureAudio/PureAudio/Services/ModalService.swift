//
//  ModalService.swift
//  AudioPure
//
//  Service for communicating with Modal API with rate limiting and retry logic
//

import Foundation
import os.log

/// Errors that can occur during Modal API communication
enum ModalServiceError: LocalizedError {
    case invalidURL
    case uploadFailed(String)
    case processingFailed(String)
    case invalidResponse
    case timeout
    case rateLimited
    case networkError(Error)
    case maxRetriesExceeded
    
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
        case .rateLimited:
            return "Server is busy. Please wait a moment and try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .maxRetriesExceeded:
            return "Unable to connect after multiple attempts. Please try again later."
        }
    }
}

/// Result from Modal processing
struct ProcessingResult {
    let outputURL: URL
    let processingTime: TimeInterval?
}

/// Actor for thread-safe Modal API communication with rate limiting
actor ModalService {
    
    // MARK: - Rate Limiting Configuration
    
    private static let maxRetries = 3
    private static let baseDelaySeconds: Double = 2.0
    private static let maxDelaySeconds: Double = 30.0
    private static let minRequestIntervalSeconds: Double = 1.0
    
    private var lastRequestTime: Date?
    
    // MARK: - Main Processing Method
    
    /// Process audio file with Modal API (with automatic retry)
    /// - Parameters:
    ///   - audioData: Raw audio file data
    ///   - prompt: Text description of sound to process
    ///   - mode: Processing mode (isolate or remove)
    ///   - highQualityMode: Enable re-ranking for Pro+ users (slower but better)
    /// - Returns: ProcessingResult with output URL
    func processAudio(
        audioData: Data,
        prompt: String,
        mode: ProcessingMode,
        highQualityMode: Bool = false
    ) async throws -> ProcessingResult {
        
        // Enforce minimum request interval (rate limiting)
        await enforceRateLimit()
        
        var lastError: Error?
        
        for attempt in 0..<Self.maxRetries {
            do {
                let result = try await performRequest(audioData: audioData, prompt: prompt, mode: mode, highQualityMode: highQualityMode)
                return result
            } catch let error as ModalServiceError {
                lastError = error
                
                // Don't retry on certain errors
                switch error {
                case .invalidURL, .invalidResponse:
                    throw error
                case .rateLimited:
                    // Longer delay for rate limiting
                    let delay = Self.baseDelaySeconds * pow(2.0, Double(attempt + 1))
                    Logger.modalService.warning("Rate limited, waiting \(delay)s before retry \(attempt + 1)/\(Self.maxRetries)")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                default:
                    // Exponential backoff for other errors
                    if attempt < Self.maxRetries - 1 {
                        let delay = min(Self.baseDelaySeconds * pow(2.0, Double(attempt)), Self.maxDelaySeconds)
                        Logger.modalService.info("Request failed, retrying in \(delay)s (attempt \(attempt + 1)/\(Self.maxRetries))")
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                }
            } catch {
                lastError = error
                if attempt < Self.maxRetries - 1 {
                    let delay = min(Self.baseDelaySeconds * pow(2.0, Double(attempt)), Self.maxDelaySeconds)
                    Logger.modalService.info("Request error, retrying in \(delay)s (attempt \(attempt + 1)/\(Self.maxRetries))")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        Logger.modalService.error("Max retries exceeded")
        throw lastError ?? ModalServiceError.maxRetriesExceeded
    }
    
    // MARK: - Rate Limiting
    
    private func enforceRateLimit() async {
        if let lastRequest = lastRequestTime {
            let elapsed = Date().timeIntervalSince(lastRequest)
            if elapsed < Self.minRequestIntervalSeconds {
                let waitTime = Self.minRequestIntervalSeconds - elapsed
                Logger.modalService.debug("Rate limiting: waiting \(waitTime)s")
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
    
    // MARK: - Request Execution
    
    private func performRequest(
        audioData: Data,
        prompt: String,
        mode: ProcessingMode,
        highQualityMode: Bool
    ) async throws -> ProcessingResult {
        
        // Capture config value outside actor context to avoid isolation issues
        let apiBase = Config.modalAPIBase
        
        // Build request URL (Modal API is at root /)
        guard let url = URL(string: apiBase + "/") else {
            throw ModalServiceError.invalidURL
        }
        
        // Convert audio to base64
        let base64Audio = audioData.base64EncodedString()
        let dataURL = "data:audio/wav;base64,\(base64Audio)"
        
        // Create JSON request matching Modal backend format
        // predict_spans: Pro+ only (adds accuracy but 3-4x slower)
        // high_quality: Pro+ re-ranking (adds quality but 4x slower)
        let requestBody: [String: Any] = [
            "input": [
                "audio": dataURL,
                "prompt": prompt,
                "mode": mode.rawValue,
                "predict_spans": highQualityMode,  // Pro+ only for accuracy
                "high_quality": highQualityMode    // Pro+ only for quality
            ]
        ]
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = await Config.uploadTimeoutSeconds
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Perform request
        let startTime = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ModalServiceError.invalidResponse
        }
        
        // Handle rate limiting (429)
        if httpResponse.statusCode == 429 {
            Logger.modalService.warning("Received 429 Too Many Requests")
            throw ModalServiceError.rateLimited
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            Logger.modalService.error("API error: Status \(httpResponse.statusCode)")
            throw ModalServiceError.processingFailed("Status \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse response
        let result = try parseResponse(data: data)
        
        let processingTime = Date().timeIntervalSince(startTime)
        Logger.modalService.info("Request completed in \(String(format: "%.1f", processingTime))s")
        return ProcessingResult(outputURL: result, processingTime: processingTime)
    }
    
    // MARK: - Helper Methods
    
    /// Parse response to extract output or decode base64 audio
    private func parseResponse(data: Data) throws -> URL {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            Logger.modalService.error("Failed to parse JSON response")
            throw ModalServiceError.invalidResponse
        }
        
        // Check status
        if let status = json["status"] as? String {
            Logger.modalService.debug("Response status: \(status)")
            if status == "succeeded" {
                // Get output (base64 audio from Modal)
                if let output = json["output"] as? String {
                    Logger.modalService.debug("Output received, length: \(output.count)")
                    return try decodeBase64Audio(output)
                } else {
                    Logger.modalService.error("No 'output' field in response")
                }
            }
        }
        
        // Check for error
        if let error = json["error"] as? String {
            Logger.modalService.error("Backend error: \(error)")
            throw ModalServiceError.processingFailed(error)
        }
        
        Logger.modalService.error("Invalid response structure")
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
