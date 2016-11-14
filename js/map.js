/*jshint esversion: 6 */
//var _ = require('lodash');

class Position {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
    toString() {
        return "x = " + this.x + " y = " + this.y;
    }
}

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


class Map {
    constructor(rows, cols) {
        this.rows = rows;
        this.cols = cols;
        this.changeListner = [];
        this.grid = [
          []
        ];
        this.cells = [];
        this.center = new Position(0,0);

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

      var square_x = Math.round(Math.sqrt(count * 2));
      var square_y = Math.round(Math.sqrt(count * 2));

        var freeCells = this.cells.reduce(
            (prev, curr) => {
                if (curr.isFree) prev++;
                return prev;
            }, 0);

        if (count > freeCells)
            count = freeCells;

        for (var i = 0; i < count; i++) {
            var row = Math.round((this.rows - square_x) / 2 + _.random(0, square_x - 1));
            var col = Math.round((this.rows - square_y) / 2 + _.random(0, square_y - 1));

            if (this.grid[row][col].isFree) {
                this.grid[row][col].type = CellType.Blocked;
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

    getOuterBoundaries() {

        // better to --> run throu reduced map
        var lowest_x = this.rows;
        var lowest_y = this.cols;
        var lpx;
        var lpy;
        var heighest_x = 0;
        var heighest_y = 0;
        var hpx;
        var hpy;

        this.cells.reduce(
            (prev, curr) => {
                if (!curr.isFree) {
                    if(lowest_x > curr.position.x) { lpx = new Position(curr.position.x,curr.position.y); lowest_x = curr.position.x; }
                    if(lowest_y > curr.position.y) { lpy = new Position(curr.position.x,curr.position.y); lowest_y = curr.position.y; }
                    if(heighest_x < curr.position.x) { hpx = new Position(curr.position.x,curr.position.y); heighest_x = curr.position.x; }
                    if(heighest_y < curr.position.y) { hpy = new Position(curr.position.x,curr.position.y); heighest_y = curr.position.y; }
                };
            }, 0);

        this.center = new Position(
          ((lpx.x + hpx.x + lpy.x) / 3),
          ((lpx.y + hpx.y + lpy.y) / 3));
        if(lineDistance(hpy, this.center) >= lineDistance(lpx, this.center))
        { this.center.x = (lpx.x + hpx.x + hpy.x) / 3;
          this.center.y = (lpx.y + hpx.y + hpy.y) / 3; }
        if(lineDistance(lpy, this.center) >= lineDistance(lpx, this.center))
        { this.center.x = (lpx.x + lpy.x + hpy.x) / 3;
          this.center.y = (lpx.y + lpy.y + hpy.y) / 3; }
        if(lineDistance(hpx, this.center) >= lineDistance(lpx, this.center))
        { center.x = (hpx.x + lpy.x + hpy.x) / 3;
          center.y = (hpx.y + lpy.y + hpy.y) / 3; }



        return "low_point_x(" + lpx.x + ", " + lpx.y + ")\r\n" +
                "low_point_y(" + lpy.x + ", " + lpy.y + ")\r\n" +
                "hei_point_x(" + hpx.x + ", " + hpx.y + ")\r\n" +
                "hei_point_y(" + hpy.x + ", " + hpy.y + ")\r\n" +
                "center(" + this.center.x + ", " + this.center.y +", r=" + lineDistance(hpx, this.center) + ")";
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
    constructor(row, col, cellType = CellType.Free) {
        this.position = new Position(col, row);
        this.cellType = cellType;
    }

    set type(cellType) {
        this.cellType = cellType;
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
}

var CellType = Object.freeze({
    Free: 0,
    Blocked: 1,
    Visited: 2,
    Current: 3,
    Start: 4,
    Goal: 5
});
