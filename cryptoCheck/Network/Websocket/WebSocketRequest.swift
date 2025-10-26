//
//  WebSocketRequest.swift
//  cryptoCheck
//
//  Created by Leonardo Soares on 26/10/2025.
//

import Foundation

struct WebSocketRequest {
    let domain: String
    let scheme: String
    let requestType: String
    let body: Data?
    let port: Int

    init(
        domain: String = .domain,
        scheme: Scheme = .wss,
        requestType: RequestType = .get,
        body: WebSocketBody? = nil,
        port: Port = .primary
    ) {
        self.domain = domain
        self.scheme = scheme.rawValue
        self.requestType = requestType.rawValue.uppercased()
        self.body = body?.asData()
        self.port = port.rawValue
    }

    func getRequest(for endpoint: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = domain
        components.port = port
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url.appending(path: endpoint.rawValue))
        request.httpMethod = requestType
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5
        if let body {
            request.httpBody = body
        }
        return request
    }
}
