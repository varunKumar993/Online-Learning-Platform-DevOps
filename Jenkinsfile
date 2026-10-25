cat > Jenkinsfile <<'EOF'
pipeline {
  agent any
  environment {
    REPO_URL = 'https://github.com/GH_USER_X/REPO_NAME_X.git'
    BRANCH   = 'master'
    IMAGE    = 'DH_USER_X/olp-app'
    TAG      = "${env.BUILD_NUMBER}"
    SERVERS  = '43.204.28.132 15.206.159.105'
  }
  triggers { githubPush() }
  stages {
    stage('Checkout') {
      steps { git branch: "${BRANCH}", url: "${REPO_URL}" }
    }
    stage('Build & Validate') {
      steps {
        sh '''
          test -s index.html
          grep -qi "<html" index.html
          echo "index.html validation passed"
        '''
      }
    }
    stage('Docker Build') {
      steps { sh 'docker build -t $IMAGE:$TAG -t $IMAGE:latest .' }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh 'echo $P | docker login -u $U --password-stdin'
          sh 'docker push $IMAGE:$TAG && docker push $IMAGE:latest'
        }
      }
    }
    stage('Deploy') {
      steps {
        sshagent(['app-server-ssh']) {
          sh '''
          for s in $SERVERS; do
            ssh -o StrictHostKeyChecking=no ubuntu@$s "
              sudo docker pull $IMAGE:$TAG &&
              (sudo docker stop olp || true) &&
              (sudo docker rm olp || true) &&
              sudo docker run -d --name olp --restart always --env-file /opt/olp/app.env -p 127.0.0.1:8081:80 $IMAGE:$TAG"
          done
          '''
        }
      }
    }
    stage('Verify') {
      steps {
        sshagent(['app-server-ssh']) {
          sh '''
          sleep 5
          for s in $SERVERS; do
            ssh -o StrictHostKeyChecking=no ubuntu@$s "sudo docker ps --filter name=olp --filter status=running | grep olp"
            curl -sf http://$s | head -5
          done
          '''
        }
      }
    }
  }
}
EOF
sed -i "s|GH_USER_X|$GH_USER|; s|REPO_NAME_X|$REPO_NAME|; s|DH_USER_X|$DH_USER|" Jenkinsfile
grep -n "REPO_URL\|BRANCH\|IMAGE \|SERVERS" Jenkinsfile
