#!/bin/sh
set -x
check_url="https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/Eventesting.aspx"
archive_url="https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/CMS_mNHIICC_Setup.Linux.zip"

# busybox 帶的 unzip 才能正常用在管道裡，
# 因為是管道接入 tar 所以沒辦法判斷壓縮格式的樣子，必須聲明正確的格式才能解壓縮；
# busybox 帶的 wget 沒有 --inet4-only 參數能用，但是健保署的 IPv6 位址回應速度...很慢...
latest_ver="$(wget -q -O - --inet4-only --no-check-certificate "$check_url" | \
  busybox grep -oE 'mLNHIICC_Setup\..*\.tar\.xz' | \
  busybox grep -oE '[[:digit:]]+\.[[:digit:]]+')"
local_ver="$(busybox cat ./settings/image_ver)"

# [小]||[大]的情況基本不應該發生，如果發生，你各位要該的應該是...
if [ "$(busybox echo "$latest_ver" | busybox cut -d . -f 1)" -gt "$(busybox echo "$local_ver" | busybox cut -d . -f 1)" ] || \
  [ "$(busybox echo "$latest_ver" | busybox cut -d . -f 2)" -gt "$(busybox echo "$local_ver" | busybox cut -d . -f 2)" ]; then
  wget -q -O - --inet4-only --no-check-certificate "$archive_url" \
    | busybox unzip -p - \
    | busybox tar x -J -f - -C ./nhiicc --strip-components 1 \
        mLNHIICC_Setup/web mLNHIICC_Setup/x64/mLNHIICC && \
  busybox mv ./nhiicc/x64/mLNHIICC ./nhiicc/ && busybox rm -r ./nhiicc/x64 && \
  busybox echo "$latest_ver" >./settings/image_ver
fi
