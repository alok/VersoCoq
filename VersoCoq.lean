/-
# VersoCoq

Verso documentation roles for Coq/Flocq references in literate Lean 4.

## Installation

Add to your `lakefile.lean`:
```lean
require VersoCoq from git "https://github.com/alok/VersoCoq"
```

## Usage

### Setup (Important!)

Due to Lean 4's attribute timing for `@[doc_role]`, you need a two-library setup:

```lean
-- In lakefile.lean:
lean_lib MyProjectRoles where
  globs := #[.one `VersoCoq.Roles]

@[default_target]
lean_lib MyProject where
  globs := #[.submodules `MyProject]
```

### In Docstrings

```lean
/-- This implements {coq}`generic_format` from Flocq.

    The rounding operation follows {coq}`round_generic`.
-/
def myFunction := ...
```

The `{coq}` role will:
- Render the identifier as inline code
- Auto-link to Flocq documentation if the identifier matches a known pattern

## Supported Flocq Modules

- **Core**: Defs, Raux, Zaux, Generic_fmt, Ulp, Round_pred, FIX, FLX, FLT, FTZ
- **Calc**: Bracket, Div, Sqrt, Plus, Mult, Round, Operations
- **Prop**: Relative, Sterbenz, Plus_error, Mult_error, Div_error
- **IEEE754**: Binary, Bits

## Extending

You can extend the prefix mappings in `VersoCoq.Flocq`:

```lean
import VersoCoq.Flocq

-- Add custom mappings
def myMappings := VersoCoq.Flocq.addPrefixMapping
  VersoCoq.Flocq.allPrefixMappings
  "MyPrefix_" "MyModule.Path"
```
-/

import VersoCoq.Flocq
import VersoCoq.Roles

namespace VersoCoq

-- Re-export Flocq utilities
export Flocq (inferUrl inferModule isFlocqDecl knownModules baseUrl)

end VersoCoq
