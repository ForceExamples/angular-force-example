import 'dart:html';
import 'dart:convert';

import 'package:force/force_browser.dart';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

class BlogPost {
  String user, title, body;

  BlogPost(this.user, this.title, this.body);

  BlogPost.fromJson(Map data) {
    user    = data["user"];
    title = data["title"];
    body = data["body"];
  }

  Map toJson() => {"user": user, "title": title, "body": body};
}

@Injectable()
class BlogComponent {

  String user = "";
  String title = "";
  String body = "";
  List<BlogPost> blogPosts = [];
  ForceClient forceClient;
  
  BlogComponent() {
    forceClient = new ForceClient();
    forceClient.connect();
    
    forceClient.onConnected.listen((ConnectEvent ce) {
      forceClient.on("new", (e, sender) {
        blogPosts.add(new BlogPost.fromJson(e.json));
      });
      forceClient.send("launch", {});
    });
  }

  void submit() {
    forceClient.send("post", new BlogPost(user, title, body).toJson());
  }
}

void main() {
  applicationFactory()
      .rootContextType(BlogComponent)
      .run();
}
