#!/bin/bash

# DBDS Keystore Password 调试脚本
# 用于诊断 keystore 密码不匹配问题

echo "=== DBDS Keystore Password Debug ==="
echo

JKS_FILE="dbds-release.jks"

if [ ! -f "$JKS_FILE" ]; then
    echo "✗ Keystore file '$JKS_FILE' not found in current directory"
    echo "Please ensure the keystore file is present"
    exit 1
fi

echo "✓ Found keystore file: $JKS_FILE"
echo "  Size: $(stat -c%s "$JKS_FILE") bytes"
echo

# 函数：测试密码
test_password() {
    local password="$1"
    local description="$2"
    
    echo "Testing $description: '$password'"
    if keytool -list -keystore "$JKS_FILE" -storepass "$password" > /dev/null 2>&1; then
        echo "  ✓ SUCCESS: Password works!"
        echo "  Available aliases:"
        keytool -list -keystore "$JKS_FILE" -storepass "$password" | grep "Alias name" | sed 's/^/    /'
        return 0
    else
        echo "  ✗ FAILED: Password incorrect"
        return 1
    fi
}

echo "=== Testing Common Passwords ==="

# 常见的密码组合
passwords=(
    "dbds2024secret"
    "dbds-2024-secret"
    "DBDS2024SECRET"
    "dbds2024"
    "password"
    "123456"
    "changeit"
    "android"
    ""
)

success=false
for pwd in "${passwords[@]}"; do
    if test_password "$pwd" "common password"; then
        success=true
        WORKING_PASSWORD="$pwd"
        break
    fi
    echo
done

if [ "$success" = false ]; then
    echo "=== No common passwords worked ==="
    echo
    echo "Manual password testing:"
    echo "Try running: keytool -list -keystore $JKS_FILE"
    echo "And enter passwords manually when prompted"
    echo
    
    # 尝试无密码
    echo "Testing with empty password..."
    echo "" | keytool -list -keystore "$JKS_FILE" 2>&1 | head -10
    
    # 显示详细的错误信息
    echo
    echo "Detailed error information:"
    keytool -list -keystore "$JKS_FILE" -storepass "wrong_password" 2>&1 | head -5
else
    echo
    echo "=== SUCCESS: Found working password ==="
    echo "Working store password: '$WORKING_PASSWORD'"
    echo
    
    # 测试别名和密钥密码
    echo "=== Testing Alias and Key Password ==="
    
    # 获取所有别名
    aliases=$(keytool -list -keystore "$JKS_FILE" -storepass "$WORKING_PASSWORD" | grep "Alias name" | sed 's/Alias name: //')
    
    for alias in $aliases; do
        echo "Testing alias: $alias"
        
        # 测试不同的密钥密码
        key_passwords=(
            "$WORKING_PASSWORD"
            "dbds2024secret"
            "dbds-2024-secret" 
            "DBDS2024SECRET"
            "password"
            ""
        )
        
        for key_pass in "${key_passwords[@]}"; do
            if keytool -list -keystore "$JKS_FILE" -alias "$alias" -storepass "$WORKING_PASSWORD" -keypass "$key_pass" > /dev/null 2>&1; then
                echo "  ✓ Key password for '$alias': '$key_pass'"
                break
            fi
        done
    done
    
    echo
    echo "=== Configuration for GitHub Secrets ==="
    echo "Based on successful tests:"
    echo "ANDROID_STORE_PASSWORD: '$WORKING_PASSWORD'"
    echo "ANDROID_KEY_PASSWORD: (test manually with each alias)"
    echo "ALIAS: (choose from the aliases listed above)"
fi

echo
echo "=== Debug Complete ===" 