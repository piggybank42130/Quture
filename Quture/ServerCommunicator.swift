import Foundation

class ServerCommunicator: ObservableObject {
    let serverURL = "http://137.184.116.12:5000"
    static var endpointIndex = 0 // To keep track of the current endpoint index
    private let cache = NSCache<NSString, NSData>()
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15 // seconds
        config.timeoutIntervalForResource = 15 // seconds
        config.httpAdditionalHeaders = ["Accept-Encoding": "gzip, deflate"] // Efficient lossless compression algorithms
        return URLSession(configuration: config)
    }
    
    // Function to request a method execution on the server with arbitrary parameters
    func sendMethod(parameters: [String: Any]) async throws -> Data {
        var modifiedParameters = parameters
        // Assuming LocalStorage.getUserId() returns an Int and can be called statically. Adjust if needed.
        let userId = LocalStorage().getUserId() // Get user ID from LocalStorage
        modifiedParameters["local_user_id"] = userId // Add/Update the user_id in parameters
        
        let cacheKey = NSString(string: "\(ServerCommunicator.endpointIndex)-\(modifiedParameters.description)")
        
        // Try to retrieve data from cache
        if let cachedData = cache.object(forKey: cacheKey) as Data? {
            return cachedData
        }
        
        // Construct the endpoint URL by including the endpointIndex in the path
        let methodEndpoint = "/execute-method-\(ServerCommunicator.endpointIndex + 1)" // Assuming your endpoints are named execute-method-1, execute-method-2, etc.
        guard let url = URL(string: "\(serverURL)\(methodEndpoint)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: modifiedParameters, options: [])
        } catch {
            throw error // Propagate serialization error
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Update cache with the new data
        cache.setObject(data as NSData, forKey: cacheKey)
        
        // Cycle through the endpoints for subsequent requests
        ServerCommunicator.endpointIndex = (ServerCommunicator.endpointIndex + 1) % 128 // Adjust the modulus according to the actual number of endpoints

        return data
    }
}
