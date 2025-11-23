@Entry
@Component
struct Index {
  pageStack : NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack){
    }.onAppear(() => {
      this.pageStack.pushPathByName('Splash', null, false);
    })
    .hideNavBar(true)
  }
}