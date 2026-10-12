#!/usr/bin/env bash
# 一键把本项目推送到 GitHub。
# 用法:
#   1) 先设置你的 token（不要提交这个文件里的 token）:
#        export GH_TOKEN=ghp_xxxxxxxxxxxx
#   2) 然后运行:
#        bash push-to-github.sh <你的GitHub用户名> [仓库名]
#
# 依赖: curl, git

set -euo pipefail

OWNER="${1:?用法: bash push-to-github.sh <GitHub用户名> [仓库名]}"
REPO="${2:-sunzi-bingfa-skill}"
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"

if [ -z "$TOKEN" ]; then
  echo "错误: 请先 export GH_TOKEN=你的GitHub Personal Access Token" >&2
  echo "生成地址: https://github.com/settings/tokens (需要 repo 权限)" >&2
  exit 1
fi

cd "$(dirname "$0")"

echo "==> 在 GitHub 上创建仓库 $OWNER/$REPO ..."
CREATE_CODE=$(curl -s -o /tmp/gh_create.json -w "%{http_code}" \
  -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO\",\"description\":\"把《孙子兵法》十三篇做成 Agent Skill\",\"private\":false,\"auto_init\":false}")

if [ "$CREATE_CODE" = "201" ]; then
  echo "    仓库创建成功"
elif [ "$CREATE_CODE" = "422" ]; then
  echo "    仓库已存在，继续推送"
else
  echo "    创建失败 (HTTP $CREATE_CODE):"; cat /tmp/gh_create.json; exit 1
fi

echo "==> 配置远程并推送 ..."
git remote remove origin 2>/dev/null || true
git remote add origin "https://oauth2:${TOKEN}@github.com/${OWNER}/${REPO}.git"
git branch -M main
git push -u origin main

echo
echo "完成! 仓库地址: https://github.com/${OWNER}/${REPO}"
