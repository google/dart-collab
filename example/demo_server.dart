//  Copyright 2011 Google Inc. All Rights Reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:collab/collab.dart';
import 'package:collab/server/server.dart';
import 'package:collab/utils.dart';

void main() {
  List<String> argv = (new Options()).arguments;
  String host = getHost(argv);
  host = (host == null) ? "127.0.0.1" : host;

  var collabServer = new CollabServer();
  collabServer.registerDocumentType("text", textDocFactory);
  StreamController sc = new StreamController();
  sc.stream.transform(new WebSocketTransformer()).listen((WebSocket ws) {
    var connection = new WebSocketConnection(ws);
    collabServer.addConnection(connection);
  });

  HttpServer.bind(host, 8080).then((HttpServer server) {
    server.listen((HttpRequest req) {
      if (req.uri.path == "/connect") {
        sc.add(req);
      } else {
        serveFile(req, req.response);
      }
    });
  });
}

String getHost(List<String> argv) {
  for (int i = 0; i < argv.length; i++) {
    String a = argv[i];
    if (a == "--host") {
      return argv[i+1];
    }
  }
}

Map<String, String> contentTypes = const {
  "html": "text/html; charset=UTF-8",
  "dart": "application/dart",
  "js": "application/javascript",
  "css": "text/css",
};

/// Very simple async static file server. Probably insecure!
void serveFile(HttpRequest req, HttpResponse resp) {
  String path = req.uri.path.endsWith('/')
      ? ".${req.uri.path}index.html"
      : req.uri.path;
  var cwd = Directory.current.path;
  print("serving $path from $cwd");

  File file = new File("$cwd/$path");
  file.exists().then((exists) {
    if (exists) {
      file.readAsString().then((text) {
        if (text == null) {
          print("$path is empty?");
        }
        resp.headers.set(HttpHeaders.CONTENT_TYPE, getContentType(file));
        file.openRead().pipe(req.response).catchError((e) {});
      });
    } else {
      resp.statusCode = HttpStatus.NOT_FOUND;
      resp.close();
    }
  });
}

String getContentType(File file) => contentTypes[file.path.split('.').last];
