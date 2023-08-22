node('linux')
{
        stage ('Poll') {
              checkout([
                      $class: 'GitSCM',
                      branches: [[name: '*/main']],
                      doGenerateSubmoduleConfigurations: false,
                      extensions: [],
                      userRemoteConfigs: [[url: 'https://github.com/ZOSOpenTools/zlibport.git']]])
        }

        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/ZOSOpenTools/zlibport.git'), string(name: 'PORT_DESCRIPTION', value: 'The zlib command provides access to the compression and check-summing facilities of the Zlib library' ), string(name: 'BUILD_LINE', value: 'STABLE')]
        }
}
