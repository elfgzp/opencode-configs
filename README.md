# OpenCode 第三方模型配置指南

本文档记录 OpenCode 配置第三方模型（特别是 Kimi For Coding 和 MiniMax）的完整方法。

## 目录

- [Kimi For Coding](#kimi-for-coding)
- [MiniMax](#minimax)
- [配置参考](#配置参考)

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

#### 2. 设置 User-Agent

由于 Kimi For Coding 会检查 User-Agent，需要在 plugin 中设置：

**创建 plugin 文件** `~/.config/opencode/plugins/user-agent.js`:

```javascript
export const UserAgentPlugin = async () => {
  return {
    "chat.headers": async (_input, output) => {
      output.headers = {
        ...output.headers,
        "User-Agent": "claude-code/0.1"
      };
    }
  };
};
```

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

### Plugin 开发

OpenCode 支持通过 plugin 扩展功能，可用钩子：

- `chat.headers`: 修改请求头
- `experimental.chat.system.transform`: 修改系统提示
- `permission.ask`: 权限请求处理
- `tool.execute.before`: 工具执行前钩子

---

## 快速开始

1. 复制 `examples/opencode.json` 到 `~/.config/opencode/`
2. 复制 `examples/plugins/user-agent.js` 到 `~/.config/opencode/plugins/`
3. 替换 API Key
4. 运行 `opencode --model kimi/kimi-for-coding`

---

## 相关链接

- [OpenCode 官网](https://opencode.ai)
- [Kimi For Coding 文档](https://www.kimi.com/coding/docs/)
- [MiniMax 平台](https://platform.minimaxi.com)
- [cc-switch 项目](../cc-switch/)
