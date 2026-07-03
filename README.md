# Testcase Generator

从庄周产品稿、禅道需求、Walle 接口、17work 资料包等生成测试点和测试用例，输出 Markdown + XMind 双格式。

## 新成员 Setup

**第一次使用**必须先安装全局 agent 到本机：

```bash
# 克隆仓库
git clone <repo-url> testcase
cd testcase

# 安装全局 agent（幂等可重复）
# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
# macOS / Linux
./scripts/install.sh

# 触发内部 CLI 的 OAuth 登录（任选一个）
npx -y --registry=http://npm.dc.servyou-it.com @servyou-ai/17work-cli@latest login
```

完成后启动 Claude Code，说"生成测试用例"或"补充 XMind"即可触发对应 agent。

## 快速使用

直接告诉 Claude 你想做什么，例如：

> "基于禅道 story 247369 + 这个庄周地址生成测试用例"
> "解析这个庄周产品稿 URL，出测试点"
> "看这几个 Walle 接口，帮我做测试点"
> "根据这几份文档补这份 XMind"

Claude 会按 `agents/testcase-generator.md` / `agents/testcase-supplementer.md` 工作流自动完成。

## 工作流

```
用户输入（URL/需求名/关键词）
   ↓
按 CLAUDE.md 路由表调用对应全局 skill 拉取内容
   ↓
庄周 → chuangtzu-skill（CLI 输出 md）
禅道 → zentao-skill（CLI 输出需求正文）
Walle → walle-skill（CLI 输出接口文档）
17work Spec → spec-skill（批量下载资料包）
17work 知识库 → forum-skill
历史用例 → usecase-skill（用户提供 URL 时才用）
   ↓
整合到 requests/{name}-{时间戳}/
   ↓
按 .trae/templates/testcase-spec.md 规范生成
   ├── testpoints/{name}-测试点-{n}.md
   └── testcases/{name}-测试用例-{n}.md
   ↓
python scripts/md2xmind.py 转换为
   └── xmind/{name}-测试用例-{n}.xmind
```

## 目录说明

| 目录 | 用途 | 是否提交 |
|---|---|---|
| `.trae/agents/` | 项目内约定（已废弃，全局版在 `~/.claude/agents/`） | 是（仅废弃说明） |
| `.trae/templates/` | 格式规范（testcase-spec） | 是 |
| `requests/` | 需求快照（拉取的多源原始内容） | 否（可加 `.gitignore`） |
| `_history/` | 历史测试沉淀 | 否 |
| `testpoints/` | 测试点 Markdown | 是 |
| `testcases/` | 测试用例 Markdown | 是 |
| `xmind/` | 测试用例 XMind | 是 |
| `scripts/` | 工具脚本 | 是 |

## 用例格式示例（默认：画布 2 风格）

测试用例 Markdown 严格 6 级标题，**默认按业务需求/迭代组织**（参考 `D:\桌面\202607.xmind` 画布 2 风格）：

```markdown
# 运营平台                              ← Sheet 标题（系统/产品名）

## 20260702-迭代                         ← 迭代名

### 【转介绍】业务员在写跟进页面接入...    ← 业务需求（【模块名】开头）
#### 新增转介绍组件                       ← 涉及功能模块
##### 关系类型切换功能                    ← 功能点
##### 默认选中"介绍了新客户"              ← 用例标题
> 优先级: 高 | 关联需求: REQ_20260702_001 | 前置条件: 业务员进入写跟进页面 | 测试数据: 无
###### 预期结果
- "介绍了新客户"选项处于选中状态
- "被老客户介绍"选项处于未选中状态
- 组件正常加载
```

**关键规则**：
- H3 业务需求标题以 `【模块名】` 开头
- 每个 H5 用例场景后**必须**带元数据块（4 个字段全填）
- 模块拆分粒度：简单需求少拆，复杂按需拆（详见 `testcase-spec.md`）

生成的 XMind 结构：

```
运营平台 (Sheet)
└── 20260702-迭代
    └── 【转介绍】业务员在写跟进页面接入...  [业务需求节点]
        └── 新增转介绍组件
            └── 关系类型切换功能
                └── 默认选中"介绍了新客户"  [🔴 priority-1 | notes: 优先级/关联需求/前置条件/测试数据]
                    ├── "介绍了新客户"选项处于选中状态
                    ├── "被老客户介绍"选项处于未选中状态
                    └── 组件正常加载
```

XMind 中：
- **优先级**（高/中/低）→ 节点 marker（🔴/🟡/🟢 priority-1/2/3）
- **关联需求/前置条件/测试数据** → 节点 notes
- **预期结果子项** → 叶子节点的子节点列表（不显示"预期结果"标题，与团队 XMind 模板一致）

### 其他风格

- 用户明确说"按功能模块全量沉淀"时，用画布 1 风格（一级 = 系统/产品，二级 = 功能模块，深度 5-6 层）
- 默认画布 2（按业务需求）

## 工具脚本

### md2xmind.py — Markdown → XMind 全量转换（生成场景）

```bash
python scripts/md2xmind.py <input.md> <output.xmind>
```

无第三方依赖（纯 Python zip + XML），输出 XMind 8 格式（与 `parse_xmind.py` / `xmind-edit.py` 兼容）。

### xmind-edit.py — XMind 增量编辑（增/删/改，**统一脚本**）

适用于"补充优化现有用例"场景，**不破坏原文件结构**。

```bash
# 添加单个子节点
python scripts/xmind-edit.py add <xmind> "<父节点>" "<子节点>" --notes "..." --marker priority-1

# 删除节点
python scripts/xmind-edit.py remove <xmind> "<节点标题>" --parent "<父节点>"

# 按 JSON 计划批量应用（核心）
python scripts/xmind-edit.py apply <xmind> --plan supplement-plan.json [--in-place]

# 更新节点 notes / marker
python scripts/xmind-edit.py set-notes <xmind> "<节点>" "<新 notes>" [--parent "<父节点>"]
python scripts/xmind-edit.py set-marker <xmind> "<节点>" priority-1 [--parent "<父节点>"]
```

**默认行为**：输出 `<原名>-new.xmind`，不覆盖原文件；加 `--in-place` 原地修改。

**JSON 计划格式**：
```json
{
  "operations": [
    {"op": "add", "parent": "父节点", "child": "子节点", "level": 5, "notes": "...", "marker": "priority-1"},
    {"op": "remove", "title": "节点", "parent": "父节点"},
    {"op": "set-notes", "title": "节点", "notes": "新内容"},
    {"op": "set-marker", "title": "节点", "marker": "priority-2"}
  ]
}
```

详细见 `python scripts/xmind-edit.py <subcommand> --help`。
