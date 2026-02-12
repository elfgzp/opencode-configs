#!/bin/bash
#
# OpenCode 一键配置脚本 - 交互式版本
# 
# 使用方法:
#   curl -fsSL https://raw.githubusercontent.com/elfgzp/opencode-configs/main/scripts/install.sh | bash
#   
# 或者先下载再执行:
#   curl -fsSL -o install.sh https://raw.githubusercontent.com/elfgzp/opencode-configs/main/scripts/install.sh
#   bash install.sh
#

set -e

# 颜色配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置目录
CONFIG_DIR="${HOME}/.config/opencode"
PLUGINS_DIR="${CONFIG_DIR}/plugins"
TEMP_DIR=$(mktemp -d)
REPO_URL="https://github.com/elfgzp/opencode-configs.git"
REPO_DIR="${TEMP_DIR}/opencode-configs"

# 清理函数
cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

# 打印函数
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║      OpenCode 一键配置 - Kimi/MiniMax 模型支持              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo -e "${BLUE}[Step $1]${NC} $2"
}

# 检查依赖
check_dependencies() {
    print_step "1" "检查依赖环境..."
    
    if ! command -v git &> /dev/null; then
        print_error "未找到 git，请先安装 git"
        exit 1
    fi
    
    if ! command -v opencode &> /dev/null; then
        print_warning "未找到 opencode 命令"
        echo ""
        echo "请先安装 OpenCode:"
        echo "  curl -fsSL https://opencode.ai/install | bash"
        echo ""
        read -p "是否继续配置？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "OpenCode 已安装"
    fi
}

# 克隆仓库
clone_repo() {
    print_step "2" "下载配置文件..."
    
    print_info "正在克隆仓库..."
    if git clone --depth 1 "${REPO_URL}" "${REPO_DIR}" 2>/dev/null; then
        print_success "仓库克隆完成"
    else
        print_error "克隆仓库失败，尝试使用本地文件..."
        # 如果克隆失败，检查当前是否在仓库中
        if [ -f "./examples/opencode.json" ]; then
            REPO_DIR="."
            print_success "使用本地仓库文件"
        else
            print_error "无法获取配置文件"
            exit 1
        fi
    fi
}

# 选择模型
select_models() {
    print_step "3" "选择要配置的模型"
    echo ""
    echo "可用的模型提供商："
    echo "  1) Kimi For Coding (推荐，支持用量翻倍活动)"
    echo "  2) MiniMax"
    echo "  3) 同时配置两个"
    echo ""
    
    read -p "请选择 [1-3]: " choice
    
    case $choice in
        1)
            SELECTED_MODELS="kimi"
            print_success "已选择: Kimi For Coding"
            ;;
        2)
            SELECTED_MODELS="minimax"
            print_success "已选择: MiniMax"
            ;;
        3)
            SELECTED_MODELS="both"
            print_success "已选择: Kimi + MiniMax"
            ;;
        *)
            print_warning "无效选择，默认配置 Kimi"
            SELECTED_MODELS="kimi"
            ;;
    esac
}

# 输入 API Key
input_api_keys() {
    print_step "4" "配置 API Key"
    echo ""
    
    # Kimi API Key
    if [[ "$SELECTED_MODELS" == "kimi" || "$SELECTED_MODELS" == "both" ]]; then
        echo -e "${CYAN}Kimi For Coding:${NC}"
        echo "  获取方式: https://platform.moonshot.cn/"
        read -sp "  请输入 Kimi API Key: " kimi_key
        echo
        
        if [ -z "$kimi_key" ]; then
            print_warning "未输入 Kimi API Key，将使用占位符"
            kimi_key="your-kimi-api-key"
        else
            print_success "Kimi API Key 已设置"
        fi
    fi
    
    echo ""
    
    # MiniMax Token
    if [[ "$SELECTED_MODELS" == "minimax" || "$SELECTED_MODELS" == "both" ]]; then
        echo -e "${CYAN}MiniMax:${NC}"
        echo "  获取方式: https://platform.minimaxi.com/"
        read -sp "  请输入 MiniMax API Key: " minimax_key
        echo
        
        if [ -z "$minimax_key" ]; then
            print_warning "未输入 MiniMax API Key，将使用占位符"
            minimax_key="your-minimax-api-key"
        else
            print_success "MiniMax API Key 已设置"
        fi
    fi
}

