# OpenCode 第三方模型配置指南

本文档记录 OpenCode 配置第三方模型（特别是 Kimi For Coding 和 MiniMax）的完整方法。

## 目录

- [🚀 一键安装](#-一键安装推荐)
- [使用方法](#使用方法)
- [Kimi For Coding](#kimi-for-coding)
- [MiniMax](#minimax)
- [配置参考](#配置参考)
- [AI 助手配置指南](#ai-助手配置指南)

---

## Kimi For Coding

### 问题背景

Kimi For Coding 与普通 Kimi 模型不同，它有特殊的访问限制：
1. **特殊路径**: 必须使用 `/coding/v1` 而不是 `/v1`
2. **User-Agent 验证**: 只允许特定的 Coding Agents 访问（如 Claude Code、Roo Code 等）

### 配置要点

#### 1. 正确的 baseURL

```json
"baseURL": "https://api.kimi.com/coding/v1"
```

❌ 错误: `https://api.kimi.com/v1` - 会返回 404

#### 2. 设置 User-Agent 和 X-Msh Headers

由于 Kimi For Coding 会检查 User-Agent，且用量翻倍活动需要识别 CLI 客户端，需要在 plugin 中设置完整的请求头：

**创建 plugin 文件** `~/.config/opencode/plugins/user-agent.js`:

```javascript
export const UserAgentPlugin = async () => {
  return {
    "chat.headers": async (_input, output) => {
      output.headers = {
        ...output.headers,
        "User-Agent": "KimiCLI/1.12.0",
        "X-Msh-Platform": "kimi_cli",
        "X-Msh-Version": "1.12.0",
        // ... 其他 headers
      };
    }
  };
};
```

**我们提供的增强版 plugin 会自动：**
- ✅ 从 PyPI 动态获取 kimi-cli 最新版本号（带24小时缓存）
- ✅ 自动设置 X-Msh-Platform: kimi_cli（用量翻倍的关键）
- ✅ 生成稳定的设备 ID 和设备信息
- ✅ 支持环境变量 `KIMI_CLI_VERSION` 手动覆盖版本号

#### 3. 完整配置示例

**~/.config/opencode/opencode.json**:

```json
{
  "$schema": "https://opencode.ai/config.json",
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
        "apiKey": "your-kimi-api-key",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    }
  }
}
```

### API 测试

使用 curl 测试配置是否正确：

```bash
# 测试连接（预期返回 200）
curl -X POST https://api.kimi.com/coding/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -H "User-Agent: claude-code/0.1" \
  -d '{
    "model": "kimi-for-coding",
    "messages": [{"role": "user", "content": "hi"}]
  }'
```

### 常见错误

| 错误信息 | 原因 | 解决方案 |
|---------|------|---------|
| `404 Not Found` (nginx) | baseURL 错误，使用了 `/v1` | 改为 `/coding/v1` |
| `403 access_terminated_error` | 缺少 User-Agent 或不是允许的 Agent | 添加 `User-Agent: claude-code/0.1` |
| `401 Invalid Authentication` | API Key 无效 | 检查 API Key 是否正确 |

---

## MiniMax

### 配置要点

MiniMax 配置相对简单，标准的 OpenAI Compatible 格式即可：

```json
{
  "minimax": {
    "models": {
      "MiniMax-M2.1": {
        "name": "MiniMax M2.1"
      }
    },
    "name": "MiniMax",
    "npm": "@ai-sdk/openai-compatible",
    "options": {
      "apiKey": "your-minimax-token",
      "baseURL": "https://api.minimaxi.com/v1"
    }
  }
}
```

注意：MiniMax 使用 JWT Token 作为 API Key，不是普通的 sk-xxx 格式。

---

## 配置参考

### cc-switch 预设对照

如果你使用 [cc-switch](https://github.com/yourusername/cc-switch) 管理配置，以下是预设值对照：

| 模型 | 预设名称 | baseURL |
|-----|---------|---------|
| Kimi k2.5 | `Kimi k2.5` | `https://api.moonshot.cn/v1` |
| Kimi For Coding | `Kimi For Coding` | `https://api.kimi.com/v1` ❌ |
| Kimi For Coding (修正) | - | `https://api.kimi.com/coding/v1` ✅ |
| MiniMax | `MiniMax` | `https://api.minimaxi.com/v1` |

**注意**: cc-switch 中的 Kimi For Coding 预设使用的是旧的 baseURL，需要手动改为 `/coding/v1`。

### OpenCode 配置结构

```typescript
interface OpenCodeProviderConfig {
  npm: string;           // AI SDK 包名，如 "@ai-sdk/openai-compatible"
  name?: string;         // 供应商显示名称
  options: {
    baseURL?: string;    // API 基础 URL
    apiKey?: string;     // API 密钥
    headers?: Record<string, string>;  // 额外请求头
    [key: string]: any;  // 其他选项（timeout 等）
  };
  models: Record<string, {
    name: string;        // 模型显示名称
    options?: any;       // 模型级选项
  }>;
}
```

### Plugin 开发与用量翻倍原理

本仓库的 `user-agent.js` 插件通过 `chat.headers` 钩子修改请求头，模拟官方 kimi-cli 客户端：

```javascript
export const UserAgentPlugin = async () => {
  return {
    "chat.headers": async (_input, output) => {
      output.headers = {
        ...output.headers,
        "User-Agent": "KimiCLI/1.12.0",
        "X-Msh-Platform": "kimi_cli",      // ← 用量翻倍关键字段
        "X-Msh-Version": "1.12.0",
        "X-Msh-Device-Id": "...",
      };
    }
  };
};
```

**可用的 Plugin 钩子：**

| 钩子 | 用途 |
|------|------|
| `chat.headers` | 修改 API 请求头 |
| `experimental.chat.system.transform` | 修改系统提示 |
| `permission.ask` | 权限请求处理 |
| `tool.execute.before` | 工具执行前钩子 |

**自定义版本号：**

```bash
# 临时使用其他版本号
export KIMI_CLI_VERSION="1.11.0"
opencode --model kimi/kimi-for-coding
```

---

## 🚀 一键安装（推荐）

### 方法 1：交互式安装脚本

```bash
curl -fsSL https://raw.githubusercontent.com/elfgzp/opencode-configs/main/scripts/install.sh | bash
```

脚本会自动：
- ✅ 检测 OpenCode 是否安装
- ✅ 询问要配置的模型（Kimi/MiniMax/两者）
- ✅ 获取 API Key（可稍后填写）
- ✅ 自动生成配置文件
- ✅ 安装 User-Agent 插件（用量翻倍必备）
- ✅ 验证配置

### 方法 2：手动复制配置

如果一键脚本无法满足需求，可以手动配置：

```bash
# 1. 克隆仓库
git clone https://github.com/elfgzp/opencode-configs.git
cd opencode-configs

# 2. 复制配置文件
mkdir -p ~/.config/opencode/plugins
cp examples/opencode.json ~/.config/opencode/
cp examples/plugins/user-agent.js ~/.config/opencode/plugins/

# 3. 编辑配置文件，填入你的 API Key
vim ~/.config/opencode/opencode.json

# 4. 启动 OpenCode
opencode --model kimi/kimi-for-coding
```

---

## 使用方法

### 启动 OpenCode

```bash
# 使用 Kimi For Coding（支持用量翻倍活动）
opencode --model kimi/kimi-for-coding

# 使用 MiniMax
opencode --model minimax/MiniMax-M2.1

# 在项目中直接运行（使用默认模型）
cd your-project
opencode
```

### 查看配置

```bash
# 查看 OpenCode 配置
opencode debug config

# 查看配置路径
opencode debug paths
```

---

## AI 助手配置指南

如果你是 AI 助手（如 Claude、Kimi、ChatGPT 等），正在帮助用户配置 OpenCode，请参考 [CONFIGURE.md](./CONFIGURE.md) 获取详细的配置步骤和命令。

## 用量翻倍活动说明

使用 Kimi For Coding 时，通过本配置可支持 **Kimi CLI 用量翻倍活动**：

- **关键 Header**: `X-Msh-Platform: kimi_cli`
- **实现方式**: User-Agent 插件自动添加所有必要的 headers
- **验证方式**: 查看 `~/.config/opencode/plugins/user-agent.js` 文件

## 文件说明

| 文件/目录 | 说明 |
|----------|------|
| `examples/opencode.json` | OpenCode 配置文件模板 |
| `examples/plugins/user-agent.js` | User-Agent 插件（用量翻倍必备） |
| `scripts/install.sh` | 一键安装脚本 |
| `CONFIGURE.md` | AI 助手配置指南 |

## 相关链接

- [OpenCode 官网](https://opencode.ai)
- [Kimi For Coding 文档](https://www.kimi.com/coding/docs/)
- [MiniMax 平台](https://platform.minimaxi.com)
- [Kimi CLI PyPI](https://pypi.org/project/kimi-cli/)
