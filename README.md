# mLNHIICC-podman
使用 Podman 在 Debian 衍生發行版上執行健保卡元件 (mLNHIICC)[^1]

[^1]:看到[這個](https://github.com/pastleo/mLNHIICC-docker-archlinux)後起意弄的，~~人家 archlinux 有 [nhiicc](https://aur.archlinux.org/packages/nhiicc)~~<ins><sup>AUR</sup></ins>~~，為什麼我們 debian 不能有？~~<br/>
代替麵線部煮麵給你吃，快端上來吧。<br/>
等等...有人在敲門...

## 本機依賴
- `podman`, `buildah`: 建置、運行容器
- `pcscd`, `pcsc-tools`: 讀卡機服務
- `ca-certificates`: 操作憑證

## 使用說明
### 安裝、運行：
```sh
git clone --depth 1 https://github.com/llc0930/mLNHIICC-podman.git
cd mLNHIICC-podman
./build.sh
./run.sh
```

- Firefox 系瀏覽器：<br/>
照[健保卡網路服務註冊－環境說明](https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/Eventesting.aspx)裡的`Firefox 瀏覽器設定說明`所述，<br/>
新增資料夾內產生的 `NHIRootCA.crt` 為信任憑證機構。

> [!WARNING]
> 如果有舊的憑證記得先刪掉，名稱叫 `nhi-localhost-ca`，唯一一個`安全裝置`欄位裡是中文`軟體安全裝置`的...<br/>
> 自動操作等我之後研究 `certutil` 怎麼操作 `cert9.db` 再說...

- Chromium 系瀏覽器：<br/>
打開 [https://localhost:7777/](https://localhost:7777/)，<br/>
會警告`你的連線不是私人連線`，<br/>
點選`進階` => `繼續前往 localhost 網站 (不安全)`，<br/>
看到`已確認為可信任服務！`，關閉分頁即可。

嗯，可以開始用了。

> [!TIP]
> 或許你想先[檢測健保卡認證](https://cloudicweb.nhi.gov.tw/cloudic/system/webtesting/SampleY.aspx)來確認元件正常運作。

### 停止：
```sh
./stop.sh
```

### 移除：
```sh
./uninstall.sh
```

## 常用連結
- [綜合所得稅申報系統](https://efile.tax.nat.gov.tw/irxw/index.jsp)
- [線上查繳稅系統(地方稅)](https://netap.tax.nat.gov.tw/PEFLRX/Ept_Login)

## 關於`/etc/hosts`
雖然：<br/>
[`nhiicc/web/Scripts/nhiicc.host.js`](../master/nhiicc/web/Scripts/nhiicc.host.js#L4)
```
 4      this.wsUri = 'wss://iccert.nhi.gov.tw:7777/echo';
```
但因新版的 `mLNHIICC` 執行檔本身會修改容器內的 `/etc/hosts` 將 `iccert.nhi.gov.tw` 映射至 `127.0.0.1`，<br/>
故腳本**並未對本機 `/etc/hosts` 做任何修改操作**。<br/>
如有必要，請自行修改：
```sh
echo "127.0.0.1 iccert.nhi.gov.tw" | sudo tee -a /etc/hosts
```
移除後也請自行還原：
```sh
sudo sed -i '/iccert\.nhi\.gov\.tw/d' /etc/hosts
```

## 吐槽
在 wss 上踩坑了，因為想偷懶沿用 ELF 執行檔，所以跑容器時用 `--net host` 參數草草了事...
- [端口映射后容器内 WebSocket 产生 502 Bad Gateway 错误 | JasonDG](https://jasondg.github.io/posts/container.websocket.502/)
- [nginx docker container: 502 bad gateway response - Stack Overflow](https://stackoverflow.com/questions/38346847/nginx-docker-container-502-bad-gateway-response/47663730#47663730)
- [docker和docker compose中使用host.docker.internal访问其他服务 – 行星带](https://beltxman.com/4257.html)

<details>
<summary>蟹煮榮恩</summary>
自然人憑證每5年坑你250規費；<br/>
行動自然人憑證限支援生物辨識的行動裝置；<br/>
門號認證限月租型門號且消耗行動數據，每次被逾時登出都要重新驗證；<br/>
戶號要先取得查詢碼...線上取得查詢碼吃其他驗證...<br/>
我真是謝謝你...的麵
</details>
