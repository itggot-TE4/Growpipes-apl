<template>
    <main>
        <h1>{{type}} Sensor: {{id}}</h1>
        <apexchart v-if="loaded_data" width="500" type="line" :options="options" :series="series"></apexchart>
    </main>
</template>

<script>
export default {
    name: 'SensorGraph',
    props: {
        id: Number,
        type: String
    },
    data() {
        return{
            options: {
                chart: {
                    id: 'vuechart-example',
                    foreColor: '#000'
                },
                xaxis: {
                    categories: Array
                }
            },
            series: [{
                name: 'series-1',
                data: Array
            }],
            loaded_data: false
        }
    },
    methods: {
        async get_data(id){
            
            let response = await fetch(`http://localhost:4567/sensor_data/${id}`,{
                method: 'GET',
                mode: 'cors'
            })
            let data = (await response.json())

            let value_list = []
            let category_list = []
            data.forEach(value => {
                value_list.push(value[0])
                category_list.push(value[1])
            })
          
            this.series[0].data = value_list
            this.options.xaxis.categories = category_list

            this.loaded_data = true
        }
    },
    beforeMount(){
        this.get_data(this.id)
    }
}
</script>

<style scoped>
    main{
        width: 600px;
        height: 400px;
        background-color: lightgray;
    }
</style>