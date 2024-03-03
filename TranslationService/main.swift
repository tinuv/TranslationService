//
//  main.swift
//  TranslationService
//
//  Created by tinuv on 2024/3/2.
//

import Foundation
import Swifter

let server = HttpServer()

server["/translate"] = { request in
    guard request.method == "POST",
          request.headers["content-type"] == "application/json"
    else {
        return .badRequest(nil)
    }

    let data = Data(request.body)

    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
          let sourceLang = json["source_lang"] as? String,
          let targetLang = json["target_lang"] as? String,
          let textList = json["text_list"] as? [String]
    else {
        return .badRequest(nil)
    }

    print("Source Language: \(sourceLang)")
    print("Target Language: \(targetLang)")
    print("Text List: \(textList)")

    let translations = textList.map { text -> [String: String] in
        let translatedText = translateTextSynchronously(text) ?? "Translation failed"
        return ["detected_source_lang": sourceLang, "text": translatedText]
    }

    let responseDict = ["translations": translations]

    do {
        let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
        return .ok(.data(responseData, contentType: "application/json; charset=utf-8"))
    } catch {
        return .internalServerError(nil)
    }
}

func translateTextSynchronously(_ text: String) -> String? {
    let semaphore = DispatchSemaphore(value: 0)
    var translatedContent: String?

    let url = URL(string: "http://localhost:11434/api/chat")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = [
        "model": "test:latest",
        "messages": [
            [
                "role": "system",
                "content": "你是一个专业,地道的翻译引擎，你只返回译文，不含任何解释"
            ],
            [
                "role": "user",
                "content": "请翻译为简体中文（避免解释原文）:\n\n \(text)"
            ]
        ],
        "stream": false
    ]

    request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
        defer { semaphore.signal() }

        guard let data, error == nil else {
            return
        }
        

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let message = json["message"] as? [String: Any],
               let content = message["content"] as? String
            {
                translatedContent = content
            }
        } catch {
            print("JSON parsing error: \(error)")
        }
    }

    task.resume()
    semaphore.wait()

    return translatedContent
}

do {
    try server.start(8080)
    print("Server has started ( port = 8080 ). Try to connect now...")
    RunLoop.main.run()
} catch {
    print("Server start error: \(error)")
}
