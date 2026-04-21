import lottie, { AnimationItem } from '@ohos/lottie';

@Builder
export function SplashBuilder (){
  Splash()
}

@Entry
@Component
struct Splash {
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateName: string = 'animation';
  private splashTimerId: number = -1;
  private domLoadedCallback: ((args: Object) => void) | null = null;
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.splashTimerId = setTimeout(() => {
      this.pageInfos.pushPathByName('Game', '')
    }, 1500)
  }

  aboutToDisappear(): void {
    if (this.splashTimerId !== -1) {
      clearTimeout(this.splashTimerId);
      this.splashTimerId = -1;
    }
    this.destroy();
  }

  loadAnimation() {
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: false,
      name: this.animateName,
      contentMode: 'Contain',
      path: 'common/splash_animation.json'
    })

    this.domLoadedCallback = (_args: Object): void => {
      this.animateItem?.changeColor([225, 25, 100, 1]);
      this.animateItem?.play()
    };
    this.animateItem.addEventListener('DOMLoaded', this.domLoadedCallback);
  }

  destroy() {
    if (this.domLoadedCallback !== null) {
      this.animateItem?.removeEventListener('DOMLoaded', this.domLoadedCallback);
      this.domLoadedCallback = null;
    }
    lottie.destroy(this.animateName);
    this.animateItem = null;
  }

  build() {
    NavDestination() {
      Row() {
        Canvas(this.canvasRenderingContext)
          .width('100%')
          .height('100%')
          .onReady(() => {
            if (this.animateItem != null) {
              this.animateItem?.resize();
            } else {
              this.canvasRenderingContext.imageSmoothingEnabled = true;
              this.canvasRenderingContext.imageSmoothingQuality = 'medium'
              this.loadAnimation();
            }
          })
      }
      .width('100%').height('100%').backgroundColor('#3E57C5')
    }.width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
