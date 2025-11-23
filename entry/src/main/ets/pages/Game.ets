import { Cell, ShapeDefinition } from '../model/Game';
import { GameConstants } from '../common/GameConstants';
import { SourceArea } from '../components/SourceArea';
import { GameBoard } from '../components/GameBoard';
import { promptAction } from '@kit.ArkUI';


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
  @State clearingCells: Cell[] = [];
  @State gridState: (Resource | null)[][] = [];
  @State currentShape: ShapeDefinition = GameConstants.ALL_SHAPES[0];
  @State displayedScore: number = 0;
  @Watch('onTargetScoreChange') @State targetScore: number = 0;
  @State bestScore: number = AppStorage.get('bestScore') as number;
  @State cellAnimationState: Map<string, 'clearing' | 'cleared'> = new Map();
  @State dropZoneArea: Area = {
    width: 0,
    height: 0,
    position: { x: 0, y: 0 },
    globalPosition: { x: 0, y: 0 }
  };
  @State draggableBlockArea: Area = {
    width: 0,
    height: 0,
    position: { x: 0, y: 0 },
    globalPosition: { x: 0, y: 0 }
  };
  private scoreAnimationInterval: number = -1;

  pageInfos: NavPathStack = new NavPathStack();



  onGameOverStateChange() {
    if (this.isGameOver) {
      this.fillGridForGameOver();
      setTimeout(() => {
        AppStorage.setOrCreate('score', this.displayedScore);
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
          setTimeout(() => {
            this.gridState[row][col] = $r('app.color.game_over_block');
            this.gridState = [...this.gridState];
          }, delay);
        }
      }
    }
  }

  startScoreAnimation() {
    if (this.scoreAnimationInterval !== -1) {
      clearInterval(this.scoreAnimationInterval);
    }

    const interval = 20;
    this.scoreAnimationInterval = setInterval(() => {
      if (this.displayedScore < this.targetScore) {
        const diff = this.targetScore - this.displayedScore;
        const step = Math.max(1, Math.ceil(diff / 15));
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

  aboutToAppear() {
    this.initializeGridState();
  }

  initializeGridState() {
    const gridState: (Resource | null)[][] = []

    for (let i = 0; i < GameConstants.GRID_SIZE; i++) {
      const grid: (Resource | null)[] = []
      for (let j = 0; j < GameConstants.GRID_SIZE; j++) {
        grid.push(null)
      }
      gridState.push(grid)
    }
    this.gridState = gridState;
  }

  showMessage(msg: string) {
    promptAction.openToast({
      message: msg,
      duration: 400
    })
  }

  build() {

    NavDestination() {
    Column() {
      Column() {
        Row() {
          Image($r('app.media.crown')).width(32).height(32)
          Text(`${this.bestScore}`).fontColor('#ffef960a').fontWeight(FontWeight.Bold).fontSize(20)
        }.width('100%').height(20).justifyContent(FlexAlign.Center)

        Row() {
          Text(this.displayedScore.toString()).fontSize(25).fontWeight(FontWeight.Bold).fontColor(Color.White).padding(4)
        }.width('100%').height(35).justifyContent(FlexAlign.Center)
      }

      GameBoard({
        gridState: this.gridState,
        cellAnimationState: this.cellAnimationState,
        highlightCells: this.highlightCells,
        currentShape: this.currentShape,
        dropZoneArea: this.dropZoneArea
      })

      SourceArea({
        currentShape: $currentShape,
        isGameOver: this.isGameOver,
        visualOffsetX: $visualOffsetX,
        visualOffsetY: $visualOffsetY,
        isDragging: $isDragging,
        highlightCells: $highlightCells,
        dropZoneArea: this.dropZoneArea,
        gridState: this.gridState,
        targetScore: this.targetScore,
        cellAnimationState: this.cellAnimationState,
        bestScore: this.bestScore
      })

    }.width('100%').height('100%').padding(20).backgroundColor('#3E57C5')

    }.width('100%')
    .height('100%')
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })

  }
}