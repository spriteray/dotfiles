#!/bin/bash

# ==========================================
# 1. 配置区
# ==========================================
SESSION_NAME=${1:-"workspace"}
PROJECT_NAME=${2:-"SpaceRelayBuilder"}
PROJECT_ROOT="$HOME/$PROJECT_NAME"

VIRTUAL_X=256
VIRTUAL_Y=80

# 统一配置数组 (窗口名 | 路径 | 布局)
WINDOWS_CONFIG=(
    "editor   | .               | cmd:vim"
    "console  | bin             | triple:30:30:./top.sh"
    "admin    | .               | none"
    "other1   | .               | none"
    "other2   | .               | none"
    "other3   | .               | none"
    "other4   | .               | none"
)

# ==========================================
# 2. 逻辑区
# ==========================================

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# 创建后台会话
tmux new-session -d -x $VIRTUAL_X -y $VIRTUAL_Y -s "$SESSION_NAME" -c "$PROJECT_ROOT"

# 获取 base-index (适配用户的 tmux.conf 设置)
# 这样即使你设置了从 1 开始，脚本也能准确找到第一个窗口
BASE_IDX=$(tmux show-options -gv base-index)
BASE_IDX=${BASE_IDX:-0}

for i in "${!WINDOWS_CONFIG[@]}"; do
    IFS='|' read -r name path layout_info <<< "${WINDOWS_CONFIG[$i]}"
    W_NAME=$(echo "$name" | xargs)
    W_PATH=$(echo "$path" | xargs)
    L_INFO=$(echo "$layout_info" | xargs)
    TARGET_PATH="$PROJECT_ROOT/$W_PATH"

    # 当前窗口的 ID
    CURR_IDX=$((BASE_IDX + i))

    # 第一个元素重命名，后面的元素新建
    if [ $i -eq 0 ]; then
        tmux rename-window -t "$SESSION_NAME:$BASE_IDX" "$W_NAME"
    else
        tmux new-window -n "$W_NAME" -t "$SESSION_NAME" -c "$TARGET_PATH"
    fi

    # 布局逻辑处理
    case "$L_INFO" in
        cmd:*)
            tmux send-keys -t "$SESSION_NAME:$CURR_IDX" "${L_INFO#cmd:}" C-m ;;
        triple:*)
            IFS=':' read -r _ H V RUN <<< "$L_INFO"
            # 使用 -l % 兼容 Tmux 3.4
            tmux split-window -h -l "${H}%" -t "$SESSION_NAME:$CURR_IDX" -c "$TARGET_PATH"
            tmux split-window -v -l "${V}%" -t "$SESSION_NAME:$CURR_IDX.2" -c "$TARGET_PATH"
            [ -n "$RUN" ] && tmux send-keys -t "$SESSION_NAME:$CURR_IDX.2" "$RUN" C-m
            ;;
    esac
done

# --- 动态聚焦 ---
tmux select-window -t "$SESSION_NAME:^"  # 序号最小的窗口
tmux select-pane -t "$SESSION_NAME:^.0" # 该窗口第一个面板
tmux attach-session -t "$SESSION_NAME"
