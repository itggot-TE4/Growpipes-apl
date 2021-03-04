<template>
  <div class="home">
    <h1>Homepage</h1>
    <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit. Rem eius, maxime soluta, unde libero alias beatae tempora dolores debitis omnis delectus. At, sed qui? Itaque ut eligendi adipisci numquam a?</p>
    <Sensor v-for="Sensor in sensors" :key="Sensor.id" :id="Sensor.id" :data="Sensor.data" :type="Sensor.type" v-on:click="test2(Sensor.id)"/>
    <div class="graphholder">
      <SensorGraph v-if="show_graph.state" :key="show_graph.id" :id="show_graph.id" :type="show_graph.type"/>
    </div>
  </div>
</template>

<script>

import Sensor from '../components/Sensor.vue'
import SensorGraph from '../components/SensorGraph.vue'


export default {
  name: 'Home',
  data() {
    return{
      sensors: {},
      show_graph: {state: false, id: Number, type: String}
    }
  },
  components: {
    Sensor,
    SensorGraph
  },
  methods: {
    async getsensors(){
      
      const response = await fetch('http://localhost:4567/',{
        method: 'GET',
        mode: 'cors'
        
      })
      let data =(await response.json())    
  
      data.forEach(value => {
        Object.assign(this.sensors, {[value[0]]: {id: value[0], type: value[1], data: value[2]}})
      })
      this.updatesensor()
    },
    async updatesensor(){
      let response = await fetch('http://localhost:4567/',{
        method: 'GET',
        mode: 'cors'
      })

      if (response.status == 502) {
        await this.updatesensor()
      } else if (response.status != 200) {

        console.log(response.statusText)
        await new Promise(resolve =>  setTimeout(resolve, 1000))
        await this.updatesensor()

      } else {
        let data = (await response.json())
        
        data.forEach(sensor => { 
          Object.assign(this.sensors[sensor[0]], {id: sensor[0], data: sensor[2]})
        })
        
        await this.updatesensor()
      }
    },
    test2(id){
      console.log(this.sensors[id])
      this.show_graph.state = true
      this.show_graph.id = id
      this.show_graph.type = this.sensors[id].type
    }
  },
  beforeMount(){
    this.getsensors()
  }
}
</script>

<style scoped>

  .graphholder{
    position: absolute;
    top: 50% - 200px;
    left: 40%;
  }

</style>
