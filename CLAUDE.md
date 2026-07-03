# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目目的

测试用例工作台，承担**两个工作流**：
1. **生成**：给定需求（庄周产品稿、禅道 story、Walle 接口、17work 资料包）→ 输出 Markdown 测试点 + Markdown 测试用例 + XMind 用例文件
2. **补充优化**：给定现有 XMind + 新设计文档 → 保留主框架，只追加缺失测试点

## 新成员 Setup（**第一次 clone 必须执行**）

工作流依赖两个**全局 agent**（`~/.claude/agents/`），必须先安装到本机才能用：

```bash
# 1. 安装全局 agent（幂等，可重复执行）
# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# macOS / Linux (bash)
./scripts/install.sh

# 2. 首次使用需要登录内部 CLI（任选一个触发 OAuth 登录）
npx -y --registry=http://npm.dc.servyou-it.com @servyou-ai/17work-cli@latest login

# 3. 启动 Claude Code，说"生成测试用例"或"补充 XMind"即可触发 agent
```

> agent 升级时只需重新跑 `install.ps1` / `install.sh`，源在 `agents/` 目录。

## Skill 路由表（看到对应 URL/关键词即调用全局 skill）

| 输入 | 全局 skill | 命令 |
|---|---|---|
| `chuangtzu.dc.servyou-it.com` 链接 | `chuangtzu-skill` | `npx -y --registry=http://npm.dc.servyou-it.com @servyou-ai/chuangtzu-cli@latest -u <url> -t md` |
| `zentao.dc.servyou-it.com` 链接 | `zentao-skill` | `node ~/.claude/skills/zentao-skill/scripts/cli.cjs zentao url <url>` |
| `walle.dc.servyou-it.com` 链接 | `walle-skill` | `node ~/.claude/skills/walle-skill/scripts/cli.cjs walle url <url>` |
| `baymax.dc.servyou-it.com` 链接 | `usecase-skill` | `node ~/.claude/skills/usecase-skill/scripts/cli.cjs usecase url <url>` |
| `17work.dc.servyou-it.com` Spec 链接 | `spec-skill` | `npx -y --registry=http://npm.dc.servyou-it.com @servyou-ai/17work-spec-cli@latest spec download --url <url>` |
| `17work.dc.servyou-it.com` 知识库链接（`/read/book/<X>/<id>`） | `forum-skill` | `npx -y --registry=http://npm.dc.servyou-it.com @servyou-ai/17work-cli@latest docs download <postsId> -o .` |
| 庄周 `17boot` 业务项目 | `17boot-skill` | 拉取远端激活说明 + 业务知识 |
| 桌面 `D:\桌面\*.xmind` 模板参考 | `xmind` skill | `python3 ~/.claude/skills/xmind/parse_xmind.py <path>` |
| "生成测试用例" / "出测试点" | `testcase-generator` agent（**全局**） | `~/.claude/agents/testcase-generator.md` |
| 现有 XMind + 新设计文档，"补充"/"完善"/"优化这份 XMind" | `testcase-supplementer` agent（**全局**） | `~/.claude/agents/testcase-supplementer.md` |

**关键原则**：不要用 Playwright 抓取以上平台的页面 — 它们的全局 CLI/skill 已能直接输出结构化内容（JSON/Markdown）。

## Agent 调用入口

按用户意图**派发给对应全局 subagent**（Claude Code 自动按 description 匹配）：

| 用户意图 | Agent | 流程封装 |
|---|---|---|
| 从零生成用例 | `testcase-generator` | 多源拉取 → 整合 → 生成测试点 → 生成测试用例 → `md2xmind.py` → XMind |
| 补充优化现有用例 | `testcase-supplementer` | 解析现有 XMind → 拉新文档 → 识别补充点 → 生成 plan → `xmind-edit.py apply` → 输出 `<原名>-new.xmind` |

- 两个 agent 都定义在 `~/.claude/agents/`（**全局**，任意项目可用）
- 触发关键词：见各 agent 的 `description` 字段

> **关于 subagent 全局化**：`~/.claude/agents/` 下的 agent 在所有项目自动可用；`<项目>/.claude/agents/` 下的仅限当前项目。本项目内 `.trae/agents/` 目录是历史约定，**不是 Claude Code 原生识别路径**，AI 不会自动派活。

### 复用原则（项目硬约束）
- **能复用就复用，能扩展就扩展，减少不必要的新增**：
  - 读 XMind → `scripts/parse_xmind.py`（**不写新读 XMind 的代码**）
  - 拉文档 → 庄周/禅道/Walle/17work/Baymax 全局 skill（**不自己写 HTTP 抓取**）
  - 写/改 XMind → `scripts/xmind-edit.py`（**不自己写 XML**）
  - 全量生成 XMind → `scripts/md2xmind.py`（**不重写转换器**）
- agent 本身**只是"调度 + 推理"层**，不引入新脚本/工具

## 输出文件位置

