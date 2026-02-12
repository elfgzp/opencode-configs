#!/bin/bash
#
# 更新 kimi-cli 版本号的辅助脚本
# 
# 用法:
#   ./update-version.sh           # 查看最新版本并提示更新
#   ./update-version.sh --apply   # 直接更新 plugin 中的版本号

set -e

PLUGIN_FILE="${HOME}/.config/opencode/plugins/user-agent.js"
LOCAL_PLUGIN="./plugins/user-agent.js"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 正在查询 kimi-cli 最新版本...${NC}"

# 从 PyPI 获取最新版本
LATEST_VERSION=$(curl -s https://pypi.org/pypi/kimi-cli/json | grep -o '"version":"[^"]*"' | head -1 | sed 's/"version":"//;s/"$//')

if [ -z "$LATEST_VERSION" ]; then
    echo -e "${RED}❌ 无法获取最新版本号，请检查网络连接${NC}"
    exit 1
fi

echo -e "${GREEN}✓ PyPI 最新版本: ${LATEST_VERSION}${NC}"

# 检查当前 plugin 中的版本
if [ -f "$PLUGIN_FILE" ]; then
    CURRENT_VERSION=$(grep -o 'FALLBACK_VERSION = "[^"]*"' "$PLUGIN_FILE" 2>/dev/null | sed 's/FALLBACK_VERSION = "//;s/"$//' || echo "unknown")
    echo -e "${BLUE}ℹ️  当前 plugin 版本: ${CURRENT_VERSION}${NC}"
    
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo -e "${GREEN}✓ 已经是最新版本，无需更新${NC}"
        exit 0
    fi
    
    echo -e "${YELLOW}⚠️  发现新版本: ${CURRENT_VERSION} → ${LATEST_VERSION}${NC}"
else
    echo -e "${YELLOW}⚠️  未找到已安装的 plugin${NC}"
fi

# 是否应用更新
if [ "$1" = "--apply" ]; then
    if [ -f "$LOCAL_PLUGIN" ]; then
        # 更新本地 plugin 文件中的 FALLBACK_VERSION
        sed -i.bak "s/FALLBACK_VERSION = \"[^\"]*\"/FALLBACK_VERSION = \"${LATEST_VERSION}\"/" "$LOCAL_PLUGIN" && rm -f "$LOCAL_PLUGIN.bak"
        echo -e "${GREEN}✓ 已更新本地 plugin 版本号: ${LATEST_VERSION}${NC}"
        
        # 如果已安装，同时更新安装目录
        if [ -f "$PLUGIN_FILE" ]; then
            cp "$LOCAL_PLUGIN" "$PLUGIN_FILE"
            echo -e "${GREEN}✓ 已同步更新到: ${PLUGIN_FILE}${NC}"
        fi
    else
        echo -e "${RED}❌ 未找到本地 plugin 文件: ${LOCAL_PLUGIN}${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${BLUE}💡 提示:${NC}"
    echo "   新版本 ${LATEST_VERSION} 可用！"
    echo "   运行 './update-version.sh --apply' 更新版本号"
    echo ""
    echo -e "${BLUE}📋 或者设置环境变量临时使用新版本:${NC}"
    echo "   export KIMI_CLI_VERSION=${LATEST_VERSION}"
    echo "   opencode --model kimi/kimi-for-coding"
fi
