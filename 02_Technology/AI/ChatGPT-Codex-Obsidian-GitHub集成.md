# ChatGPT、Codex、Obsidian 与 GitHub 集成方案

## 目标与已验证范围

GitHub 仓库 `Wuyf9/KnowledgeBase` 保存云端版本；Obsidian 编辑本地 Markdown。历史 Vault 路径为 `D:\github\KnowledgeBase`，仅代表当时那台电脑。

2026-09-05「Obsidian对接方案」中，集成笔记提交为 [5bbc4e1](https://github.com/Wuyf9/KnowledgeBase/commit/5bbc4e123927981b753a0762dacb52f4e7a68e98)，随后用户回复“很好，我看到了”。这是 GitHub 直写闭环的依据，不代表所有设备已 Pull 或所有会话都具备写入能力。

2026-09-05 本次整理会话重新读取仓库，确认默认分支 main，连接返回 pull/push 权限。具体写入结果以仓库提交历史为准。当前会话未独立复测本机 Obsidian MCP。

## 两条链路的职责

```text
具备仓库写入工具的 AI 会话 → GitHub → 本机 Pull → Obsidian
本机 Codex → 已加载的 Obsidian MCP → Vault → 本机 Commit + Push → GitHub
```

- GitHub 连接只看到云端已提交的版本；看不到未推送的本地编辑。
- MCP 直接编辑 Vault 后仍需 Git 提交和推送，不能把“文件保存成功”当成“云端同步完成”。
- 手机发起云端整理不依赖本机开机，但手机上的会话是否能写入，取决于当时可用工具及授权。不能用“同一账号、插件未关闭”保证永久连通。
- GitHub Connector / GitHub 插件在不同产品、模式中的能力可能不同。只读连接能检索，不等于能创建提交；开始任务时检查仓库可见性和实际写入工具。
- 桌面 Obsidian Git 使用本地 Git；其移动端实现不同，不把 Windows 的系统 Git 或 SSH 配置照搬到手机。

## GitHub 写入的完整流程

1. 明确仓库、目标分支；读取当前提交、完整目录树和相关笔记。
2. 按主题搜索同义词与错误码；优先扩充原文件，再决定新增。
3. 区分用户确认、日志验证、通用参考和待验证方案；先去除凭据及业务敏感日志。
4. 按关联主题生成一批变更，检查差异、链接与标题。
5. 基于读取时的版本创建提交。更新分支前确认它没有变化；若变化则重新读取并合并。禁止强制覆盖其他设备的新提交。
6. 回读提交和文件，汇报提交链接。用户设备 Pull 后再核对 Obsidian 中内容。

版本管理和冲突操作统一维护于 [[02_Technology/Git/Windows-Git安装配置与升级]]，不在本篇复制安装教程。

## 历史 Obsidian MCP 配置

以下来自旧笔记和「Obsidian对接方案」，是特定插件的历史记录。端口和路径应以当前插件界面实际显示为准。

```toml
[mcp_servers.obsidian]
url = "https://127.0.0.1:27124/mcp/"
bearer_token_env_var = "OBSIDIAN_API_KEY"
```

OpenAI 官方文档支持通过环境变量提供 HTTP MCP 的 bearer token；这不证明第三方服务已启动或本机证书一定可信。[OpenAI MCP 文档](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)

旧记录中的端口组合为 HTTP 27123、HTTPS 27124。旧笔记记载把 HTTP 用到 HTTPS 端口造成 502，改正后成功；本次没有重新还原该故障，不能把所有 502 都归因于协议。

### 连接失败时分层验收

| 层次 | 检查 | 能证明什么 |
| --- | --- | --- |
| 服务 | Obsidian 与对应插件已启动 | 本机服务具备运行前提 |
| 协议与端口 | 按插件显示核对 URL | 排除连错端口或协议 |
| TLS | `curl.exe https://127.0.0.1:27124/`，不跳过证书验证 | 仅证明该 curl 使用的信任链可用 |
| 鉴权 | 环境变量在 Codex 进程可见 | 仍需实际请求确认 token 有效 |
| MCP | 当前会话能列出工具并读取一篇笔记 | MCP 协议、鉴权及工具加载共同可用 |
| GitHub | 回读远程文件和提交 | 云端写入已完成 |

根路径返回 HTTP 成功不等于 MCP 握手成功；curl 与 Codex 的证书信任机制也可能不同。更改环境变量后通常需要重新启动相关进程。

## 维护约定

Token、API Key、密码留在凭据存储或环境变量中。此文只保留变量名。通用排查入口见 [[02_Technology/Network/网络与代理分层排查]]；故障状态见 [[04_Troubleshooting/README]]。

来源：既有集成笔记；历史对话「Obsidian对接方案」（2026-09-05，ID：6a832b30-fd24-83ea-a0fb-a974ae438b8d）；本次 GitHub 只读检查。移动端差异参考 [Obsidian Git 维护者说明](https://github.com/Vinzent03/obsidian-git/blob/master/README.md)。

#AI #ChatGPT #Codex #Obsidian #GitHub #MCP #知识库
