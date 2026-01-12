import { GameConstants } from '../common/GameConstants';
import { Cell, ShapeDefinition } from '../model/Game';

interface CellRef {
  id: string;
  row: number;
  col: number;
}

function buildBoardCells(size: number): Array<CellRef> {
  let out: Array<CellRef> = [];
  for (let r = 0; r < size; r++) {
    for (let c = 0; c < size; c++) {
      out.push({ id: `${r}-${c}`, row: r, col: c });
    }
  }
  return out;
}

const BOARD_CELLS: Array<CellRef> = buildBoardCells(GameConstants.GRID_SIZE);

@Component
export struct GameBoard {
  @Link gridState: (Resource | null)[][];
  @Link cellAnimationState: Map<string, 'clearing' | 'cleared'>;
  @Link highlightCells: Cell[];
  @Prop currentShape: ShapeDefinition;
  @Link dropZoneArea: Area;

  private isHighlighted(row: number, col: number): boolean {
    return this.highlightCells.some((c: Cell) => c.row === row && c.col === col);
  }

  build() {
    Grid() {
      ForEach(BOARD_CELLS, (cell: CellRef) => {
        GridItem() {
          if (this.gridState[cell.row][cell.col] !== null) {
            Text()
              .width('100%')
              .height('100%')
              .backgroundColor(this.gridState[cell.row][cell.col] as Resource)
              .borderRadius(4)
              .padding(4)
              .scale(this.cellAnimationState.get(cell.id) === 'clearing'
                ? { x: 1.3, y: 1.3 }
                : { x: 1, y: 1 })
              .opacity(this.cellAnimationState.get(cell.id) === 'clearing' ? 0 : 1)
              .animation({ duration: 300, curve: Curve.EaseIn })
          } else if (this.isHighlighted(cell.row, cell.col)) {
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
      }, (cell: CellRef) => cell.id)
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
