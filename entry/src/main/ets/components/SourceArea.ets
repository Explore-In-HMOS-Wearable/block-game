import { GameConstants } from '../common/GameConstants';
import { Cell, PlacementInfo, ShapeDefinition } from '../model/Game';

@Component
export struct SourceArea {
  @Link currentShape: ShapeDefinition;
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
  @State isLineClearing: boolean = false;
  @State showShape: boolean = false;
  @State draggableBlockArea: Area = {
    width: 0,
    height: 0,
    position: { x: 0, y: 0 },
    globalPosition: { x: 0, y: 0 }
  };

  aboutToAppear(): void {
    this.generateNewShapeAndCheckGameOver()
  }

  private resetDraggableBlock() {
    this.visualOffsetX = 0;
    this.visualOffsetY = 0;
    this.highlightCells = [];
  }

  getPlacementInfo(finalGlobalX: number, finalGlobalY: number): PlacementInfo {
    const dropZoneWidth = this.dropZoneArea.width as number;
    const dropZoneHeight = this.dropZoneArea.height as number;
    const dropZoneGlobalX = this.dropZoneArea.globalPosition.x as number;
    const dropZoneGlobalY = this.dropZoneArea.globalPosition.y as number;
    const cellWidth = dropZoneWidth / GameConstants.GRID_SIZE;
    const cellHeight = dropZoneHeight / GameConstants.GRID_SIZE;
    const anchorRelativeX = finalGlobalX - dropZoneGlobalX;
    const anchorRelativeY = finalGlobalY - dropZoneGlobalY;
    const anchorCol = Math.floor(anchorRelativeX / cellWidth);
    const anchorRow = Math.floor(anchorRelativeY / cellHeight);
    const targetCells: Cell[] = [];
    let canPlace = true;

    for (const shapeCell of this.currentShape.cells) {
      const targetRow = anchorRow + shapeCell.row;
      const targetCol = anchorCol + shapeCell.col;
      if (targetRow < 0 || targetRow >= GameConstants.GRID_SIZE ||
        targetCol < 0 || targetCol >= GameConstants.GRID_SIZE ||
        this.gridState[targetRow][targetCol] !== null) {
        canPlace = false;
        break;
      }
      targetCells.push({ row: targetRow, col: targetCol });
    }
    return { targetCells, canPlace };
  }

  checkForCompletedLines(placedCells: Cell[]): boolean {
    const rowsToCheck = new Set(placedCells.map(c => c.row));
    const colsToCheck = new Set(placedCells.map(c => c.col));
    const cellsToClear: Cell[] = [];
    rowsToCheck.forEach(rowIndex => {
      if (this.gridState[rowIndex].every(cell => cell !== null)) {
        for (let j = 0; j < GameConstants.GRID_SIZE; j++) {
          cellsToClear.push({ row: rowIndex, col: j });
        }
      }
    });
    colsToCheck.forEach(colIndex => {
      let isColFull = true;
      for (let i = 0; i < GameConstants.GRID_SIZE; i++) {
        if (this.gridState[i][colIndex] === null) {
          isColFull = false;
          break;
        }
      }
      if (isColFull) {
        for (let i = 0; i < GameConstants.GRID_SIZE; i++) {
          if (!cellsToClear.some(cell => cell.row === i && cell.col === colIndex)) {
            cellsToClear.push({ row: i, col: colIndex });
          }
        }
      }
    });

    if (cellsToClear.length > 0) {
      this.isLineClearing = true;
      this.targetScore += cellsToClear.length * 10;

      cellsToClear.forEach((cell, index) => {
        const key = `${cell.row}-${cell.col}`;
        setTimeout(() => {
          this.cellAnimationState.set(key, 'clearing');
          this.cellAnimationState = new Map(this.cellAnimationState);
        }, index * GameConstants.CLEAR_ANIMATION_DELAY_MS);
      });

      const totalAnimationTime = cellsToClear.length * GameConstants.CLEAR_ANIMATION_DELAY_MS + 300;
      setTimeout(() => {
        const newGrid = [...this.gridState.map(row => [...row])];
        cellsToClear.forEach(cell => {
          newGrid[cell.row][cell.col] = null;
        });
        this.gridState = newGrid;
        this.isLineClearing = false;
        this.cellAnimationState.clear();
        this.generateNewShapeAndCheckGameOver();
      }, totalAnimationTime);

      return true;
    }
    return false
  }

