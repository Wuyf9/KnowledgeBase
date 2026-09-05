---
date: 2026-09-05
tags:
  - Git
  - Windows
  - 环境配置
  - 故障排查
status: 已恢复正常（用户确认）
---

# Windows Git 安装、配置、升级与问题处理记录

## 本次处理背景与结果

- 环境：Windows，使用 PowerShell。
- 已有知识库记录：此前 SourceTree 使用 Embedded Git，PowerShell 中无法直接执行 `git --version`；当时建议安装独立的 Git for Windows，供终端及其他工具使用。
- 本次讨论整理了 Git 的安装、基础配置、升级和排查方法。
- 2026-09-05 用户确认：“正常了，git能正常使用了”。
- 本次对话没有记录最终使用的安装方式、实际版本号、安装路径或终端输出；以下为可复用步骤，不代表每一条命令都已执行。SourceTree 是否切换到系统 Git、远程推送是否成功，均未单独确认。

关联背景：[[02_Technology/AI/ChatGPT-Codex-Obsidian-GitHub集成]]

## 1. 检查现有安装

打开 PowerShell：

```powershell
git --version
where.exe git
```

- 返回版本号：终端能找到 Git。
- 提示找不到命令：可能未安装独立 Git，或者 PATH 尚未生效。
- 返回多个路径：可能存在多套 Git；需要确认当前工具实际使用哪一套。

SourceTree 能操作仓库，并不代表 PowerShell 一定能使用 Git；内置 Git 可能只供 SourceTree 使用。

## 2. 安装 Git for Windows

以下方式任选一种。

### 官方安装包

1. 打开 [Git 官方 Windows 下载页](https://git-scm.com/install/windows)。
2. 根据电脑架构选择安装包，普通 Intel/AMD 电脑一般选 x64。
3. 运行安装程序，多数选项可保持默认；确保允许命令行和第三方程序使用 Git。
4. 安装完成后关闭并重新打开 PowerShell。
5. 执行 `git --version` 验证。

### winget 安装

```powershell
winget install --id Git.Git -e --source winget
```

如果系统找不到 winget，使用官方安装包即可。

## 3. 设置提交身份

替换示例中的姓名和邮箱：

```powershell
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
git config --global init.defaultBranch main
git config --global --list
```

- 姓名、邮箱用于标记提交作者，不是 GitHub/GitLab 登录凭据。
- `--global` 对当前 Windows 用户生效；单个仓库可以设置自己的配置覆盖它。
- 默认分支设置影响后续新建仓库，不会重命名已有仓库分支。

## 4. 在项目中使用

### 下载已有远程仓库

将占位文字替换为实际仓库地址：

```powershell
git clone 仓库地址
```

### 初始化本地项目

```powershell
cd "D:\你的项目目录"
git init
git status
```

首次提交前，先配置 `.gitignore`，排除密码文件、依赖目录和构建产物，并检查将要提交的内容：

```powershell
git add .
git diff --cached --stat
git diff --cached
git commit -m "初始化项目"
```

完成本地提交不等于已上传 GitHub；上传还需要配置远程仓库并完成认证。

## 5. 升级 Git

关闭正在执行 Git 操作的程序，然后运行：

```powershell
git update-git-for-windows
```

按照提示完成更新。也可以从官网下载新版安装包更新已有安装，通常无须先卸载。

升级完成后重开终端：

```powershell
git --version
where.exe git
```

正常升级会保留仓库和用户配置。若版本未变化，检查是否存在多个安装路径，以及终端或应用是否需要重启。

## 6. 常见故障排查

| 现象 | 检查与处理 |
| --- | --- |
| SourceTree 能用，PowerShell 找不到 Git | 内置 Git 可能未加入系统 PATH；安装可供命令行使用的 Git for Windows |
| 安装后仍找不到 Git | 重开终端和相关应用；检查安装选项及 PATH 是否包含实际 Git 命令目录 |
| 升级后版本未变化 | 用 `where.exe git` 查看多版本路径，确认当前调用的程序 |
| 克隆或推送认证失败 | 检查远程地址、账号权限、令牌或 SSH 配置 |
| 不同工具显示不同版本 | 检查各工具使用的是内置 Git 还是系统 Git |

## 7. 区分三种操作

- **安装或升级 Git**：维护电脑上的版本管理工具。
- **更新项目代码**：通常使用 `git pull`；运行前检查本地改动。
- **部署应用**：还涉及项目构建、运行环境和服务启动，不能仅靠安装 Git 完成。

## 8. SourceTree、Obsidian 与终端统一 Git

状态：2026-09-05「配置系统Git」提出此需求，尚无切换完成回执。以下补充在本篇，避免再建一份安装教程。

1. 用前文的 `where.exe git` 确認实际路径；PowerShell 中不要用 `where git`，它可能解析为筛选命令别名。
2. SourceTree：Tools → Options → Git → Use System Git，核对显示版本和路径后重启。
3. Obsidian Git（桌面）：优先使用 PATH 中的 Git；找不到时在插件的 Custom Git binary path 填实际 `git.exe` 路径，再彻底重启 Obsidian。不要照抄别台电脑的路径。
4. Git 可执行文件和 SSH 客户端分别配置。若终端用 OpenSSH、SourceTree 用 PuTTY/Plink，两者密钥格式、代理进程可能不同；先核对实际客户端，再决定是否统一，不能仅切换 System Git 就宣布 SSH 也一致。
5. 在同一仓库分别执行刷新 / Fetch，确认远程分支可见。安装成功、读取成功、推送成功是三个独立验收项。

### SSH 与 HTTPS 分开排查

先在 Vault 目录执行：

```powershell
git remote -v
git status --short --branch
git config --show-origin --get core.sshCommand
```

- `git@github.com:...` 使用 SSH；`https://github.com/...` 使用 HTTPS 凭据。提交姓名和邮箱不负责远程认证。
- SSH 可执行 `ssh -T git@github.com`，首次连接按 GitHub 官方公钥指纹核验主机；认证成功提示“不提供 shell”是预期行为，退出码不一定为 0。
- 不要覆盖已有私钥。若已有可用密钥，先确认 GitHub 登记的公钥、SSH 配置以及实际选中的身份。
- 本地 Git 凭据和 AI 的 GitHub 连接授权分别验收；一边能用不证明另一边能用。

### 多端同步与冲突处理

开始编辑：先 `git status`，本地有改动时先保存并检查；工作区干净后用 `git pull --ff-only` 更新。出现分叉时先 Fetch、阅读双方差异，再选择合并；不要为了继续同步覆盖本地笔记。

写完：仅暂存本次文件 → 阅读暂存差异 → Commit → Push → 在 GitHub 查看提交。Obsidian 的 Commit 与 Push 是不同步骤。云端 AI 写完后，本机 Pull 才会获得新文件；连接工作流见关联集成笔记。

## 参考资料

- [Git 官方 Windows 安装说明](https://git-scm.com/install/windows)
- [Git for Windows FAQ（包含升级命令）](https://gitforwindows.org/faq.html)

来源：2026-09-05 本次对话，以及知识库中已有的集成方案笔记。完成状态依据用户确认，非本次独立终端测试。

补充来源：[SourceTree 官方切换说明](https://support.atlassian.com/sourcetree/kb/using-embedded-git-or-system-git-in-sourcetree/)、[Obsidian Git 维护者说明](https://github.com/Vinzent03/obsidian-git/blob/master/README.md)。核对日期：2026-09-05。
