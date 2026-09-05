#!/bin/zsh
# Signs the already-built release HAP locally. Passwords are read interactively
# and are never written to disk or echoed.
set -euo pipefail

PROJECT_DIR=${0:A:h:h}
JAVA=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home/bin/java
KEYTOOL=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home/bin/keytool
SIGN_TOOL=/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/lib/hap-sign-tool.jar
KEYSTORE="$PROJECT_DIR/HarmonySign/xiangyin_map_release.p12"
CERTIFICATE="$PROJECT_DIR/HarmonySign/xiangyin_map_release_chain.cer"
PROFILE="$PROJECT_DIR/HarmonySign/xiangyin-map-releaseRelease.p7b"
INPUT="$PROJECT_DIR/entry/build/default/outputs/default/entry-default-unsigned.hap"
OUTPUT="$PROJECT_DIR/entry/build/default/outputs/default/entry-default-release-signed.hap"
VERIFY_CERT_CHAIN="$PROJECT_DIR/entry/build/default/outputs/default/entry-default-release-signed-cert-chain.cer"
VERIFY_PROFILE="$PROJECT_DIR/entry/build/default/outputs/default/entry-default-release-signed-profile.p7b"

for file in "$JAVA" "$KEYTOOL" "$SIGN_TOOL" "$KEYSTORE" "$CERTIFICATE" "$PROFILE" "$INPUT"; do
  [[ -f "$file" ]] || { print -u2 "缺少文件：$file"; exit 1; }
done

read -rs "STORE_PASSWORD?P12 密码："; print
[[ -n "$STORE_PASSWORD" ]] || { print -u2 "P12 密码不能为空。"; exit 1; }
KEY_ALIASES=("${(@f)$(LC_ALL=C "$KEYTOOL" -list -storetype PKCS12 -keystore "$KEYSTORE" -storepass "$STORE_PASSWORD" 2>/dev/null | awk -F, '/PrivateKeyEntry/{print $1}')}")
if (( ${#KEY_ALIASES[@]} == 1 )); then
  KEY_ALIAS="$KEY_ALIASES[1]"
  print "已识别 Key Alias：$KEY_ALIAS"
else
  print -u2 "无法自动识别 Key Alias；请检查 P12 密码或证书内容。"
  exit 1
fi
read -rs "KEY_PASSWORD?Key Alias 密码（直接回车表示与 P12 密码相同）："; print
[[ -n "$KEY_PASSWORD" ]] || KEY_PASSWORD="$STORE_PASSWORD"
trap 'unset STORE_PASSWORD KEY_PASSWORD' EXIT

"$JAVA" -jar "$SIGN_TOOL" sign-app \
  -mode localSign \
  -keyAlias "$KEY_ALIAS" \
  -keyPwd "$KEY_PASSWORD" \
  -appCertFile "$CERTIFICATE" \
  -profileFile "$PROFILE" \
  -profileSigned 1 \
  -inFile "$INPUT" \
  -signAlg SHA256withECDSA \
  -keystoreFile "$KEYSTORE" \
  -keystorePwd "$STORE_PASSWORD" \
  -outFile "$OUTPUT" \
  -compatibleVersion 23 \
  -signCode 1

"$JAVA" -jar "$SIGN_TOOL" verify-app \
  -inFile "$OUTPUT" \
  -outCertChain "$VERIFY_CERT_CHAIN" \
  -outProfile "$VERIFY_PROFILE"
print "发布签名 HAP：$OUTPUT"
