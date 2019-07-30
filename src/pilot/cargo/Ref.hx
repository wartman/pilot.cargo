package pilot.cargo;

import haxe.ds.Vector;

abstract Ref<T>(Vector<T>) {

  public var value(get, set):T;

  @:noUsing 
  @:from 
  public static inline function to<A>(value:A):Ref<A> {
    var ref = new Ref();
    ref.value = value;
    return ref;
  }

  @:to inline function get_value():T return this[0];
  inline function set_value(value:T) return this[0] = value;

  public function new() {
    this = new Vector(1);
  }

  public function toString() return '@[${ Std.string(value) }]';

}
