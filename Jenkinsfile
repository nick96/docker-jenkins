pipeline {
    agent any

    parameters {
	string(name: 'IMAGE_NAME', defaultValue: 'quay.io/nick96/jenkins')
    }

    stages {
	stage('Build') {
	    steps {
		sh "docker build -f Dockerfile -t ${params.IMAGE_NAME}:latest ."
		sh "docker build -f Dockerfile -t ${params.IMAGE_NAME}:${GIT_COMMIT} ."
	    }
	}

	stage('Test') {
	    steps {
		sh "bash -x test.sh ${params.IMAGE_NAME}"
	    }
	}

	stage('Publish') {
	    steps {
		withDockerRegistry([credentialsId: 'jenkins-nspain-quay-io', url: 'https://quay.io/api/v1/']) {
		    echo "Pushing image tag '${GIT_COMMIT}'..."
		    sh "docker push ${params.IMAGE_NAME}:${GIT_COMMIT}"

		    echo "Pushing image tag 'latest'..."
		    sh "docker push ${params.IMAGE_NAME}:latest"
		}
	    }
	}
    }

    post {
	always {
	    sh "docker rmi -f ${params.IMAGE_NAME}:${GIT_COMMIT}"
	}
    }
}
