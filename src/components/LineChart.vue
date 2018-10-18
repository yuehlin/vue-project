<template>
  <b-container>
    <b-row>
      <b-col>
        <h1>This is line chart</h1>
      </b-col>
    </b-row>
    <b-row>
      <b-col cols="3">
        <b-form-select v-model="selectedState" :options="stateOptions" class="mb-3" >
          <template slot="first">
            <!-- this slot appears above the options from 'options' prop -->
            <option :value="null" disabled>-- Please select a state --</option>
          </template>
        </b-form-select>
      </b-col>
      <b-col>
        <svg width="500" height="270">
          <g style="transform: translate(0, 10px)">
            <path :d="line" />
          </g>
        </svg>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import * as d3 from 'd3';

export default {
  name: 'vue-line-chart',
  data() {
    return {
      monthlyPayment: [],
      line: '',
      selectedState: null,
      stateOptions: [
        { value: 'California', text: 'California' },
      ],
    };
  },

  mounted() {
    this.calculatePath();
  },

  watch: {
    monthlyPayment() {
      this.calculatePath();
    },

    selectedState() {
      this.getData();
    },
  },
  
  methods: {
    getScales() {
      const x = d3.scaleTime().range([0, 480]);
      const y = d3.scaleLinear().range([0, 100]);
      d3.axisLeft().scale(x);
      d3.axisBottom().scale(y);
      x.domain(d3.extent(this.monthlyPayment, (d, i) => i));
      y.domain([0, d3.max(this.monthlyPayment, d => d)]);
      return { x, y };
    },

    calculatePath() {
      const scale = this.getScales();
      const path = d3.line()
        .x((d, i) => scale.x(i))
        .y(d => scale.y(d));
      this.line = path(this.monthlyPayment);
    },

    getData() {
      const that = this;
      if (that.selectedState) {
        let defaultUrl = `http://127.0.0.1:5000/monthly_payment_with_time/` + that.selectedState;
        d3.json(defaultUrl).then(function(response) {
          that.monthlyPayment = response.monthly_payment;
        });
      }
    },

  },
};
</script>

<style lang="sass" scoped>
svg
  margin: 25px;
path
  fill: none
  stroke: #76BF8A
  stroke-width: 3px
</style>