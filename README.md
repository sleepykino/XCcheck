# XCcheck - 信创系统信息采集与合规检查工具

## 概述

XCcheck 是一套面向信创（信息技术应用创新）环境的系统信息采集与合规检查工具，包含：

- **syscheck.sh** — Linux 采集脚本，自动获取操作系统、CPU、数据库等信息并输出 XML
- **viewer.html** — 网页端解析工具，支持批量导入 XML、卡片化展示、合规检查、CSV 导出

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
    <Name>银河麒麟（服务器版）</Name>
    <Version>V10</Version>
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
</SystemInfo>
```

当未检测到数据库时，输出：

```xml
  <Database>不存在数据库</Database>
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
| 欧拉EulerOS | `/etc/euleros-release` |
| 龙蜥Anolis | `/etc/anolis-release` |
| 腾讯TencentOS | `/etc/tencentos-release` |
| 普华iSoft | `/etc/iSoft-release` |
| 红旗RedFlag | `/etc/redflag-release` |
| 灵犀Linx | `/etc/linx-release` |
| 新支点NewStart | `/etc/newstart-release` |
|凝思NFSSecurity| `/etc/nfs-release` |
| 中科方德 | `/etc/founder-release` |

通用回退链：`/etc/os-release` → `lsb_release` → `/etc/redhat-release` → `/etc/lsb-release` → `uname`

---

## 支持的数据库

脚本通过命令行工具检测、安装目录检测、systemd/service 服务检测三种策略识别以下 18 种信创数据库：

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

---

## 注意事项

### 权限要求

1. **建议以 root 用户执行**：数据库检测需要读取安装目录（如 `/opt/dmdbms`）和查询 systemd 服务状态，普通用户可能无法获取完整信息
2. **最低权限**：若无法使用 root，至少需要：
   - 读取 `/proc/cpuinfo` 的权限（获取 CPU 信息）
   - 读取 `/etc/*-release` 系列文件的权限（获取操作系统信息）
   - 执行 `hostname`、`uname`、`nproc` 等基础命令的权限
   - 执行 `systemctl` 或 `service` 的权限（检测数据库服务状态）

### IP 地址获取

- 通过命令行参数指定时直接使用，不做格式校验
- 自动获取策略优先级：`hostname -I` → `ip -4 route get` → `ifconfig` → 网卡配置文件
- 自动获取会跳过 `127.0.0.1` 和 `::1`，优先返回第一个非回环地址
- 若所有策略均失败，IP 将显示为 `Unknown`

### 操作系统检测

- 各系统专有检测命令优先执行，确保识别结果准确（如麒麟的 `nkvers`）
- 同一系统的桌面版和服务器版可能输出不同名称（如"银河麒麟（桌面版）"和"银河麒麟（服务器版）"），在合规检查时需分别配置
- 部分国产操作系统的 release 文件格式不统一，脚本做了多层解析适配，但不排除个别版本获取不到完整名称的情况

### 数据库检测

- **检测策略**：命令行工具 → 安装目录 → systemd/service 服务，三者互补，任一命中即识别
- **版本获取**：依赖各数据库的 `-V` 或 `--version` 参数输出，不同版本可能输出格式不同，脚本通过正则提取版本号，可能无法获取某些数据库的版本
- **TDSQL / PolarDB 等**：这类数据库通常以分布式集群方式部署，单机检测可能无法发现；TDSQL 常以 MySQL 协议兼容方式运行，若未安装独立客户端则难以识别
- **TaurusDB**：华为云数据库，通常不提供本地命令行工具，主要依赖服务名和安装目录检测
- **奥星贝斯(OceanBase)**：检测 `observer` 进程对应的命令，而非 `oceanbase` 本身
- **同一台机器安装多个数据库**：支持输出多个数据库，每个数据库独立一行
- **数据库未在 PATH 中**：如果数据库命令不在系统 PATH 中但安装在标准目录下，目录检测仍可识别（但版本可能为空）

### 兼容性

- 脚本使用 `#!/bin/bash`，需 Bash 环境
- 依赖的常用命令：`grep`、`sed`、`awk`、`head`、`cut`、`sort`、`cat`、`wc`
- 可选命令（缺失不影响基本运行）：`lsb_release`、`lscpu`、`nproc`、`ip`、`ifconfig`、`systemctl`、`service`、`nkvers`
- 已适配 `grep -oP`（Perl 正则）和 `grep -oE`（扩展正则），若系统 grep 不支持 `-P` 选项，部分 IP 获取逻辑可能回退到其他方式
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
| 卡片展示 | 每台主机一张卡片，显示系统名称、版本、CPU、数据库等信息 |
| 合规检查 | 配置允许列表，自动判断每项信息是否合规 |
| 筛选过滤 | 按合规状态（全部/合规/不合规）和操作系统类型筛选 |
| 搜索 | 按 IP、主机名、系统名称等关键词搜索 |
| CSV 导出 | 导出包含合规状态的数据表格，支持 Excel 打开 |

### 合规检查规则

共 5 个检查项，每项可独立配置：

| 检查项 | 说明 |
|-------|------|
| 系统名称 | 操作系统名称需在合规列表中 |
| 系统版本 | 操作系统版本需在合规列表中 |
| CPU型号 | CPU 型号需在合规列表中 |
| CPU架构 | CPU 架构需在合规列表中（如 x86_64、aarch64、loongarch64） |
| 数据库类型 | 检测到的数据库任一在合规列表中即为合规；无数据库则不合规 |

**判定规则**：
- 采用模糊匹配（双向包含），如合规列表中写"达梦"，检测到"达梦 8.1"也判定合规
- 多项检查中**任一不合规**，整条记录标记为不合规
- 未配置规则的检查项不参与判定

### 使用流程

1. 打开 `viewer.html`
2. 拖拽或点击上传 `sysinfo_*.xml` 文件（支持多选）
3. 查看卡片信息
4. （可选）展开左侧合规配置面板，输入合规列表
5. 点击"应用规则"执行合规检查
6. 使用筛选和搜索查看结果
7. 点击"导出CSV"下载数据

---

## 测试文件

项目包含 5 个测试 XML 文件，可用于验证 viewer.html 功能：

| 文件 | 系统 | 数据库 | 合规状态（示例规则） |
|-----|------|--------|-------------------|
| test_kylin_compliant.xml | 银河麒麟（桌面版） | 达梦 8.1 | 合规 |
| test_uos_compliant.xml | 统信UOS（桌面版） | 金仓 V8R6 | 合规 |
| test_founder_compliant.xml | 中科方德（桌面版） | 华为GaussDB 3.0 + 瀚高 9.5 | 不合规（CPU架构） |
| test_kylin_server_compliant.xml | 银河麒麟（服务器版） | 不存在数据库 | 不合规（架构+数据库） |
| test_anolis_noncompliant.xml | 龙蜥Anolis OS | MySQL 8.0.32 | 不合规（系统+架构+数据库） |

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

## 版本

- **v1.1.0** — 增加信创数据库检测（18种）、合规检查支持数据库类型
- **v1.0.0** — 初始版本，操作系统和 CPU 信息采集、合规检查、CSV 导出
