#! /bin/bash

echo "正在上传到fir.im...."
#####http://fir.im/api/v2/app/appID?token=APIToken，里面的appID是你要上传应用的appID，APIToken是你fir上的APIToken
fir p ../output/ExampleApp.ipa
# changelog=`cat $projectDir/README`
# curl -X PUT --data "changelog=$changelog" http://fir.im/api/v2/app/appID?token=APIToken
echo "\n打包上传更新成功！"
