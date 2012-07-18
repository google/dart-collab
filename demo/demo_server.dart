#import('dart:io');
#import('dart:isolate');
#import('../src/collab.dart');
#import('../src/server/server.dart');
#import('../src/utils.dart');

void main() {
  List<String> argv = (new Options()).arguments;
  String host = getHost(argv);
  host = (host == null) ? "127.0.0.1" : host;
  var transport= new WebSocketTransport();
  var collabServer = new CollabServer(transport);
  var server = new HttpServer();
  server.addRequestHandler(
      (HttpRequest req) => (req.path == "/connect"),
      transport.handler);
  server.defaultRequestHandler = serveFile;
  server.listen(host, 8080);  
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

/// Very simple async static file server. Possibly insecure!
void serveFile(HttpRequest req, HttpResponse resp) {
  String path = (req.path.endsWith('/')) ? ".${req.path}index.html" : ".${req.path}";
  print("serving $path");
  
  File file = new File(path);
  file.exists().then((bool exists) {
    if (exists) {
      file.readAsText().then((String text) {
        if (text == null) {
          print("$path is empty?");
        }
        resp.headers.set(HttpHeaders.CONTENT_TYPE, getContentType(file));
        resp.outputStream.writeString(text);
        resp.outputStream.close();
      });      
    } else {
      resp.statusCode = HttpStatus.NOT_FOUND;
      resp.outputStream.close();
    }
  });
}

String getContentType(File file) => contentTypes[file.name.split('.').last()];
