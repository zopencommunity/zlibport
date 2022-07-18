node('linux') 
{
        stage('Build') {
                build job: 'Port-Pipeline', parameters: [string(name: 'REPO', value: 'zlibport'), string(name: 'DESCRIPTION', 'zlibport' )]
        }
}
