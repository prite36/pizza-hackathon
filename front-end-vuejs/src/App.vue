<template>
  <div id="app">
    <router-view/>
  </div>
</template>

<style lang="scss">
.container {
  width: 60%;
  // margin-top: 100px;
  margin: 100px auto !important;
}
#flex-body {
  display: flex;
}
body {
  margin: 0px;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}
#nav {
  padding: 30px;
  a {
    font-weight: bold;
    color: #2c3e50;
    &.router-link-exact-active {
      color: #42b983;
    }
  }
}
</style>
