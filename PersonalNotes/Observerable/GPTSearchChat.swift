//
//  GPTSearch.swift
//  PersonalNotes
//
//  Created by MacBook on 25/03/2024.
//

import Foundation
import SwiftUI


struct MessageGPTRequestModel:Codable{
    let role:String
    let content:String
}
struct GPTRequest:Encodable{
    let model:String
    let temperature:Double = 0.5
    let max_tokens:Int = 1024
    let messages: [MessageGPTRequestModel]
    let stop:String = "[<|im_end|>]"
    let stream:Bool
}
class ChatGPTAPI {
    
    private let apiKey: String
    private var historyList = [String]()
    private var historyListTurbo = [MessageGPTRequestModel]()
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        //let url = URL(string: "https://api.openai.com/v1/completions")!
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    private let jsonDecoder = JSONDecoder()
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    private var historyListText: String {
        historyList.joined()
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func generateChatGPTTurboMessages(from text:String)->[MessageGPTRequestModel]{
        
        var nList = [MessageGPTRequestModel]()
        nList.append(MessageGPTRequestModel(role: "user", content: text))
        nList.append(contentsOf: historyListTurbo)
        
        guard let jsonData = try? JSONEncoder().encode(nList) else {
            print("json encode failed")
            return []
        }
        let dataString = String(data: jsonData, encoding: .utf8)!
        if dataString.count > (4000 * 4) {
            _ = historyListTurbo.dropFirst()
            nList = generateChatGPTTurboMessages(from: text)
        }
        //print(dataString)
        return nList
    }
    private func jsonBody(text: String, stream: Bool = false) throws -> Data {
        
        let obj = GPTRequest(model: "gpt-3.5-turbo", messages: generateChatGPTTurboMessages(from: text), stream: false)
        guard let jsonData = try? JSONEncoder().encode(obj) else {
            print("json encode failed")
            return Data()
        }
        let dataString = String(data: jsonData, encoding: .utf8)!
        print(dataString)
        return jsonData
        //return try JSONSerialization.data(withJSONObject: obj)
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        
        //for text-davinci-003
        self.historyList.append("User: \(userText)\n\n\nApp: \(responseText)<|im_end|>\n")
        
        //for gpt-3.5-turbo
        self.historyListTurbo.append(MessageGPTRequestModel(role: "user", content: userText))
        self.historyListTurbo.append(MessageGPTRequestModel(role: "assistant", content: responseText))
    }
    

    func sendMessage(_ text: String) async throws -> String {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text, stream: false)
        
        let (data, response) = try await urlSession.data(for: urlRequest)
        
        print("data=", String(data: data, encoding: .utf8) ?? "")
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw "Bad Response: \(httpResponse.statusCode)"
        }

        do {
            let completionResponse = try self.jsonDecoder.decode(CompletionResponse.self, from: data)
            let responseText = completionResponse.choices.first?.message.content ?? ""
            self.appendToHistoryList(userText: text, responseText: responseText)
            return responseText
        } catch {
            throw error
        }
    }
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}

struct CompletionResponse: Decodable {
    let choices: [Choice]
}

struct Choice: Decodable {
    let message: Message
}
struct Message: Decodable {
    let role: String
    let content: String
}
