import { describe, it, expect } from '@ohos/hypium';
import { Cell } from '../main/ets/model/Game';
import {
  applyShapeToGrid,
  calculateScoreDelta,
  canPlaceShape,
  canShapeBePlacedAnywhere,
  clearCells,
  cloneGrid,
  createEmptyGrid,
  findDuplicateLayouts,
  getCompletedLines,
  nextRand,
  randomShapeIndex,
  ShapeLayout
} from '../main/ets/model/GameLogic';

export default function localUnitTest() {
  describe('localUnitTest', () => {
    const occupied = {};
    const lineShape: ShapeLayout = {
      name: 'line',
      cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }]
    };
    const lShape: ShapeLayout = {
      name: 'l_shape',
      cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }, { row: 1, col: 1 }]
    };

    it('createEmptyGrid returns a square grid filled with null', 0, () => {
      const grid = createEmptyGrid(3);
      expect(grid.length).assertEqual(3);
      expect(grid[0].length).assertEqual(3);
      expect(grid[2][2]).assertEqual(null);
    });

    it('cloneGrid returns a deep copy', 0, () => {
      const grid = createEmptyGrid(2);
      const filledGrid = applyShapeToGrid(grid, [{ row: 0, col: 1 }], occupied);
      const clonedGrid = cloneGrid(filledGrid);
      clonedGrid[0][1] = null;
      expect(filledGrid[0][1] !== null).assertTrue();
    });

    it('nextRand keeps values below one', 0, () => {
      const result = nextRand(0xffffffff);
      expect(result.value < 1).assertTrue();
      expect(result.seed >= 0).assertTrue();
    });

    it('randomShapeIndex returns an in-range index', 0, () => {
      const result = randomShapeIndex(123456, 5);
      expect(result.index >= 0).assertTrue();
      expect(result.index < 5).assertTrue();
    });

    it('canPlaceShape returns valid target cells for open positions', 0, () => {
      const grid = createEmptyGrid(4);
      const placement = canPlaceShape(grid, lShape.cells, 1, 1);
      const expectedCells: Cell[] = [{ row: 1, col: 1 }, { row: 2, col: 1 }, { row: 2, col: 2 }];
      expect(placement.canPlace).assertTrue();
      expect(JSON.stringify(placement.targetCells)).assertEqual(JSON.stringify(expectedCells));
    });

    it('canPlaceShape rejects occupied or out-of-bounds positions', 0, () => {
      let grid = createEmptyGrid(4);
      grid = applyShapeToGrid(grid, [{ row: 1, col: 1 }], occupied);
      const blockedPlacement = canPlaceShape(grid, lShape.cells, 1, 1);
      const outOfBoundsPlacement = canPlaceShape(grid, lShape.cells, 3, 3);
      expect(blockedPlacement.canPlace).assertFalse();
      expect(outOfBoundsPlacement.canPlace).assertFalse();
    });

    it('canShapeBePlacedAnywhere finds remaining legal placements', 0, () => {
      const grid = createEmptyGrid(3);
      expect(canShapeBePlacedAnywhere(grid, lineShape.cells, 3)).assertTrue();
    });

    it('canShapeBePlacedAnywhere returns false when the board is full', 0, () => {
      let grid = createEmptyGrid(2);
      grid = applyShapeToGrid(
        grid,
        [{ row: 0, col: 0 }, { row: 0, col: 1 }, { row: 1, col: 0 }, { row: 1, col: 1 }],
        occupied
      );
      expect(canShapeBePlacedAnywhere(grid, lineShape.cells, 2)).assertFalse();
    });

    it('getCompletedLines deduplicates row and column intersections', 0, () => {
      let grid = createEmptyGrid(3);
      grid = applyShapeToGrid(
        grid,
        [
          { row: 0, col: 1 },
          { row: 1, col: 1 },
          { row: 2, col: 1 },
          { row: 2, col: 0 },
          { row: 2, col: 2 }
        ],
        occupied
      );
      const result = getCompletedLines(grid, [{ row: 2, col: 1 }]);
      expect(JSON.stringify(result.clearedRows)).assertEqual('[2]');
      expect(JSON.stringify(result.clearedCols)).assertEqual('[1]');
      expect(result.cellsToClear.length).assertEqual(5);
    });

    it('clearCells only clears requested positions', 0, () => {
      let grid = createEmptyGrid(3);
      grid = applyShapeToGrid(
        grid,
        [{ row: 0, col: 0 }, { row: 1, col: 1 }],
        occupied
      );
      const clearedGrid = clearCells(grid, [{ row: 0, col: 0 }]);
      expect(clearedGrid[0][0]).assertEqual(null);
      expect(clearedGrid[1][1] !== null).assertTrue();
    });

    it('calculateScoreDelta includes placement and line clear points', 0, () => {
      expect(calculateScoreDelta(0)).assertEqual(10);
      expect(calculateScoreDelta(4)).assertEqual(50);
    });

    it('findDuplicateLayouts reports duplicate shapes', 0, () => {
      const duplicates = findDuplicateLayouts([
        {
          name: 'shape_a',
          cells: [{ row: 0, col: 0 }, { row: 0, col: 1 }]
        },
        {
          name: 'shape_b',
          cells: [{ row: 0, col: 1 }, { row: 0, col: 0 }]
        },
        {
          name: 'shape_c',
          cells: [{ row: 0, col: 0 }, { row: 1, col: 0 }]
        }
      ]);
      expect(JSON.stringify(duplicates)).assertEqual('[\"shape_a == shape_b\"]');
    });
  });
}
