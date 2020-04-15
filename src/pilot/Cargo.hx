package pilot;

class Cargo {
  
  public static macro function observeHtml(expr) {
    var vNode = pilot.dsl.Markup.parse(expr);
    return macro pilot.cargo.Observed.node({
      wrap: () -> ${vNode}
    });
  }

}
