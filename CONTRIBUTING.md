# Contributing to infra

Thank you for your interest in contributing to this infrastructure repository.

## Python-First Principle

This project follows a **Python-first principle** for all tooling and automation.

### Language Selection Policy

1. **Default**: Python is the primary language for infrastructure utilities
2. **Exceptions require explicit justification**:
   - Python is technically insufficient for the use case
   - Proven performance constraints exist
   - System-level bindings unavailable in Python

See [docs/LANGUAGE_DECISION.md](docs/LANGUAGE_DECISION.md) for details.

## Development Setup

### Prerequisites

- Python 3.11 or later
- Go 1.21+ (for legacy helm-snapshot command only)
- Make

### Initial Setup

```bash
# Clone repository
git clone https://github.com/Rtur2003/infra.git
cd infra

# Install Python dependencies
cd scripts
pip install -e .
pip install -e ".[dev]"

# Install pre-commit hooks
pre-commit install
```

## Code Quality Standards

### Testing

All code changes must include tests:

```bash
cd scripts
pytest infrautil/tests/ -v --cov=infrautil
```

### Linting and Formatting

Before committing, ensure code passes quality checks:

```bash
# Format code
black infrautil/

# Lint
ruff check infrautil/

# Type check
mypy infrautil/
```

Or use pre-commit hooks to automate this:

```bash
pre-commit run --all-files
```

### Type Annotations

- All functions must have type annotations
- Use Python 3.11+ union syntax: `str | None` not `Optional[str]`
- Pydantic models for configuration validation

## Commit Conventions

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `fix`: Bug fix
- `safety`: Security or robustness fix
- `validation`: Input validation or error handling
- `refactor`: Code restructuring without behavior change
- `structure`: Architecture or responsibility changes
- `tooling`: Development tools or CI/CD
- `policy`: Governance or process documentation
- `docs`: Documentation only
- `visuals`: Formatting or readability (no logic changes)
- `chore`: Maintenance tasks

### Rules

1. **One logical change per commit** - independently revertable
2. **Same file, different areas** → separate commits
3. **Clear subject** - what changed and why
4. **Body explains reasoning** - not what (code shows that)

### Examples

**Good**:
```
fix(jsonnet): add multi-document YAML separator support

The build_yaml function was concatenating YAML documents without
separators, causing multi-resource manifests to fail parsing.

Added explicit '---' separators between documents per YAML spec.
```

**Bad**:
```
misc: fixes and updates

- Fixed tests
- Updated imports
- Added docs
```

## Pull Request Process

1. **Create topic branch** from main:
   ```bash
   git checkout -b <type>/<descriptive-name>
   ```

2. **Make atomic commits** following conventions above

3. **Run quality checks**:
   ```bash
   make lint
   pytest infrautil/tests/
   ```

4. **Create pull request** with:
   - Clear title following commit convention
   - Description explaining motivation and changes
   - Link to related issues if any

5. **Respond to review feedback** promptly

## Directory Structure

```
infra/
├── .github/          # GitHub workflows and actions
├── docs/             # Architecture and decision documents
├── k8s/              # Kubernetes manifests
│   ├── apps/         # Jsonnet application definitions
│   └── namespaces/   # Generated namespace manifests
├── scripts/          # Infrastructure utilities
│   └── infrautil/    # Python tool for manifest management
│       ├── commands/ # CLI command implementations
│       ├── lib/      # Core library functions
│       └── tests/    # Test suite
├── terraform/        # Terraform configurations
└── static/           # Static assets
```

## Adding New Features

### New infrautil Commands

1. Create module in `scripts/infrautil/commands/`
2. Implement `execute_<command>()` function
3. Add CLI interface in `scripts/infrautil/cli.py`
4. Add tests in `scripts/infrautil/tests/`
5. Update documentation

### New Kubernetes Applications

1. Create directory in `k8s/apps/<app-name>/`
2. Add `app.json5` with metadata
3. Create Jsonnet manifests
4. Run `make snapshot` to generate YAML
5. Test with `make lint`

## Questions or Issues?

- Open an issue for bugs or feature requests
- Check existing documentation in `docs/`
- Review `scripts/README.md` for infrautil details

## License

Same as the parent repository.
