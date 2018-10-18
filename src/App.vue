<template>
  <div id="app">
    <b-navbar toggleable="md" type="dark" variant="info" :sticky="true">
      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
      <b-navbar-brand href="#">NavBar</b-navbar-brand>
      <b-collapse is-nav id="nav_collapse">
        <b-navbar-nav>
          <b-nav-item href="#line-chart">Line Chart</b-nav-item>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
    
    <b-container id="house-price-section">
      <b-row>
        <HousePrice />
      </b-row>
    </b-container>
  </div>
</template>

<script>
import HousePrice from './components/HousePrice.vue';

export default {
  name: 'app',
  components: {
    HousePrice,
  },
}
</script>

<style lang="scss">
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#house-price-section {
  margin-top: 32px;
}

h1, h2 {
  font-weight: normal;
}

ul {
  list-style-type: none;
  padding: 0;
}

li {
  display: inline-block;
  margin: 0 10px;
}

a {
  color: #42b983;
}
</style>
