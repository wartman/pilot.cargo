Pilot Cargo
===========
Data for [Pilot](https://github.com/wartman/pilot), based heavily on [Coconut.Data](https://github.com/MVCoconut/coconut.data) and [Tink State](https://github.com/haxetink/tink_state).

Features
--------

Setting `-D pilot-cargo-constant` in your HXML will generate classes *without* using `tink_state`, which might be useful for targets (like PHP) that won't benefit from reactive programming. 

API
---

Models work something like this:

```haxe
import pilot.cargo.Model;

class Foo implements Model {
  @:prop var foo:String;
}
```

> todo: Explain how models work

You can make sections reactive using the `pilot.cargo.Observed` component. It looks something like this:

```haxe
var myModel = new Foo({ foo: 'foo' });
Pilot.html(<Observed wrap={() -> <>
  <p>Everything in here is observable</p>
  <p>It will update whenever this changes: {myModel.foo}</p>
  <button onClick={_ -> myModel.foo = 'bar'}>Update</button>
</>}>);
```

You can also use the `pilot.Cargo.html(...)` macro to wrap a vNode in an `<Observed/>`:

```haxe
var myModel = new Foo({ foo: 'foo' });
// This is the same as the last example:
pilot.Cargo.observeHtml(<>
  <p>Everything in here is observable</p>
  <p>It will update whenever this changes: {myModel.foo}</p>
  <button onClick={_ -> myModel.foo = 'bar'}>Update</button>
</>);
```
