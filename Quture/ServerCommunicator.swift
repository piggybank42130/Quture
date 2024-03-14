import Foundation

class ServerCommunicator: ObservableObject {
    let serverURL = "http://137.184.116.12:5000"
    static var endpointIndex = 0 // To keep track of the current endpoint index

    // Function to request a method execution on the server with arbitrary parameters
    func sendMethod(parameters: [String: Any]) async throws -> Data {
        // Construct the endpoint URL by including the endpointIndex in the path
        let methodEndpoint = "/execute-method-\(ServerCommunicator.endpointIndex + 1)" // Assuming your endpoints are named execute-method-1, execute-method-2, etc.
        print(parameters, parameters["method_name"], methodEndpoint)
        guard let url = URL(string: "\(serverURL)\(methodEndpoint)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            throw error // Propagate serialization error
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // Cycle through the endpoints for subsequent requests
        ServerCommunicator.endpointIndex = (ServerCommunicator.endpointIndex + 1) % 128 // Assuming you have 32 endpoints, cycle back to 0 after 32

        return data
    }
}
