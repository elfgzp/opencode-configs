# OpenCode 配置指南（LLM 版本）

## 概述

本文档供 AI 助手使用，帮助用户一键配置 OpenCode 以支持 Kimi For Coding 和 MiniMax 模型。

**适用场景：**
- 用户说"帮我配置 OpenCode"
- 用户想使用 Kimi 或 MiniMax 模型
- 用户想参加 Kimi 用量翻倍活动

---

## 执行步骤

### Step 1: 询问用户配置偏好

向用户询问以下信息：

```
🤖 我来帮你配置 OpenCode！请告诉我：

1. 你想配置哪个模型？（可多选）
   [ ] Kimi For Coding（推荐，支持用量翻倍活动）
   [ ] MiniMax

2. 你的 API Key：
   - Kimi API Key: [用户输入]
   - MiniMax API Key: [用户输入]
   
   （如果用户暂时没有，可以后续在 ~/.config/opencode/opencode.json 中手动添加）
```

### Step 2: 执行配置命令

根据用户选择，执行以下操作：

#### 2.1 克隆配置仓库

```bash
# 创建临时目录并克隆
TEMP_DIR=$(mktemp -d)
git clone --depth 1 https://github.com/elfgzp/opencode-configs.git "${TEMP_DIR}/opencode-configs"
REPO_DIR="${TEMP_DIR}/opencode-configs"
```

#### 2.2 确保配置目录存在

```bash
mkdir -p ~/.config/opencode/plugins
```

#### 2.3 备份现有配置（如有）

```bash
if [ -f ~/.config/opencode/opencode.json ]; then
    cp ~/.config/opencode/opencode.json \
       ~/.config/opencode/opencode.json.backup.$(date +%Y%m%d_%H%M%S)
fi
```

#### 2.4 复制 User-Agent 插件（如果配置 Kimi）

```bash
if [ -f "${REPO_DIR}/examples/plugins/user-agent.js" ]; then
    cp "${REPO_DIR}/examples/plugins/user-agent.js" ~/.config/opencode/plugins/
fi
```

#### 2.5 生成配置文件

根据用户选择，生成对应的配置文件：

**仅 Kimi:**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "_comment": "OpenCode 配置文件 - Kimi For Coding（支持用量翻倍）",
  "model": "kimi/kimi-for-coding",
  "plugin": [
    "oh-my-opencode@latest",
    "./plugins/user-agent.js"
  ],
  "provider": {
    "kimi": {
      "models": {
        "kimi-for-coding": {
          "name": "Kimi For Coding"
        }
      },
      "name": "Kimi For Coding",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "USER_KIMI_API_KEY",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    }
  }
}
EOF
```

**仅 MiniMax:**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "_comment": "OpenCode 配置文件 - MiniMax",
  "model": "minimax/MiniMax-M2.1",
  "plugin": [
    "oh-my-opencode@latest"
  ],
  "provider": {
    "minimax": {
      "models": {
        "MiniMax-M2.1": {
          "name": "MiniMax M2.1"
        }
      },
      "name": "MiniMax",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "USER_MINIMAX_API_KEY",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
```

**两者都配置:**

```bash
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "_comment": "OpenCode 配置文件 - Kimi For Coding + MiniMax",
  "model": "kimi/kimi-for-coding",
  "plugin": [
    "oh-my-opencode@latest",
    "./plugins/user-agent.js"
  ],
  "provider": {
    "kimi": {
      "models": {
        "kimi-for-coding": {
          "name": "Kimi For Coding"
        }
      },
      "name": "Kimi For Coding",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "USER_KIMI_API_KEY",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    },
    "minimax": {
      "models": {
        "MiniMax-M2.1": {
          "name": "MiniMax M2.1"
        }
      },
      "name": "MiniMax",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "apiKey": "USER_MINIMAX_API_KEY",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
```

**替换 API Key:**

```bash
# 替换为用户提供的实际 API Key
sed -i.bak "s/USER_KIMI_API_KEY/${USER_KIMI_API_KEY}/g" ~/.config/opencode/opencode.json
sed -i.bak "s/USER_MINIMAX_API_KEY/${USER_MINIMAX_API_KEY}/g" ~/.config/opencode/opencode.json
rm -f ~/.config/opencode/opencode.json.bak
```

### Step 3: 验证配置

```bash
# 检查配置文件
if [ -f ~/.config/opencode/opencode.json ]; then
    echo "✓ 配置文件已生成"
fi

# 检查插件（如果配置了 Kimi）
if [ -f ~/.config/opencode/plugins/user-agent.js ]; then
    echo "✓ User-Agent 插件已安装"
fi

# 验证 JSON 格式
python3 -m json.tool ~/.config/opencode/opencode.json > /dev/null && echo "✓ 配置格式正确"
```

### Step 4: 告知用户使用方式

向用户展示以下信息：

```
🎉 配置完成！

使用方法：
---------

# 使用 Kimi For Coding（支持用量翻倍）
opencode --model kimi/kimi-for-coding

# 使用 MiniMax
opencode --model minimax/MiniMax-M2.1

# 或者在项目中直接运行
opencode

配置详情：
----------
• 配置文件: ~/.config/opencode/opencode.json
• 插件目录: ~/.config/opencode/plugins/
• 用量翻倍: 使用 Kimi 模型时自动生效

如需修改 API Key，直接编辑配置文件即可。
```

---

## 关键知识点

### 1. 为什么要 User-Agent 插件？

Kimi For Coding 需要特定的请求头来识别客户端：
- `User-Agent: KimiCLI/{version}` - 标识为 CLI 客户端
- `X-Msh-Platform: kimi_cli` - **关键**：用量翻倍活动的识别字段

### 2. baseURL 区别

| 模型 | 正确的 baseURL | 注意 |
|------|---------------|------|
| Kimi For Coding | `https://api.kimi.com/coding/v1` | 必须是 `/coding/v1` |
| MiniMax | `https://api.minimaxi.com/v1` | 标准 OpenAI 兼容格式 |

### 3. API Key 获取

- **Kimi**: https://platform.moonshot.cn/
- **MiniMax**: https://platform.minimaxi.com/

---

## 故障排除

### 问题：404 Not Found

**原因**: baseURL 错误，使用了 `/v1` 而不是 `/coding/v1`

**解决**: 修正配置文件中的 baseURL

### 问题：403 access_terminated_error

**原因**: 缺少 User-Agent 或不是允许的 Agent

**解决**: 确保 user-agent.js 插件已正确安装并加载

### 问题：401 Invalid Authentication

**原因**: API Key 无效或过期

**解决**: 检查并更新配置文件中的 API Key

---

## 示例对话

### 场景 1：用户想配置 Kimi

**用户**: "帮我配置 OpenCode 使用 Kimi"

**AI**: 
1. "我来帮你配置！需要 Kimi 的 API Key，你有吗？"
2. 等待用户输入或让用户选择稍后配置
3. 执行上述配置步骤
4. 告知用户配置完成和使用方法

### 场景 2：用户想配置多个模型

**用户**: "我想同时配置 Kimi 和 MiniMax"

**AI**:
1. "好的！请提供两个 API Key："
   - "Kimi API Key: [等待输入]"
   - "MiniMax API Key: [等待输入]"
2. 生成包含两个 provider 的配置
3. 验证并告知使用方法

### 场景 3：用户没有 API Key

**用户**: "我想试试 Kimi"

**AI**:
1. "可以！你可以先去 https://platform.moonshot.cn/ 注册并获取 API Key"
2. "或者我可以现在帮你配置好框架，API Key 你可以稍后填入配置文件"
3. 生成占位符配置，告知用户如何修改
