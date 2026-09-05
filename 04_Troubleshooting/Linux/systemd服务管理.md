# systemd 服务管理与日志排查

状态：通用参考，来自高频问答；本次未在目标 Linux 主机执行。适用于使用 systemd 的发行版，实际单元名先确认。

## 先定位，再重启

把 `example.service` 替换为真实单元名：

```bash
systemctl list-unit-files --type=service
sudo systemctl status example.service --no-pager -l
sudo systemctl cat example.service
sudo journalctl -u example.service -n 100 --no-pager -o short-iso
sudo journalctl -u example.service --since "1 hour ago" --no-pager
sudo journalctl -u example.service -f
```

先保留故障时段日志，再修改配置；`-f` 为实时跟踪，Ctrl+C 只结束查看。journal 中没有业务日志时，检查应用是否写文件、日志级别及保留策略。

## 常用动作与边界

| 命令 | 作用 |
| --- | --- |
| `sudo systemctl start example.service` | 本次启动 |
| `sudo systemctl stop example.service` | 停止 |
| `sudo systemctl restart example.service` | 停止后重启，有短暂中断 |
| `sudo systemctl enable example.service` | 设置开机启动，本身不立即启动 |
| `sudo systemctl enable --now example.service` | 开机启动并立即启动 |
| `sudo systemctl disable example.service` | 取消开机启动，本身不停止 |
| `sudo systemctl daemon-reload` | 修改 unit 后让 systemd 重读定义，不会自动重启应用 |

应用自身配置修改是否支持热更新，由应用决定；不能用 daemon-reload 代替应用重启。

## 启动失败的排查顺序

1. `systemctl cat` 查看实际加载的文件和覆盖配置，确认 ExecStart、User、WorkingDirectory。
2. 确認可执行文件存在、运行账户能读取配置并写入必要的数据目录。需要逐级目录的访问权限，不能只检查文件本身。
3. 检查解释器、运行时、CPU 架构与脚本换行。脚本用 LF，按需给执行权限，不把 `chmod 777` 作为修复默认值。
4. 若报地址无效或端口占用，转 [[02_Technology/Network/网络与代理分层排查]]。
5. 服务 active 后继续验收健康接口、依赖和一次实际业务操作。active 只表示进程层状态，不保证业务成功。
6. 修改 unit 后执行 daemon-reload、restart，再回看日志。持续重启时先查首个异常，不用无限重试掩盖原因。

## 与部署和定时任务的关系

本篇统一维护服务命令；unit 模板、发布与回滚见 [[02_Technology/Deployment/服务部署与脚本维护]]。定时执行身份、环境和日志见 [[02_Technology/Linux/定时任务与权限]]。

来源：历史对话「查看Linux服务日志」（ID：6a72a886-38e8-83ea-b414-db820a2da32a）。命令规范参考 systemd 的本机 `man systemctl`、`man journalctl`；[systemd 源码与手册](https://github.com/systemd/systemd/tree/main/man)。
