# 组织级别 Secrets 配置指南

## 概述

本项目已配置为使用 GitHub 组织级别的 secrets 进行 Android 应用签名。当仓库移至组织后，需要在组织设置中配置以下 secrets。

## 需要配置的 Secrets

### 1. 在组织设置中添加 Secrets

导航到：**GitHub 组织 > Settings > Secrets and variables > Actions > Organization secrets**

添加以下 4 个 secrets：

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `KEY_JKS` | [见 temp_jks/github_secrets.txt] | base64 编码的 DBDS 签名证书 |
| `ALIAS` | `dbds-key` | 证书别名 |
| `ANDROID_KEY_PASSWORD` | `dbds2024secret` | 密钥密码 |
| `ANDROID_STORE_PASSWORD` | `dbds2024secret` | 证书库密码 |

### 2. Secret 访问策略

配置这些 secrets 的访问策略：

- **可见性**: 选择 "Selected repositories" 或 "All repositories"
- **访问权限**: 确保目标仓库有权限访问这些 secrets

## 工作流文件说明

项目包含以下工作流文件：

### 1. `.github/workflows/android-build.yml`
- **用途**: Android 专用构建和签名
- **触发条件**: 
  - 推送到 `main` 或 `develop` 分支
  - 创建标签 (v*)
  - Pull Request 到 `main` 分支
  - 手动触发
- **功能**:
  - 构建 APK 和 AAB 文件
  - 使用组织 secrets 进行签名
  - 上传构建产物
  - 自动创建 GitHub Release (仅限标签)

### 2. `.github/workflows/multi-platform-build.yml`
- **用途**: 多平台构建 (Android, iOS, macOS, Windows, Linux)
- **触发条件**:
  - 推送到 `main` 分支
  - 创建标签 (v*)
  - 手动触发
- **功能**:
  - 同时构建所有支持的平台
  - Android 使用组织 secrets 签名
  - 创建统一的 Release

## 安全特性

### 1. Secret 保护
- secrets 只在非 Pull Request 事件中使用
- 构建完成后自动清理临时密钥文件
- 使用 `if: always()` 确保清理步骤总是执行

### 2. 条件构建
- Pull Request 只构建 debug 版本，不使用签名密钥
- 只有可信的分支和标签触发签名构建

## 迁移步骤

### 1. 仓库迁移到组织
```bash
# 如果是个人仓库，需要转移到组织
# 在 GitHub 网页上: Settings > General > Transfer ownership
```

### 2. 配置组织 Secrets
1. 复制 `temp_jks/github_secrets.txt` 中的 `KEY_JKS` 值
2. 在组织设置中添加所有 4 个 secrets
3. 确保仓库有访问权限

### 3. 验证配置
1. 推送代码触发工作流
2. 检查工作流日志确认 secrets 正确加载
3. 验证生成的 APK/AAB 文件已正确签名

## 常见问题

### Q: 工作流显示 "Secret not found"
**A**: 检查以下几点：
- Secrets 是否在组织级别正确配置
- 仓库是否有权限访问组织 secrets
- Secret 名称是否完全匹配（区分大小写）

### Q: 签名失败
**A**: 验证以下内容：
- `KEY_JKS` 的 base64 编码是否正确
- 密码是否正确匹配
- 证书别名是否为 `dbds-key`

### Q: 构建在 PR 中失败
**A**: 这是正常的，PR 构建不使用签名 secrets，只构建 debug 版本

## 密钥信息

- **证书文件**: `temp_jks/dbds-release.jks`
- **主题**: CN=DBDS, OU=Development, O=DBDS, L=Beijing, S=Beijing, C=CN
- **有效期**: 2025-06-24 至 2052-11-09 (约27年)
- **算法**: RSA 2048位
- **SHA256**: B1:60:E5:42:0D:08:6A:05:AF:49:79:E6:EE:55:6F:F0:0B:EC:A2:BB:CA:57:AF:39:4E:7A:E6:F1:01:4A:93:50

---

⚠️ **重要提醒**: 请妥善保管密钥文件和密码，不要将其提交到代码仓库中！ 