<?php

ini_set('display_errors', 1);
error_reporting(~0);
    
require_once('riak-php-client/src/Basho/Riak/Riak.php');
require_once('riak-php-client/src/Basho/Riak/Bucket.php');
require_once('riak-php-client/src/Basho/Riak/Exception.php');
require_once('riak-php-client/src/Basho/Riak/Link.php');
require_once('riak-php-client/src/Basho/Riak/MapReduce.php');
require_once('riak-php-client/src/Basho/Riak/Object.php');
require_once('riak-php-client/src/Basho/Riak/StringIO.php');
require_once('riak-php-client/src/Basho/Riak/Utils.php');
require_once('riak-php-client/src/Basho/Riak/Link/Phase.php');
require_once('riak-php-client/src/Basho/Riak/MapReduce/Phase.php');

function countries(){

        $client = new Basho\Riak\Riak('localhost', 10018); 
        $bucket = $client->bucket('countries');
        $start    = new DateTime(date('Y-m-d'));

        $year= $start->format("[Y,");
        $month= $start->format("m,");
        $day= $start->format("d]");
        $new= ltrim($month,"0");
        $new2= ltrim($day,"0");
   
        $date= $year . $new . $new2;
        $obj = $bucket->getBinary($date);
        $data= $obj -> getData();
        echo(json_encode($data));
        //echo $data;
}

function gamename(){

        $client = new Basho\Riak\Riak('localhost', 10018); 
        $bucket = $client->bucket('maphours');
        $start    = new DateTime(date('Y-m-d'));

        $year= $start->format("[Y,");
        $month= $start->format("m,");
        $day= $start->format("d]");
        $new= ltrim($month,"0");
        $new2= ltrim($day,"0");
   
        $date= $year . $new . $new2;
        $obj = $bucket->getBinary($date);
        $data= $obj -> getData();
        echo(json_encode($data));

}

//gamename();

?>

<html> 
<body>
<head><script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="highstock.js"></script>
<script src="http://code.highcharts.com/stock/modules/exporting.js"></script>

<div id="container" style="height: 400px; width: 1000px"></div>


</head>



<script>

function mostPopularGame (){
        var myVariable = <?php echo gamename();?>;
        var myString3 = String(myVariable);
        var res = myString3.replace(/(\u005B)/g, "");
        var res2 = res.replace(/(\u005D)/g, "");
        var res3 = res2.replace(/(\u007B)/g, "");
        var res4 = res3.replace(/(\u007D)/g, "");       
        var res5 = res4.replace(/(\u0022)/g, "");
        var array = res5.split(',');
              
        return array[0];
}

var chart1 = new Highcharts.Chart({
chart: {
            renderTo: 'container',
            type: 'column'
        },
        title: {
            text: 'Players for most popular game by country'
        },
        subtitle: {
            text: 'Source: Steam'
        },
        xAxis: {
            categories: ['League of legends', 'Dota2', 'Wow', 'Heroes of newerth','Smite','Defense of the ancients','Bloodline Champions','Grand theft Auto', 'Half life',
'Far cry'],
            title: {
                text: 'Countries'
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Players',
              
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            valueSuffix: ' players'
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -40,
            y: 100,
            floating: true,
            borderWidth: 1,
            backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
            shadow: true
        },
        credits: {
            enabled: false
        },
        series: [{
            name: 'Players',
            data: [700, 681, 650, 642, 610,600,520,505,450,400]
        }]
    });


function gamestoday (){
        var myVariable = <?php echo countries();?>;
        var myString3 = String(myVariable);
        var res = myString3.replace(/(\u005B)/g, "");
        var res2= res.replace(/(\u005D)/g, "");
        var res3= res2.replace(/(\u007B)/g, "");
        var res4= res3.replace(/(\u007D)/g, "");
        var array = res4.split(',');
        var arrayLength = array.length;
        var games = [];
        var hours = [];
        for (var i = 0; i < arrayLength; i++) {
        
        if (i%2 == 0) {
        games.push(array[i]);
        } 
        else {
        hours.push(parseInt(array[i]));
        }
    
        }

        return games;
}

function hourstoday (){

    
        var myVariable = <?php echo countries();?>;
        var myString3 = String(myVariable);
        var res = myString3.replace(/(\u005B)/g, "");
        var res2= res.replace(/(\u005D)/g, "");
        var res3= res2.replace(/(\u007B)/g, "");
        var res4= res3.replace(/(\u007D)/g, "");
        var array = res4.split(',');
        var arrayLength = array.length;
        var games = [];
        var hours = [];
        for (var i = 0; i < arrayLength; i++) {
        
        if (i%2 == 0) {
        games.push(array[i]);
        } 

        //document.write("fitta");
        else {
        hours.push(parseInt(array[i]));
        }
    
        }

        return hours; 
    
    
}

function graph() {
    chart1.xAxis[0].setCategories(gamestoday());
    chart1.series[0].setData(hourstoday());
    chart1.setTitle({text: "Players for most popular game (" + mostPopularGame() + ") by country"});

}

graph();


</script> 

</body>
</html> 

