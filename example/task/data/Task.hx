package task.data;

import pilot.cargo.Model;

class Task implements Model {
  
  @:prop var title:String;
  @:prop var content:String;
  @:prop(mutable = true) var completed:Bool = false;
  @:prop(mutable = true) var editing:Bool = false;

  // This is here because I'm testing `toJson` and desperately
  // need a real test unit.
  @:prop var test:Test = new Test({ hm: 'foo' });

  @:transition
  public function update(title:String, content:String) {
    return { 
      title: title,
      content: content, 
      completed: false 
    };
  }

}

// Todo: remove and add real tests
class Test implements Model {
  @:prop var hm:String;
}
