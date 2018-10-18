<template>
  <b-container>
    <b-row>
      <b-col>
        <svg 
          :width="svgWidth"
          :height="svgHeight"
        />
      </b-col>
      <b-col cols="3">
        <b-form-select v-model="selectedState" :options="stateOptions" class="mb-3" >
          <template slot="first">
            <!-- this slot appears above the options from 'options' prop -->
            <option :value="null" disabled>-- Please select a state --</option>
          </template>
        </b-form-select>
      </b-col>
    </b-row>
    <b-row>
      <div id="map"></div>
    </b-row>
  </b-container>
</template>

<script>
import * as d3 from "d3";

export default {
  name: 'house-price',

  data() {
    return {
      svgWidth: 600,
      svgHeight: 200,
      margin: {
        top: 20,
        right: 20,
        bottom: 30,
        left: 50
      },
      avgData: [],
      stateData: [],
      selectedState: null,
      stateOptions: [],
    };
  },

  computed: {
    width() {
      return this.svgWidth - this.margin.left - this.margin.right;
    },
    height() {
      return this.svgHeight - this.margin.top - this.margin.bottom;
    }
  },

  mounted() {
    this.getStates();
    this.getAverageHousePriceData();
    this.drawChoroplethMap();
  },

  watch: {
    avgData() {
      this.drawPriceTime();
    },
    stateData() {
      this.drawPriceTime();
    },
    selectedState() {
      this.getStateHousePriceData();
    }
  },

  methods: {
    getAverageHousePriceData() {
      const that = this;
      const defaultUrl = `http://127.0.0.1:5000/house_price_with_time`;
      d3.json(defaultUrl).then(function(response) {
        that.avgData = [];
        for (let i = 0, len = response.time.length; i < len; i++) {
          that.avgData.push({
            date: new Date(response.time[i]),
            value: response.house_price[i]
          });
        }
      });
    },
    getStateHousePriceData() {
      const that = this;
      if (that.selectedState) {
        const defaultUrl =
          `http://127.0.0.1:5000/house_price_with_time/` + that.selectedState;
        d3.json(defaultUrl).then(function(response) {
          that.stateData = [];
          for (let i = 0, len = response.time.length; i < len; i++) {
            that.stateData.push({
              date: new Date(response.time[i]),
              value: response.house_price[i]
            });
          }
        });
      }
    },
    getStates() {
      const that = this;
      const defaultUrl = `http://127.0.0.1:5000/state_name`;
      const states = [];
      d3.json(defaultUrl).then(function(response) {
        response.forEach(element => {
          states.push({
            value: element,
            text: element
          });
        });
        that.stateOptions = states;
      });
    },
    drawPriceTime() {
      const svg = d3.select("svg");
      svg.selectAll("*").remove();
      svg.attr("width", this.svgWidth).attr("height", this.svgHeight);
      const xDomain = d3.extent(
        this.avgData.map(d => d.date).concat(this.stateData.map(d => d.date))
      );
      const yDomain = d3.extent(
        this.avgData.map(d => d.value).concat(this.stateData.map(d => d.value))
      );

      /* Draw avg data */
      const g = svg
        .append("g")
        .attr(
          "transform",
          "translate(" + this.margin.left + "," + this.margin.top + ")"
        );
      const x = d3.scaleTime().rangeRound([0, this.width]);
      const y = d3.scaleLinear().rangeRound([this.height, 0]);
      const line1 = d3
        .line()
        .x(function(d) {
          return x(d.date);
        })
        .y(function(d) {
          return y(d.value);
        });
      x.domain(xDomain);
      y.domain(yDomain);
      g.append("g")
        .attr("transform", "translate(0," + this.height + ")")
        .call(d3.axisBottom(x))
        .select(".domain")
        .remove();
      g.append("g")
        .call(d3.axisLeft(y))
        .append("text")
        .attr("fill", "#000")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", "0.71em")
        .attr("text-anchor", "end")
        .text("Price ($)");
      g.append("path")
        .datum(this.avgData)
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-linejoin", "round")
        .attr("stroke-linecap", "round")
        .attr("stroke-width", 1.5)
        .attr("d", line1);

      /* Draw state data */
      const line2 = d3
        .line()
        .x(function(d) {
          return x(d.date);
        })
        .y(function(d) {
          return y(d.value);
        });
      g.append("path")
        .datum(this.stateData)
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-linejoin", "round")
        .attr("stroke-linecap", "round")
        .attr("stroke-width", 1.5)
        .attr("d", line2);
    },
    drawChoroplethMap() {
      //Width and height of map
      var width = 960;
      var height = 500;

      var lowColor = '#f9f9f9'
      var highColor = '#bc2a66'

      // D3 Projection
      var projection = d3.geoAlbersUsa()
        .translate([width / 2, height / 2]) // translate to center of screen
        .scale([1000]); // scale things down so see entire US

      // Define path generator
      var path = d3.geoPath() // path generator that will convert GeoJSON to SVG paths
        .projection(projection); // tell path generator to use albersUsa projection

      //Create SVG element and append map to the SVG
      var svg = d3.select("#map")
        .append("svg")
        .attr("width", width)
        .attr("height", height);

      // Load in my states data!
      d3.csv("src/assets/statesdata.csv").then(function(data) {
        var dataArray = [];
        for (var d = 0; d < data.length; d++) {
          dataArray.push(parseFloat(data[d].value))
        }
        var minVal = d3.min(dataArray)
        var maxVal = d3.max(dataArray)
        var ramp = d3.scaleLinear().domain([minVal,maxVal]).range([lowColor,highColor])

        // Load GeoJSON data and merge with states data
        d3.json("src/assets/us-states.json").then(function(json) {

          // Loop through each state data value in the .csv file
          for (var i = 0; i < data.length; i++) {

            // Grab State Name
            var dataState = data[i].state;

            // Grab data value 
            var dataValue = data[i].value;

            // Find the corresponding state inside the GeoJSON
            for (var j = 0; j < json.features.length; j++) {
              var jsonState = json.features[j].properties.name;

              if (dataState == jsonState) {

                // Copy the data value into the JSON
                json.features[j].properties.value = dataValue;

                // Stop looking through the JSON
                break;
              }
            }
          }

          // Bind the data to the SVG and create one path per GeoJSON feature
          svg.selectAll("path")
            .data(json.features)
            .enter()
            .append("path")
            .attr("d", path)
            .style("stroke", "#fff")
            .style("stroke-width", "1")
            .style("fill", function(d) { return ramp(d.properties.value) });
          
          // add a legend
          var w = 140, h = 300;

          var key = d3.select("#map")
            .append("svg")
            .attr("width", w)
            .attr("height", h)
            .attr("class", "legend");

          var legend = key.append("defs")
            .append("svg:linearGradient")
            .attr("id", "gradient")
            .attr("x1", "100%")
            .attr("y1", "0%")
            .attr("x2", "100%")
            .attr("y2", "100%")
            .attr("spreadMethod", "pad");

          legend.append("stop")
            .attr("offset", "0%")
            .attr("stop-color", highColor)
            .attr("stop-opacity", 1);
            
          legend.append("stop")
            .attr("offset", "100%")
            .attr("stop-color", lowColor)
            .attr("stop-opacity", 1);

          key.append("rect")
            .attr("width", w - 100)
            .attr("height", h)
            .style("fill", "url(#gradient)")
            .attr("transform", "translate(0,10)");

          var y = d3.scaleLinear()
            .range([h, 0])
            .domain([minVal, maxVal]);

          var yAxis = d3.axisRight(y);

          key.append("g")
            .attr("class", "y axis")
            .attr("transform", "translate(41,10)")
            .call(yAxis)
        });
      });
    },
  }
};
</script>

<style type="text/css" scoped>

/* Legend Font Style */
#chart {
	font: 11px sans-serif;
	background-color: #ffffff;
}
        
/* Legend Position Style */
.legend {
	left:20px;
	top:30px;
}

.axis text {
	font: 10px sans-serif;
}

.axis line, .axis path {
	fill: none;
	stroke: #000;
	shape-rendering: crispEdges;
}

</style>