# 生成配置文件
generate_config() {
    print_step "5" "生成配置文件..."
    
    # 确保配置目录存在
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${PLUGINS_DIR}"
    
    # 备份现有配置
    if [ -f "${CONFIG_DIR}/opencode.json" ]; then
        backup_name="opencode.json.backup.$(date +%Y%m%d_%H%M%S)"
        cp "${CONFIG_DIR}/opencode.json" "${CONFIG_DIR}/${backup_name}"
        print_info "已备份原配置: ${backup_name}"
    fi
    
    # 生成新配置
    local config_file="${CONFIG_DIR}/opencode.json"
    
    # 根据选择生成配置
    if [[ "$SELECTED_MODELS" == "kimi" ]]; then
        cat > "$config_file" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
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
        "apiKey": "${kimi_key}",
        "baseURL": "https://api.kimi.com/coding/v1"
      }
    }
  }
}
EOF
    elif [[ "$SELECTED_MODELS" == "minimax" ]]; then
        cat > "$config_file" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
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
        "apiKey": "${minimax_key}",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
    else
        # both
        cat > "$config_file" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
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
        "apiKey": "${kimi_key}",
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
        "apiKey": "${minimax_key}",
        "baseURL": "https://api.minimaxi.com/v1"
      }
    }
  }
}
EOF
    fi
    
    print_success "配置文件已生成: ${config_file}"
}

# 安装插件
install_plugin() {
    if [[ "$SELECTED_MODELS" == "kimi" || "$SELECTED_MODELS" == "both" ]]; then
        print_step "6" "安装 User-Agent 插件..."
        
        if [ -f "${REPO_DIR}/examples/plugins/user-agent.js" ]; then
            cp "${REPO_DIR}/examples/plugins/user-agent.js" "${PLUGINS_DIR}/"
            print_success "插件已安装: ${PLUGINS_DIR}/user-agent.js"
            print_info "此插件用于模拟 kimi-cli 客户端，支持用量翻倍活动"
        else
            print_warning "未找到插件文件，跳过安装"
        fi
    fi
}

# 验证配置
verify_config() {
    print_step "7" "验证配置..."
    
    # 检查配置文件是否存在
    if [ -f "${CONFIG_DIR}/opencode.json" ]; then
        print_success "配置文件存在"
        
        # 检查插件是否正确加载
        if [[ "$SELECTED_MODELS" == "kimi" || "$SELECTED_MODELS" == "both" ]]; then
            if [ -f "${PLUGINS_DIR}/user-agent.js" ]; then
                print_success "User-Agent 插件已就绪"
            else
                print_warning "User-Agent 插件未找到"
            fi
        fi
        
        # 测试 API 连通性（仅当有实际 key 时）
        if [[ "$kimi_key" != "your-kimi-api-key" && "$kimi_key" != "" ]]; then
            print_info "测试 Kimi API 连通性..."
            if curl -s -o /dev/null -w "%{http_code}" \
                -H "Authorization: Bearer ${kimi_key}" \
                -H "User-Agent: KimiCLI/1.12.0" \
                https://api.kimi.com/coding/v1/models 2>/dev/null | grep -q "200"; then
                print_success "Kimi API 连接正常"
            else
                print_warning "Kimi API 连接测试失败，请检查 API Key"
            fi
        fi
    else
        print_error "配置文件不存在"
        exit 1
    fi
}

# 打印完成信息
print_finish() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 配置完成！                             ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ "$SELECTED_MODELS" == "kimi" || "$SELECTED_MODELS" == "both" ]]; then
        echo -e "${CYAN}Kimi For Coding:${NC}"
        echo "  opencode --model kimi/kimi-for-coding"
        echo ""
    fi
    
    if [[ "$SELECTED_MODELS" == "minimax" || "$SELECTED_MODELS" == "both" ]]; then
        echo -e "${CYAN}MiniMax:${NC}"
        echo "  opencode --model minimax/MiniMax-M2.1"
        echo ""
    fi
    
    echo -e "${YELLOW}提示:${NC}"
    if [[ "$kimi_key" == "your-kimi-api-key" || "$kimi_key" == "" ]]; then
        echo "  • 您未输入 Kimi API Key，请编辑 ~/.config/opencode/opencode.json 添加"
    fi
    if [[ "$minimax_key" == "your-minimax-api-key" || "$minimax_key" == "" ]]; then
        echo "  • 您未输入 MiniMax API Key，请编辑 ~/.config/opencode/opencode.json 添加"
    fi
    echo "  • 配置文件位置: ~/.config/opencode/opencode.json"
    echo "  • 用量翻倍活动: 使用 Kimi 模型时自动生效"
    echo ""
}

# 主函数
main() {
    print_header
    
    check_dependencies
    clone_repo
    select_models
    input_api_keys
    generate_config
    install_plugin
    verify_config
    print_finish
}

main "$@"
