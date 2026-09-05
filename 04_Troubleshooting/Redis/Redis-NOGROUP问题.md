# Redis NOGROUP：Stream 与消费者组初始化

状态：**Redis 阶段已恢复（历史原始日志证明），整个外部推送流程未闭环**。本次未连接用户 Redis 实例，也未执行任何修复命令。

## 故障与恢复证据

2026-08-05「Redis Stream 错误排查」的用户日志显示 XREADGROUP 报 NOGROUP，缺少指定 Stream 或消费者组。

同一对话附件 `log-.txt` 已在本次读取，17:51:21 的记录依次显示 Stream 已存在、消费者组已存在、初始化成功、读取到 10 条新消息。后续又出现外部 HTTP 尝试 10 秒超时。因而只确认 Redis 初始化和读取恢复，不确认 HTTP 推送成功。

附件还出现“重置消费者组到最早位置”。这是历史行为，不作为本篇建议：每次启动重置进度可能重复消费。

## 先诊断

连接实例与 DB 的检查统一见 [[02_Technology/Redis/Redis连接与数据类型排查]]。下列名称为示例：

```redis
EXISTS example:stream
TYPE example:stream
XINFO GROUPS example:stream
```

TYPE 为 none 时 key 不存在；为 stream 才进一步检查组。若类型不同，先排查命名冲突，不删除覆盖已有 key。

常见方向：首次启动未初始化、连错实例或数据库、组名不一致、数据被清理或恢复时未恢复该结构。错误本身不能确定是哪一个原因。

## 确认消费起点后创建

需要处理已有积压消息时：

```redis
XGROUP CREATE example:stream example-consumers 0 MKSTREAM
```

仅消费创建之后的新消息时，以 `$` 替代 `0`。MKSTREAM 在 key 缺失时创建空 Stream；同名组已存在会返回 BUSYGROUP。不要先销毁已有组，也不要重置已有进度来处理这个正常并发初始化结果。[Redis XGROUP CREATE](https://redis.io/docs/latest/commands/xgroup-create/)

应用启动应在消费循环前完成幂等初始化；多个实例同时启动时，仅把确实表示同组已存在的 BUSYGROUP 当作可继续，不能吞掉连接失败、认证失败或 WRONGTYPE。

## 验收并区分下一阶段

- XINFO GROUPS 能查到目标组，应用初始化成功。
- 确认读取了一条约定的测试消息；读取本身会改变消费状态，使用隔离测试数据。
- 业务处理成功后再确认 ACK。进程中断后的 pending 消息需要明确恢复机制；只读取 `>` 不会自动重跑全部历史 pending。
- XACK 不等于删除 Stream 消息；删除、裁剪和其他消费者组的保留需求分别设计。
- 外部 HTTP 返回与业务落库独立验收。超时可能已产生外部效果，重试必须处理幂等。

消息消费恢复后仍有 HTTP 超时，转 [[02_Technology/Network/网络与代理分层排查]]；不要继续重建 Redis 组。

来源：历史对话 ID：6a72ff62-1f30-83ea-ac25-9fe823cfa290；用户故障文本和附件 log-.txt。待补：当时实际采用的代码 / 命令及完整端到端成功回执，不能从恢复日志反推一定执行了本篇示例命令。
