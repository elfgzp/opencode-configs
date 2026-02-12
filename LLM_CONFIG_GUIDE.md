# OpenCode 配置指南（AI 助手版）

> **本文档供 AI 助手使用**  
> 当用户说"帮我配置 OpenCode"时，请按以下步骤执行。

---

## Step 1: 询问用户

向用户确认以下信息：

```
我来帮你配置 OpenCode！请告诉我：

1. 要配置哪些模型？（可多选）
   - Kimi For Coding（推荐，支持用量翻倍活动）
   - MiniMax

2. API Key（如果没有可以稍后配置）：
   - Kimi API Key: ____________
   - MiniMax API Key: ____________
```

---

## Step 2: 执行配置

### 2.1 克隆配置仓库

```bash
cd /tmp && git clone --depth 1 https://github.com/elfgzp/opencode-configs.git
REPO_DIR="/tmp/opencode-configs"
```

### 2.2 创建配置目录

```bash
mkdir -p ~/.config/opencode/plugins
```

### 2.3 备份现有配置（如有）

```bash
if [ -f ~/.config/opencode/opencode.json ]; then
    cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup.$(date +%Y%m%d_%H%M%S)
    echo "已备份原配置"
fi
```

### 2.4 安装 User-Agent 插件（如配置 Kimi）

```bash
if [ -f "${REPO_DIR}/examples/plugins/user-agent.js" ]; then
    cp "${REPO_DIR}/examples/plugins/user-agent.js" ~/.config/opencode/plugins/
    echo "✓ User-Agent 插件已安装"
fi
```

### 2.5 生成配置文件

根据用户选择，执行对应的配置：

**仅 Kimi：**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "kimi/kimi-for-coding",
  "plugin": ["oh-my-opencode@latest", "./plugins/user-agent.js"],
  "provider": {
    "kimi": {
      "models": { "kimi-for-coding": { "name": "Kimi For Coding" } },
      "name": "Kimi For Coding",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "KIMI_API_KEY_PLACEHOLDER",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    }
  }
}
EOF
```

**仅 MiniMax：**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "minimax/MiniMax-M2.1",
  "plugin": ["oh-my-opencode@latest"],
  "provider": {
    "minimax": {
      "models": { "MiniMax-M2.1": { "name": "MiniMax M2.1" } },
      "name": "MiniMax",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "MINIMAX_API_KEY_PLACEHOLDER",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
```

**两者都配置：**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "kimi/kimi-for-coding",
  "plugin": ["oh-my-opencode@latest", "./plugins/user-agent.js"],
  "provider": {
    "kimi": {
      "models": { "kimi-for-coding": { "name": "Kimi For Coding" } },
      "name": "Kimi For Coding",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "KIMI_API_KEY_PLACEHOLDER",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    },
    "minimax": {
      "models": { "MiniMax-M2.1": { "name": "MiniMax M2.1" } },
      "name": "MiniMax",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "MINIMAX_API_KEY_PLACEHOLDER",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
```

### 2.6 替换 API Key

```bash
# 替换为用户提供的实际 API Key
sed -i.bak "s/KIMI_API_KEY_PLACEHOLDER/${KIMI_API_KEY}/g" ~/.config/opencode/opencode.json 2>/dev/null || true
sed -i.bak "s/MINIMAX_API_KEY_PLACEHOLDER/${MINIMAX_API_KEY}/g" ~/.config/opencode/opencode.json 2>/dev/null || true
rm -f ~/.config/opencode/opencode.json.bak
```

---

## Step 3: 验证配置

```bash
# 检查配置文件
if [ -f ~/.config/opencode/opencode.json ]; then
    echo "✓ 配置文件已生成"
    python3 -m json.tool ~/.config/opencode/opencode.json > /dev/null && echo "✓ JSON 格式正确"
fi

# 检查插件
if [ -f ~/.config/opencode/plugins/user-agent.js ]; then
    echo "✓ User-Agent 插件已就绪"
fi

# 清理临时文件
rm -rf /tmp/opencode-configs
```

---

## Step 4: 告知用户

配置完成后，向用户展示：

```
🎉 OpenCode 配置完成！

使用命令：
  opencode --model kimi/kimi-for-coding    # Kimi（用量翻倍）
  opencode --model minimax/MiniMax-M2.1    # MiniMax

配置文件：~/.config/opencode/opencode.json

如需修改 API Key，直接编辑配置文件即可。
```

---

## 关键知识

### 用量翻倍原理

Kimi CLI 用量翻倍活动通过 `X-Msh-Platform: kimi_cli` header 识别 CLI 客户端：

| Header | 作用 |
|--------|------|
| `User-Agent: KimiCLI/{version}` | 标识 CLI 客户端 |
| `X-Msh-Platform: kimi_cli` | **用量翻倍关键识别字段** |
| `X-Msh-Version` | 版本号 |
| `X-Msh-Device-Id` | 设备唯一标识 |

### baseURL 注意事项

| 模型 | 正确 baseURL | 错误 baseURL |
|------|-------------|-------------|
| Kimi For Coding | `https://api.kimi.com/coding/v1` ✅ | `https://api.kimi.com/v1` ❌ |
| MiniMax | `https://api.minimaxi.com/v1` ✅ | - |

### API Key 获取

- **Kimi**: https://platform.moonshot.cn/
- **MiniMax**: https://platform.minimaxi.com/

---

## 故障排除

| 问题 | 原因 | 解决 |
|------|------|------|
| 404 Not Found | baseURL 错误 | 使用 `/coding/v1` |
| 403 access_terminated_error | 缺少 User-Agent | 确保插件已安装 |
| 401 Invalid Authentication | API Key 无效 | 检查并更新 API Key |
