# claude-plain-style

一个 Claude Code 插件。你每次提交问题后、模型开始回答前，它会把一份约 500 字的 `STYLE.md` 风格规则附加到你的输入里。效果是：Claude 评审方案、比较选项、写周报和文档时，先说结论，再给依据，不用比喻、反转句和金句代替说明。

它不适合写文案、科普这类需要吸引力的文字，原因见下方「适用范围」。

规则全文见 [`plugins/plain-style/STYLE.md`](plugins/plain-style/STYLE.md)。

## 安装

### 方式一：安装插件（推荐）

在 Claude Code 对话框里依次执行：

```
/plugin marketplace add xiaozhenliu/claude-plain-style
/plugin install plain-style@claude-plain-style
```

第一条命令把本仓库添加为插件来源，第二条安装插件。也可以在终端里执行同样的操作：

```bash
claude plugin marketplace add xiaozhenliu/claude-plain-style
claude plugin install plain-style@claude-plain-style
```

默认安装到用户级，对你所有项目生效。只想在某个项目里用，在该项目目录下加 `--scope` 参数：

| 参数 | 生效范围 | 配置写入位置 |
|---|---|---|
| `--scope user`（默认） | 你的所有项目 | `~/.claude/settings.json` |
| `--scope project` | 当前项目，配置随仓库提交，团队成员共用 | `.claude/settings.json` |
| `--scope local` | 当前项目，只对你自己生效，不提交 | `.claude/settings.local.json` |

安装后重启 Claude Code 会话。插件运行需要系统装有 `jq` 或 `python3` 二者之一，macOS 和大多数 Linux 默认带 `python3`。

### 方式二：手动配置

不想装插件时，把 [`STYLE.md`](plugins/plain-style/STYLE.md) 复制到项目根目录，再在项目的 `.claude/settings.json` 里加入：

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -Rs '{hookSpecificOutput:{hookEventName:\"UserPromptSubmit\",additionalContext:.},suppressOutput:true}' \"${CLAUDE_PROJECT_DIR}/STYLE.md\"",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

手动方式只对这一个项目生效，并且需要系统装有 `jq`（macOS：`brew install jq`）。插件方式和手动方式选一种，同时使用会让规则注入两次。

## 使用

### 日常使用

装好后照常提问，不需要输入任何额外命令。每次提交问题时，插件自动附加规则。规则不会出现在对话记录里，Claude 的回答会按规则组织。

### 确认是否生效

1. 在终端执行 `claude plugin list`，列表里应有 `plain-style@claude-plain-style`，状态为已启用。
2. 在 Claude Code 里执行 `/hooks`，`UserPromptSubmit` 下应能看到本插件的 hook。
3. 提交问题时，状态栏会显示「注入 STYLE.md 输出风格约束」。这一步耗时很短，可能看不到。

### 临时关闭和重新打开

写文案这类不适合的任务前先关掉，写完再打开：

```
/plugin disable plain-style@claude-plain-style
/plugin enable plain-style@claude-plain-style
```

只在某个项目里关闭，在该项目目录下用终端执行：

```bash
claude plugin disable plain-style@claude-plain-style --scope project
```

开关后如果效果没有变化，重启 Claude Code 会话。

### 给某个项目换一套规则

在项目根目录放一份自己的 `STYLE.md`。插件每次运行时先检查项目根目录：

1. 项目根目录有 `STYLE.md`，就用这份。
2. 没有，就用插件自带的默认规则。

这里的项目根目录是你启动 Claude Code 时所在的目录。子目录里的 `STYLE.md` 不会被读取。文件名必须是大写的 `STYLE.md`。

### 更新和卸载

```bash
claude plugin marketplace update claude-plain-style   # 拉取本仓库的最新版本
claude plugin update plain-style@claude-plain-style   # 更新插件，重启后生效
claude plugin uninstall plain-style@claude-plain-style
```

## 改成你自己的规则

两种方式：

1. 在某个项目根目录放一份自己的 `STYLE.md`，只影响该项目，见上方「给某个项目换一套规则」。
2. Fork 本仓库，修改 `plugins/plain-style/STYLE.md`，再把安装命令里的 `xiaozhenliu/claude-plain-style` 换成你的仓库地址。

写规则的建议步骤：

1. 从你觉得别扭的 AI 输出里摘出三段具体的句子。
2. 给每句归类，写成一条禁止项，例句直接用摘出来的原句。
3. 加一条正面要求，说明你希望它怎么写。只写禁止项，输出会变得干瘪。
4. 用同一条指令对比改前改后的输出，不满意就回到第 2 步。

## 适用范围

实测结论（模型 claude-opus-5，Claude Code 2.1.252）：

| 任务类型 | 风格差异 | 建议 |
|---|---|---|
| 评审方案、看战略、比较选项 | 明显。默认版用金句给判断，开启后给判断的依据 | 开 |
| 周报、技术文档介绍 | 明显 | 开 |
| App 商店文案、官网文案、科普解释 | 明显，但去掉修辞后失去吸引力 | 关 |
| 技术选型建议 | 弱 | 无所谓 |
| 代码审查 | 无 | 无所谓 |

代码类任务没有差别，因为模型处理代码问题时本来就先给结论、不用比喻。文案类任务变差，因为比喻、对比句和节奏正是这类文字需要的。

## 常见问题

**会增加成本吗。** 每轮多出约 500 字的输入。按当前价格可以忽略。

**和 CLAUDE.md 里的写作要求冲突怎么办。** 两者会同时进入上下文，建议只保留一处。

**写在 CLAUDE.md 里和用插件有区别吗。** 7 轮连续对话的实测没有测出差别。用插件是因为装一次对所有项目生效，`CLAUDE.md` 要每个项目放一份。只有一个项目的话，写进 `CLAUDE.md` 同样够用。

**装了但没效果。** 按顺序检查：

1. `claude plugin list` 里插件是否已启用。
2. 安装或开关后是否重启了 Claude Code 会话。
3. 系统里 `jq` 和 `python3` 是否至少有一个。两个都没有时，提问照常进行，但规则不会注入。

**对英文输出有效吗。** 只测过中文。规则是中文写的，用于英文输出需要重写。

## License

MIT
