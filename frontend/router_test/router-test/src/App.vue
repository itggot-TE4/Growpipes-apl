<template>
  <body>
    <Header title="HEJ"></Header>
    <router-view/>
  </body>
</template>

<script>

import Header from './components/Header.vue'


export default {
  name: 'App',
  components: {
    Header
  }
}
</script>



<style>

body{
  margin: 0;
  width: 100vw;
  height: 100vh;
  background-color: red;   
}

</style>
