# infrautil

Python-based infrastructure utility for Kubernetes manifest management.

## Overview

`infrautil` is a command-line tool that automates the management of Kubernetes manifests in this infrastructure repository. It provides three main functions:

1. **Snapshot Generation** - Converts Jsonnet manifests to YAML
2. **Namespace Management** - Auto-generates namespace configurations from application metadata
3. **Helm Snapshot** - Generates Helm chart snapshots (Go implementation)

## Why Python?

This tool was migrated from Go to Python following the **Python-first principle**. See [Language Decision](../../docs/LANGUAGE_DECISION.md) for the full rationale.

Key benefits:
- Better integration with Kubernetes YAML/JSON tooling
- More maintainable for infrastructure automation
- Easier onboarding for contributors
- Rich ecosystem for manifest validation

## Installation

### Development Mode

```bash
cd scripts
pip install -e .
```

### Production

```bash
cd scripts
pip install .
```

### Dependencies

- Python 3.11+
- jsonnet
- pyyaml
- click
- pydantic
- json5

## Usage

### Basic Commands

```bash
# Generate YAML snapshots from Jsonnet
infrautil snapshot -d k8s/apps -o k8s/snapshots/apps

# Generate namespace manifest
infrautil namespace -d k8s/apps -o k8s/namespaces/namespaces.json5

# Show help
infrautil --help

# Verbose output
infrautil -v snapshot -d k8s/apps -o k8s/snapshots/apps
```

### Via Makefile

The recommended way to use infrautil is through the Makefile:

```bash
# Generate all snapshots
make snapshot

# Generate namespaces
make namespace

# Generate app snapshots only
make app-snapshot
```

## Architecture

### Module Structure

```
infrautil/
├── __init__.py           # Package initialization
├── cli.py                # Click-based CLI interface
├── config.py             # Configuration management
├── logging_config.py     # Logging setup
├── commands/             # Command implementations
│   ├── snapshot.py       # Snapshot generation logic
│   └── namespace.py      # Namespace management logic
├── lib/                  # Core library modules
│   ├── jsonnet.py        # Jsonnet to YAML conversion
│   ├── apps.py           # Application configuration parsing
│   └── namespace.py      # Namespace utilities
└── tests/                # Test suite
    ├── test_jsonnet.py
    └── test_namespace.py
```

### Design Principles

1. **Separation of Concerns** - CLI, business logic, and library code are separated
2. **Type Safety** - Pydantic models for configuration validation
3. **Error Handling** - Explicit error types and messages
4. **Testability** - Core logic isolated from CLI for easy testing
5. **Logging** - Structured logging for debugging and monitoring

## Development

### Running Tests

```bash
cd scripts
pytest infrautil/tests/ -v
```

### Code Quality

```bash
# Format code
black infrautil/

# Lint
ruff check infrautil/

# Type check
mypy infrautil/
```

### Adding New Commands

1. Create command module in `infrautil/commands/`
2. Implement `execute_<command>()` function
3. Add CLI interface in `infrautil/cli.py`
4. Add tests in `infrautil/tests/`
5. Update this README

## Migration from Go

The Go implementation is retained only for the `helm-snapshot` command, which requires Go-specific Helm libraries. The roadmap includes:

- [ ] Migrate helm-snapshot to Python using helm CLI
- [ ] Remove Go implementation entirely
- [ ] Update CI/CD to use Python exclusively

## Contributing

When contributing to infrautil:

1. Follow the **Python-first principle**
2. Add tests for new functionality
3. Update documentation
4. Use atomic commits with clear messages
5. Run code quality checks before committing

## License

Same as the parent repository.
