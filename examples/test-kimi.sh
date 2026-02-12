#!/bin/bash
# 测试 Kimi For Coding API 连接

API_KEY="${KIMI_API_KEY:-sk-kimi-your-api-key-here}"
BASE_URL="https://api.kimi.com/coding/v1"

echo "=== 测试 Kimi For Coding API ==="
echo "Base URL: $BASE_URL"
echo ""

# 测试 1: 错误的 baseURL (预期 404)
echo "测试 1: 错误的 baseURL (/v1 而不是 /coding/v1)"
curl -s -X POST "https://api.kimi.com/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"model": "kimi-for-coding", "messages": [{"role": "user", "content": "hi"}]}' \
  -w "\nHTTP Code: %{http_code}\n"
echo ""

# 测试 2: 正确的 baseURL 但缺少 User-Agent (预期 403)
echo "测试 2: 正确的 baseURL 但缺少 User-Agent"
curl -s -X POST "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"model": "kimi-for-coding", "messages": [{"role": "user", "content": "hi"}]}' \
  -w "\nHTTP Code: %{http_code}\n"
echo ""

# 测试 3: 正确的配置 (预期 200)
echo "测试 3: 正确的配置 (baseURL + User-Agent)"
curl -s -X POST "$BASE_URL/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -H "User-Agent: claude-code/0.1" \
  -d '{"model": "kimi-for-coding", "messages": [{"role": "user", "content": "hi"}]}' \
  -w "\nHTTP Code: %{http_code}\n" | head -20
echo ""

echo "=== 测试完成 ==="
