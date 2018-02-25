
#!/bin/sh
# build.sh
# 
# 注意目录的空格
# 注意sh权限和mobileprovision的权限
# SIGN可以从钥匙串中获取
# icon图片有哪些规则的。规定好尺寸
#获取执行脚本目录，打包脚本必须要和项目中同一个目录
#苹果SDK目录
PROJDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_BUILDDIR="${PROJDIR}/build/Release-iphoneos"
echo "------------------${PROJECT_BUILDDIR}"
#编译目标，必须指定，一个项目中会有多个编译目标
TARGET_NAME=CorMobiApp
#编译出来app的名称，好像是代码中指定死的，开发人员才知道。示例KndCRMv2，代码不一样，值不一样
COMPILE_APP_NAME="CorMobiApp"

#生成客户端的目标目录
IPA_TARGET_DIR=${1}
#签名 "iPhone Distribution: Shenzhen Kingnod Consulting Inc"
SIGN=${2}
#SIGNTEAM  "TKZ6NJZD4M"
SIGNTEAM=${3}
#BUNDLEID "com.KND.test.debug"
BUNDLEID=${4}
#描述文件名称
SPECIFIER=${5}
#IPA_NAME
IPANAME=${6}
#APPNAME(xian
APPNAME=${7}
#描述文件路径
PROVISONNING_PROFILE=${8}

#修改export.plist文件
/usr/libexec/PlistBuddy -c 'Delete :provisioningProfiles' exportOptionsPlist.plist

/usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" exportOptionsPlist.plist

/usr/libexec/PlistBuddy -c "Add :provisioningProfiles:${BUNDLEID} string ${SPECIFIER}" exportOptionsPlist.plist

echo "---=========---------------"
#当前用户名，导入描述文件时需要
USER_NAME=${LOGNAME}
if [ USER_NAME == "" ]
then
    USER_NAME="dev"
else
    echo "有用户名::${USER_NAME}"
fi
PROVISION_XCODE_DIR="/Users/${USER_NAME}/Library/MobileDevice/Provisioning Profiles/"
uuid=$(grep UUID -A1 -a $PROVISONNING_PROFILE | grep -io "[-A-Z0-9]\{36\}")

echo "uuid ==  ------------------${uuid}"

#拷贝描述文件
echo cp $PROVISONNING_PROFILE ${uuid}.mobileprovision
cp $PROVISONNING_PROFILE ${uuid}.mobileprovision
#导入描述文件
echo cp ${uuid}.mobileprovision "${PROVISION_XCODE_DIR}/"
cp ${uuid}.mobileprovision "${PROVISION_XCODE_DIR}/"

#p12证书文件
P12_FILE=${9}
#p12证书文件密码
P12_FILE_PASS=${10}

security unlock-keychain -p 1234 login.keychain
security list-keychains -s login.keychain
security import ${P12_FILE} -k login.keychain -P "${P12_FILE_PASS}" -T /usr/bin/codesign

#修改应用BundleId
/usr/libexec/PlistBuddy -c "Set CFBundleIdentifier ${BUNDLEID}" ${PROJDIR}/CorMobiApp/CorMobiApp-info.plist

#ICON图标路径"
ICON57=${11}
#ICON图标路径"
ICON114=${12}
#ICON120图标
ICON120=${13}
#ICON180图标
ICON180=${14}
#VERSION版本号
VERSION=${15}

echo "VERSION:::${VERSION}"

#替换icon图标
cp ${ICON120} ${PROJDIR}/CorMobiApp/Assets.xcassets/AppIcon.appiconset/AppIcon60x60@2x.png
cp ${ICON180} ${PROJDIR}/CorMobiApp/Assets.xcassets/AppIcon.appiconset/AppIcon60x60@3x.png
cp ${ICON57} ${PROJDIR}/CorMobiApp/Assets.xcassets/AppIcon.appiconset/AppIcon57x57.png
cp ${ICON114} ${PROJDIR}/CorMobiApp/Assets.xcassets/AppIcon.appiconset/AppIcon57x57@2x.png
cp ${ICON114} ${PROJDIR}/CorMobiApp/Assets.xcassets/AppIcon.appiconset/AppIcon40x40@3x.png


WELCOMEPAGES=${16}

XCENT_FILE="/xpackage/uploadFiles/xcentFile"

#导出ipa 所需plist
ADHOCExportOptionsPlist=./exportOptionsPlist.plist


SOURCE_CODEAPP_XCENT="${XCENT_FILE}/codeApp.xcent"
CODEAPP_XCENT="${XCENT_FILE}/temp_codeApp.xcent"

SOURCEAPP_PATH="${PROJECT_BUILDDIR}/${COMPILE_APP_NAME}.xcarchive/Products/Applications/${COMPILE_APP_NAME}.app"
GUILD_PATH="${SOURCEAPP_PATH}/IntroduceViewSource.bundle/"
"===============================================${SIGN}"

  
# compile project
echo "###############Building Project#################"
cd "${PROJDIR}"
# 清理缓存
xcodebuild -target "${TARGET_NAME}" clean
# 编译
# xcodebuild -target "${TARGET_NAME}" -sdk "${TARGET_SDK}" -configuration Debug
xcodebuild archive -project ${PROJDIR}/${COMPILE_APP_NAME}.xcodeproj \
-scheme ${TARGET_NAME} \
-archivePath ${PROJECT_BUILDDIR}/${COMPILE_APP_NAME}.xcarchive \
-configuration Release \
CODE_SIGN_IDENTITY="${SIGN}" \
PROVISIONING_PROFILE="${uuid}" \
DEVELOPMENT_TEAM="${SIGNTEAM}" \
PROVISIONING_PROFILE_SPECIFIER="${SPECIFIER}" \
PRODUCT_BUNDLE_IDENTIFIER="${BUNDLEID}"


