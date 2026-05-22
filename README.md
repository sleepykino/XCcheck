# XCcheck - 信创系统信息采集与合规检查工具

## 概述

XCcheck 是一套面向信创（信息技术应用创新）环境的系统信息采集与合规检查工具，包含：

- **syscheck.sh** — Linux 采集脚本，自动获取操作系统、CPU、数据库、双系统、机器品牌等信息并输出 XML
- **viewer.html** — 网页端解析工具，支持批量导入 XML、卡片化展示、合规检查、规则导入、CSV 导出

---

## syscheck.sh 使用说明

### 基本用法

```bash
# 赋予执行权限
chmod +x syscheck.sh

# 自动获取IP，执行采集
./syscheck.sh

# 指定IP地址
./syscheck.sh 192.168.1.100
```

### 输出文件

脚本在当前目录生成 XML 文件，命名格式：`sysinfo_<IP>_<日期>.xml`

示例：`sysinfo_192.168.1.100_20260507.xml`

### XML 输出结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<SystemInfo>
  <Hostname>kylin-server-01</Hostname>
  <IP>192.168.1.100</IP>
  <CollectTime>2026-05-07 10:30:00</CollectTime>
  <OS>
    <Name>Kylin Linux Advanced</Name>
    <Version>V10 (Lance)</Version>
    <Kernel>4.19.90-24.4.v2101.ky10.x86_64</Kernel>
  </OS>
  <CPU>
    <Model>Kunpeng 920</Model>
    <Architecture>aarch64</Architecture>
    <Cores>96</Cores>
  </CPU>
  <Database>
    <Name>达梦</Name>
    <Version>8.1</Version>
  </Database>
  <Database>
    <Name>金仓</Name>
    <Version>V8R6</Version>
  </Database>
  <DualBoot>
    <Flag>否</Flag>
    <OS></OS>
  </DualBoot>
  <MachineVendor>华为</MachineVendor>
</SystemInfo>
```

当未检测到数据库时，输出：

```xml
  <Database>不存在数据库</Database>
```

当检测到双系统时：

```xml
  <DualBoot>
    <Flag>是</Flag>
    <OS>Windows</OS>
  </DualBoot>
