/**
 * User-Agent Plugin for OpenCode
 * 
 * 这个 plugin 用于设置 User-Agent 请求头，解决 Kimi For Coding 等模型
 * 对 Coding Agents 的访问限制问题。
 * 
 * 使用方法:
 * 1. 将此文件复制到 ~/.config/opencode/plugins/
 * 2. 在 opencode.json 的 plugin 数组中添加 "./plugins/user-agent.js"
 */

export const UserAgentPlugin = async () => {
  return {
    /**
     * 在每次 chat 请求时修改 headers
     * 添加 User-Agent 头来模拟 Claude Code
     */
    "chat.headers": async (_input, output) => {
      output.headers = {
        ...output.headers,
        "User-Agent": "claude-code/0.1"
      };
    }
  };
};
