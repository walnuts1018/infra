# Go Code Deprecation Strategy

## Current State

The `scripts/infrautil/` directory contains both Python and Go implementations:

### Python Implementation (Primary)
- `cli.py` - CLI interface
- `commands/` - Command implementations
- `lib/` - Core libraries (jsonnet, apps, namespace)
- `tests/` - Test suite

### Go Implementation (Legacy)
- `main.go` - Entry point
- `*Cmd.go` - Command handlers
- `lib/*.go` - Library functions
- `lib/*_test.go` - Go tests

## Deprecation Timeline

### Phase 1: Current (Complete)
**Status**: ✅ Complete

- [x] Python implementation functional and tested
- [x] Makefile uses Python by default
- [x] Documentation updated to reflect Python-first
- [x] All tests passing (12/12)

### Phase 2: Transition Period (Next 3 months)
**Goal**: Migrate helm-snapshot to Python

Tasks:
- [ ] Implement helm CLI wrapper in Python
- [ ] Add helm-snapshot tests
- [ ] Validate output matches Go version
- [ ] Update CI/CD to test both versions
- [ ] Document helm-snapshot migration

Exit Criteria:
- Python helm-snapshot produces identical output
- Performance acceptable (< 2x Go version)
- All tests passing

### Phase 3: Deprecation Warnings (Following 3 months)
**Goal**: Mark Go code as deprecated

Tasks:
- [ ] Add deprecation notices to Go code
- [ ] Add runtime warnings when Go binary is used
- [ ] Update all documentation to remove Go references
- [ ] Create migration guide for external users (if any)
- [ ] Monitor for any Go usage in logs/metrics

Exit Criteria:
- No production usage of Go binaries
- All users migrated to Python tool
- Documentation complete

### Phase 4: Removal (After 6 months total)
**Goal**: Remove Go code entirely

Tasks:
- [ ] Remove all `*.go` files
- [ ] Remove `go.mod` and `go.sum`
- [ ] Remove Go setup from CI/CD
- [ ] Remove Go-specific documentation
- [ ] Clean up Makefile Go targets
- [ ] Archive final Go version for reference

Exit Criteria:
- Zero Go code in repository
- All workflows use Python exclusively
- Clean git history with proper deprecation trail

## Justification

### Why Deprecate Go?

1. **Python-First Principle**: Repository standard requires Python as default
2. **Maintenance Burden**: Dual implementation increases complexity
3. **No Performance Justification**: Current workload is I/O bound, not CPU bound
4. **Better Tooling**: Python ecosystem superior for infrastructure automation
5. **Single Source of Truth**: Eliminates risk of implementation drift

### Why Keep Go Temporarily?

1. **Helm Integration**: Go version uses Helm Go libraries directly
2. **Risk Mitigation**: Gradual migration reduces deployment risk
3. **Validation**: Side-by-side testing ensures correctness
4. **User Impact**: Allows time for external users to migrate

## Migration Path

### For helm-snapshot Command

**Current (Go)**:
```go
// Uses Helm Go libraries directly
helmClient := action.NewInstall(actionConfig)
release, err := helmClient.Run(chart, vals)
```

**Future (Python)**:
```python
# Wrapper around helm CLI
result = subprocess.run(
    ["helm", "template", name, chart_path, "--values", values_file],
    capture_output=True,
    text=True,
    check=True,
)
```

**Trade-offs**:
- Pro: No Go dependencies, simpler maintenance
- Pro: Uses same helm binary as production
- Con: Slight performance overhead (process spawn)
- Con: Relies on helm CLI being installed

Decision: **Performance overhead is acceptable** for CI/CD use case.

## Rollback Plan

If Python helm-snapshot proves inadequate:

1. **Keep Go binary**: Restore Go build in Makefile
2. **Hybrid approach**: Python for everything except helm-snapshot
3. **Document exception**: Explicit justification per Python-first policy
4. **Re-evaluate timeline**: Consider longer migration period

This should be a **last resort** - prefer solving Python implementation issues.

## Success Metrics

### Phase 1 (Current)
- ✅ 12/12 tests passing
- ✅ Makefile uses Python
- ✅ Documentation updated

### Phase 2 (Helm Migration)
- ⏳ helm-snapshot in Python
- ⏳ Output validation tests
- ⏳ Performance benchmarks

### Phase 3 (Deprecation)
- ⏳ Zero Go usage in production
- ⏳ Migration guide published
- ⏳ Warnings in place

### Phase 4 (Removal)
- ⏳ Go code removed
- ⏳ Clean git history
- ⏳ Updated CI/CD

## References

- [Language Decision](LANGUAGE_DECISION.md) - Python-first rationale
- [Migration Guide](MIGRATION_GUIDE.md) - Completed Python migration
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Current state

## Contact

Questions about this deprecation plan:
- Open an issue with label `deprecation`
- Reference this document in discussions
- Propose timeline adjustments with justification

---

**Last Updated**: 2024-12-20  
**Status**: Phase 1 Complete, Phase 2 Planning  
**Owner**: Infrastructure Team
