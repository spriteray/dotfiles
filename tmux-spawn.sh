#!/bin/bash
# ==============================================================================
# tmux-spawn.sh  —  tmux workspace launcher
#
# 用法:
#   tmux-spawn.sh [config_file]
#   tmux-spawn.sh workspace.conf
#
# 若不传参数，默认读取 ~/.config/tmux/workspace.conf
#
# 配置格式:
#   窗口名 | 路径 | pane1命令 | h:尺寸%:pane2命令 | v:尺寸%:pane3命令 | ...
#
#   - 第3列：第一个 pane 的命令（可为空）
#   - 第4列起：h 或 v 开头，表示从当前 active pane 水平/垂直分割
#   - 尺寸是新 pane 占父 pane 的百分比
#
# 示例:
#   editor  | ~/proj        | vim
#   console | ~/proj/bin    |              | h:30: | v:50:./top.sh
#   monitor | ~/proj        | htop         | h:40:./log.sh
#   empty   | ~/proj        |
# ==============================================================================

# 1. 定位配置文件
DEFAULT_CONF="$HOME/.config/tmux/workspace.conf"
CONF_FILE="${1:-$DEFAULT_CONF}"

if [[ ! -f "$CONF_FILE" ]]; then
    echo "[ERROR] 配置文件不存在: $CONF_FILE"
    exit 1
fi

# 2. 解析配置文件
SESSION_NAME=$(basename "$CONF_FILE")
SESSION_NAME="${SESSION_NAME%.*}"

declare -a WINDOWS_CONFIG=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ \| ]] && WINDOWS_CONFIG+=("$line")
done < "$CONF_FILE"

if [[ ${#WINDOWS_CONFIG[@]} -eq 0 ]]; then
    echo "[ERROR] 配置文件中没有窗口配置"
    exit 1
fi

# 3. 若会话已存在则直接 attach
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "[INFO] 会话 '$SESSION_NAME' 已存在，直接 attach"
    exec tmux attach-session -t "$SESSION_NAME"
fi

VIRTUAL_X=${TMUX_VIRTUAL_X:-220}
VIRTUAL_Y=${TMUX_VIRTUAL_Y:-50}

# 4. 创建后台会话
tmux new-session -d -x "$VIRTUAL_X" -y "$VIRTUAL_Y" -s "$SESSION_NAME" -c "$HOME"

# 5. 创建各窗口
for i in "${!WINDOWS_CONFIG[@]}"; do
    raw="${WINDOWS_CONFIG[$i]}"

    # 用 IFS 按 | 拆成数组，支持任意列数
    IFS='|' read -ra COLS <<< "$raw"

    W_NAME=$(echo "${COLS[0]:-}" | xargs)
    W_PATH=$(echo "${COLS[1]:-}" | xargs)
    TARGET_PATH=$(eval echo "$W_PATH")

    # 创建/重命名窗口
    if [[ $i -eq 0 ]]; then
        tmux rename-window -t "$SESSION_NAME" "$W_NAME"
    else
        tmux new-window -n "$W_NAME" -t "$SESSION_NAME" -c "$TARGET_PATH"
    fi

    # 读取该窗口实际 index
    W_IDX=$(tmux display-message -t "$SESSION_NAME" -p '#{window_index}')
    WIN="$SESSION_NAME:$W_IDX"

    # cd 到目标路径
    tmux send-keys -t "$WIN" "cd '${TARGET_PATH}' && clear" C-m

    # 第3列：第一个 pane 的命令
    PANE1_CMD=$(echo "${COLS[2]:-}" | xargs)
    [[ -n "$PANE1_CMD" ]] && tmux send-keys -t "$WIN" "$PANE1_CMD" C-m

    # 第4列起：逐个 pane 分割
    for col_idx in $(seq 3 $((${#COLS[@]} - 1))); do
        PANE_DEF=$(echo "${COLS[$col_idx]}" | xargs)
        [[ -z "$PANE_DEF" ]] && continue

        # 格式: h:尺寸:命令  或  v:尺寸:命令  （命令可为空）
        DIRECTION=$(echo "$PANE_DEF" | cut -d':' -f1)
        SIZE=$(echo      "$PANE_DEF" | cut -d':' -f2)
        CMD=$(echo       "$PANE_DEF" | cut -d':' -f3-)

        if [[ "$DIRECTION" == "h" ]]; then
            tmux split-window -h -l "${SIZE}%" -t "$WIN" -c "$TARGET_PATH"
        elif [[ "$DIRECTION" == "v" ]]; then
            tmux split-window -v -l "${SIZE}%" -t "$WIN" -c "$TARGET_PATH"
        else
            echo "[WARN] 窗口 '$W_NAME': 未知分割方向 '$DIRECTION'，跳过此 pane"
            continue
        fi

        # 新 pane 自动成为 active，直接发送命令
        CMD=$(echo "$CMD" | xargs)
        if [[ -n "$CMD" ]]; then
            tmux send-keys -t "$WIN" "cd '${TARGET_PATH}' && clear && $CMD" C-m
        else
            tmux send-keys -t "$WIN" "cd '${TARGET_PATH}' && clear" C-m
        fi
    done

    # 焦点回该窗口第一个 pane
    tmux select-pane -t "$WIN.{top-left}"
done

# 6. 聚焦第一个窗口
FIRST_WIN=$(echo "${WINDOWS_CONFIG[0]}" | cut -d'|' -f1 | xargs)
tmux select-window -t "$SESSION_NAME:$FIRST_WIN"
exec tmux attach-session -t "$SESSION_NAME"

