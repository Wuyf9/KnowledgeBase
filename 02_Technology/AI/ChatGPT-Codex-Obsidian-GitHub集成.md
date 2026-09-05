# ChatGPT、Codex、Obsidian 与 GitHub 集成方案

## 目标

建立一套跨设备、可持续维护的个人技术知识库，让 Windows、iPad、手机和其他电脑都能访问同一份笔记，同时让 ChatGPT 和 Codex 能参与知识整理、写入和维护。

## 最终架构

```text
                        GitHub
                   Wuyf9/KnowledgeBase
                         ↑      ↓
                         Git 同步
                         ↑      ↓
                    Obsidian Vault
                         ↑
              Local REST API with MCP
                         ↑
                      Codex Desktop

ChatGPT
   ↓
GitHub Connector
   ↓
Wuyf9/KnowledgeBase
```

## 各组件职责

### Obsidian

作为本地知识库编辑器，Vault 位于：

```text
D:\github\KnowledgeBase
```

主要用于：

- 阅读和编辑 Markdown 笔记
- 使用双链、标签和模板
- 通过 Obsidian Git 与 GitHub 同步

### GitHub

作为知识库的云端中心和版本历史来源。

作用：

- 多终端同步
- Git 历史记录
- 统一保存 AI 和人工修改
- 为 ChatGPT 提供远程访问入口

仓库：

```text
Wuyf9/KnowledgeBase
```

### Codex Desktop

Codex 通过 Obsidian 的本地 MCP 服务直接读写 Vault。

使用的插件：

```text
Local REST API with MCP
```

最终 MCP 配置：

```toml
[mcp_servers.obsidian]
url = "https://127.0.0.1:27124/mcp/"
bearer_token_env_var = "OBSIDIAN_API_KEY"
```

API Key 不直接写入配置文件，而是保存在 Windows 用户环境变量：

```text
OBSIDIAN_API_KEY
```

### ChatGPT

ChatGPT 不直接访问本机 `127.0.0.1`，而是通过 GitHub Connector 访问知识库。

因此 ChatGPT 可以在任意设备上：

- 读取知识库
- 搜索已有笔记
- 分析项目进度
- 创建或修改 Markdown 文件
- 将聊天总结直接提交到 GitHub

## Obsidian MCP 端口规则

插件提供两组地址：

```text
HTTP  : http://127.0.0.1:27123/mcp/
HTTPS : https://127.0.0.1:27124/mcp/
```

需要特别注意协议和端口必须匹配：

```text
http  + 27123  ✅
https + 27124  ✅
http  + 27124  ❌
https + 27123  ❌
```

曾出现 Codex 返回 502，最终定位为配置成了：

```text
http://127.0.0.1:27124/mcp/
```

即使用 HTTP 协议访问 HTTPS 端口。

修正为：

```text
https://127.0.0.1:27124/mcp/
```

后连接成功。

## HTTPS 证书配置

Obsidian Local REST API 使用本地生成的 CA 证书。

证书导入 Windows 后，可通过以下命令验证：

```powershell
curl.exe https://127.0.0.1:27124/
```

如果不使用 `-k` 也能正常返回服务状态，说明 Windows 已经信任证书。

## Git 与 SourceTree

此前 SourceTree 使用 Embedded Git，导致 PowerShell 中无法直接执行：

```powershell
git --version
```

后续建议安装系统级 Git for Windows，让以下工具统一使用同一套 Git：

```text
PowerShell
SourceTree
VS Code
Obsidian Git
```

2026-09-05 状态更新：用户已确认 Git 恢复正常使用。安装、配置、升级和排查步骤已整理到 [[02_Technology/Git/Windows-Git安装配置与升级]]。本次未记录实际安装方式和版本号，也未单独确认 SourceTree 是否已切换到系统 Git。

## GitHub Connector

ChatGPT 已连接 GitHub Connector，并确认能够访问：

```text
Wuyf9/KnowledgeBase
```

当前能力包括：

- 读取仓库文件
- 搜索知识库
- 查看提交记录
- 创建 Markdown
- 更新 Markdown
- 提交 Git 变更

这意味着只要使用同一个 ChatGPT 账号，并保持 GitHub Connector 授权有效，就可以在 Windows、浏览器、iPad、手机等不同终端通过 ChatGPT 操作同一个知识库。

## 推荐工作流

### 使用 ChatGPT 时

```text
讨论技术问题
   ↓
让 ChatGPT 整理总结
   ↓
直接提交到 GitHub KnowledgeBase
   ↓
Obsidian Git Pull
   ↓
本地 Obsidian 更新
```

### 使用 Codex 时

```text
Codex
   ↓ MCP
Obsidian Vault
   ↓ Git
GitHub
```

## 同步原则

为了减少多端冲突：

1. 开始编辑前先 Pull
2. 编辑完成后尽快 Commit + Push
3. 避免多个设备同时修改同一篇笔记
4. AI 写入前优先检查是否已有同主题笔记
5. API Key、Token、密码等敏感信息禁止提交到 GitHub

## 当前结论

最终形成双通道但不冲突的架构：

```text
ChatGPT → GitHub → Obsidian
Codex   → MCP    → Obsidian → GitHub
```

GitHub 作为云端统一知识库，Obsidian 作为本地编辑器，ChatGPT 负责远程整理和写入，Codex 负责本机直接读写 Vault。

#AI #ChatGPT #Codex #Obsidian #GitHub #MCP #知识库
