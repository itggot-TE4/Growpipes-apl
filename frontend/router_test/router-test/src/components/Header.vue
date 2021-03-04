<template>
    <header>
        <h1>{{title}}</h1>
        <button v-on:click="exit()">exit</button>
        <div id="nav">
            <router-link to="/">Home</router-link> |
            <router-link :to="{ name: 'About' }">About</router-link>
        </div>
    </header>
</template>

<script>
export default {
    name: 'Test',
    props: {
        title: String
    },
    methods: {
        exit(){
            fetch('http://localhost:4567/exit', {
                method: 'GET'
            })
        }
    }
}
</script>

<style scoped>
    header{
        margin: 0;
        width: 100%;
        height: 50px;
        background-color: green;
        display: flex;
        flex-direction: row;
    }
    h1{
        margin-block-start: 0;
        margin-inline-end: 0;
    }
    #nav {
        padding: 30px;
    }

    #nav a {
        font-weight: bold;
        color: #2c3e50;
    }

    #nav a.router-link-exact-active {
        color: #42b983;
    }
</style>