  generateNewShapeAndCheckGameOver() {
    this.generateNewShape();
    if (!this.canNextShapeBePlaced()) {
      this.isGameOver = true;
      if (this.targetScore > this.bestScore) {
        AppStorage.set('bestScore', this.targetScore);
        this.bestScore = this.targetScore;
      }
    }
  }

  canNextShapeBePlaced(): boolean {
    for (let row = 0; row < GameConstants.GRID_SIZE; row++) {
      for (let col = 0; col < GameConstants.GRID_SIZE; col++) {
        let canPlaceAtThisPosition = true;
        for (const shapeCell of this.currentShape.cells) {
          const targetRow = row + shapeCell.row;
          const targetCol = col + shapeCell.col;

          if (targetRow >= GameConstants.GRID_SIZE ||
            targetCol >= GameConstants.GRID_SIZE ||
            this.gridState[targetRow][targetCol] !== null
          ) {
            canPlaceAtThisPosition = false;
            break;
          }
        }
        if (canPlaceAtThisPosition) {
          return true;
        }
      }
    }
    return false;
  }

  generateNewShape() {
    const randomIndex = Math.floor(Math.random() * GameConstants.ALL_SHAPES.length);
    this.currentShape = GameConstants.ALL_SHAPES[randomIndex];
    this.showShape = true;
  }

  build() {
    Stack() {
      Stack() {
        ForEach(this.currentShape.cells, (cell: Cell, index: number) => {
          if (this.showShape) {
            Text()
              .width(GameConstants.BLOCK_PREVIEW_SIZE)
              .height(GameConstants.BLOCK_PREVIEW_SIZE)
              .backgroundColor(this.currentShape.color)
              .borderRadius(4)
              .position({
                x: cell.col * (GameConstants.BLOCK_PREVIEW_SIZE + 2),
                y: cell.row * (GameConstants.BLOCK_PREVIEW_SIZE + 2)
              })
          }

        }, (cell: Cell, index: number) => `${this.currentShape.name}-${index}`)
      }
      .width((Math.max(...this.currentShape.cells.map(c => c.col)) + 1) * GameConstants.BLOCK_PREVIEW_SIZE)
      .height((Math.max(...this.currentShape.cells.map(c => c.row)) + 1) * GameConstants.BLOCK_PREVIEW_SIZE)
      .onAreaChange((_, area) => {
        this.draggableBlockArea = area;
      })
      .translate({ x: this.visualOffsetX, y: this.visualOffsetY })
      .animation({ duration: 500, curve: Curve.EaseOut })
      .scale(this.isDragging ? { x: 1.2, y: 1.2 } : { x: 1.0, y: 1.0 })
      .zIndex(100)
      .margin(10)
      .gesture(
        PanGesture({
          distance: (this.isGameOver || this.isLineClearing) ? 10000 : 10
        })
          .onActionStart(() => {
            this.isDragging = true
          })
          .onActionUpdate((e: GestureEvent) => {
            this.visualOffsetX = e.offsetX;
            this.visualOffsetY = e.offsetY - 30;
            const blockGlobalX = (this.draggableBlockArea.globalPosition.x as number);
            const blockGlobalY = (this.draggableBlockArea.globalPosition.y as number);
            const placement = this.getPlacementInfo(blockGlobalX + e.offsetX, blockGlobalY + e.offsetY);
            this.highlightCells = placement.canPlace ? placement.targetCells : [];
          })
          .onActionEnd((e: GestureEvent) => {
            this.isDragging = false;

            const blockGlobalX = (this.draggableBlockArea.globalPosition.x as number);
            const blockGlobalY = (this.draggableBlockArea.globalPosition.y as number);
            const placement = this.getPlacementInfo(blockGlobalX + e.offsetX, blockGlobalY + e.offsetY);

            if (placement.canPlace) {
              this.showShape = false;
              const newGrid = [...this.gridState.map(row => [...row])];
              placement.targetCells.forEach(cell => {
                newGrid[cell.row][cell.col] = this.currentShape.color;
              });
              this.gridState = newGrid;
              this.targetScore += 10;
              const lineWasCleared = this.checkForCompletedLines(placement.targetCells);
              if (!lineWasCleared) {
                this.generateNewShapeAndCheckGameOver();
              }
            }
            this.resetDraggableBlock();
          })
      )
    }
    .height(30)
    .width('100%')
  }
}