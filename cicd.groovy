node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'zlibport'), string(name: 'DESCRIPTION', ''The zlib command provides access to the compression and check-summing facilities of the Zlib library )]
        }
}
