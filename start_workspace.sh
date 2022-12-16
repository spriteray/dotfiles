#!/bin/bash

session_name=$1
project_name=magicserver
window_list="console,bin protocol,protocol fight,scripts/fight simulate,tools/simulator memchk,bin/memchk debug,bin/debug"

# 打开会话
tmux new-session -s $session_name -n editor -d
tmux send-keys -t $session_name 'cd ~/magicserver' C-m

window_id=1
for w in $window_list; do
	name=${w%,*}
	path=${w#*,}
	cmd="cd ~/$project_name/$path"
	window_id=`expr $window_id + 1`
	tmux new-window -n $name -t $session_name
	tmux send-keys -t $session_name:$window_id "$cmd" C-m
	if [ "$name" == "console" ]; then
		# 分割
		tmux split-window -h -p 10 -t $session_name:$window_id
		tmux split-window -v -t $session_name:$window_id.2
		tmux send-keys -t $session_name:$window_id.2 "$cmd" C-m
		tmux send-keys -t $session_name:$window_id.3 "$cmd" C-m
	fi
done

tmux new-window -n admin -t $session_name
tmux new-window -n other -t $session_name

tmux select-window -t $session_name:1

tmux attach -t $session_name -d
