import { GameConstants } from '../common/GameConstants'
import { Cell, ShapeDefinition } from '../model/Game';


@Component
export struct GameBoard {
  @Link gridState: (Resource | null)[][];
  @Link cellAnimationState: Map<string, 'clearing' | 'cleared'>;
  @Link highlightCells: Cell[];
  @Prop currentShape: ShapeDefinition;
  @Link dropZoneArea: Area;

  build() {
    Grid() {
      ForEach(this.gridState, (rowItems: Resource[], rowIndex) => {
        ForEach(rowItems, (cellColor: Resource, colIndex) => {
          GridItem() {
            if (cellColor) {
              Text()
                .width('100%')
                .height('100%')
                .backgroundColor(cellColor)
                .borderRadius(4)
                .padding(4)
                .scale(this.cellAnimationState.get(`${rowIndex}-${colIndex}`) === 'clearing' ? { x: 1.3, y: 1.3 } :
                  { x: 1, y: 1 })
                .opacity(this.cellAnimationState.get(`${rowIndex}-${colIndex}`) === 'clearing' ? 0 : 1)
                .animation({ duration: 300, curve: Curve.EaseIn })
            } else if (this.highlightCells.some(c => c.row === rowIndex && c.col === colIndex)) {
              Text()
                .width('95%')
                .height('95%')
                .backgroundColor(this.currentShape.color)
                .opacity(0.5)
                .borderRadius(4)
            } else {
              Column()
                .width('95%')
                .height('95%')
                .backgroundColor(Color.Transparent)
                .border({ width: 1, color: '#20284E' })
            }
          }
        })
      })
    }
    .backgroundColor('#242C54')
    .columnsTemplate(Array(GameConstants.GRID_SIZE).fill('1fr').join(' '))
    .rowsTemplate(Array(GameConstants.GRID_SIZE).fill('1fr').join(' '))
    .width('50%')
    .aspectRatio(1)
    .onAreaChange((_, area) => this.dropZoneArea = area)
    .margin({ bottom: 15 })
    .borderRadius(4)
    .padding(4)
  }
}