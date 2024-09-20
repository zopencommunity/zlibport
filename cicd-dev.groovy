node('linux')
{
      stage ('Poll') {
            // Poll from upstream:
            checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/master']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[url: "https://github.com/madler/zlib.git"]]])
            // Poll from local
            checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[url: 'https://github.com/zopencommunity/zlibport.git']]])
      }

      stage('Build') {
              build job: 'Port-Pipeline', parameters: [string(name: 'PORT_GITHUB_REPO', value: 'https://github.com/zopencommunity/zlibport.git'), string(name: 'PORT_DESCRIPTION', value: 'The zlib command provides access to the compression and check-summing facilities of the Zlib library' ), string(name: 'BUILD_LINE', value: 'DEV')]
      }
}
