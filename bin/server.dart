library force_angular;

import 'package:force/force_serverside.dart';
import 'package:logging/logging.dart';
import 'package:forcemvc/force_mvc.dart';
import 'package:mustache4dart/mustache4dart.dart';

main() {

  // Create a force server
  ForceServer fs = new ForceServer(port: 8080, 
                               clientFiles: '../build/web/');
  
  // Setup logger
  fs.setupConsoleLog();

  fs.server.staticFileTypes.add("map");
  
  fs.start().then((_) {
    if (fs.server.viewRender is MustacheRender) {
       MustacheRender mustacheRender = fs.server.viewRender;
       mustacheRender.delimiter = new Delimiter('[[', ']]');
    }
    
    fs.server.on("/", (req, model) {
        return "angularforce";
      });
  });
  
}

