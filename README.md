# VersoCoq

Verso documentation roles for Coq/Flocq references in literate Lean 4 projects.

[![Reservoir](https://img.shields.io/badge/reservoir-VersoCoq-blue)](https://reservoir.lean-lang.org/)

## Features

- **`{coq}` doc role**: Auto-links Coq identifiers to Flocq documentation
- **Extensible URL inference**: Add custom prefix-to-module mappings
- **Comprehensive Flocq coverage**: Core, Calc, Prop, and IEEE754 modules

## Installation

Add to your `lakefile.lean`:

```lean
require VersoCoq from git "https://github.com/alok/VersoCoq"
```

## Usage

### Important: Two-Library Setup

Due to Lean 4's `@[doc_role]` attribute timing (`applicationTime := .afterCompilation`),
the roles must compile **before** files that use them in docstrings.

```lean
-- lakefile.lean
import Lake
open Lake DSL

package MyProject

require VersoCoq from git "https://github.com/alok/VersoCoq"

-- Roles library - compiles FIRST
lean_lib MyProjectRoles where
  globs := #[.one `VersoCoq.Roles]

-- Main library - compiles SECOND (uses roles)
@[default_target]
lean_lib MyProject where
  globs := #[.submodules `MyProject]
```

### In Docstrings

```lean
/-- This implements {coq}`generic_format` from Flocq.

    The rounding follows {coq}`round_generic` with {coq}`ulp` precision.
-/
def myRoundingFunction := ...
```

**Output**: The identifiers render as hyperlinks to their Flocq documentation:
- `generic_format` → [Core.Generic_fmt](https://flocq.gitlabpages.inria.fr/html/Flocq.Core.Generic_fmt.html#generic_format)
- `ulp` → [Core.Ulp](https://flocq.gitlabpages.inria.fr/html/Flocq.Core.Ulp.html#ulp)

## Supported Flocq Modules

| Category | Modules | Example Prefixes |
|----------|---------|------------------|
| **Core** | Defs, Raux, Zaux, Generic_fmt, Ulp, Round_pred, FIX, FLX, FLT, FTZ | `bpow`, `generic_format`, `ulp`, `FLT_` |
| **Calc** | Bracket, Div, Sqrt, Plus, Mult | `bracket_`, `Fdiv`, `Fsqrt` |
| **Prop** | Relative, Sterbenz, Plus_error, Mult_error, Div_error | `relative_error`, `sterbenz` |
| **IEEE754** | Binary, Bits | `B754_`, `Bplus`, `bits_of_` |

## Extending

Add custom prefix mappings:

```lean
import VersoCoq.Flocq

def myMappings := VersoCoq.Flocq.addPrefixMapping
  VersoCoq.Flocq.allPrefixMappings
  "MyCoq_" "My.Module.Path"
```

## API Reference

### `VersoCoq.Flocq`

| Function | Type | Description |
|----------|------|-------------|
| `inferUrl` | `String → Option String` | Get Flocq doc URL for identifier |
| `inferModule` | `String → Option String` | Get Flocq module path |
| `isFlocqDecl` | `String → Bool` | Check if identifier is from Flocq |
| `knownModules` | `List String` | All known Flocq modules |

### `VersoCoq.Roles`

| Role | Usage | Description |
|------|-------|-------------|
| `{coq}` | `` {coq}`identifier` `` | Coq/Flocq reference with auto-linking |

## Future Roadmap

- [ ] Coq LSP integration for hover documentation
- [ ] More Coq libraries (MathComp, Coquelicot, etc.)
- [ ] Bidirectional linking (Lean ↔ Coq)
- [ ] Type signature display in tooltips

## License

Apache 2.0

## Contributing

Contributions welcome! Please open issues or PRs on GitHub.
