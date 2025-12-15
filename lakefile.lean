import Lake
open Lake DSL

/-- verso-coq: Verso documentation roles for Coq/Flocq references

    Provides semantic documentation roles for literate Lean 4 projects
    that reference Coq libraries, particularly Flocq (Floats for Coq).

    Features:
    - `{coq}` role: Auto-links Coq identifiers to Flocq documentation
    - Extensible URL inference for Flocq modules
-/
package «verso-coq» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`linter.missingDocs, true⟩
  ]

/-- Verso dependency for doc role infrastructure -/
require verso from git "https://github.com/leanprover/verso" @ "v4.27.0-rc1"

/-- Core utilities (URL inference, module mappings) - no special compilation order needed -/
lean_lib VersoCoqCore where
  globs := #[.one `VersoCoq.Flocq]

/-- Doc roles library - must compile separately due to @[doc_role] attribute timing

    Import this in your project's lean_lib that needs {coq} role support.
    Due to Lean 4's `applicationTime := .afterCompilation`, this must be
    in a separate lean_lib that compiles BEFORE files using the roles.
-/
@[default_target]
lean_lib VersoCoq where
  globs := #[.one `VersoCoq, .one `VersoCoq.Roles]
