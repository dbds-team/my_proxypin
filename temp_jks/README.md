# DBDS Android 签名密钥配置

## GitHub Secrets 配置

在 GitHub 仓库的 **Settings > Secrets and variables > Actions** 中添加以下 4 个变量：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `KEY_JKS` | [见 github_secrets.txt] | base64 编码的证书内容 |
| `ALIAS` | `dbds-key` | 证书别名 |
| `ANDROID_KEY_PASSWORD` | `dbds2024secret` | 密钥密码 |
| `ANDROID_STORE_PASSWORD` | `dbds2024secret` | 证书库密码 |

## 文件说明

- **dbds-release.jks**: Android 签名密钥库文件
- **github_secrets.txt**: 完整的 GitHub Secrets 配置内容
- **README.md**: 本说明文件

## 密钥信息

- **证书别名**: dbds-key
- **有效期**: 2025-06-24 至 2052-11-09 (约27年)
- **密钥算法**: RSA 2048位
- **证书主题**: CN=DBDS, OU=Development, O=DBDS, L=Beijing, S=Beijing, C=CN
- **SHA256指纹**: B1:60:E5:42:0D:08:6A:05:AF:49:79:E6:EE:55:6F:F0:0B:EC:A2:BB:CA:57:AF:39:4E:7A:E6:F1:01:4A:93:50

## 使用方法

1. 将 `KEY_JKS` 中的 base64 字符串复制到 GitHub Secrets
2. 设置其他三个变量的值
3. 在 GitHub Actions 工作流中引用这些密钥进行 Android 应用签名

## 安全提醒

⚠️ **重要**: 请妥善保管这些密钥信息，不要泄露给他人！ 