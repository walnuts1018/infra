# Language Priority Decision

## Python-First Resolution

This project has been migrated from Go to Python as the primary implementation language.

### Rationale

1. **Ecosystem Alignment**: Python provides better tooling for Kubernetes manifest manipulation with mature libraries (pyyaml, jsonnet)
2. **Maintainability**: Python's dynamic nature and extensive standard library reduce boilerplate
3. **Team Familiarity**: Python has broader adoption and lower barrier to entry for infrastructure automation
4. **Tooling Integration**: Better integration with existing CI/CD and infrastructure tooling
5. **Development Velocity**: Faster iteration cycles for infrastructure utilities

### Go Alternative Considered

The previous implementation used Go, which provided:
- Static typing and compilation
- Better performance for high-throughput scenarios
- Strong concurrency primitives

However, these advantages were not critical for this use case:
- The tool processes manifests in CI/CD with sub-second execution time requirements
- Concurrency is I/O bound (file operations), not CPU bound
- Type safety can be achieved with mypy and pydantic

### Decision

**Python is the primary language** for this project's utility tooling. Go may be considered only if:
- Performance profiling demonstrates Python is insufficient
- System-level bindings are required that Python cannot provide
- Integration with Go-specific tooling is mandatory

This decision follows the principle: **attempt Python first, justify alternatives explicitly**.
