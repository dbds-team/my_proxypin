# DBDS 签名密钥配置说明

## 概述
此目录包含 DBDS 项目的 Android 应用签名相关密钥配置文件和说明。

## 组织 Secrets 配置
已在 GitHub Organization 中配置的密钥变量：

| 变量名 | 说明 | 状态 |
|--------|------|------|
| `KEY_JKS` | Base64 编码的 Android 签名证书内容 | ✅ 已配置 |
| `ALIAS` | 证书别名 | ✅ 已配置 |
| `ANDROID_KEY_PASSWORD` | 密钥密码 | ✅ 已配置 |
| `ANDROID_STORE_PASSWORD` | 证书库密码 | ✅ 已配置 |

## 调试信息
- 在 `android-build.yml` 工作流中添加了详细的密钥验证和调试信息
- 在 `flutter-test.yml` 中添加了 secrets 可用性检查
- 包含 base64 格式验证和 keystore 密码验证

## 工作流修改
1. **android-build.yml**: 添加了完整的密钥验证流程
2. **flutter-test.yml**: 添加了开始时的 secrets 检查

## 故障排除
如果构建失败，查看工作流日志中的调试信息：
- 检查 secrets 是否正确读取
- 验证 base64 编码格式
- 确认 keystore 密码正确性
- 验证证书别名存在

## 文件说明
- `dbds_secrets.properties` - Properties 格式的配置模板
- `README.md` - 本说明文档

创建时间: $(date '+%Y-%m-%d %H:%M:%S') 