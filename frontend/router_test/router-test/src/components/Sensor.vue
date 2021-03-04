<template>
    <main>
        <h1>{{type}}: {{id}} value: {{data}}</h1>
    </main>
</template>

<script>
export default {    
    name: 'Sensor',
    props: {
        id: Number,
        data: Number,
        type: String
    }
}
</script>

<style scoped>
    main{
        margin: 20px;
        height: 100px;
        width: 300px;
        display: flex;
        background-color: blue;
    }
</style>