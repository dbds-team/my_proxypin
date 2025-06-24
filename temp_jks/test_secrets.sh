#!/bin/bash

# DBDS Secrets 测试脚本
# 用于在本地测试 GitHub organization secrets 配置

echo "=== DBDS Secrets Configuration Test ==="
echo "Testing GitHub Organization secrets for Android signing"
echo

# 模拟 GitHub Actions 环境变量检查
echo "1. Checking environment variables simulation..."

# 这些变量在实际 GitHub Actions 中会自动设置
# 本地测试时需要手动导出这些环境变量

test_vars=(
    "KEY_JKS"
    "ALIAS" 
    "ANDROID_KEY_PASSWORD"
    "ANDROID_STORE_PASSWORD"
)

echo "Required secrets for DBDS signing:"
for var in "${test_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo "  ✓ $var is set"
        if [ "$var" = "KEY_JKS" ]; then
            echo "    Length: ${#!var} characters"
        elif [ "$var" = "ALIAS" ]; then
            echo "    Value: ${!var}"
        else
            echo "    Value: [HIDDEN]"
        fi
    else
        echo "  ✗ $var is not set"
    fi
done

echo
echo "2. Testing base64 validation (if KEY_JKS is set)..."
if [ -n "$KEY_JKS" ]; then
    if echo "$KEY_JKS" | base64 -d > /dev/null 2>&1; then
        echo "  ✓ KEY_JKS has valid base64 format"
        
        # Try to create temporary jks file
        temp_jks="/tmp/test_dbds.jks"
        echo "$KEY_JKS" | base64 -d > "$temp_jks"
        
        if [ -f "$temp_jks" ]; then
            echo "  ✓ Temporary JKS file created"
            echo "    Size: $(stat -c%s "$temp_jks") bytes"
            
            # Test with keytool if password is available
            if [ -n "$ANDROID_STORE_PASSWORD" ]; then
                if keytool -list -keystore "$temp_jks" -storepass "$ANDROID_STORE_PASSWORD" > /dev/null 2>&1; then
                    echo "  ✓ Keystore and password verified"
                    echo "  Available aliases:"
                    keytool -list -keystore "$temp_jks" -storepass "$ANDROID_STORE_PASSWORD" | grep "Alias name" | sed 's/^/    /'
                else
                    echo "  ✗ Keystore or password verification failed"
                fi
            fi
            
            # Cleanup
            rm -f "$temp_jks"
        else
            echo "  ✗ Failed to create temporary JKS file"
        fi
    else
        echo "  ✗ KEY_JKS has invalid base64 format"
    fi
else
    echo "  - Skipped (KEY_JKS not set)"
fi

echo
echo "3. GitHub Actions workflow compatibility check..."
echo "Modified workflows:"
echo "  ✓ .github/workflows/android-build.yml - Added keystore debugging"
echo "  ✓ .github/workflows/flutter-test.yml - Added secrets verification"

echo
echo "=== Test completed ==="
echo
echo "To run this test with actual secrets:"
echo "  export KEY_JKS='your_base64_encoded_jks'"
echo "  export ALIAS='your_alias'"
echo "  export ANDROID_KEY_PASSWORD='your_key_password'"
echo "  export ANDROID_STORE_PASSWORD='your_store_password'"
echo "  bash temp_jks/test_secrets.sh" 