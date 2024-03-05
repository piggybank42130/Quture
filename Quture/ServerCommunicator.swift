import Foundation

class ServerCommunicator: ObservableObject {
    let serverURL = "http://137.184.116.12:5000"
    
    // Function to request a method execution on the server with arbitrary parameters
    func sendMethod(parameters: [String: String], completion: @escaping (Result<Data, Error>) -> Void) {
        var components = URLComponents(string: "\(serverURL)/execute-method")
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components?.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
    
    // Function to execute a command on the server with arbitrary parameters
    func executeCommand(parameters: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(serverURL)/send-command") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard data != nil else {
                    completion(.failure(NSError(domain: "DataError", code: -1001, userInfo: nil)))
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
