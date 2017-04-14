/*jshint esversion: 6 */
//var _ = require('lodash');

class Moveable {
    constructor(map, cellType) {

        this.cellType = cellType;
        this.map = map;
        this.position = undefined;
    }

    moveTo(position) {
        if (this.position !== undefined) {
            this.map.updateCellOnPosition(position, cell => {
                cell.type = CellType.Free;
                return cell;
            });
        }
        this.position = position;
        this.map.updateCellOnPosition(position, cell => {
            cell.type = this.cellType;
            return cell;
        });
    }
}

/*Represents the grid and all it´s properties. Cells are stored in here. */
class Map {
    constructor(rows, cols) {
        this.rows = rows;
        this.cols = cols;
        this.changeListner = [];
        this.grid = [
          []
        ];
        this.cells = [];
        this.center = new Position(cols,rows);
        this.radius = 10;
        this.radius80p = 10;

        this.initializeGrid();
    }

    initializeGrid() {
        for (var row = 0; row < this.rows; row++) {
            this.grid.push([]);
            for (var col = 0; col < this.cols; col++) {
                var c = new Cell(row, col);
                
                // uncool and needs to be fixed.

                this.grid[row].push(c);

                this.cells.push(c);
            }
        }
    }

    //todo: use array observe: https://developer.mozilla.org/de/docs/Web/JavaScript/Reference/Global_Objects/Array/observe
    //using this function will automatically singnalize that the map has changed
    updateCellOnPosition(position, lambda) {
        var updatedCell = lambda(this.getCell(position.x, position.y));
        this.updateCell(updatedCell);
    }

    updateCell(cell) {
        this.grid[cell.position.y][cell.position.x] = cell;
        this.hasChanged(cell);
    }

    hasChanged(updatedCell) {
        this.changeListner.forEach(changeListner => changeListner(updatedCell));
    }

    notifyOnChange(lambda) {
        this.changeListner.push(lambda);
    }


    addRandomObstacles(count) {
        //apply some magic to count free cells
        var freeCells = this.getLivingCellsCount();

        if (count > freeCells)
            count = freeCells;

        for (var i = 0; i < count; i++) {
            var row = _.random(0, this.rows - 1);
            var col = _.random(0, this.cols - 1);

            if (this.grid[row][col].isFree) {
                this.grid[row][col].type = CellType.Blocked;
                this.hasChanged(this.grid[row][col]);
            } else {
                i--;
            }
        }
    }

    addObstaclesFromCenter(count, initPercent)
    {
      /*  TODO: Implement from cellinsert from Center
      /*
      /******************************
      */
      count =  Math.round(this.cells.length * initPercent);
      this.radius = initPercent * 200;
      this.center = new Position(this.rows / 2, this.cols / 2);
      var minfromCenter = initPercent * -200;
      var maxfromCenter = initPercent * 200;
        
        
        var freeCells = this.cells.reduce(
            (prev, curr) => {
                if (curr.isFree) prev++;
                return prev;
            }, 0);

        if (count > freeCells)
            count = freeCells;

        for (var i = 0; i < count; i++) {
            //var row = Math.round((this.rows - square_x) / 2 + _.random(0, square_x - 1));
            //var col = Math.round((this.rows - square_y) / 2 + _.random(0, square_y - 1));
            var row = Math.round(_.random(minfromCenter, maxfromCenter)) + 24;
            var col = Math.round(_.random(minfromCenter, maxfromCenter)) + 24;
            var ld = lineDistance(this.grid[row][col].position, this.center);
            
            if (this.grid[row][col].isFree &&  ld < this.radius) {
                this.grid[row][col].type = CellType.Blocked;
                this.grid[row][col].isBorder = true;
                this.hasChanged(this.grid[row][col]);
            } else {
                i--;
            }
        }

    }

    getLivingCellsCount() {
        return this.cells.reduce(
            (prev, curr) => {
                if (curr.isFree) prev++;
                return prev;
            }, 0);
    }

    getBlockedCellsCount() {
        return this.cells.reduce(
            (prev, curr) => {
                if (!curr.isFree) prev++;
                return prev;
            }, 0);
    }
    
    getBorders() {
        // v2
        var points = [];

        this.cells.reduce(
            (prev, curr) => {
                if (curr.isBorder) {
                    points.push(curr.position);
                };
            }, 0);

        return points;    
        
    }
    
  	getRandomCell() {
  		var row = _.random(0, this.rows - 1);
        var col = _.random(0, this.cols - 1);
  		return this.grid[row][col];
  	}

    getStartCell() {
        return this.cells.find(cell => cell.isStart);
    }

    getGoalCell() {
        return this.cells.find(cell => cell.isGoal);
    }

    getCells() {
        return _.flatten(this.grid);
    }

    getCell(x, y) {
        if (x >= 0 && y >= 0 && x < this.cols && y < this.rows) {
            return this.grid[y][x];
        } else {
            return undefined;
        }
    }
    
    reset() {
        this.cells.filter(cell => cell.isVisited || cell.isCurrent || cell.isGoal || cell.isBlocked).forEach(cell => {
            cell.type = CellType.Free;
            cell.color = undefined;
        })
    }
}

class Cell {
    constructor(row, col, border = false, cellType = CellType.Free, distanceToCenter = 0) {
        this.position = new Position(col, row);
        this.cellType = cellType;
        this.border = border;
        this.distToCenter = distanceToCenter;
    }
    
    set type(cellType) {
        this.cellType = cellType;
    }
    
    set isBorder(border) {
        this.border = border;
    }
    
    set setDistToCenter(distanceToCenter) {
        this.distToCenter = distanceToCenter;
    }

    get type() {
        return this.cellType;
    }
    get isFree() {
        return this.type === CellType.Free;
    }
    get isBlocked() {
        return this.type === CellType.Blocked;
    }
    get isVisited() {
        return this.type === CellType.Visited;
    }
    get isCurrent() {
        return this.type === CellType.Current;
    }
    get isStart() {
        return this.type === CellType.Start;
    }
    get isGoal() {
        return this.type === CellType.Goal;
    }
    
    get isBorder() {
        return this.border;
    }
    get getDistToCenter() {
        return this.distToCenter;
    }
}

var CellType = Object.freeze({
    Free: 0,
    Blocked: 1,
    Visited: 2,
    Current: 3,
    Start: 4,
    Goal: 5,
});
