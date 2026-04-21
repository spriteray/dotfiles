#!/bin/bash
# ==============================================================================
# tmux-launch.sh  —  tmux workspace launcher
#
# 用法:
#   tmux-launch.sh [config_file]
#   tmux-launch.sh workspace.conf
#
# 若不传参数，默认读取 ~/.config/tmux/workspace.conf
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
    W_NAME=$(echo "$raw" | cut -d'|' -f1 | xargs)
    W_PATH=$(echo "$raw" | cut -d'|' -f2 | xargs)
    L_INFO=$(echo "$raw" | cut -d'|' -f3 | xargs)
    TARGET_PATH=$(eval echo "$W_PATH")

    # 创建/重命名窗口，之后该窗口自动成为 active
    if [[ $i -eq 0 ]]; then
        tmux rename-window -t "$SESSION_NAME" "$W_NAME"
    else
        tmux new-window -n "$W_NAME" -t "$SESSION_NAME" -c "$TARGET_PATH"
    fi

    # 读取刚创建窗口的真实 index（唯一用到数字的地方）
    W_IDX=$(tmux display-message -t "$SESSION_NAME" -p '#{window_index}')
    WIN="$SESSION_NAME:$W_IDX"

    # cd 到目标路径
    tmux send-keys -t "$WIN" "cd '${TARGET_PATH}' && clear" C-m

    # ── 布局处理（split 不指定 pane，始终对 active pane 操作）──────────────
    case "$L_INFO" in
        none) ;;

        cmd:*)
            tmux send-keys -t "$WIN" "${L_INFO#cmd:}" C-m
            ;;

        # triple:H%:V%:command
        # ┌──────────┬──────────┐
        # │          │  [active]│ ← split-h 后右侧成为 active，执行 RUN
        # │          ├──────────┤
        # │          │          │ ← split-v 后右下成为 active
        # └──────────┴──────────┘
        triple:*)
            IFS=':' read -r _ H V RUN <<< "$L_INFO"
            # 当前 active = 左侧 pane；水平分割，右侧成为新 active
            tmux split-window -h -l "${H}%" -t "$WIN" -c "$TARGET_PATH"
            # 当前 active = 右上 pane；垂直分割，右下成为新 active
            tmux split-window -v -l "${V}%" -t "$WIN" -c "$TARGET_PATH"
            # 在右上执行命令：选回右上（上一个 pane）
            tmux select-pane -t "$WIN.{top-right}"
            [[ -n "$RUN" ]] && tmux send-keys -t "$WIN.{top-right}" "$RUN" C-m
            # 焦点回左侧
            tmux select-pane -t "$WIN.{left}"
            ;;

        # hsplit:H%:left_cmd:right_cmd
        hsplit:*)
            IFS=':' read -r _ H LEFT_CMD RIGHT_CMD <<< "$L_INFO"
            # 水平分割，右侧成为新 active
            tmux split-window -h -l "${H}%" -t "$WIN" -c "$TARGET_PATH"
            [[ -n "$RIGHT_CMD" ]] && tmux send-keys -t "$WIN.{right}" "$RIGHT_CMD" C-m
            tmux select-pane -t "$WIN.{left}"
            [[ -n "$LEFT_CMD"  ]] && tmux send-keys -t "$WIN.{left}"  "$LEFT_CMD"  C-m
            ;;

        *)
            echo "[WARN] 未知布局: '$L_INFO'，窗口 '$W_NAME' 跳过"
            ;;
    esac
done

# 6. 聚焦第一个窗口
FIRST_WIN=$(echo "${WINDOWS_CONFIG[0]}" | cut -d'|' -f1 | xargs)
tmux select-window -t "$SESSION_NAME:$FIRST_WIN"
exec tmux attach-session -t "$SESSION_NAME"

