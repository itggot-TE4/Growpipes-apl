<template>
    <main>
        <h1>{{type}} Sensor: {{id}}</h1>
        <apexchart width="500" type="line" :options="options" :series="series"></apexchart>
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
                    id: 'vuechart-example'
                },
                xaxis: {
                    categories: [1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998]
                }
            },
            series: [{
                name: 'series-1',
                data: Array
            }]
        }
    },
    methods: {
        async get_data(id){
            console.log(id)
            if (id == 1){
                this.series[0].data = [1,6,2,8,5,6,7]
            }else if(id == 2){
                this.series[0].data = [2,10,1,5,6,3,9]
            }
            let response = await fetch(`http://localhost:4567/sensor_data/${id}`,{
                method: 'GET',
                mode: 'cors'
            })
            let data = (await response.json())

            // value_list = []
            // category_list = []
            // data.forEach(value => {
            //     value_list.push
            // })

            console.log(data)
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
        background-color: purple;
    }
</style>