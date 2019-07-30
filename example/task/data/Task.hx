package task.data;

import pilot.cargo.Model;

class Task implements Model {
  
  @:prop var title:String;
  @:prop var content:String;
  @:prop(mutable = true) var completed:Bool = false;
  @:prop(mutable = true) var editing:Bool = false;

  @:transition
  public function update(title:String, content:String) {
    return { 
      title: title,
      content: content, 
      completed: false 
    };
  }

}
