# README

用于修改系统 Yum 源设置。适用于 RHEL 类系统。

目前经过测试的系统：

* CentOS Stream 8
* a

需要修改 `vars/main.yml` 文件中的 `Local_YumRepo_URL` 变量为内部 Yum 源服务器地址。