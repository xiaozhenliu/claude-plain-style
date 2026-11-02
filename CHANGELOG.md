# 更新记录

版本号格式为 `主版本.次版本.修订号`。插件版本以 `plugins/plain-style/.claude-plugin/plugin.json` 中的 `version` 为准，每个版本在 Git 中有同名标签，例如 `v0.1.1`。

## 0.1.1（2026-11-02）

### 新增

- README 增加「在 Codex 中使用」：用 Codex 的 hook 配置注入规则，分为对所有项目生效和只对一个项目生效两种写法，并附排查步骤。
- README 增加「在 ChatGPT 中使用」：ChatGPT 不支持 hook，说明如何把规则粘贴到自定义指令或 Project 指令里。

### 修复

- `inject.sh` 在没有 `CLAUDE_PROJECT_DIR` 变量时，改用当前工作目录查找项目里的 `STYLE.md`。修复前，在 Codex 中项目自带的 `STYLE.md` 不会替换默认规则。Claude Code 中的行为没有变化。

### 升级方法

```bash
claude plugin marketplace update claude-plain-style
claude plugin update plain-style@claude-plain-style
```

更新后重启 Claude Code 会话。

## 0.1.0（2026-11-02）

首次公开发布。

- Claude Code 插件 `plain-style`：每次提交问题时，通过 `UserPromptSubmit` hook 把 `STYLE.md` 风格规则附加到输入里。
- 项目根目录有 `STYLE.md` 时，用项目的规则替换插件自带的默认规则。
- 系统有 `jq` 时用 `jq` 生成输出，没有时改用 `python3`。
- README 包括插件安装、三种安装范围、手动配置、开关、更新、卸载、适用范围和常见问题。