#Check if build succeeded
if [ $? != 0 ]
then
  exit 1
fi
echo "#################Replace Source################"

echo "#################Replace Source################${GUILD_PATH}*.*"


# 拷贝xcent模板
cp ${SOURCE_CODEAPP_XCENT} ${CODEAPP_XCENT}
# 替换相关资源,启动图片、程序logo等
# 修改程序logo
echo "#################Replace Source################::::::${ICON120}"
cp ${ICON120} ${SOURCEAPP_PATH}/AppIcon60x60@2x.png
cp ${ICON180} ${SOURCEAPP_PATH}/AppIcon60x60@3x.png
cp ${ICON57} ${SOURCEAPP_PATH}/AppIcon57x57.png
cp ${ICON114} ${SOURCEAPP_PATH}/AppIcon57x57@2x.png
cp ${ICON114} ${SOURCEAPP_PATH}/AppIcon40x40@3x.png
cp ${ICON120} ${SOURCEAPP_PATH}/ic_about_logo_t.png


echo "#####WELCOMEPAGE############${WELCOMEPAGE}############${SOURCEAPP_PATH}/LaunchImage.png####"

IFS=',' arr=($WELCOMEPAGES)
for i in "${!arr[@]}"; do

if [ "$i" == "0" ]
then
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-700@2x.png
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage@2x.png
printf "WELCOMEPAGEWELCOMEPAGE%s\t%s\n" "$i" "${arr[$i]}"
fi

if [ "$i" == "1" ]
then
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-568h@2x.png
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-700-568h@2x.png
printf "WELCOMEPAGEWELCOMEPAGE%s\t%s\n" "$i" "${arr[$i]}"
fi

if [ "$i" == "2" ]
then
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-800-667h@2x.png
printf "WELCOMEPAGEWELCOMEPAGE%s\t%s\n" "$i" "${arr[$i]}"
fi

if [ "$i" == "3" ]
then
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-800-Portrait-736h@3x.png
printf "WELCOMEPAGEWELCOMEPAGE%s\t%s\n" "$i" "${arr[$i]}"
fi

if [ "$i" == "4" ]
then
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-1100-2436h@3x.png
cp "${arr[$i]}" ${SOURCEAPP_PATH}/LaunchImage-1100-Portrait-2436h@3x.png
printf "WELCOMEPAGEWELCOMEPAGE%s\t%s\n" "$i" "${arr[$i]}"
fi

done
#替换欢迎页
#cp ${WELCOMEPAGE} ${SOURCEAPP_PATH}/LaunchImage.png
#替换欢迎页
#cp ${WELCOMEPAGE} ${SOURCEAPP_PATH}/LaunchImage@2x.png
# 替换签名文件
cp "${PROVISONNING_PROFILE}" ${SOURCEAPP_PATH}/embedded.mobileprovision


# 移除原先签名信息
# rm -rf -r ${SOURCEAPP_PATH}/_CodeSignature
# 修改应用信息info.plist
# 修改打包证书
# sed -i " " "s/iPhone Distribution: Shenzhen Kingnod Consulting Inc/${SIGN}/g" ${SOURCEAPP_PATH}/info.plist
echo ${SOURCEAPP_PATH}/info.plist
# 修改程序名称
/usr/libexec/PlistBuddy -c "Set CFBundleDisplayName ${APPNAME}" ${SOURCEAPP_PATH}/info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleName ${APPNAME}" ${SOURCEAPP_PATH}/info.plist
# 修改程序版本号
/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${VERSION}" ${SOURCEAPP_PATH}/info.plist
/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString ${VERSION}" ${SOURCEAPP_PATH}/info.plist
# cat ${SOURCEAPP_PATH}/info.plist
# 修改证书信息codeApp.xcent
# sed -i "s/com.KND.test.debug/${BUNDLEID}/g" ${CODEAPP_XCENT}
# sed -i "s/TKZ6NJZD4M/${SIGNTEAM}/g" ${CODEAPP_XCENT}
# cat ${CODEAPP_XCENT}
# 重新编译签名
# /usr/bin/codesign --force --sign "${SIGN}" --entitlements ${CODEAPP_XCENT} ${SOURCEAPP_PATH}
echo "#################Build Ipa################"

# 生产IPA
echo "${PROJECT_BUILDDIR}/${COMPILE_APP_NAME}.app"
# /usr/bin/xcrun -sdk iphoneos PackageApplication -verbose "${PROJECT_BUILDDIR}/${COMPILE_APP_NAME}.app" -o "${IPA_TARGET_DIR}${IPANAME}.ipa" --sign "${SIGN}" --embed ${SOURCEAPP_PATH}/embedded.mobileprovision
xcodebuild -exportArchive \
-archivePath ${PROJECT_BUILDDIR}/${COMPILE_APP_NAME}.xcarchive \
-exportOptionsPlist ${ADHOCExportOptionsPlist} \
-exportPath ${IPA_TARGET_DIR}

 mv ${IPA_TARGET_DIR}/${COMPILE_APP_NAME}.ipa ${IPA_TARGET_DIR}/${IPANAME}.ipa





