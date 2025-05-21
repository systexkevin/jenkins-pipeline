pipeline {
  agent any
  environment {
    HOME = "${env.WORKSPACE}"
  }
  stages {
    stage('Supply Chain Code Scan') {
      agent {
        docker {
          image 'aquasec/aqua-scanner'
        }
      }
      steps {
        withCredentials([
          string(credentialsId: 'AQUA_KEY', variable: 'AQUA_KEY'),
          string(credentialsId: 'AQUA_SECRET', variable: 'AQUA_SECRET'),
          string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')
        ]){
          sh '''
            export TRIVY_RUN_AS_PLUGIN=aqua
            export AQUA_URL=https://api.asia-1.supply-chain.cloud.aquasec.com
            export CSPM_URL=https://asia-1.api.cloudsploit.com
            trivy fs --scanners misconfig,vuln,secret . --sast --reachability
            # To customize which severities to scan for, add the following flag: --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL
            # To enable SAST scanning, add: --sast
            # To enable reachability scanning, add: --reachability
            # To enable npm/dotnet/gradle non-lock file scanning, add: --package-json / --dotnet-proj / --gradle
            # For http/https proxy configuration add env vars: HTTP_PROXY/HTTPS_PROXY, CA-CRET (path to CA certificate)
          '''
          }
      }       
    }
    stage('Build Image from Dockerfile') {
      agent any
      steps {
        script {
          def dockerfile = 'Dockerfile'
          def imageName = 'my-apache:1.0'
          sh "docker build -t ${imageName} -f ${dockerfile} ."
        }
      }
    }
    
    stage('Aqua Image Scan') {
      agent any
      steps {
        withCredentials([
          string(credentialsId: 'AQUA_KEY', variable: 'AQUA_KEY'),
          string(credentialsId: 'AQUA_SECRET', variable: 'AQUA_SECRET'),
          string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')
        ]){
          aqua containerRuntime: 'docker', customFlags: '', hideBase: false, hostedImage: '', localImage: 'my-apache:1.0', localToken: '', locationType: 'local', notCompliesCmd: '', onDisallowed: 'ignore', policies: 'Default', register: false, registry: 'systexacr', scannerPath: '/root/scannercli', showNegligible: false, tarFilePath: ''
        }
      }
    }

    stage('Manifest Generation') {
      steps  {
        withCredentials([
        // Replace GITHUB_APP_CREDENTIALS_ID with the id of your github app credentials
        usernamePassword(credentialsId: 'GITHUB_APP_CREDENTIALS_ID', usernameVariable: 'GITHUB_APP', passwordVariable: 'GITHUB_TOKEN'), 
        string(credentialsId: 'AQUA_KEY', variable: 'AQUA_KEY'), 
        string(credentialsId: 'AQUA_SECRET', variable: 'AQUA_SECRET')
    ]) {
        // Replace ARTIFACT_PATH with the path to the root folder of your project 
        // or with the name:tag the newly built image
        sh '''
            export BILLY_SERVER=https://billy.asia-1.codesec.aquasec.com
            curl -sLo install.sh download.codesec.aquasec.com/billy/install.sh
            curl -sLo install.sh.checksum https://github.com/argonsecurity/releases/releases/latest/download/install.sh.checksum
            if ! cat install.sh.checksum | sha256sum --check; then
                echo "install.sh checksum failed"
                exit 1
            fi
            BINDIR="." sh install.sh
            rm install.sh install.sh.checksum
            ./billy generate \
                --access-token ${GITHUB_TOKEN} \
                --aqua-key ${AQUA_KEY} \
                --aqua-secret ${AQUA_SECRET} \
                --cspm-url https://asia-1.api.cloudsploit.com \
                --artifact-path "my-apache:1.0" 

                # The docker image name:tag of the newly built image
                # --artifact-path "my-image-name:my-image-tag" \
                # OR the path to the root folder of your project. I.e my-repo/my-app 
                # --artifact-path "ARTIFACT_PATH"
        '''
      }
    }
  }    
  }
}

