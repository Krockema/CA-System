// app.controller('graphController', function ($attrs, $interval, $scope) {
app.controller('graphController', function ($interval, $scope) {
  $scope.initDensity = parseInt(2500);
  $scope.initDistanceFromCenter = parseInt(20);
  $scope.initDistribution = parseInt(5);
  $scope.dividePercent = parseInt(5);
  $scope.flipPercent = parseInt(5);
  $scope.updateCycle = parseInt(100);
  $scope.stepcounter = 0;


  // chart Preperation
  $scope.lbl_pie = ["Dead", "Alive"];
  var population = (parseInt($scope.initDistribution) * parseInt($scope.initDensity) / 100);
  $scope.ds_pie = [population, parseInt($scope.initDensity) - population];
  $scope.lbl_line = [0];
  // i know ... scarry....
  $scope.series = ['&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Population' ];
  $scope.ds_line = [[population]];
  var logstring = "";
    

  $scope.algorithm = {
    voronoi : true,
    delaunay : false,
    pointers : true,
    centerInfection : true,
    dynamicSystem : false
  };
  var stop;
  // Canvas Context
  var canvas = document.getElementById("c"),
      context = canvas.getContext("2d"),
      width = canvas.width = 500,
      height = canvas.height = 500;
  // Voronoi Parameters
  var particles = new Array($scope.initDensity);
  var voronoi = d3_voronoi.voronoi()
      .extent([[-1, -1], [width + 1, height + 1]]);
  var topology;
  var VoronoiGeo;

  $scope.generateMap =  function() {
      // initialize the map - Create a Random Dot Matrix
      population = 0;
      count = 0;
      $scope.stepcounter = 0;
      particles = new Array($scope.initDensity);
      for (var i = 0; i < parseInt($scope.initDensity); ++i) {
          let x2 = Math.random() * width;
          let y2 = Math.random() * height;
          var cellType = getCellInfectionState(x2, y2);

          particles[i] = {0: x2,
                          1: y2,
                          vx: 0,
                          vy: 0,
                          cellType: cellType,
                          isBorder: false,
                          number: count};
          count++;
          }
      topology = computeTopology(voronoi(particles));
      VoronoiGeo = topojson.mesh(topology, topology.objects.voronoi, function(a, b) { return a !== b; });
      setBorders();
      reDrawGraph(topology);
      // start voronoi teslation and Create its TreeStructure
      
  };
    
    function setBorders() {        
        let cells = particles.filter(cell => cell.cellType != 'healthy');
        let c = 0;
        for(let cell of cells) {
            let neighbors = getValidNeighbors(cell.number);
            if(neighbors.length > 0) {  cell.isBorder = true; 
                                        c++; }
            else{ cell.isBorder = false; }
        }
        return c;
    }

    function getBorders() {
        var p = [];
        for(let pnt of particles.filter(cell => cell.isBorder == true)) {
            p.push(new Position(pnt[0], pnt[1]));
        }
        return p;
    }

    function getGetInfectionCount() {
        return particles.filter(cell => cell.cellType != 'healthy').length;
    }
    
  function getCellInfectionState(x2, y2) {
    var cellType = 'healthy';
    let maxDistance = (width * parseInt($scope.initDistanceFromCenter) / 100);
    let x1 = width / 2;
    let y1 = height / 2;
    if($scope.algorithm.centerInfection === true) {
      if(Math.sqrt( (x2-=x1)*x2 + (y2-=y1)*y2 ) < maxDistance 
         && (population < (parseInt($scope.initDensity) * parseInt($scope.initDistribution) / 100))) {
        population++;
        cellType = 'infected';
      }
    } else if (Math.random() < (parseInt($scope.initDistribution) / 100)) {
      population++;
      cellType = 'infected';
    }
    return cellType;
  }

  $scope.startRun = function() {
    // Don't start a new Run if the Old is still active
    // TODO: Abbruchbedingung --> System is full;
    if ( angular.isDefined(stop) ) return;

      var dp = parseInt($scope.dividePercent);
      var fc = parseInt($scope.flipPercent);
      stop = $interval(function() {
        // Step Logic
        if ($scope.algorithm.dynamicSystem) {
          stepDynamic(dp, fc);
        } else {
          stepStatic(dp, fc);
        }
        // Step Counter
        $scope.stepcounter = $scope.stepcounter + 1;

        if($scope.stepcounter % parseInt($scope.updateCycle) === 0) {
          reDrawGraph();
        }

        if($scope.stepcounter % $scope.updateCycle === 0) {
          /* Statistics -  */
          $scope.ds_line[0].push(population);
          $scope.lbl_line.push($scope.stepcounter / 100);
          $scope.ds_pie = [population, parseInt($scope.initDensity) - population];
            if (population % ($scope.initDensity * 0.9) === 0) {
              $interval.cancel(stop);
              stop = undefined;
              saveLogToFile(logstring, 'gs1.txt'); logstring = "";
            }    
        }

          
      }, 0); // ms till next Step.

  };

  $scope.stopRun = function() {
    if (angular.isDefined(stop)) {
      $interval.cancel(stop);
      stop = undefined;
    }
  };

  function stepDynamic(dividePercentCell, flipPercentCell) {
    let isRunning = true;

    for (var i = 0; i < particles.length; ++i) {
        var p = particles[i];
        p[0] += p.vx; if (p[0] < 0) p[0] = p.vx *= -1; else if (p[0] > width) p[0] = width + (p.vx *= -1);
        p[1] += p.vy; if (p[1] < 0) p[1] = p.vy *= -1; else if (p[1] > height) p[1] = height + (p.vy *= -1);
        p.vx += 0.1 * (Math.random() - 0.5) - 0.01 * p.vx;
        p.vy += 0.1 * (Math.random() - 0.5) - 0.01 * p.vy;

    }
    var currentCell = _.random(0, parseInt($scope.initDensity) - 1);
    if (Math.random() < (dividePercentCell / 100)) {
      particles.push(_.clone(particles[currentCell]));
    }

    topology = computeTopology(voronoi(particles)); // for recreating the topology if cell realy should move some time
    VoronoiGeo = topojson.mesh(topology, topology.objects.voronoi, function(a, b) { return a !== b; });  // required ? not sure
    return isRunning;
  }

  function stepStatic(dividePercentCell, flipPercentCell) {
      let isRunning = true;
      let currentCell = _.random(0, parseInt($scope.initDensity) - 1);

      if(particles[currentCell].cellType != 'healthy') {

        // Reset if Cell Moved or Infected previously
        if(particles[currentCell].cellType != 'infected') {
          particles[currentCell].cellType = 'infected';
        }

        // Filter neightbors
        let neighbors = getValidNeighbors(currentCell);
        // Cell RuleSystem.
        if(neighbors.length > 0) {
          var ran = Math.random() * 100;
          var direction = _.random(0, neighbors.length - 1);
          if (ran <= dividePercentCell) {
                particles[neighbors[direction]].cellType = 'divided';
                particles[neighbors[direction]].isBorder = true;
                population++;
                if(neighbors.length > 1) {
                    particles[currentCell].isBorder = true;
                } else {
                    particles[currentCell].isBorder = false;
                }
          }
          if(ran <= dividePercentCell + flipPercentCell && ran > dividePercentCell ) {
                particles[currentCell].cellType = 'healthy';
                particles[neighbors[direction]].cellType = 'moved';
          }
        }
      }
      return isRunning;
  }


  function getValidNeighbors(currentCell) {
    let neighbor = topojson.neighbors(topology.objects.voronoi.geometries)[currentCell];
    var validNeigbors = [];
    for (var i = 0; i < neighbor.length; i++) {
      if (particles[neighbor[i]].cellType === 'healthy') {
        validNeigbors.push(neighbor[i]);
      }
    }
    return validNeigbors;
  }
    
  function getNeighbors(currentCell) {
    let neighbor = topojson.neighbors(topology.objects.voronoi.geometries)[currentCell];
    var validNeigbors = [];
    for (var i = 0; i < neighbor.length; i++) {
      if (particles[neighbor[i]].cellType === 'healthy') {
        validNeigbors.push(neighbor[i]);
      }
    }
    return validNeigbors;
  }    

  $scope.refreshGraph = function() {
    reDrawGraph();
  };

  function reDrawGraph() {
    context.clearRect(0, 0, width, height);
    if(logstring == "") { logstring="time;cell.id;size;surface;cell.x;cell.y;neighbors;center.x;center.y;\r\n"; } ;
    var border = getBorders();
    var sphere = makeCircle(border);
    
  // VORONOI
    if ($scope.algorithm.voronoi) {
      // Draw whole Voronoi
      context.beginPath();
      renderMultiLineString(context, VoronoiGeo);
      context.strokeStyle = "rgba(0,0,0,0.4)";
      context.lineWidth = 0.5;
      context.stroke();


  // Colorize Infected Cells.
      context.beginPath();
      renderMultiPolygon(context, topojson.merge(topology, topology.objects.voronoi.geometries.filter(
        function(d) { return (d.data.cellType === 'infected' || d.data.cellType === 'moved' || d.data.cellType === 'divided'); })));
      context.fillStyle = "rgba(255,0,0,0.1)";
      context.fill();
      context.lineWidth = 1.5;
      context.lineJoin = "round";
      context.strokeStyle = "rgba(255,0,0,1)";
      context.stroke();
    }

      
    // POINTS
    if ($scope.algorithm.pointers) {
      particles.forEach(function(p, i) {
        // logging.  
        if(p.cellType != 'healthy') { 
          let cs = calcPolygonArea(topojson.merge(topology, topology.objects.voronoi.geometries.filter(
                    function(d) { return (d.data.number === p.number); })));
          let neighbors = topojson.neighbors(topology.objects.voronoi.geometries)[p.number];
          logstring = logstring + 
              $scope.stepcounter + ";" + 
              p.number + ";" + 
              cs + ";100;" + 
              p[0] + ";" + 
              p[1] + ";" + 
              neighbors.length + ";" + 
              sphere.x + ";" + sphere.y + ";" + 
              distanceToCenter(sphere, p) + "\r\n"; 
        }
  
        // logging end.
          
          
        context.beginPath();
        context.arc(p[0], p[1], 2.5, 0, 2 * Math.PI);
        if (p.cellType == 'healthy') {
          context.fillStyle = "rgba(0,0,0,0)";
        } else if (p.cellType == 'moved') {
          context.fillStyle = "rgba(63, 127, 191, 1)";
        } else if (p.cellType == 'divided') {
          context.fillStyle = "rgba(63, 127, 191, 1)";
        } else if (p.isBorder == true) {
            context.fillStyle = "rgba(0,0,0,1)";
        } else {
          context.fillStyle = "rgba(255,0,0,1)";
        }
        context.fill();
      });
    }

    // DELAUNAY
    if ($scope.algorithm.delaunay) {
      context.beginPath();
      var delaunay = d3.geom.delaunay(particles);
      context.setLineDash([5, 15]);
      renderDelaunay(context, delaunay);
      context.strokeStyle = "rgba(0,0,0,1)";
      context.lineWidth = 0.5;
      context.stroke();
      context.setLineDash([1]);
    }

    // calc Area all given Poligons and return its size
    // Corrected !
    // gesamt bereich
    calcPolygonArea(topojson.merge(topology, topology.objects.voronoi.geometries), 'Clear');
    
    // Infizierter Bereich.
    calcPolygonArea(topojson.merge(topology, topology.objects.voronoi.geometries.filter(
        function(d) { return (d.data.cellType === 'infected' || 
                              d.data.cellType === 'moved' || 
                              d.data.cellType === 'divided'); })));
    // Ausdehnung - Kann für Geschwindigkeitsoptimierung in das Point Drawing migriert werden.
    // var distance = 15;

    // console.log('Ausdehnung : ' + roundToTwo(distance));
    // console.log("Rand: " + border.length);
    // console.log("Count: " + getGetInfectionCount());

    context.beginPath();
    context.arc(sphere.x, sphere.y, sphere.r+5, 0, 2*Math.PI);
    context.strokeStyle = "rgba(0,153,0,1)";
    context.stroke();
    //if($scope.stepcounter % 200000 === 0) { saveLogToFile(logstring, 'gs1.txt'); logstring = ""; };
}

// Drawing Functions.
  function renderMultiLineString(context, line) {
    line.coordinates.forEach(function(line) {
      line.forEach(function(point, i) {
        if (i) context.lineTo(point[0], point[1]);
        else context.moveTo(point[0], point[1]);
      });
    });
  }

  function renderMultiPolygon(context, polygon) {
    polygon.coordinates.forEach(function(polygon) {
      polygon.forEach(function(ring) {
        ring.forEach(function(point, i) {
          if (i) context.lineTo(point[0], point[1]);
          else context.moveTo(point[0], point[1]);
        });
      });
    });
  }

  function renderDelaunay(contect, line) {
    for (var i = 0; i < line.length; i++) {
      context.moveTo(line[i][0][0],line[i][0][1]);
      context.lineTo(line[i][1][0],line[i][1][1]);
      context.lineTo(line[i][2][0],line[i][2][1]);
    }
  }
 });
