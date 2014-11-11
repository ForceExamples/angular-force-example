library force_angular;

import 'package:force/force_serverside.dart';
import 'package:forcemvc/force_mvc.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:bigcargo/bigcargo.dart';
import 'dart:async';

main() {
  // You can also use a memory implementation here, just switch the CargoMode to MEMORY
  Cargo cargo = new Cargo(MODE: CargoMode.MONGODB, conf: {"collection": "store", "address": "mongodb://127.0.0.1/test" });
  
  // Create a force server
  ForceServer fs = new ForceServer(port: 8080, 
                                 clientFiles: '../build/web/');
    
  // Setup logger
  fs.setupConsoleLog();
  
  // wait until our forceserver is been started and our connection with the persistent layer is done!
  Future.wait([fs.start(), cargo.start()]).then((_) {
      // we need to change {{ into [[ because of angular
      if (fs.server.viewRender is MustacheRender) {
         MustacheRender mustacheRender = fs.server.viewRender;
         mustacheRender.delimiter = new Delimiter('[[', ']]');
      }
      
      // Tell Force what the start page is!
      fs.server.on("/", (req, model) => "angularforce");
     
      fs.on("post", (fme, sender) {
         cargo.add("posts", fme.json);
         fs.send("new", fme.json);
      });
      
      // send saved items to the client
      fs.on("launch", (fme, sender) {
          cargo.getItem("posts").then((obj) {
            if (obj !=null && obj is List) {
              List list = obj;
              for (var item in list) {
                // send to socket id that just connected to the server.
                fs.sendTo(fme.wsId, "new", item);
              }
            } 
          });
        });
    
    });
}

