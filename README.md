# 🤖 Machiners Platoon

An automated development agent squadron powered by [Claude Code Action](https://github.com/anthropics/claude-code-action) that transforms issues into production-ready pull requests.

## Overview

Machiners Platoon is a collection of 5 specialized AI bots that work together to automatically implement features, from initial issue analysis to final code review. Simply create an issue, add a label, and watch as the system enhances requirements, creates implementation plans, writes code, and prepares pull requests for review.

## Features

- 📝 **Flexible Issue Creation**: Write rough ideas - AI bots will enhance and complete requirements automatically
- 🤖 **5 Specialized AI Bots**: Product Manager, Architect, Engineer, and Review bots work together seamlessly
- ⚡ **Issue to PR Automation**: Complete development workflow from concept to production-ready code
- 🌐 **Multi-Language Support**: Works in any natural language and programming language
- 🅰️ **Powered by Claude**: Uses Claude Code Action for intelligent code generation and analysis
- 💰 **Cost Control**: Built-in review cycle limits prevent runaway AI costs

## Why Machiners Platoon?

Machiners Platoon is built **entirely with GitHub Actions** - no external infrastructure required:

- 🚫 **No servers needed** - Runs entirely on GitHub's infrastructure
- 🚫 **No third-party services** - No subscriptions or external dependencies
- 🚫 **No agent frameworks** - Unlike [Mastra](https://github.com/mastra-ai/mastra) or [VoltAgent](https://github.com/VoltAgent/voltagent), no complex frameworks to learn
- ✅ **Just GitHub Actions** - Simple YAML files you can customize anytime

Everything runs in your GitHub repository. Want to customize the behavior? Just edit the YAML files.

## Demo (Japanese)

https://github.com/convcha/rust-wc/issues/5

## Getting Started

### Automated Installation (Recommended)

Run in your repository's root directory with [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) or other coding agents:

```bash
claude "https://github.com/convcha/machiners-platoon Read this GitHub repository's README and follow the Manual Installation section to install these GitHub Actions into my project"
```

For busy developers (skip permission prompts - use at your own risk):

```bash
claude --dangerously-skip-permissions "https://github.com/convcha/machiners-platoon Read this GitHub repository's README and follow the Manual Installation section to install these GitHub Actions into my project"
```

**Note**: After automated installation, you'll still need to manually configure repository settings and secrets as described in the [Configuration](#configuration) section.

### Manual Installation

1. Run the installation script in your repository's root directory:
   ```shell
   curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/refs/heads/main/scripts/install.sh | bash
   ```

   Or download and run locally:
   ```shell
   curl -s https://raw.githubusercontent.com/convcha/machiners-platoon/refs/heads/main/scripts/install.sh -o install.sh
   chmod +x install.sh
   ./install.sh
   ```

2. Insert language-specific setup steps to `# <!-- INSERT SETUP STEPS HERE -->` in these files:
   - `.github/workflows/engineer-bot.yml`
   - `.github/workflows/engineer-fixes-bot.yml`
   - NEVER: Do not edit other sections
   - NEVER: Do not edit other files

3. Configure GitHub repository settings:
   - Enable "Allow GitHub Actions to create and approve pull requests"
   - Path: Settings → Actions → General → Workflow permissions

4. Add required secrets (see [Configuration](#configuration) for details):
   - `ANTHROPIC_API_KEY` - Your Claude API key
   - `GH_PERSONAL_ACCESS_TOKEN` - GitHub token with repo permissions

5. Create the trigger label:
   - Go to Issues → Labels → New label
   - Name: `🤖 Machiners Platoon` (customizable - see [Configuration](#github-actions-variables))

## Usage

1. Create an issue (rough title and description are fine - bots will enhance them)
2. Add the trigger label (default: `🤖 Machiners Platoon`) to trigger automation
3. Watch the magic happen:
    - Issue gets enhanced with detailed requirements
    - Implementation plan is created (if needed)
    - Code is implemented and PR is created
    - Automated review and feedback cycles run
    - PR is prepared for human review and merge

## Configuration

### Repository Settings

Enable PR creation in **Settings → Actions → General**:
- ✅ Allow GitHub Actions to create and approve pull requests

![](./docs/images/pr-permission.png)

### GitHub Actions Secrets

Add in **Settings → Secrets and variables → Actions → Secrets**:

| Name | Required | Description | Default Value |
|----|:---:|----|----|
| `ANTHROPIC_API_KEY` | ✅ | Claude API key for AI operations | N/A |
| `GH_PERSONAL_ACCESS_TOKEN` | ✅ | [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) with repo permissions (Actions: Write, Contents: Write, Issues: Write, Metadata: Read, Pull requests: Write) | N/A |

![](./docs/images/repository-secrets.png)

![](./docs/images/personal-access-tokens.png)

### GitHub Actions Variables

Add in **Settings → Secrets and variables → Actions → Variables**:

| Name | Required | Description | Default Value |
|----|:---:|----|----|
| `MACHINERS_PLATOON_LANG` | ❌ | Target language for bot communications. Supports any natural language name (e.g., "Japanese", "日本語", "Spanish", "Español", "Français") | "English" |
| `MACHINERS_PLATOON_TRIGGER_LABEL` | ❌ | Custom trigger label for activating the bot squadron. Allows using different labels for different projects or environments | "🤖 Machiners Platoon" |

![](./docs/images/lang.png)

## Updates

When this repository receives updates, you can easily apply the updates to your repository using [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) or other coding agents:

```bash
claude "Properly compare my current GitHub Actions in .github/workflows/ and .github/actions/ with the latest version from https://github.com/convcha/machiners-platoon and update them while preserving my language-specific setup steps"
```

For busy developers (skip permission prompts - use at your own risk):

```bash
claude --dangerously-skip-permissions "Properly compare my current GitHub Actions in .github/workflows/ and .github/actions/ with the latest version from https://github.com/convcha/machiners-platoon and update them while preserving my language-specific setup steps"
```

## Bot Squadron

### Product Manager Bot
Analyzes and enhances issues, provides complexity estimates, and intelligently routes to appropriate downstream bots.

### System Architect Bot
Creates detailed technical implementation plans for complex features, analyzing existing codebase patterns.

### Engineer Bot
Implements features according to plans, creates feature branches, runs validation, and creates pull requests.

### Architect Review Bot
Reviews implementations for quality, security, and architectural compliance with automatic feedback cycles.

### Engineer Fixes Bot
Addresses review feedback systematically and maintains code quality throughout iterations.

## Workflow

```mermaid
graph TD
    A[Create Issue] --> B[Add Trigger Label]
    B --> C[Product Manager Bot Enhances]
    C --> D{Complexity Analysis}
    D -->|Complex| E[System Architect Bot]
    D -->|Simple| F[Engineer Bot]
    E --> F
    F --> G[Create Pull Request]
    G --> H[Architect Review Bot]
    H --> I{Review Result}
    I -->|Issues Found| J[Engineer Fixes Bot]
    I -->|Approved| K[Ready for Human Review]
    J --> H
```

## Cost Management

- **Cycle Limits**: Maximum 3 review iterations to control costs
- **Smart Routing**: Intelligent decisions to avoid unnecessary operations
- **Execution Tracking**: Detailed cost and duration tracking displayed in issues
- **Automatic Stopping**: Prevents infinite loops and runaway costs

## Security

- Bots cannot approve or merge PRs - human oversight required
- Limited repository scope with specific tool allowances
- Automatic commit signing
- Secure API key storage in GitHub secrets
- Built-in cycle protection prevents abuse

## Labels

- Trigger Label (default: `🤖 Machiners Platoon`) - Main trigger label (never removed automatically, configurable via `MACHINERS_PLATOON_TRIGGER_LABEL`)
- `🤖 Review Cycle 1/2/3` - Tracks review iterations
- `🤖 Architect Approved` - PR ready for human review
- `🚨 Manual Review Required` - Human intervention needed
- `🤖 Max Cycles Reached` - Automation stopped due to limits

## Documentation

For detailed information about the system architecture, bot specifications, and workflow mechanics, see:

- [**ARCHITECTURE.md**](./ARCHITECTURE.md) - Detailed bot specifications, workflow diagrams, and system architecture

## Contributing

This project provides the foundation for automated development workflows. To contribute:

1. Fork the repository
2. Create your feature branch
3. Test your changes with the provided workflows
4. Submit a pull request

## License

This project is open source and available under the MIT License.
