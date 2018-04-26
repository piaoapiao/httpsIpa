echo ${BUILD_NUMBER}


git reset --hard HEAD
# /bin/bash
# 工程名  YHB_Prj  StudentLoan
APP_NAME="StudentLoan"
#scheme
SCHEME="StudentLoan"
# app 类型   xcodeproj,xcworkspace
APP_TYPE="xcworkspace"
# Debug Release
PackageMode="Release"
#method  development, app-store, ad-hoc, enterprise
method="enterprise"
#DevelopmentTeam
DevelopmentTeam="YXY7V48A96"
# 证书
CODE_SIGN_DISTRIBUTION="iPhone Distribution: Shanghai Nonobank financial information service Co. Ltd."
#provision file name       mxd,schoolLoanEnterDis
#PROVISIONING_PROFILE_SPECIFIER="BailingDis"
PROVISIONING_PROFILE_SPECIFIER="schoolLoanEnterDis2"
#BundleID
#bundleID="bailing.nono.maizi"
bundleID="com.nonobank.schoolLoan"

iconfile="icon57.png"

fildeServerPath="/Users/Shared/archives/MobileAppFiles/ios"

HttpsServer="https://fe-testin.nonobank.com"

#Nagain on off
Nagain="off"
if [ ${Nagain} = "on" ]; then
FLAGS="-mllvm -reorder-bb -mllvm -split -mllvm -split-num=3 -mllvm -flatten -mllvm -zlog"
COMPILER="com.apple.compilers.llvm.nagain.3.9.0.1_4_beta"
MODULE="NO"
elif [ ${Nagain} = "off" ]; then
FLAGS=""
COMPILER=""
MODULE="YES"
fi


#pod install

#project path
PROJECT_PATH="${PWD}"

cd  "${PROJECT_PATH}"



if [ ! -d "ipa" ]; then 
mkdir "ipa" 
fi 

if [ -f "exportOptions.plist" ]; then 
rm "exportOptions.plist" 
fi 


# info.plist路径
project_infoplist_path="${PROJECT_PATH}/${APP_NAME}/InfoPlistFiles/Info.plist"

/usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier ${bundleID}"   ${project_infoplist_path}
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y%m%d%H%M)"
IPANAME="${APP_NAME}_V${bundleShortVersion}_${DATE}.ipa"

sed -i '' "s/Automatic/Manual/g"  "${PROJECT_PATH}/${APP_NAME}.xcodeproj/project.pbxproj"

echo "##################### Turn off push start ###################"
n=$(awk '/com.apple.Push/{print NR}' "${PROJECT_PATH}/${APP_NAME}.xcodeproj/project.pbxproj")
n=$((n+1))
sed -i '' "$n s/1/0/g" "${PROJECT_PATH}/${APP_NAME}.xcodeproj/project.pbxproj"
sed -i '' '/<key>aps-environment/d' ${PROJECT_PATH}/${APP_NAME}/InfoPlistFiles/${APP_NAME}.entitlements
sed -i '' '/<string>/d' ${PROJECT_PATH}/${APP_NAME}/InfoPlistFiles/${APP_NAME}.entitlements
echo "##################### Turn off push end ###################"

BundlePath="NULL"

if [ ${PackageMode} =  "Release" ];then
	BundlePath="Release-iphoneos"
	if [ ! -d "Release-iphoneos" ]; then 
	mkdir "Release-iphoneos" 
	fi 
else 
	BundlePath="Debug-iphoneos"
	if [ ! -d "Debug-iphoneos" ]; then 
	mkdir "Debug-iphoneos" 
	fi
fi


if [ ! -d "ipa" ]; then 
mkdir "ipa" 
fi 

if [ ${APP_TYPE} = "xcworkspace" ]; then
    xcodebuild -workspace "${PROJECT_PATH}/${APP_NAME}.${APP_TYPE}" -scheme "${SCHEME}" -configuration "Release" clean \
    archive -archivePath "${PROJECT_PATH}/${APP_NAME}" \
    DEVELOPMENT_TEAM=${DevelopmentTeam}  DEVELOPMENT_TEAM="${DevelopmentTeam}" \
    CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" \
    PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE_SPECIFIER}" ProvisioningStyle="Manual" \
    PRODUCT_BUNDLE_IDENTIFIER="${bundleID}" GCC_PREPROCESSOR_DEFINITIONS="$(value) OpenEnviromentSelect=${OpenMasterEnv}"
elif [ ${APP_TYPE} = "xcodeproj" ]; then
    xcodebuild -project "${PROJECT_PATH}/${APP_NAME}.${APP_TYPE}" -scheme "${SCHEME}" -configuration "Release" clean \
    archive -archivePath "${PROJECT_PATH}/${APP_NAME}" \
    DEVELOPMENT_TEAM=${DevelopmentTeam}  DEVELOPMENT_TEAM="${DevelopmentTeam}" \
    CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" \
    PROVISIONING_PROFILE_SPECIFIER="${PROVISIONING_PROFILE_SPECIFIER}" ProvisioningStyle="Manual" \
    PRODUCT_BUNDLE_IDENTIFIER="${bundleID}"

