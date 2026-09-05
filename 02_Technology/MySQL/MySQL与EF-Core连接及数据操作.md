# MySQL / EF Core 连接、生命周期与数据操作

状态：MySQL 握手异常有历史日志；修复未闭环。EF Core、SQL 部分为通用参考，未宣称在用户数据库执行。

## 先辨认驱动与阶段

记录 MySQL 服务端版本、.NET 版本、驱动名称版本、EF Provider 版本和实际连接目标。MySql.Data 与 MySqlConnector 是不同驱动，连接参数、行为与 EF Provider 依赖不能随意混用。

排查顺序：目标和端口 → TCP → TLS / 身份认证 → 数据库权限 → SQL 执行。网络层见 [[02_Technology/Network/网络与代理分层排查]]。

## 案例：认证阶段读取流失败

2026-07-30「MySQL 连接问题分析」提供：

```text
MySql.Data.MySqlClient.MySqlException
Authentication ... mysql_native_password ...
Reading from the stream has failed
SocketException (10053)
SslStream
```

可确认认证期间出现传输读取失败，堆栈涉及 TLS；不能仅凭这些字段判定密码错误、TLS 不兼容或连接池是最终根因。

1. 对照同一时段数据库错误日志、重启记录和主机网络事件。
2. 用相同主机、端口、账号进行独立连接测试，并保持可比较的 TLS 策略。CLI 成功只缩小范围，不证明应用连接选项相同。
3. 核对驱动与认证插件兼容性、证书名称及信任链。
4. 一次仅改变一个变量，例如连接池设置；如果同时关闭 TLS 和连接池，就无法知道是哪项改变产生作用。
5. 历史回答的关闭 TLS 只能视为受控诊断思路，不保存为生产默认连接串。优先修复受支持的 TLS 配置，也不盲目切换认证插件。

待补：最终驱动 / 服务端版本、对照测试和恢复日志。

## EF Core 生命周期与 AutoDetect

DbContext 是短生命周期工作单元，不支持多个并发操作共享一个实例。每次异步操作及时 await；并行任务分别创建 context / 作用域。[EF Core DbContext](https://learn.microsoft.com/en-us/ef/core/dbcontext-configuration/)

Web 中一般按请求作用域；后台任务的作用域由 [[02_Technology/DotNet/后端配置与生命周期]] 管理。需要独立单元可采用 IDbContextFactory，谁创建谁按规则释放。

Pomelo 支持显式提供 MySqlServerVersion / MariaDbServerVersion 或 ServerVersion.AutoDetect。AutoDetect 需要访问数据库；服务器不可达会影响该初始化路径。显式版本可以避免这一探测，但不会修复实际连接故障，版本也不能凭空填写。Provider 与 EF Core 主版本按兼容矩阵匹配。[Pomelo 配置](https://github.com/PomeloFoundation/Pomelo.EntityFrameworkCore.MySql#3-services-configuration)

## SQL 修改与分页

修改前用相同条件 SELECT，核对记录数、主键及影响范围。使用参数化查询，不拼接用户输入。以下只演示支持事务的表上的单会话操作，表名字段均为占位示例：

```sql
START TRANSACTION;
SELECT id, enabled FROM example_items WHERE id = 123 FOR UPDATE;
UPDATE example_items SET enabled = 1 WHERE id = 123;
SELECT ROW_COUNT();
SELECT id, enabled FROM example_items WHERE id = 123;
ROLLBACK;
```

示例最后回滚；真实修改核对结果后才选择提交。回滚能力取决于存储引擎和操作类型，DDL 可能触发隐式提交；不要套用此模板认为任何修改都能撤销。DELETE 同样需要精确条件及备份，不能只因为语法正确就批量执行。

分页必须稳定排序，排序列有重复时增加唯一键作为次序。深分页性能先看执行计划、索引和扫描量；不要直接把分表作为连接异常或所有慢查询的解决办法。

来源：「MySQL 连接问题分析」（ID：6a6b21d1-c830-83ea-ade9-542ca2f50cc2）；其后续图片路径讨论未合并到数据库故障。SQL 与 EF 为本轮通用知识整理。
