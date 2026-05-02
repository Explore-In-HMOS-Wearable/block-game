import { GameConstants } from '../common/GameConstants';
import { Cell, PlacementInfo, ShapeDefinition } from '../model/Game';
import {
  applyShapeToGrid,
  canPlaceShape,
  canShapeBePlacedAnywhere,
  clearCells,
  getCompletedLines
} from '../model/GameLogic';
import { secureRandomNumber } from '../utils/SecureRandom';
import vibrator from '@ohos.vibrator';

const PREVIEW_GAP = 3;
const SOURCE_TRAY_HEIGHT = 94;

@Component
export struct SourceArea {
  @Watch('onShapeChanged') @Link currentShape: ShapeDefinition;
  @Link isGameOver: boolean;
  @Link visualOffsetX: number;
  @Link visualOffsetY: number;
  @Link isDragging: boolean;
  @Link highlightCells: Cell[];
  @Link dropZoneArea: Area;
  @Link gridState: (Resource | null)[][];
  @Link targetScore: number;
  @Link cellAnimationState: Map<string, 'clearing' | 'cleared'>;
  @Link bestScore: number;
  @Watch('onResetCounterChanged') @Link resetCounter: number;
  @State isLineClearing: boolean = false;
  @State showShape: boolean = false;
  @State isDragInvalid: boolean = false;
  @State shapeMaxCol: number = 0;
  @State shapeMaxRow: number = 0;
  @State snapBackDuration: number = 0;
  @State draggableBlockArea: Area = {
    width: 0,
    height: 0,
    position: { x: 0, y: 0 },
    globalPosition: { x: 0, y: 0 }
  };
  private hoverAnchorRow: number = -999;
  private hoverAnchorCol: number = -999;

  aboutToAppear(): void {
    this.updateShapeDimensions();
    this.generateNewShapeAndCheckGameOver();
  }

  private onShapeChanged(): void {
    this.updateShapeDimensions();
  }

  private onResetCounterChanged(): void {
    this.showShape = false;
    this.isDragInvalid = false;
    this.isLineClearing = false;
    this.generateNewShapeAndCheckGameOver();
  }

  private updateShapeDimensions(): void {
    this.shapeMaxCol = Math.max(...this.currentShape.cells.map(c => c.col));
    this.shapeMaxRow = Math.max(...this.currentShape.cells.map(c => c.row));
  }

  private triggerHaptic(duration: number): void {
    vibrator.startVibration(
      { type: 'time', duration: duration },
      { id: 0, usage: 'touch' }
    ).catch(() => {});
  }

  private resetDraggableBlock() {
    this.snapBackDuration = 220;
    this.visualOffsetX = 0;
    this.visualOffsetY = 0;
    this.highlightCells = [];
    this.hoverAnchorRow = -999;
    this.hoverAnchorCol = -999;
  }

  private getAnchorCell(finalGlobalX: number, finalGlobalY: number): Cell {
    const dropZoneWidth = this.dropZoneArea.width as number;
    const dropZoneHeight = this.dropZoneArea.height as number;
    const dropZoneGlobalX = this.dropZoneArea.globalPosition.x as number;
    const dropZoneGlobalY = this.dropZoneArea.globalPosition.y as number;
    const cellWidth = dropZoneWidth / GameConstants.GRID_SIZE;
    const cellHeight = dropZoneHeight / GameConstants.GRID_SIZE;
    return {
      row: Math.floor((finalGlobalY - dropZoneGlobalY) / cellHeight),
      col: Math.floor((finalGlobalX - dropZoneGlobalX) / cellWidth)
    };
  }

  private updateHighlightForPointer(finalGlobalX: number, finalGlobalY: number): void {
    const anchor = this.getAnchorCell(finalGlobalX, finalGlobalY);
    if (anchor.row === this.hoverAnchorRow && anchor.col === this.hoverAnchorCol) {
      return;
    }

    this.hoverAnchorRow = anchor.row;
    this.hoverAnchorCol = anchor.col;
    const placement = this.getPlacementInfo(finalGlobalX, finalGlobalY);
    this.highlightCells = placement.canPlace ? placement.targetCells : [];
  }

  getPlacementInfo(finalGlobalX: number, finalGlobalY: number): PlacementInfo {
    const anchor = this.getAnchorCell(finalGlobalX, finalGlobalY);
    return canPlaceShape(this.gridState, this.currentShape.cells, anchor.row, anchor.col);
  }

  checkForCompletedLines(placedCells: Cell[]): boolean {
    const completedLines = getCompletedLines(this.gridState, placedCells);
    if (completedLines.cellsToClear.length > 0) {
      this.isLineClearing = true;
      this.targetScore += completedLines.cellsToClear.length * 10;
      this.triggerHaptic(120);

      const clearingState = new Map<string, 'clearing' | 'cleared'>();
      completedLines.cellsToClear.forEach((cell: Cell) => {
        clearingState.set(`${cell.row}-${cell.col}`, 'clearing');
      });
      this.cellAnimationState = clearingState;

      const totalAnimationTime = 300;
      setTimeout(() => {
        this.gridState = clearCells(this.gridState, completedLines.cellsToClear) as (Resource | null)[][];
        this.isLineClearing = false;
        this.cellAnimationState = new Map();
        this.generateNewShapeAndCheckGameOver();
      }, totalAnimationTime);

      return true;
    }
    return false;
  }

