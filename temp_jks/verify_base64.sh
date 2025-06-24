#!/bin/bash

# DBDS Base64 验证脚本
# 用于验证 GitHub secrets 中的 base64 编码格式

echo "=== DBDS Base64 Verification ==="
echo

JKS_FILE="dbds-release.jks"

if [ ! -f "$JKS_FILE" ]; then
    echo "✗ Keystore file '$JKS_FILE' not found"
    exit 1
fi

echo "✓ Found keystore file: $JKS_FILE"
ORIGINAL_SIZE=$(stat -c%s "$JKS_FILE")
echo "  Original size: $ORIGINAL_SIZE bytes"

echo
echo "=== Generating Correct Base64 ==="

# 生成正确的 base64 编码
echo "Generating base64 from keystore..."
BASE64_CONTENT=$(base64 -w 0 "$JKS_FILE")
BASE64_LENGTH=${#BASE64_CONTENT}

echo "✓ Base64 generated successfully"
echo "  Length: $BASE64_LENGTH characters"
echo "  First 50 chars: ${BASE64_CONTENT:0:50}..."
echo "  Last 50 chars: ...${BASE64_CONTENT: -50}"

echo
echo "=== Testing Base64 Decoding ==="

# 测试解码
TEST_FILE="/tmp/test_decode.jks"
echo "$BASE64_CONTENT" | base64 -d > "$TEST_FILE"

if [ -f "$TEST_FILE" ]; then
    DECODED_SIZE=$(stat -c%s "$TEST_FILE")
    echo "✓ Decoding successful"
    echo "  Decoded size: $DECODED_SIZE bytes"
    
    if [ "$ORIGINAL_SIZE" -eq "$DECODED_SIZE" ]; then
        echo "✓ Size matches original"
        
        # 验证内容是否完全相同
        if cmp -s "$JKS_FILE" "$TEST_FILE"; then
            echo "✓ Content matches original perfectly"
        else
            echo "✗ Content differs from original"
        fi
        
        # 测试解码后的 keystore
        echo
        echo "Testing decoded keystore with keytool..."
        if keytool -list -keystore "$TEST_FILE" -storepass dbds2024secret > /dev/null 2>&1; then
            echo "✓ Decoded keystore works with keytool"
        else
            echo "✗ Decoded keystore fails with keytool"
            keytool -list -keystore "$TEST_FILE" -storepass dbds2024secret 2>&1 | head -3
        fi
    else
        echo "✗ Size mismatch: original=$ORIGINAL_SIZE, decoded=$DECODED_SIZE"
    fi
    
    rm -f "$TEST_FILE"
else
    echo "✗ Failed to decode base64"
fi

echo
echo "=== GitHub Secrets Configuration ==="
echo "Copy this base64 content to GitHub Organization secrets as KEY_JKS:"
echo
echo "--- BEGIN BASE64 ---"
echo "$BASE64_CONTENT"
echo "--- END BASE64 ---"

echo
echo "=== Common Base64 Issues ==="
echo "1. Ensure no line breaks in GitHub secrets"
echo "2. No extra spaces or whitespace"
echo "3. Copy the ENTIRE base64 string"
echo "4. Verify the base64 string length: $BASE64_LENGTH chars"

# 检查是否有常见的base64问题
echo
echo "=== Validating Current Format ==="
if [ -n "$KEY_JKS" ]; then
    echo "Testing provided KEY_JKS environment variable..."
    CURRENT_LENGTH=${#KEY_JKS}
    echo "  Provided length: $CURRENT_LENGTH chars"
    echo "  Expected length: $BASE64_LENGTH chars"
    
    if [ "$CURRENT_LENGTH" -eq "$BASE64_LENGTH" ]; then
        echo "✓ Length matches"
        
        if [ "$KEY_JKS" = "$BASE64_CONTENT" ]; then
            echo "✓ Content matches perfectly"
        else
            echo "✗ Content differs"
            echo "  First difference at character:"
            for ((i=0; i<${#BASE64_CONTENT}; i++)); do
                if [ "${BASE64_CONTENT:$i:1}" != "${KEY_JKS:$i:1}" ]; then
                    echo "  Position $i: expected '${BASE64_CONTENT:$i:1}', got '${KEY_JKS:$i:1}'"
                    break
                fi
            done
        fi
    else
        echo "✗ Length mismatch"
    fi
else
    echo "No KEY_JKS environment variable set for testing"
    echo "To test: export KEY_JKS='<your_base64_content>' && bash verify_base64.sh"
fi

echo
echo "=== Verification Complete ===" 