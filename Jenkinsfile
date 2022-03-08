pipeline {
   agent any
   stages {
      stage('clone repo') {
          steps {
              sh("""
              wget https://raw.githubusercontent.com/BanderSmoozie/hello/main/hello
              cat hello
              rm hello
              """)
          }
      }
   }
}
