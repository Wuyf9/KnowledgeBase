# 故障案例库

按错误特征进入主文档。这里只保存索引和证据状态，不复制排查正文；“已给方案”不等于“已修复”。

| 现象 | 状态 | 唯一入口 |
| --- | --- | --- |
| Windows 终端找不到 Git | 用户确认 Git 恢复；具体安装版本与 SourceTree 切换未单独确认 | [[02_Technology/Git/Windows-Git安装配置与升级]] |
| GitHub 笔记直写与本地同步 | 历史提交后用户确认看到了；各设备 Pull 未逐一验收 | [[02_Technology/AI/ChatGPT-Codex-Obsidian-GitHub集成]] |
| Obsidian MCP 返回 502 | 旧文档记载协议修正后恢复；本轮未复测 | [[02_Technology/AI/ChatGPT-Codex-Obsidian-GitHub集成]] |
| Linux 服务启动、状态与日志 | 通用排查，无特定故障闭环声明 | [[04_Troubleshooting/Linux/systemd服务管理]] |
| TCP 未连接但 Ping 成功 | 重复日志已证实；重构跨平台验收待补 | [[04_Troubleshooting/TCP/TCP断线重连]] |
| Redis NOGROUP | 原始日志证明初始化与读取恢复；下游 HTTP 尚超时 | [[04_Troubleshooting/Redis/Redis-NOGROUP问题]] |
| Redis LLEN 等待响应超时 | 原始错误已提供；根因与修复待补 | [[02_Technology/Redis/Redis连接与数据类型排查]] |
| MySQL 认证中读取流失败 / 10053 | 原始错误已提供；TLS 等属于待验证方向 | [[02_Technology/MySQL/MySQL与EF-Core连接及数据操作]] |
| 海康 JPEG 无温度 / 预览叠加消失 | 通道 XML 已核对；最终修复未确认 | [[03_Hardware/Hikvision/码流抓图与测温排查]] |

新增案例使用 [[07_Templates/Problem]]。同一错误在同一主文档增加“案例差异”，只有根因、环境边界或处理方法明显不同才独立成篇。

收录和去重规则见 [[知识库维护说明]]；通用网络入口见 [[02_Technology/Network/网络与代理分层排查]]。
