// Initiate angular
app.controller('caController', function ($interval, $scope) {
    var map = this;
    $scope.map = map;
    map.name = "CellSystem";
    $scope.rows = 50;
    $scope.cols = 50;
    map.map = new Map($scope.cols, $scope.rows);
    // map.map.notifyOnChange(cell => console.log(cell.position.toString(), cell));
    // Map Preperation
    map.cellSize = 10;
    map.widthPx = map.map.cols * map.cellSize;
    map.heightPx = map.map.rows * map.cellSize;
    var stop;  // intervallbinding to stop
    var flipcounter;
    var dividecounter;
    var mapsize = map.map.cols * map.map.rows;
    var initialBlock = mapsize * 0.1;
    var logstring = "";

    $scope.lbl_pie = ["Dead", "Alive"];
    $scope.ds_pie = [initialBlock, mapsize - initialBlock];

    // chart Preperation
    $scope.initPercent = parseInt(5);
    $scope.dividePercent = parseInt(70);
    $scope.flipPercent = parseInt(30);
    $scope.stepcounter = 0;
    //$scope.onClick = function (points, evt) { console.log(points, evt); };
    //$scope.labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
    $scope.lbl_line = [0];
    // i know ... scarry....
    $scope.series = ['&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Population' ];
    $scope.ds_line = [[initialBlock]];


    $scope.saveFile = function() {


        // saveLogToFile("Hello, world!", "CA_TEXTFILE");
        /*
        var svgString = new XMLSerializer().serializeToString(document.querySelector('svg'));

        var canvas = document.getElementById("canvas");
        var ctx = canvas.getContext("2d");
        var DOMURL = self.URL || self.webkitURL || self;
        var img = new Image();
        var svg = new Blob([svgString], {type: "image/svg+xml;charset=utf-8"});
        var url = DOMURL.createObjectURL(svg);
        img.onload = function() {
            ctx.drawImage(img, 0, 0);
            var png = canvas.toDataURL("image/png");
            var png_con = document.getElementById('png-container');
            png_con.innerHTML = '<img src="'+png+'"/>';
            DOMURL.revokeObjectURL(png);
        };
        img.src = url;

        // draw to canvas...
        canvas.toBlob(function(blob) {
            saveAs(blob, "CA_step_" + $scope.stepcounter + ".png");
        });
        
        var svgString = new XMLSerializer().serializeToString(document.querySelector('svg'));
        saveLogToFile(svgString, "CA_step_" + $scope.stepcounter + ".svg");
        */
    };

    $scope.runStepByStep = function() {
      // Don't start a new Run if the Old is still active
      if ( angular.isDefined(stop) ) return;

      let system = new CellSystem(map.map);
      var dp = parseInt($scope.dividePercent);
      var fc = parseInt($scope.flipPercent);
      stop = $interval(function() {
        // To Do Each Step
        system.step(dp, fc);
        $scope.stepcounter = $scope.stepcounter + 1;

        if($scope.stepcounter % 100 === 0) {
            var population = system.getPopulation();
            $scope.ds_line[0].push(population);
            $scope.lbl_line.push($scope.stepcounter / 100);
            $scope.ds_pie = [population, mapsize - population];
            // Logging options
            logstring = "step: " + $scope.stepcounter + " blocked: " + map.map.getBlockedCellsCount() + " free: " + map.map.getLivingCellsCount() + ";\r\n";
            console.log(logstring + map.map.getOuterBoundaries() + "\r\n");
            // $scope.saveFile();

        }
      }, 10); // ms till next Step.
    };

    $scope.stopRun = function() {
      if (angular.isDefined(stop)) {
        $interval.cancel(stop);
        stop = undefined;
      }
    };

    $scope.resetMap = function() {
            map.map.reset();
            logstring = "";
    };

    map.addRandomObstacles = () => {
        //map.map.reset();
        var value = parseInt($scope.initPercent)/100;
        map.map.addRandomObstacles((map.map.cols * map.map.rows) * value);
    };

    map.addObstaclesFromCenter = () => {
        //map.map.reset();
        var value = parseInt($scope.initPercent)/100;
        map.map.addObstaclesFromCenter(parseInt($scope.initPercent), value);
    };

    map.clickOnCell = (cell) => {
        switch (cell.type) {
        case CellType.Blocked:
            cell.type = CellType.Free;
            break;
        case CellType.Free:
            cell.type = CellType.Blocked;
            break;
        default:
        }
        this.map.updateCell(cell);
    };

    map.mouseOverCell = (cell, event) => {
        if (event.buttons == 1) {
            this.clickOnCell(cell);
        }
    };
});
