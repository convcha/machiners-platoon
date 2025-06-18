# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Machiners Platoon is a GitHub Actions-powered automated development agent squadron that implements a complete development workflow from issue creation to pull request deployment. The system consists of 5 specialized AI bots that work together through repository dispatch events.

## Bot Architecture

### Core Workflow Chain
1. **Product Manager Bot** (`product-manager-bot.yml`) - Enhances issues and routes to appropriate bots
2. **System Architect Bot** (`system-architect-bot.yml`) - Creates technical implementation plans
3. **Engineer Bot** (`engineer-bot.yml`) - Implements features and creates PRs
4. **Architect Review Bot** (`architect-review-bot.yml`) - Reviews PRs with cycle protection
5. **Engineer Fixes Bot** (`engineer-fixes-bot.yml`) - Addresses review feedback

### Repository Dispatch Events
- `🏛️ Architecture Review` - Triggers System Architect Bot
- `🛠️ Lets Build This` - Triggers Engineer Bot implementation
- `🏗️ Architect PR Review` - Triggers Architect Review Bot
- `🔧 Fixes Required` - Triggers Engineer Fixes Bot
- `🚀 Deploy Preview` - Triggers preview deployment

## Critical Label Management
- **NEVER** remove the trigger label from Issues or PRs - this is the primary trigger label
- The trigger label is configurable via the `MACHINERS_PLATOON_TRIGGER_LABEL` GitHub Actions variable (defaults to `🤖 Machiners Platoon`)
- Review cycle labels (`🤖 Review Cycle 1/2/3`) track automation iterations
- `🤖 Architect Approved` indicates PR approval
- `🚨 Manual Review Required` and `🤖 Max Cycles Reached` indicate when human intervention is needed

## Trigger Label Configuration
- The trigger label can be customized by setting the `MACHINERS_PLATOON_TRIGGER_LABEL` GitHub Actions variable
- Set as repository variable in **Settings → Secrets and variables → Actions → Variables**
- Defaults to `🤖 Machiners Platoon` if not configured
- This allows using different trigger labels for different projects or environments

## Cost Control & Cycle Protection
- Maximum 3 automated review cycles to prevent infinite loops and control AI costs
- Each bot execution is tracked with cost, duration, and token usage via the `claude-result-tracker` action
- Cost information is automatically added to issues in a standardized table format

## Language Support
- All bots support multiple languages through the `MACHINERS_PLATOON_LANG` GitHub Actions variable
- Set as repository variable in **Settings → Secrets and variables → Actions → Variables**
- Supports any natural language name (e.g., "日本語", "Español", "Français")
- Defaults to "English" if not set
- User-facing content (issue updates, PR descriptions, comments) will be written in the specified language
- Internal bot instructions remain in English for consistency
- Markdown section names are also translated to the target language

## Common Operations

### Adding New Bots
When adding new bot workflows:
- Follow the existing naming pattern: `{role}-bot.yml`
- Use the same permission structure and allowed/disallowed tools
- Include the claude-result-tracker action for cost tracking
- Implement cycle protection for any review/feedback loops

### Modifying Bot Instructions
Bot behavior is defined in the `custom_instructions` and `direct_prompt` sections of each workflow. Key requirements:
- Always preserve the configured trigger label (defaults to `🤖 Machiners Platoon`)
- Use repository dispatch events for bot coordination
- Include cost tracking and cycle protection
- Follow the established JSON decision file pattern for bot routing

### Bot Configuration
- All bots use the `convcha/claude-code-action@main` action
- API keys are stored in `ANTHROPIC_API_KEY` and `GH_PERSONAL_ACCESS_TOKEN` secrets
- Engineer bots include Node.js and pnpm setup steps
- Timeout is set to 30 minutes for all bot executions

## Validation Commands
Based on the workflow configurations, the following validation commands are expected:
- `pnpm install` - Install dependencies
- Standard lint, format, and typecheck commands (specific commands should be determined from target project)

## Architecture Patterns
- Event-driven architecture using GitHub repository dispatch
- JSON decision files for bot routing (never committed to repository)
- Cycle protection with automatic stopping and manual override capabilities
- Comprehensive cost tracking and transparency
- Automatic issue-PR linking with standardized sections

## Security Considerations
- Bots cannot approve or merge PRs (human oversight required)
- Limited repository scope with specific tool allowlists
- Automatic commit signing
- API keys secured in GitHub secrets
- Cycle limits prevent runaway AI costs

## Documentation Maintenance
- **IMPORTANT**: Whenever files are updated, always update both CLAUDE.md and README.md to reflect the latest changes
- Keep documentation synchronized with code changes to maintain accuracy
- Update relevant sections that describe modified functionality or architecture
