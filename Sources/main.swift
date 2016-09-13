//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><head><meta name=\"google-site-verification\" content=\"6-9f2ocr9wqaL2ygviqUpnbjld6Sr05V5IAK3v5ikaI\" /><title>Hello, world on Ubuntu!</title></head><body>Hello, world!</body></html>")
		response.completed()
	}
)

routes.add(method: .get, uri: "/test", handler: {
        request, response in
        response.setHeader(.contentType, value: "application/json")
        let responseData: [String:Any] = ["a" : 1, "b" : 0.1, "c" : true, "d" : [2, 4, 5, 10]]
    
        do {
            try response.setBody(json: responseData)
        } catch {
        
        }
    
        response.completed()
    }
)

routes.add(method: .get, uri: "/image", handler: {
    request, response in
    let docRoot = request.documentRoot
    do {
        
        let imageFile = File("\(docRoot)/photo.jpg")
        let imageSize = imageFile.size
        let imageBytes = try imageFile.readSomeBytes(count: imageSize)
        
        response.setHeader(.contentType, value: MimeType.forExtension("jpg"))
        response.setHeader(.contentLength, value: "\(imageBytes.count)")
        response.setBody(bytes: imageBytes)
    } catch {
        response.status = .internalServerError
        response.setBody(string: "Error handling request: \(error)")
    }
    
    response.completed()
})

// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8182
server.serverPort = 8182

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**

server.documentRoot = "./webroot/"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
