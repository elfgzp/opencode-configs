# 安装指南

## 快速配置 Kimi For Coding

### 1. 复制配置文件

```bash
# 创建插件目录
mkdir -p ~/.config/opencode/plugins

# 复制 plugin
cp examples/plugins/user-agent.js ~/.config/opencode/plugins/

# 复制配置文件
cp examples/opencode.json ~/.config/opencode/
```

### 2. 编辑配置文件

编辑 `~/.config/opencode/opencode.json`，替换 API Key：

```json
{
  "options": {
    "apiKey": "sk-kimi-your-actual-api-key"
  }
}
```

### 3. 验证配置

```bash
# 测试 API 连接
./examples/test-kimi.sh

# 或使用 opencode
opencode --model kimi/kimi-for-coding
```

## 用量翻倍活动配置

plugin 已内置对用量翻倍活动的支持，会自动设置 `X-Msh-Platform: kimi_cli` 等关键 headers。

### 版本号设置

plugin 默认会**自动从 PyPI 获取** kimi-cli 最新版本号（24小时缓存）：

```bash
# 手动指定版本号（覆盖自动获取）
export KIMI_CLI_VERSION="1.12.0"
opencode --model kimi/kimi-for-coding

# 调整缓存时间（默认24小时）
export KIMI_CLI_VERSION_CACHE_HOURS=12
```

### 手动获取最新版本（供参考）

```bash
# 查看最新版本
curl -s https://pypi.org/pypi/kimi-cli/json | grep -o '"version":"[^"]*"' | head -1

# 或查看 GitHub releases
curl -s https://api.github.com/repos/moonshot-ai/kimi-cli/releases/latest | grep '"tag_name":' | sed 's/.*"tag_name": "\(.*\)".*/\1/'
```

## 配置 MiniMax

MiniMax 使用 JWT Token，配置类似：

```json
{
  "minimax": {
    "options": {
      "apiKey": "eyJhbGci...your-jwt-token",
      "baseURL": "https://api.minimaxi.com/v1"
    }
  }
}
```

注意：MiniMax 不需要 User-Agent plugin。

## 故障排除

### 404 Not Found

检查 baseURL 是否为 `https://api.kimi.com/coding/v1`，不是 `/v1`。

### 403 Forbidden

检查是否正确加载了 `user-agent.js` plugin。

### 401 Unauthorized

检查 API Key 是否有效。
