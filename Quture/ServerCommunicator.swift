import Foundation

class ServerCommunicator: ObservableObject {
    let serverURL = "http://137.184.116.12:5000"
    
    // Function to request a method execution on the server with arbitrary parameters
    func sendMethod(parameters: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "\(serverURL)/execute-method") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch let error {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data was nil."])))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
    
    
    

//    
//    // Function to execute a command on the server with arbitrary parameters
//    func executeCommand(parameters: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
//        guard let url = URL(string: "\(serverURL)/send-command") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            request.httpBody = jsonData
//            
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                guard data != nil else {
//                    completion(.failure(NSError(domain: "DataError", code: -1001, userInfo: nil)))
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    completion(.success(true))
//                }
//            }.resume()
//        } catch {
//            completion(.failure(error))
//        }
//    }
        
    // Function to receive a method and its parameters from the server, then execute accordingly
//    func executeCommand() {
//        guard let url = URL(string: "\(serverURL)/send-command") else { return }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error fetching command: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            do {
//                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let methodName = jsonObject["method_name"] as? String,
//                   let parameters = jsonObject["parameters"] as? [String: Any] {
//                    DispatchQueue.main.async {
//                        // Based on methodName, call the respective function with parameters
//                        self.runCommand(name: methodName, parameters: parameters)
//                    }
//                }
//            } catch {
//                print("Failed to parse JSON response: \(error.localizedDescription)")
//            }
//        }.resume()
//    }

    /*
    private func runCommand(name: String, parameters: [String: Any]) {
        switch name {
        case "function":
            // Assuming 'updateUI' expects a 'message' and a 'value'
            if let message = parameters["message"] as? String,
               let value = parameters["value"] as? Int {
                function(message: message, value: value)
            }
        default:
            print("Received an unknown method name: \(name)")
        }
    }
     */
}
