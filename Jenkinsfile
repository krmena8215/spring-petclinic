def version, PROYECTO = "mypockrml", SERVICE = "spring-boot", BRANCH_PROJECT = "master",
CREDENTIALS_ID = "0b93e6f9-2f68-433f-8ef6-85ed16264194",
URL_GIT = "https://github.com/krmena8215/spring-petclinic.git"
     pipeline
      {
       agent {
      label 'maven'
        }
        stages
        {

                stage('Build App') {
                  steps
                   {
                    git branch: "${BRANCH_PROJECT}",
                    url: "${URL_GIT}",
                    credentialsId: "${CREDENTIALS_ID}"
                    script {
                        def pom = readMavenPom file: 'pom.xml'
                        version = pom.version
                    }
                    sh "mvn install -DskipTests=true"
                  }
                }

          stage('Create Builder Image') {
            when {
              expression {
                openshift.withCluster() {
                  openshift.withProject(PROYECTO) {
                    return !openshift.selector("bc", SERVICE).exists();
                  }
                }
              }
            }
            steps {
              script {
                openshift.withCluster() {
                  openshift.withProject(PROYECTO) {
                    openshift.newBuild("--name=${ SERVICE }", "--image-stream=java-alpine:latest","--binary=true", "strategy=docker")
                  }
                }
              }
            }
          }

          stage('Build Image') {
            steps {
              script {
                openshift.withCluster() {
                  openshift.withProject(PROYECTO) {
                    openshift.selector("bc", SERVICE).startBuild("--from-dir=.","--follow")
                  }
                }
              }
            }
          }

            stage('SonarQube analysis') {
              withSonarQubeEnv(credentialsId: 'f225455e-ea59-40fa-8af7-08176e86507a', installationName: 'https://sonarqube-mypockrml.18.217.164.179.nip.io') { // You can override the credential to be used
                sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.6.0.1398:sonar'
              }
            }

          stage('Create and deploy dev') {
            when {
              expression {
                openshift.withCluster() {
                  openshift.withProject(PROYECTO) {
                    return !openshift.selector('dc', SERVICE).exists()
                  }
                }
              }
            }
            steps {
              script {
                openshift.withCluster() {
                  openshift.withProject(PROYECTO) {
                    def app = openshift.newApp("${ SERVICE }:latest")
                    app.narrow("svc").expose();
                  }
                }
              }
            }
          }
        }
      }
