/**
 * User-Agent Plugin for OpenCode - Kimi CLI 模拟
 * 
 * 功能：设置与 kimi-cli 官方客户端相同的请求头，支持用量翻倍活动
 * 
 * 核心 Headers:
 * - User-Agent: KimiCLI/{version}
 * - X-Msh-Platform: kimi_cli  ← 用量翻倍活动识别关键
 * - X-Msh-Version: 版本号
 * - X-Msh-Device-Id: 设备唯一标识
 */

// 从环境变量获取版本，或使用默认版本
// 建议定期更新此版本号，或设置 KIMI_CLI_VERSION 环境变量
const DEFAULT_VERSION = "1.12.0";

export const UserAgentPlugin = async () => {
  const version = process.env.KIMI_CLI_VERSION || DEFAULT_VERSION;
  
  // 生成稳定的设备 ID（基于时间戳和随机数）
  const deviceId = `opencode_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;
  
  return {
    "chat.headers": async (_input, output) => {
      const client = _input?.client;
      
      // 构建 User-Agent
      let userAgent = `KimiCLI/${version}`;
      if (client?.name) {
        userAgent += ` (${client.name}${client.version ? ` ${client.version}` : ''})`;
      }
      
      // 设置完整的 headers（与 kimi-cli 一致）
      output.headers = {
        ...output.headers,
        "User-Agent": userAgent,
        "X-Msh-Platform": "kimi_cli",
        "X-Msh-Version": version,
        "X-Msh-Device-Name": "opencode-client",
        "X-Msh-Device-Model": "OpenCode",
        "X-Msh-Os-Version": "unknown",
        "X-Msh-Device-Id": deviceId,
      };
    }
  };
};
