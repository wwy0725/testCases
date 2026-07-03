#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从 Baymax 拉取的用例 Markdown 建立"功能→用例"反向映射。

输入：_history/baymax-*.md
输出：
  - knowledge/_index/baymax-功能映射.md（人读）
  - knowledge/_index/baymax-功能映射.json（程序读）

工作原理：
  1. 解析 Baymax Markdown 树（数字开头 = 用例，其他 = 模块/标题）
  2. 跟踪每个用例的完整路径（如：运营平台/小二当家/机构一户式/转介绍）
  3. 基于路径节点作为"功能标签"（机构一户式、转介绍、跟进记录...）
  4. 基于 glossary.md 关键词做"功能归类"
  5. 输出反向索引
"""

import sys
import os
import io
import re
import json
import argparse
from pathlib import Path
from collections import defaultdict
from datetime import datetime

if sys.platform == 'win32':
    try:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
    except Exception:
        pass


def load_business_terms() -> list:
    """从 glossary.md 加载业务术语。"""
    project_root = Path.cwd()
    glossary = project_root / 'knowledge' / 'glossary.md'
    if not glossary.exists():
        return []
    content = glossary.read_text(encoding='utf-8')
    terms = set()
    for line in content.split('\n'):
        m = re.match(r'\|\s*\*?\*?([^*|]+?)\*?\*?\s*\|', line)
        if m:
            term = m.group(1).strip().replace('**', '').strip()
            if term and len(term) < 30 and term not in ('术语', '定义', '来源', '业务线归属'):
                terms.add(term)
    # 加补充业务词
    extra = {'跟进', '跟进对象', '跟进方式', '新增跟进', '查询跟进',
             '写跟进', '跟进组件', '关联组件', '介绍客户', '被介绍',
             '新客户引流', '介绍源', '新引流', '责任户', '公共池',
             '转介绍', '机构一户式', '企业一户式', '一人式', '商机', '续费', '签到'}
    terms.update(extra)
    return sorted(terms, key=len, reverse=True)


def parse_baymax_markdown(md_path: Path) -> list:
    """解析 Baymax Markdown 树，返回 [(path, case_id, title, full_text), ...]。

    Baymax 输出格式示例：
      - 运营平台
        - 小二当家
          - 机构一户式
            1. 验证...（用例标题）
              - 步骤
              - 预期
    """
    content = md_path.read_text(encoding='utf-8')
    lines = content.split('\n')

    # 状态：当前路径栈（每个元素是 dict: {indent, title}）
    path_stack = []
    cases = []  # 收集的用例

    # 当前用例的累积文本（标题 + 步骤 + 预期）
    current_case = None

    for line in lines:
        if not line.strip():
            continue

        # 缩进级别（2 空格 = 1 级）
        indent = len(line) - len(line.lstrip(' '))
        stripped = line.strip()

        # 移除可能的 emoji/前缀字符
        # Baymax 输出前可能有 emoji 和 📝 前缀
        clean_line = re.sub(r'^[^\w-]+', '', stripped).strip()
        if not clean_line:
            clean_line = stripped

        # 判断是模块（- 开头）还是用例（数字. 开头）
        if clean_line.startswith('- '):
            title = clean_line[2:].strip()
            # 弹出栈中 indent >= 当前 indent 的
            while path_stack and path_stack[-1]['indent'] >= indent:
                path_stack.pop()
            path_stack.append({'indent': indent, 'title': title})
            current_case = None  # 切换模块，重置
        elif re.match(r'^\d+\.\s', clean_line):
            # 用例标题
            case_id_match = re.match(r'^(\d+)\.\s+(.+)', clean_line)
            case_id = int(case_id_match.group(1))
            case_title = case_id_match.group(2).strip()
            current_case = {
                'id': case_id,
                'title': case_title,
                'path': ' / '.join([p['title'] for p in path_stack]),
                'source_file': md_path.name,
                'full_text': case_title,
            }
            cases.append(current_case)
        else:
            # 用例下的步骤或预期（以 - 开头但不是数字）
            if current_case is not None:
                current_case['full_text'] += ' ' + clean_line

    return cases


def match_function_tags(case: dict, business_terms: list) -> list:
    """从用例标题+路径+步骤文本中匹配业务术语。"""
    text = case['title'] + ' ' + case['path'] + ' ' + case.get('full_text', '')
    matched = set()
    for term in business_terms:
        if term in text:
            matched.add(term)
    return list(matched)


def build_index(history_dir: Path, output_md: Path, output_json: Path):
    """构建功能→用例映射。"""
    # 1. 加载业务术语
    business_terms = load_business_terms()
    print(f'加载业务术语: {len(business_terms)} 个')

    # 2. 解析所有 Baymax 文件
    all_cases = []
    md_files = list(history_dir.glob('baymax-*.md'))
    print(f'发现 {len(md_files)} 个 Baymax 文件')
    for md_file in md_files:
        cases = parse_baymax_markdown(md_file)
        print(f'  {md_file.name}: {len(cases)} 个用例')
        all_cases.extend(cases)
    print(f'合计: {len(all_cases)} 个用例')

    # 3. 建立反向索引
    # 按"功能标签"分组
    by_tag = defaultdict(list)  # {term: [case1, case2, ...]}
    by_path = defaultdict(list)  # {path_node: [case1, case2, ...]}

    for case in all_cases:
        # 路径节点作为功能标签
        path_nodes = [p.strip() for p in case['path'].split('/') if p.strip()]
        for node in path_nodes:
            by_path[node].append(case)

        # 业务术语匹配
        matched_terms = match_function_tags(case, business_terms)
        for term in matched_terms:
            by_tag[term].append(case)

    # 4. 输出 Markdown
    output_md.parent.mkdir(parents=True, exist_ok=True)
    lines = []
    lines.append('# Baymax 历史用例 - 功能反向映射')
    lines.append('')
    lines.append(f'生成时间: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}')
    lines.append(f'用例总数: **{len(all_cases):,}**')
    lines.append(f'功能标签数（路径节点）: {len(by_path)}')
    lines.append(f'功能标签数（业务术语）: {len(by_tag)}')
    lines.append('')
    lines.append('---')
    lines.append('')

    # 4a. 路径维度（按功能模块聚合）
    lines.append('## 📂 按功能模块（路径节点）')
    lines.append('')
    lines.append('> 从 Baymax 树结构提取的"用例所在路径"作为功能标签。')
    lines.append('')

    sorted_paths = sorted(by_path.items(), key=lambda x: -len(x[1]))
    for path, cases_list in sorted_paths[:50]:  # top 50
        lines.append(f'### {path}（{len(cases_list):,} 个用例）')
        lines.append('')
        # 显示前 5 个用例示例
        for c in cases_list[:5]:
            lines.append(f'- {c["id"]}. {c["title"]} (来源: {c["source_file"]})')
        if len(cases_list) > 5:
            lines.append(f'- _... 还有 {len(cases_list) - 5} 个用例_')
        lines.append('')

    # 4b. 业务术语维度
    lines.append('## 🏷️ 按业务术语（glossary）')
    lines.append('')
    lines.append('> 基于 glossary.md 关键词匹配的用例归类。subagent 按需索引时使用。')
    lines.append('')

    sorted_tags = sorted(by_tag.items(), key=lambda x: -len(x[1]))
    for tag, cases_list in sorted_tags[:80]:  # top 80
        if not cases_list:
            continue
        lines.append(f'### {tag}（{len(cases_list):,} 个用例）')
        lines.append('')
        # 显示前 3 个用例示例
        for c in cases_list[:3]:
            lines.append(f'- {c["id"]}. {c["title"][:80]}')
        if len(cases_list) > 3:
            lines.append(f'- _... 还有 {len(cases_list) - 3} 个用例_')
        lines.append('')

    output_md.write_text('\n'.join(lines), encoding='utf-8')
    print(f'\n✅ Markdown 输出: {output_md}')

    # 5. 输出 JSON（程序读，紧凑格式 + 去重）
    # 用例 ID 全局唯一化（不同文件 ID 可能重复）
    case_index = {}  # {case_uid: {id, title, source, path}}
    case_to_tags = defaultdict(set)  # {case_uid: {tag1, tag2, ...}}
    case_to_path_nodes = defaultdict(set)  # {case_uid: {path1, path2, ...}}

    for case in all_cases:
        uid = f"{case['source_file']}#{case['id']}"
        case_index[uid] = {
            'id': case['id'],
            't': case['title'][:100],  # 截断长标题
            's': case['source_file'],
        }
        for node in [n.strip() for n in case['path'].split('/') if n.strip()]:
            case_to_path_nodes[uid].add(node)
        for term in match_function_tags(case, business_terms):
            case_to_tags[uid].add(term)

    # 聚合：{tag/path: [case_uid1, case_uid2, ...]}
    by_tag_compact = defaultdict(list)
    for uid, tags in case_to_tags.items():
        for tag in tags:
            by_tag_compact[tag].append(uid)

    by_path_compact = defaultdict(list)
    for uid, nodes in case_to_path_nodes.items():
        for node in nodes:
            by_path_compact[node].append(uid)

    json_data = {
        'meta': {
            'generated_at': datetime.now().isoformat(),
            'total_cases': len(all_cases),
            'total_tags': len(by_tag_compact),
            'total_paths': len(by_path_compact),
        },
        'cases': case_index,  # case_uid -> {id, t, s}
        'by_path': by_path_compact,  # path_node -> [case_uid]
        'by_tag': by_tag_compact,  # term -> [case_uid]
    }
    # 不缩进，紧凑格式
    output_json.write_text(json.dumps(json_data, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    print(f'✅ JSON 输出: {output_json}')


def main():
    parser = argparse.ArgumentParser(description='建立 Baymax 历史用例的反向映射')
    parser.add_argument('--history-dir', default='_history', help='Baymax 缓存目录')
    parser.add_argument('--output-md', default='knowledge/_index/baymax-功能映射.md', help='Markdown 输出')
    parser.add_argument('--output-json', default='knowledge/_index/baymax-功能映射.json', help='JSON 输出')
    args = parser.parse_args()

    history_dir = Path.cwd() / args.history_dir
    if not history_dir.exists():
        print(f'错误: 目录不存在: {history_dir}', file=sys.stderr)
        sys.exit(1)

    output_md = Path.cwd() / args.output_md
    output_json = Path.cwd() / args.output_json

    build_index(history_dir, output_md, output_json)


if __name__ == '__main__':
    main()
