import lottie, { AnimationItem } from '@ohos/lottie';

@Entry
@Component
struct Splash {
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  private animateItem: AnimationItem | null = null;
  private animateName: string = "animation";

  aboutToAppear(): void {
    setTimeout(() => {
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/Game' });
    }, 1500)
  }

  aboutToDisappear(): void {
    lottie.destroy();
  }

  loadAnimation() {
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: false,
      name: this.animateName,
      contentMode: 'Contain',
      path: "common/splash_animation.json",
    })

    this.animateItem.addEventListener('DOMLoaded', (args: Object): void => {
      this.animateItem?.changeColor([225, 25, 100, 1]);
      this.animateItem?.play()
    });
  }

  destroy() {
    this.animateItem?.removeEventListener("DOMLoaded");
    lottie.destroy(this.animateName);
    this.animateItem = null;
  }

  build() {
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
  }
}