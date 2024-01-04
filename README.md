# shell
快捷安装脚本
```
wget https://raw.githubusercontent.com/wsadczh/shell/main/one_install.sh


# gost安装
mkdir gost
wget https://github.com/go-gost/gost/releases/download/v3.0.0-rc8/gost_3.0.0-rc8_linux_amd64.tar.gz
tar -zxvf gost_3.0.0-rc8_linux_amd64.tar.gz 
/root/czh/gost/gost -L=:38080 

vi /etc/systemd/system/gost.service

[Unit]
Description= gost
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/czh/gost
ExecStart=/root/czh/gost/gost -L=:38080 
Restart=on-failure

[Install]
WantedBy=multi-user.target

systemctl start gost.service
systemctl status gost.service
systemctl enable gost.service 
```