fi	     

echo "${BundlePath}"


echo "<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>compileBitcode</key>
    <false/>
    <key>method</key>
    <string>enterprise</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.nonobank.schoolLoan</key>
        <string>schoolLoanEnterDis2</string>
    </dict>
    <key>signingCertificate</key>
    <string>EE9339A5DFCAE00015EA9CDADDD9BD257312E738</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>YXY7V48A96</string>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>" >> exportOptions.plist



/usr/libexec/PlistBuddy -c "Set:method ${method}" "${PROJECT_PATH}/exportOptions.plist"

/usr/libexec/PlistBuddy -c "Set:teamID ${DevelopmentTeam}" "${PROJECT_PATH}/exportOptions.plist"



ipaUrl="${HttpsServer}/MobileAppFiles/ios/${APP_NAME}/${BUILD_NUMBER}/${APP_NAME}.ipa"

ipaImage="${HttpsServer}/MobileAppFiles/ios/${APP_NAME}/${BUILD_NUMBER}/icon.png"

/usr/libexec/PlistBuddy -c "Add:manifest:appURL string ${ipaUrl}" "${PROJECT_PATH}/exportOptions.plist"

/usr/libexec/PlistBuddy -c "Add:manifest:displayImageURL string ${ipaImage}" "${PROJECT_PATH}/exportOptions.plist"

/usr/libexec/PlistBuddy -c "Add:manifest:fullSizeImageURL string ${ipaImage}" "${PROJECT_PATH}/exportOptions.plist"

xcodebuild -exportArchive -archivePath "${PROJECT_PATH}/${APP_NAME}.xcarchive" -exportPath "${PROJECT_PATH}/ipa" -exportOptionsPlist "${PROJECT_PATH}/exportOptions.plist"

#    ipa
echo "${PROJECT_PATH}/ipa/${APP_NAME}"


#mv "${PROJECT_PATH}/${IPANAME}" "${PROJECT_PATH}/ipa/${IPANAME}"

#蒲公英上的User Key
uKey="e"
#蒲公英上的API Key
apiKey="e"
#要上传的ipa文件路径
IPA_PATH="${PROJECT_PATH}/ipa/${APP_NAME}.ipa"
rm -rf text.txt
#执行上传至蒲公英的命令
#echo "++++++++++++++upload+++++++++++++"
#curl -F "file=@${IPA_PATH}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" https://qiniu-storage.pgyer.com/apiv1/app/upload





# 下面是上传相关文件到https服务器

cp "${PROJECT_PATH}/${APP_NAME}/Assets.xcassets/AppIcon.appiconset/${iconfile}"  "${PROJECT_PATH}/ipa/icon.png"

AppDicPath="${fildeServerPath}/${APP_NAME}"


mainifestUrl="${HttpsServer}/MobileAppFiles/ios/${APP_NAME}/${BUILD_NUMBER}/manifest.plist"

echo '<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Document</title>
</head>
<div style="margin:0 auto;height:500px;">
<p style="text-align:center;margin-top:100px; font-size:20px; "> 
<a  href="itms-services://?action=download-manifest\&url=${mainifestUrl}">内网下载ipa</a></p>
</div>
<body>	
</body>
</html>' >> index.html

mv "${PROJECT_PATH}/index.html"  "${PROJECT_PATH}/ipa/index.html"


if [ ! -d "${AppDicPath}" ]; then 
mkdir "${AppDicPath}"
fi 


downUrl="${HttpsServer}/MobileAppFiles/ios/${APP_NAME}/${BUILD_NUMBER}/index.html"

qrencode -o "${PROJECT_PATH}/ipa/qrcode.png"   "${downUrl}"
 
qrencodeUrl="${HttpsServer}/MobileAppFiles/ios/${APP_NAME}/${BUILD_NUMBER}/qrcode.png"

BUILD_URL="${qrencodeUrl}"

echo $qrencodeUrl

cp -rf "${PROJECT_PATH}/ipa"  "${AppDicPath}/${BUILD_NUMBER}/" 

chmod  -R 777  "${AppDicPath}/${BUILD_NUMBER}"

rm -rf  "${PROJECT_PATH}/ipa"






##上传至平台目录
#sshpass -p '123456' scp "${PROJECT_PATH}/ipa/${IPANAME}" localadmin@192.168.1.50:/home/localadmin/apps/nono/ipa/

rm -r "${PROJECT_PATH}/${APP_NAME}.xcarchive"
rm -r "${PROJECT_PATH}/exportOptions.plist"
#rm -r "${PROJECT_PATH}/ipa"
rm -r "${PROJECT_PATH}/Release-iphoneos"

#mkdir -p  
#mkdir -p "./${BUILDNUM}" 



#cp APP_NAME

