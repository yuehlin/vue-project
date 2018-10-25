import Vue from 'vue'
import BootstrapVue from "bootstrap-vue"
import App from './App.vue'
import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap-vue/dist/bootstrap-vue.css"

Vue.use(BootstrapVue)

// This is a global mixin, it is applied to every vue instance
Vue.mixin({
  data() {
    return {
      get dbHostUrl() {
        return `http://192.168.1.12:5000`;
      }
    }
  },
})

new Vue({
  el: '#app',
  render: h => h(App)
})
