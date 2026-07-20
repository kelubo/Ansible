# Ansible

用于系统初始化、配置和管理的 Ansible 剧本

## 目录结构

```
Ansible/
├── inventory/             # 主机清单
│   ├── production.ini     # 生产环境
│   ├── staging.ini        # 测试环境
│   └── group_vars/        # 组变量
│       └── all.yml        # 全局变量
├── playbooks/             # 剧本
│   ├── web/               # Web 相关剧本
│   │   ├── web-notls.yml  # Nginx 非 TLS 配置
│   │   └── web-tls.yml    # Nginx TLS 配置
│   ├── OS_init.yml        # 系统初始化
│   ├── OS_software.yml    # 软件安装
│   ├── OS_update.yml      # 系统更新
│   └── 其他剧本文件
├── roles/                 # 角色
│   ├── OS_update/         # 系统更新角色
│   ├── OpenSSH/           # SSH 配置角色
│   ├── Time/              # 时区配置角色
│   ├── Vim/               # Vim 配置角色
│   ├── common/            # 通用任务角色
│   └── yum_repo/          # Yum 仓库配置角色
├── files/                 # 静态文件
├── templates/             # Jinja2 模板
├── ansible.cfg            # Ansible 配置
└── README.md              # 本文档
```

## 测试环境

* CentOS

* Ubuntu

## 使用方法

### 1. 配置主机清单

编辑 `inventory/` 目录中的主机清单文件：

```bash
# 编辑生产环境主机清单
nano inventory/production.ini

# 编辑测试环境主机清单
nano inventory/staging.ini

# 编辑全局变量
nano inventory/group_vars/all.yml
```

### 2. 运行剧本

#### 系统初始化
```bash
ansible-playbook playbooks/OS_init.yml
```

#### 系统更新
```bash
ansible-playbook playbooks/OS_update.yml
```

#### 安装软件
```bash
ansible-playbook playbooks/OS_software.yml
```

#### 配置 Web 服务器（Nginx 带 TLS）
```bash
ansible-playbook playbooks/web/web-tls.yml
```

### 3. 自定义配置

#### 添加新角色
在 `roles/` 目录中创建新角色：

```bash
ansible-galaxy init roles/new_role
```

#### 添加新剧本
在 `playbooks/` 目录中创建新剧本：

```bash
nano playbooks/new_playbook.yml
```

## 配置说明

### ansible.cfg
主要配置文件是 `ansible.cfg`，包含了针对性能和可用性的优化设置。

### 全局变量
通用变量定义在 `inventory/group_vars/all.yml` 中：
- 时区设置
- Yum 仓库 URL
- 常用软件包
- SSH 配置

## 性能优化

- **Forks**: 20 个并发连接
- **SSH Pipelining**: 启用以提高连接速度
- **事实缓存**: 启用，24小时超时
- **收集子集**: 最小化事实收集
- **主机密钥检查**: 开发环境中禁用

## 安全考虑因素

- 使用 Ansible Vault 存储敏感信息
- 为每个环境生成唯一的 SSH 密钥
- 限制对主机清单文件的访问
- 谨慎使用 sudo，仅在需要时指定 become: yes

## 故障排除

### 检查 Ansible 版本
```bash
ansible --version
```

### 测试连接
```bash
ansible all -m ping
```

### 在调试模式下运行剧本
```bash
ansible-playbook playbooks/OS_init.yml -vvv
```

### 检查日志
```bash
cat ansible.log
```
