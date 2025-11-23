import { ArcButton, ArcButtonOptions } from '@ohos.arkui.advanced.ArcButton';
import { ArcButtonStyleMode, ColorMetrics, LengthMetrics, LengthUnit } from '@kit.ArkUI';

@Builder
export function GameOverBuilder (){
  GameOver()
}

@Entry
@Component
struct GameOver {
  @State score: number = 0;
  @State targetScore: number = 0;
  @State bestScore: number = 0;
  @State screenOpacity: number = 1;
  private scoreAnimationInterval: number = -1;
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.bestScore = AppStorage.get('bestScore') as number;
  }

  onPageShow(): void {
    this.targetScore = AppStorage.get('score') as number;
    this.startScoreAnimation()
  }

  startScoreAnimation() {
    if (this.scoreAnimationInterval !== -1) {
      clearInterval(this.scoreAnimationInterval);
    }

    const interval = 20;
    this.scoreAnimationInterval = setInterval(() => {
      if (this.score < this.targetScore) {
        const diff = this.targetScore - this.score;
        const step = Math.max(1, Math.ceil(diff / 15));
        this.score += step;

        if (this.score > this.targetScore) {
          this.score = this.targetScore;
        }

      } else {
        clearInterval(this.scoreAnimationInterval);
        this.scoreAnimationInterval = -1;
      }
    }, interval);
  }

  build() {

    NavDestination() {

      Column() {

        Text($r('app.string.game_over'))
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.gameover_text_light_blue'))

        Column() {
          Text($r('app.string.score'))
            .fontSize(20)
            .fontColor($r('app.color.gameover_text_light_blue'))
            .opacity(0.8)

          Text(this.score.toString())
            .fontSize(35)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.White)
        }.alignItems(HorizontalAlign.Center)

        Column() {
          Text($r('app.string.best_score'))
            .fontSize(20)
            .fontColor($r('app.color.gameover_text_light_blue'))
            .opacity(0.8)

          Text(this.bestScore.toString())
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.gameover_text_gold'))
        }.alignItems(HorizontalAlign.Center)

        ArcButton({
          options: new ArcButtonOptions({
            label: $r('app.string.play_again'),
            styleMode: ArcButtonStyleMode.CUSTOM,
            fontSize: new LengthMetrics(18, LengthUnit.FP),
            fontColor: ColorMetrics.resourceColor($r('app.color.gameover_bg_blue')),
            backgroundColor: ColorMetrics.resourceColor('#FFF'),
            onClick: () => {
              this.pageInfos.pushPathByName('Game', '')
            }
          })
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.gameover_bg_blue'))
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })

  }
}