name: IBM Cloud Auto Restart

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]
  schedule:
    - cron: '0 12 * * *'      # 根据自己的需要设置何时重启

jobs:
  ibm-cloud-restart:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2 

    - name: Init
      run: |
        wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
        echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
        sudo apt-get update
        sudo apt-get install cf-cli
    - name: Login IBM Cloud
      env:
        IBM_ACCOUNT: ${{ secrets.IBM_ACCOUNT }}
        IBM_PASSWORD: ${{ secrets.IBM_PASSWORD }}
      run: |
        cf login -a https://api.us-south.cf.cloud.ibm.com -u $IBM_ACCOUNT << EOF
        $IBM_PASSWORD
        EOF
    - name: Get IBM Cloud Apps
      run: |
        cf a
    - name: Restart IBM Cloud
      env:
        IBM_APP_NAME: ${{ secrets.IBM_APP_NAME }}
      run: |
        cf restart $IBM_APP_NAME
