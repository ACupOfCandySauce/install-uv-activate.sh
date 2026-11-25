#!/usr/bin/env bash
set -e

HOOK_FILE="$HOME/.uv-activate.sh"

cat > "$HOOK_FILE" << 'UV_ACTIVATE_EOF'
uv() {
    if [[ "${1:-}" == "activate" ]]; then
        shift
        local target="${1:-.}"
        local activate=""

        if   [[ -f "${target}/.venv/bin/activate" ]];    then activate="${target}/.venv/bin/activate"
        elif [[ -f "${target}/bin/activate" ]];           then activate="${target}/bin/activate"
        elif [[ -f "${target}/.venv/Scripts/activate" ]]; then activate="${target}/.venv/Scripts/activate"
        elif [[ -f "${target}/Scripts/activate" ]];       then activate="${target}/Scripts/activate"
        fi

        if [[ -z "$activate" ]]; then
            echo "未找到虚拟环境：${target}" >&2
            return 1
        fi

        if [[ -n "${VIRTUAL_ENV:-}" ]]; then
            deactivate 2>/dev/null || true
        fi

        source "$activate"
        return 0
    fi

    command uv "$@"
}

alias uva='uv activate'
UV_ACTIVATE_EOF

if ! grep -qF "source $HOOK_FILE" "$HOME/.bashrc"; then
    echo "source $HOOK_FILE" >> "$HOME/.bashrc"
fi

echo "✅ 已注册 uv activate（别名 uva）"
echo "   新开终端或执行 source ~/.bashrc 后生效"