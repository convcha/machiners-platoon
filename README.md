# 🤖 Machiners Platoon

An automated development agent squadron powered by GitHub Actions that transforms issues into production-ready pull requests.

## Overview

Machiners Platoon is a collection of 5 specialized AI bots that work together to automatically implement features, from initial issue analysis to final code review. Simply create an issue, add a label, and watch as the system enhances requirements, creates implementation plans, writes code, and prepares pull requests for review.

## Features

- ⚡ **Automated Development Workflow**: Complete automation from issue to PR
- 📝 **Flexible Issue Creation**: Issue titles and descriptions can be rough - bots will enhance and complete them automatically
- 🤖 **Multi-Agent Collaboration**: 5 specialized bots handle different aspects of development
- 🌐 **Multi-Language Support**: Bots communicate in any language you prefer
- 💰 **Cost Control**: Built-in cycle limits prevent runaway AI costs
- 🔧 **Language Agnostic**: Easily adaptable to any programming language or framework
- 🔒 **Security First**: Human oversight required for final approval and merge

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
   - Name: `🤖 Machiners Platoon`

## Usage

1. Create an issue (rough title and description are fine - bots will enhance them)
2. Add the `🤖 Machiners Platoon` label to trigger automation
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

![](./docs/images/lang.png)

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
    A[Create Issue] --> B[Add 🤖 Machiners Platoon Label]
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
- **Execution Tracking**: Detailed cost and duration tracking for all operations
- **Automatic Stopping**: Prevents infinite loops and runaway costs

## Security

- Bots cannot approve or merge PRs - human oversight required
- Limited repository scope with specific tool allowances
- Automatic commit signing
- Secure API key storage in GitHub secrets
- Built-in cycle protection prevents abuse

## Labels

- `🤖 Machiners Platoon` - Main trigger label (never removed automatically)
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