```

---

## 支持的操作系统

脚本针对以下国产操作系统做了专有检测适配，优先使用各系统特有命令和 release 文件：

| 操作系统 | 检测方式 |
|---------|---------|
| 银河麒麟 | `nkvers` 命令、`/etc/kylin-release` |
| 中标麒麟 | `/etc/neokylin-release` |
| 统信UOS | `/etc/uos-release` |
| 深度Deepin | `/etc/deepin-release`、`/etc/deepin-version` |
| openEuler | `/etc/openEuler-release` |
| 华为云EulerOS | `/etc/euleros-release`、`/etc/hce-release` |
| 龙蜥Anolis | `/etc/anolis-release` |
| 腾讯TencentOS | `/etc/tencentos-release` |
| 普华iSoft | `/etc/iSoft-release` |
| 红旗RedFlag | `/etc/redflag-release` |
| 灵犀Linx | `/etc/linx-release` |
| 新支点NewStart | `/etc/newstart-release` |
| 凝思NFSSecurity | `/etc/nfs-release` |
| 中科方德 | `/etc/founder-release` |

通用回退链：`/etc/os-release` → `lsb_release` → `/etc/redhat-release` → `/etc/lsb-release` → `uname`

---

## 支持的 CPU / 芯片

脚本通过 `lscpu` 优先检测，回退到 `/proc/cpuinfo` 解析，并自动过滤虚拟化标识（bios、virt、qemu、bochs）。

### 支持的信创 CPU 架构

| 架构 | 说明 | 对应芯片 |
|------|------|---------|
| x86_64 | x86 64位架构 | 海光、兆芯 |
| aarch64 | ARM 64位架构 | 鲲鹏、飞腾 |
| loongarch64 | 龙芯自主架构 | 龙芯3号系列 |
| sw_64 | 申威64位架构 | 申威处理器 |

### 支持的信创 CPU 型号

| CPU | 厂商 | 架构 | 检测标识 |
|-----|------|------|---------|
| 鲲鹏 920 | 华为 | aarch64 | Kunpeng 920、Kunpeng |
| 鲲鹏 916 | 华为 | aarch64 | Kunpeng 916 |
| 飞腾 FT-2000/+ | 飞腾 | aarch64 | FT-2000、Phytium |
| 飞腾 D2000 | 飞腾 | aarch64 | D2000、Phytium |
| 飞腾 S2500 | 飞腾 | aarch64 | S2500、Phytium |
| 龙芯 3A5000 | 龙芯 | loongarch64 | Loongson-3A5000、3A5000 |
| 龙芯 3C5000 | 龙芯 | loongarch64 | Loongson-3C5000、3C5000 |
| 龙芯 3A6000 | 龙芯 | loongarch64 | Loongson-3A6000、3A6000 |
| 海光 3000 系列 | 海光 | x86_64 | Hygon、海光 |
| 海光 5000 系列 | 海光 | x86_64 | Hygon、海光 |
| 海光 7000 系列 | 海光 | x86_64 | Hygon、海光 |
| 兆芯 KX-6000 | 兆芯 | x86_64 | Zhaoxin、兆芯、KX-6000 |
| 兆芯 KH-30000 | 兆芯 | x86_64 | Zhaoxin、兆芯、KH-30000 |
| 申威 1618 | 申威 | sw_64 | Sunway、申威、SW64 |
| 申威 3231 | 申威 | sw_64 | Sunway、申威、SW64 |

### CPU 检测策略

1. **lscpu 优先**：优先使用 `lscpu` 命令获取 CPU 型号（在虚拟机环境中更准确）
2. **/proc/cpuinfo 回退**：依次检测以下字段：
   - `model name`（x86 架构通用）
   - `Model\s*:`（鲲鹏等 ARM 处理器）
   - `Hardware`（飞腾等 aarch64 处理器）
   - `cpu model`（MIPS 等架构）
   - `cpu\s*:`（部分嵌入式处理器）
   - `cpu part`（ARM 处理器型号编码）
3. **虚拟化过滤**：自动过滤包含 bios、virt、qemu、bochs 的结果，避免虚拟机显示虚拟 CPU

---

## 支持的数据库

脚本通过命令行工具检测、安装目录检测、systemd/service 服务检测、Docker 容器检测四种策略识别以下 24 种信创数据库：

| 数据库 | 检测命令/目录/服务 |
|-------|------------------|
| 达梦 | `dmserver`、`disql`、`/opt/dmdbms`、`/dmdbms` |
| 金仓 | `ksql`、`kingbase`、`sys_ctl`、`/opt/Kingbase` |
| 神舟通用 | `osdb`、`osci`、`/opt/ShenTong` |
| 瀚高 | `hgdb`、`hgdb-admin`、`/opt/highgo` |
| 南大通用 | `gbase`、`gbasedbt`、`/opt/gbase` |
| 优炫 | `uxsql`、`uxdb`、`/opt/uxdb` |
| 海量 | `vds_cli`、`vastbase`、`/opt/vastbase` |
| 阿里PolarDB | `polardb`、`/opt/polardb` |
| 腾讯TDSQL | `tdsql`、`/opt/tdsql`、systemd 服务 |
| 虚谷 | `xugusql`、`xugu`、`/opt/xugu` |
| 东方金信 | `xdb`、`jxdb`、`/opt/jxserver` |
| 万里开源 | `greatdb`、`greatsql`、`/opt/greatdb` |
| 华为GaussDB | `gaussdb`、`gs_ctl`、`/opt/gaussdb`、systemd 服务 |
| 平凯 | `pingcap`、`tidb`、`/opt/tidb`、systemd 服务 |
| 中兴GoldenDB | `goldendb`、`/opt/goldendb`、systemd 服务 |
| 奥星贝斯 | `oceanbase`、`observer`、`/opt/oceanbase`、systemd 服务 |
| TaurusDB | systemd 服务、`/opt/taurusdb` |
| MySQL | `mysql`、`mysqld`、`/usr/bin/mysql`、Docker 镜像 |
| PostgreSQL | `psql`、`postgres`、`/usr/bin/psql`、Docker 镜像 |
| Oracle | `sqlplus`、`oracle`、`/opt/oracle`、Docker 镜像 |
| SQL Server | `sqlcmd`、`/opt/mssql`、Docker 镜像 |
| MongoDB | `mongo`、`mongod`、`/usr/bin/mongo`、Docker 镜像 |
| Redis | `redis-cli`、`redis-server`、Docker 镜像 |
| MariaDB | `mariadb`、`mysqld`、Docker 镜像 |

### Docker 容器数据库检测

脚本支持检测 Docker 容器中运行的数据库：

- 通过 `docker ps` 获取运行中的容器
- 根据镜像名称关键词匹配数据库类型
- 通过 `docker inspect` 获取数据库版本信息

支持的 Docker 镜像关键词：

| 数据库 | 镜像关键词 |
|-------|-----------|
| 达梦 | dmdb, dm, dameng |
| 金仓 | kingbase, kingbase8, kdb |
| 神舟通用 | shentong, osci, osdb |
| 瀚高 | highgo, hgdb |
| MySQL | mysql |
| PostgreSQL | postgres, postgresql |
| Oracle | oracle, oraclelinux |
| SQL Server | mssql, sqlserver |
| MongoDB | mongo, mongodb |
| Redis | redis |
| MariaDB | mariadb |

---

## 双系统检测

脚本通过多种策略检测是否存在双系统：

| 策略 | 说明 |
|------|------|
| GRUB2 配置 | 解析 `/boot/grub2/grub.cfg`，查找非当前系统的启动项 |
| GRUB 配置 | 解析 `/boot/grub/grub.cfg` |
| EFI 启动项 | 使用 `efibootmgr` 列出 EFI 启动项（需 root） |
| EFI 目录遍历 | 遍历 `/boot/efi/EFI/` 目录查找其他系统 |
| os-prober | 调用 `os-prober` 工具检测（需 root） |
| NTFS 分区 | 检测是否存在 NTFS 分区（可能安装 Windows） |

**排除项**：以下启动项会被排除，不判定为双系统：
- BIOS/固件工具：BootManagerMenuApp、BIOS Setup、Enter Setup、Consolidated Boot Manager
- 恢复工具：SystemResetApp、Recovery、Backup、BIOS Backup and Recovery
- 网络启动：PXE、Network Boot、UEFI PXE App
- 诊断工具：Diagnostic、Tools、Diags、HISI
- 保留分区：RESERVE、Shell、fw

---

## 机器品牌检测

脚本通过以下方式检测机器品牌：

| 策略 | 说明 |
|------|------|
| DMI 信息 | 读取 `/sys/devices/virtual/dmi/id/` 下的 sys_vendor、board_vendor、chassis_vendor |
| dmidecode | 调用 `dmidecode` 获取厂商信息（需 root） |
| 产品名称 | 读取 product_name 并匹配已知品牌 |

支持识别的品牌：

| 品牌 | 匹配关键词 |
|------|-----------|
| 联想 | Lenovo, ThinkPad, ThinkCentre, 联想 |
| 华为 | Huawei, HUAWEI, 华为 |
| 戴尔 | Dell, DELL, 戴尔 |
| 惠普 | HP, Hewlett, 惠普 |
| 华硕 | ASUS, 华硕 |
| 宏碁 | Acer, 宏碁 |
| 神舟 | Hasee, 神舟 |
| 浪潮 | Inspur, 浪潮 |
| 曙光 | Sugon, 曙光 |
| 长城 | Great Wall, 长城 |
| 宝德 | PowerLeader, 宝德 |
| 紫光 | Unisplendour, 紫光 |
| 新华三 | H3C, 新华三 |
| 中兴 | ZTE, 中兴 |
| 富士通 | Fujitsu, 富士通 |
| 三星 | Samsung, 三星 |
| 清华同方 | Tongfang, 清华同方 |
| 海尔 | Haier, 海尔 |

---

## 注意事项

### 权限要求

1. **建议以 root 用户执行**：部分检测需要 root 权限
2. **非 root 用户**：脚本会自动检测权限并跳过需要 root 的检测项
   - 跳过的检测：`efibootmgr`、`dmidecode`、`os-prober`
   - 替代方案：`systemctl list-unit-files` 替代 `systemctl list-units`
   - `netstat -tln` 替代 `netstat -tlnp`（去掉需 root 的 `-p` 参数）
3. **最低权限**：若无法使用 root，至少需要：
   - 读取 `/proc/cpuinfo` 的权限（获取 CPU 信息）
   - 读取 `/etc/*-release` 系列文件的权限（获取操作系统信息）
   - 执行 `hostname`、`uname`、`nproc` 等基础命令的权限
   - 执行 `docker ps` 的权限（检测 Docker 容器数据库）

### IP 地址获取

- 通过命令行参数指定时直接使用，不做格式校验
- 自动获取策略优先级：`hostname -I` → `ip -4 route get` → `ifconfig` → 网卡配置文件
- 自动获取会跳过 `127.0.0.1` 和 `::1`，优先返回第一个非回环地址
- 若所有策略均失败，IP 将显示为 `Unknown`

### 操作系统检测

- 各系统专有检测命令优先执行，确保识别结果准确（如麒麟的 `nkvers`）
- 同一系统的桌面版和服务器版可能输出不同名称，在合规检查时需分别配置
- 部分国产操作系统的 release 文件格式不统一，脚本做了多层解析适配
- 麒麟系统 `nkvers` 输出含 `#` 号装饰线，脚本自动清理
- 统信 UOS 同时包含 `/etc/uos-release` 和 `/etc/deepin-release`，脚本优先识别 UOS
- 华为云 EulerOS (HCE) 已适配双系统检测排除

### CPU 检测

- 优先使用 `lscpu` 获取型号，在虚拟机环境中更准确
- 自动过滤虚拟化标识（bios、virt、qemu、bochs），虚拟机中不会错误显示虚拟 CPU
- aarch64 架构通过 `Hardware` 和 `cpu part` 字段检测飞腾、鲲鹏等处理器
- 版本号支持纯整数格式（如 KylinSec OS 3）和带小数点格式（如 V10.1）

### 数据库检测

- **检测策略**：命令行工具 → 安装目录 → systemd/service 服务 → Docker 容器，四者互补
- **版本获取**：依赖各数据库的 `-V` 或 `--version` 参数输出，不同版本可能输出格式不同
- **同一台机器安装多个数据库**：支持输出多个数据库，每个数据库独立一行
- **数据库未在 PATH 中**：如果数据库命令不在系统 PATH 中但安装在标准目录下，目录检测仍可识别

### 兼容性

- 脚本使用 `#!/bin/bash`，需 Bash 环境
- 依赖的常用命令：`grep`、`sed`、`awk`、`head`、`cut`、`sort`、`cat`、`wc`
- 可选命令（缺失不影响基本运行）：`lsb_release`、`lscpu`、`nproc`、`ip`、`ifconfig`、`systemctl`、`service`、`nkvers`、`docker`、`efibootmgr`、`dmidecode`
- XML 输出使用 heredoc，确保特殊字符（`&`、`<`、`>`、`"`、`'`）经 `xml_escape()` 转义

### 安全相关

- 脚本仅做信息读取，不修改任何系统配置
- 不收集密码、密钥等敏感信息
- 输出的 XML 文件保存在脚本所在目录，注意文件权限管理
- 建议采集完成后将 XML 文件及时转移或删除，避免信息泄露

---

## viewer.html 使用说明

### 打开方式

直接用浏览器打开 `viewer.html` 即可使用，无需服务器部署。

### 功能说明

| 功能 | 说明 |
|-----|------|
| 批量导入 | 拖拽或点击上传多个 XML 文件 |
| 卡片展示 | 每台主机一张卡片，显示系统名称、版本、CPU、数据库、双系统、机器品牌等信息 |
| 合规检查 | 配置允许列表，自动判断每项信息是否合规 |
| 规则导入 | 从 Excel 文件导入合规规则，支持 Sheet 页和列选择 |
| 筛选过滤 | 按合规状态（全部/合规/不合规）和操作系统类型筛选 |
| 搜索 | 按 IP、主机名、系统名称等关键词搜索 |
| CSV 导出 | 导出包含合规状态的数据表格，支持 Excel 打开 |

### 合规检查规则

共 7 个检查项，每项可独立配置，页面加载时自动填入默认规则：

| 检查项 | 默认规则 |
|-------|---------|
| 系统名称 | kylin、uos、麒麟、统信、Euler、欧拉、方德、Deepin、openEuler、Anolis |
| 系统版本 | V10、V20、1050、1060、20、23、7、8、9 |
| CPU型号 | Kunpeng、飞腾、龙芯、Loongson、海光、Hygon、兆芯、Zhaoxin、申威、Sunway |
| CPU架构 | x86_64、aarch64、loongarch64、sw_64 |
| 数据库类型 | 达梦、金仓、华为GaussDB、瀚高、南大通用、神舟通用、海量、虚谷、万里开源、平凯、中兴GoldenDB、奥星贝斯、TaurusDB、PolarDB、TDSQL、优炫、东方金信 |
| 双系统 | 否 |
| 机器品牌 | 联想、华为、戴尔、惠普、华硕、浪潮、曙光、长城、宝德、紫光、新华三、中兴、神舟、宏碁、清华同方、海尔 |

**判定规则**：
- 采用模糊匹配（双向包含），大小写不敏感，如规则写"kylin"，检测到"Kylin Linux"也判定合规
- 数据库类型：检测到的**所有**数据库必须在合规列表中才算合规，任一数据库不在列表即为不合规
- 多项检查中**任一不合规**，整条记录标记为不合规
- 未配置规则的检查项不参与判定
- 无数据库时不参与数据库合规判定

### 规则导入

支持从 Excel 文件（.xlsx / .xls / .csv）导入合规规则：

1. 点击"导入规则"按钮
2. 选择 Excel 文件
3. 在弹窗中选择规则项、Sheet 页和列
4. 预览解析结果
5. 点击"导入"覆盖当前规则

**数据格式**：支持 `;` 分隔的多关键字行，例如：

| 数据库字段 |
|-----------|
| 达梦;disql;dmserver |
| PolarDB |
| TDSQL |

解析结果：`达梦`、`disql`、`dmserver`、`PolarDB`、`TDSQL`

### 使用流程

1. 打开 `viewer.html`
2. 拖拽或点击上传 `sysinfo_*.xml` 文件（支持多选）
3. 查看卡片信息
4. 合规规则已自动填入，可直接点击"应用合规规则"
5. （可选）手动修改规则或从 Excel 导入规则
6. 使用筛选和搜索查看结果
7. 点击"导出CSV"下载数据

---

## 测试文件

项目包含 5 个测试 XML 文件，可用于验证 viewer.html 功能：

| 文件 | 系统 | 数据库 | 双系统 | 机器品牌 |
|-----|------|--------|--------|---------|
| test_kylin_compliant.xml | 银河麒麟（桌面版） | 达梦 8.1 | 否 | 联想 |
| test_uos_compliant.xml | 统信UOS（桌面版） | 金仓 V8R6 | 否 | 华为 |
| test_founder_compliant.xml | 中科方德（桌面版） | 华为GaussDB 3.0 + 瀚高 9.5 | 否 | 戴尔 |
| test_kylin_server_compliant.xml | 银河麒麟（服务器版） | 不存在数据库 | 否 | 浪潮 |
| test_anolis_noncompliant.xml | 龙蜥Anolis OS | MySQL 8.0.32 | 是(Windows) | Unknown |

---

## 目录结构

```
XCcheck/
├── syscheck.sh                          # 采集脚本
├── viewer.html                          # 网页解析工具
├── test_kylin_compliant.xml             # 测试文件
├── test_uos_compliant.xml               # 测试文件
├── test_founder_compliant.xml           # 测试文件
├── test_kylin_server_compliant.xml      # 测试文件
├── test_anolis_noncompliant.xml         # 测试文件
└── README.md                            # 本文档
```

---

