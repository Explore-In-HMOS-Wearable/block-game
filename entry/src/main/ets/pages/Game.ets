import { Cell, ShapeDefinition } from '../model/Game';
import { GameConstants } from '../common/GameConstants';
import { createEmptyGrid } from '../model/GameLogic';
import { SourceArea } from '../components/SourceArea';
import { GameBoard } from '../components/GameBoard';

@Builder
export function GameBuilder (){
  Game()
}

@Entry
@Component
struct Game {
  @Watch('onGameOverStateChange') @State isGameOver: boolean = false;
  @State visualOffsetX: number = 0;
  @State visualOffsetY: number = 0;
  @State isDragging: boolean = false;
  @State highlightCells: Cell[] = [];
  @State gridState: (Resource | null)[][] = [];
  @State currentShape: ShapeDefinition = GameConstants.ALL_SHAPES[0];
  @State displayedScore: number = 0;
  @Watch('onTargetScoreChange') @State targetScore: number = 0;
  @State bestScore: number = (AppStorage.get<number>('bestScore') ?? 0);
  @State cellAnimationState: Map<string, 'clearing' | 'cleared'> = new Map();
  @State dropZoneArea: Area = {
    width: 0,
    height: 0,
    position: { x: 0, y: 0 },
    globalPosition: { x: 0, y: 0 }
  };
  @State resetCounter: number = 0;
  private scoreAnimationInterval: number = -1;

  pageInfos: NavPathStack = new NavPathStack();

  onGameOverStateChange() {
    if (this.isGameOver) {
      this.fillGridForGameOver();
      setTimeout(() => {
        AppStorage.setOrCreate('score', this.targetScore);
        this.pageInfos.pushPathByName('GameOver', '')
      }, 1200)
    }
  }

  onTargetScoreChange() {
    this.startScoreAnimation();
  }

  fillGridForGameOver() {
    for (let row = 0; row < GameConstants.GRID_SIZE; row++) {
      for (let col = 0; col < GameConstants.GRID_SIZE; col++) {
        if (this.gridState[row][col] === null) {
          const delay = (row * GameConstants.GRID_SIZE + col) * GameConstants.GAMEOVER_FILL_DELAY_MS;
          this.scheduleGridUpdate(row, col, $r('app.color.game_over_block'), delay)
        }
      }
    }
  }

  scheduleGridUpdate(row: number, col: number, res: Resource, delay: number) {
    setTimeout(() => {
      this.gridState[row][col] = res;
      this.gridState = [...this.gridState];
    }, delay);
  }

  startScoreAnimation() {
    if (this.scoreAnimationInterval !== -1) {
      clearInterval(this.scoreAnimationInterval);
    }

    const interval = 40;
    this.scoreAnimationInterval = setInterval(() => {
      if (this.displayedScore < this.targetScore) {
        const diff = this.targetScore - this.displayedScore;
        const step = Math.max(1, Math.ceil(diff / 8));
        this.displayedScore += step;
        if (this.displayedScore > this.targetScore) {
          this.displayedScore = this.targetScore;
        }
      } else {
        clearInterval(this.scoreAnimationInterval);
        this.scoreAnimationInterval = -1;
      }
    }, interval);
  }

  resetGame() {
    if (this.scoreAnimationInterval !== -1) {
      clearInterval(this.scoreAnimationInterval);
      this.scoreAnimationInterval = -1;
    }
    this.isGameOver = false;
    this.targetScore = 0;
    this.displayedScore = 0;
    this.highlightCells = [];
    this.cellAnimationState = new Map();
    this.initializeGridState();
    this.resetCounter++;
  }

  aboutToAppear() {
    this.initializeGridState();
  }

  aboutToDisappear() {
    if (this.scoreAnimationInterval !== -1) {
      clearInterval(this.scoreAnimationInterval);
      this.scoreAnimationInterval = -1;
    }
  }

  initializeGridState() {
    this.gridState = createEmptyGrid(GameConstants.GRID_SIZE) as (Resource | null)[][];
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          Column() {
            Text(this.displayedScore.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .padding({ top: 2, bottom: 6 })
          }
          .gesture(
            LongPressGesture({ duration: 600 })
              .onAction(() => {
                this.resetGame();
              })
          )

          GameBoard({
            gridState: $gridState,
            cellAnimationState: $cellAnimationState,
            highlightCells: $highlightCells,
            currentShape: this.currentShape,
            dropZoneArea: $dropZoneArea
          })

          SourceArea({
            currentShape: $currentShape,
            isGameOver: $isGameOver,
            visualOffsetX: $visualOffsetX,
            visualOffsetY: $visualOffsetY,
            isDragging: $isDragging,
            highlightCells: $highlightCells,
            dropZoneArea: $dropZoneArea,
            gridState: $gridState,
            targetScore: $targetScore,
            cellAnimationState: $cellAnimationState,
            bestScore: $bestScore,
            resetCounter: $resetCounter
          })
          .margin({ top: -22 })

        }.width('100%')
          .height('100%')
          .padding({ left: 8, right: 8, top: 6, bottom: 8 })
          .backgroundColor('#3E57C5')

        if (this.isGameOver) {
          Column() {
            Text($r('app.string.game_over'))
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .opacity(0.92)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
          .hitTestBehavior(HitTestMode.None)
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
  }
}
