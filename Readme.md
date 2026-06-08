# 🎮 成哥出品 - 热更新服务器

这是《成哥出品》游戏的热更新资源仓库。使用 GitHub Pages 为游戏客户端提供免费、稳定的热更新服务。

## 📦 工作原理

```
游戏启动 → 检查 version.json → 版本不同？ → 下载 update.pck → 自动应用
```

- **主地址**: `https://gaogongcheng.github.io/palace-update/`
- **备用地址**: `https://raw.githubusercontent.com/gaogongcheng/palace-update/main/`

## 🚀 如何发布新版本

### 方法一：使用 GitHub Actions（推荐）

1. 用 Godot 导出 PCK 文件
2. 将 `update.pck` 放到本仓库根目录
3. 修改 `version.json`，更新版本号
4. 推送到 GitHub → 自动部署

### 方法二：手动部署

```bash
# 1. 从 Godot 导出 PCK 文件（资源导出→PCK/Zip）
# 2. 复制到仓库
cp /path/to/game.pck ./update.pck
# 3. 更新版本号
# 编辑 version.json，修改 version 字段
# 4. 提交并推送
git add update.pck version.json
git commit -m "发布 v1.1"
git push
```

### 方法三：使用导出脚本

运行项目中的 `export_update.bat`（Windows）

## 📋 version.json 说明

```json
{
  "version": "1.0",        // 版本号（游戏客户端比较此字段）
  "name": "游戏名称",
  "min_apk_version": 1,    // 最低 APK 版本号
  "url": "",               // 自定义下载地址（留空使用默认地址）
  "description": "更新说明",
  "release_date": "日期",
  "file": "update.pck",
  "filesize": 0            // 文件大小（字节）
}
```

## ⚠️ 重要

- `version.json` 中的版本号必须大于游戏内置版本号才能触发更新
- 确保 `update.pck` 文件已上传到仓库
- GitHub Pages 部署通常需要 1-2 分钟生效

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