| 类型 | 路径 | 命名 |
|---|---|---|
| 需求快照（中间产物） | `requests/{需求名称}-{时间戳}/` | 含 `requirement.md`、`chuangtzu/`、`walle/`、`_sources.md` |
| 补充计划 JSON（仅 supplement 场景） | `requests/{需求名称}-{时间戳}/supplement-plan.json` | 由 `testcase-supplementer` 生成 |
| 补充变更报告（仅 supplement 场景） | `requests/{需求名称}-{时间戳}/supplement-changelog.md` | 由 `testcase-supplementer` 生成 |
| 历史测试沉淀（中间产物） | `_history/{关键词}-{日期}.md` | 用户提供 Baymax URL 时生成 |
| 测试点 | `testpoints/{需求名称}-测试点-{序号}.md` | 序号从 1 开始 |
| 测试用例（Markdown） | `testcases/{需求名称}-测试用例-{序号}.md` | 序号与测试点一致 |
| 测试用例（XMind，生成场景） | `xmind/{需求名称}-测试用例-{序号}.xmind` | 由 `scripts/md2xmind.py` 从 Markdown 生成 |
| 测试用例（XMind，补充场景） | `xmind/{原名}-补充-{YYYYMMDD}.xmind` 或 `<原路径>-new.xmind` | 由 `scripts/xmind-edit.py apply` 应用 supplement-plan.json 生成 |

## 格式规范

详见 `.trae/templates/testcase-spec.md`。要点：

**默认风格：画布 2（按业务需求/迭代组织）**——参考 `D:\桌面\202607.xmind` 画布 2 风格。
- H3 业务需求标题以 `【模块名】` 开头
- 用户明确说"按功能模块全量沉淀"时才用画布 1 风格
- 元数据块**强制**：`> 优先级: 高/中/低 | 关联需求: ... | 前置条件: ... | 测试数据: ...`（4 字段全填）

**模块拆分原则**：
- 简单需求：少拆（深度 4-5 层）
- 复杂需求：按需拆（满足任一：多模块/多角色/多平台/多 API → 拆出独立模块）
- 反模式：每个 H4 下仅 1-2 用例（拆太碎）/ 同一功能在多 H4 重复（应合并）

## 测试用例结构硬规则（**生成 + 补充优化都遵循**）

1. **每个被测功能必须有 功能用例 + 接口用例 成对出现**
2. **功能用例的前置条件必须列出接口**——元数据块 `前置条件:` 字段用 `调用的接口:` 子项写明：
   ```
   > 优先级: 高 | 关联需求: REQ_XXX | 前置条件: 调用的接口: /api/itcrmweb/follow/saveFollowRecord、/api/itcrmweb/contact/getNotRelationCallRecord | 测试数据: ...
   ```
3. **接口用例不区分新增/修改**——标题用 `校验 {接口名} 接口`，**不写**"本期新增/改造"等时间标记
4. **新增接口的 URL 本身是一条优先级 3 用例**——形式 `查询 {完整URL}`，仅用于反查接口所属模块归属，无实际业务含义
   - **这条用例必须带 4 字段元数据 + priority-3 marker**——是"补充场景不强制加元数据"风格的唯一例外

**6 级 Markdown 标题层级**（XMind 兼容性硬性要求）：
```
H1 Sheet 标题（系统/产品名）
H2 迭代/产品名
H3 业务需求（【模块名】开头）
H4 涉及模块
H5 功能点（必带元数据块）
H6 预期结果
```

**命名**：测试点与测试用例的 `{需求名称}-{序号}` 必须一一对应。

## 工具脚本

| 脚本 | 用途 | 依赖 |
|---|---|---|
| `scripts/md2xmind.py` | Markdown → XMind 全量转换（生成场景） | Python 3.8+（无第三方依赖） |
| `scripts/xmind-edit.py` | XMind 增量编辑（增/删/改 节点，**统一脚本**） | Python 3.8+（无第三方依赖） |
| `scripts/build-on-demand-index.py` | 按需建反向索引（关键词 → 全部相关文档） | Python 3.8+ |
| `scripts/sync-knowledge.ps1` | 17work 知识库同步到本地 | PowerShell + Node.js (npx) |

### `scripts/xmind-edit.py` 子命令

| 子命令 | 用途 | 典型场景 |
|---|---|---|
| `add` | 在父节点下添加子节点 | 补充单个遗漏测试点 |
| `remove` | 删除指定节点 | 删除已废弃/重复节点 |
| `apply` | 按 JSON 计划批量应用增/删/改 | **核心**：配合 `testcase-supplementer` agent 输出补充计划 |
| `set-notes` | 更新节点 notes（4 字段元数据） | 补全/修正元数据 |
| `set-marker` | 更新节点优先级 marker | 调整优先级 |

**默认行为**：输出 `<原名>-new.xmind`，不覆盖原文件；加 `--in-place` 原地修改。

**JSON 计划格式**（`apply` 用）：
```json
{
  "operations": [
    {"op": "add", "parent": "...", "child": "...", "level": 5, "notes": "...", "marker": "priority-1"},
    {"op": "remove", "title": "...", "parent": "..."},
    {"op": "set-notes", "title": "...", "notes": "..."},
    {"op": "set-marker", "title": "...", "marker": "priority-2"}
  ]
}
```

详细见 `python scripts/xmind-edit.py <subcommand> --help`。

## 归档说明

⚠️ **`.trae/rules/` 下的 4 份旧规则文件已废弃**，仅作历史归档保留。**请勿使用**，全部内容已被以下文件取代：

| 旧文件 | 替代为 |
|---|---|
| `.trae/rules/测试用例生成整体流程规则.md` | `~/.claude/agents/testcase-generator.md`（全局 subagent） |
| `.trae/rules/生成测试点规则.md` | `.trae/templates/testcase-spec.md`（测试点章节） |
| `.trae/rules/基于测试点生成测试用例规则.md` | `.trae/templates/testcase-spec.md`（测试用例章节） |
| `.trae/rules/测试用例设计.md` | `.trae/templates/testcase-spec.md` |
| `.trae/agents/testcase-generator.md`（项目内约定版） | `~/.claude/agents/testcase-generator.md`（全局原生 subagent） |