  generateNewShapeAndCheckGameOver() {
    this.generateNewShape();
    if (!this.canNextShapeBePlaced()) {
      this.isGameOver = true;
      if (this.targetScore > (this.bestScore ?? 0)) {
        AppStorage.set('bestScore', this.targetScore);
        this.bestScore = this.targetScore;
      }
      this.triggerHaptic(280);
    }
  }

  canNextShapeBePlaced(): boolean {
    return canShapeBePlacedAnywhere(this.gridState, this.currentShape.cells, GameConstants.GRID_SIZE);
  }

  generateNewShape(): void {
    const randomIndex = Math.floor(secureRandomNumber() * GameConstants.ALL_SHAPES.length);
    this.currentShape = GameConstants.ALL_SHAPES[randomIndex];
    this.showShape = true;
  }

  build() {
    Stack() {
      Stack() {
        ForEach(this.currentShape.cells, (cell: Cell) => {
          if (this.showShape) {
            Text()
              .width(GameConstants.BLOCK_PREVIEW_SIZE)
              .height(GameConstants.BLOCK_PREVIEW_SIZE)
              .backgroundColor(this.isDragInvalid ? Color.Red : this.currentShape.color)
              .borderRadius(4)
              .position({
                x: cell.col * (GameConstants.BLOCK_PREVIEW_SIZE + PREVIEW_GAP),
                y: cell.row * (GameConstants.BLOCK_PREVIEW_SIZE + PREVIEW_GAP)
              })
          }
        }, (cell: Cell) => `${this.currentShape.name}-${cell.row}-${cell.col}`)
      }
      .width(this.shapeMaxCol * (GameConstants.BLOCK_PREVIEW_SIZE + PREVIEW_GAP) + GameConstants.BLOCK_PREVIEW_SIZE)
      .height(this.shapeMaxRow * (GameConstants.BLOCK_PREVIEW_SIZE + PREVIEW_GAP) + GameConstants.BLOCK_PREVIEW_SIZE)
      .onAreaChange((_, area) => {
        this.draggableBlockArea = area;
      })
      .translate({ x: this.visualOffsetX, y: this.visualOffsetY })
      .animation({ duration: this.snapBackDuration, curve: Curve.EaseOut })
      .scale(this.isDragging ? { x: 1.24, y: 1.24 } : { x: 1.0, y: 1.0 })
      .opacity(this.isDragging ? 0.92 : 1)
      .zIndex(100)
      .margin(6)
      .gesture(
        PanGesture({
          distance: (this.isGameOver || this.isLineClearing) ? 10000 : 10
        })
          .onActionStart(() => {
            this.snapBackDuration = 0;
            this.hoverAnchorRow = -999;
            this.hoverAnchorCol = -999;
            this.isDragging = true;
          })
          .onActionUpdate((e: GestureEvent) => {
            this.visualOffsetX = e.offsetX;
            const liftOffset = (this.draggableBlockArea.height as number) * 0.1;
            this.visualOffsetY = e.offsetY - liftOffset;
            const blockGlobalX = (this.draggableBlockArea.globalPosition.x as number);
            const blockGlobalY = (this.draggableBlockArea.globalPosition.y as number);
            this.updateHighlightForPointer(blockGlobalX + e.offsetX, blockGlobalY + e.offsetY);
          })
          .onActionEnd((e: GestureEvent) => {
            this.isDragging = false;

            const blockGlobalX = (this.draggableBlockArea.globalPosition.x as number);
            const blockGlobalY = (this.draggableBlockArea.globalPosition.y as number);
            const placement = this.getPlacementInfo(blockGlobalX + e.offsetX, blockGlobalY + e.offsetY);

            if (placement.canPlace) {
              this.showShape = false;
              this.gridState = applyShapeToGrid(
                this.gridState,
                placement.targetCells,
                this.currentShape.color
              ) as (Resource | null)[][];
              this.targetScore += 10;
              this.triggerHaptic(30);
              const lineWasCleared = this.checkForCompletedLines(placement.targetCells);
              if (!lineWasCleared) {
                this.generateNewShapeAndCheckGameOver();
              }
            } else {
              this.isDragInvalid = true;
              this.triggerHaptic(20);
              setTimeout(() => {
                this.isDragInvalid = false;
              }, 200);
            }
            this.resetDraggableBlock();
          })
      )
    }
    .height(Math.max(SOURCE_TRAY_HEIGHT, this.shapeMaxRow * (GameConstants.BLOCK_PREVIEW_SIZE + PREVIEW_GAP) +
      GameConstants.BLOCK_PREVIEW_SIZE + 14))
    .width('100%')
  }
}
