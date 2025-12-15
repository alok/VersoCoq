/-
VersoCoq - Custom Documentation Roles

Verso documentation roles for Coq/Flocq references in literate Lean 4.

IMPORTANT: Due to Lean 4's attribute timing (`applicationTime := .afterCompilation`),
this module must be in a separate lean_lib that compiles BEFORE the main library
that uses these roles in docstrings.

Example lakefile.lean setup:
```lean
lean_lib MyProjectRoles where
  globs := #[.one `VersoCoq.Roles]  -- Or import VersoCoq

lean_lib MyProject where
  globs := #[.submodules `MyProject]
```
-/

import Lean.Elab.DocString
import VersoCoq.Flocq

open Lean Doc Elab
open scoped Lean.Doc.Syntax

namespace VersoCoq.Roles

/-- Extract the code content from inline syntax.

    Helper function that extracts the string from a single code inline element.
    Mimics the private `onlyCode` in `Lean.Elab.DocString.Builtin`.
-/
private def onlyCode {M : Type → Type} [Monad M] [MonadError M] (xs : TSyntaxArray `inline) : M StrLit := do
  if h : xs.size = 1 then
    match xs[0] with
    | `(inline|code($s)) => return s
    | other => throwErrorAt other "Expected code"
  else
    throwError "Expected precisely 1 code argument"

/-- Role for Coq/Flocq references with auto-linking.

    Usage in docstrings:
    ```
    /-- See {coq}`generic_format` for the format predicate. -/
    ```

    Behavior:
    - If the identifier matches a known Flocq prefix, renders as a hyperlink
      to the Flocq documentation (e.g., `generic_format` → Core.Generic_fmt)
    - Otherwise, renders as inline code without a link

    Supported Flocq modules:
    - Core: Defs, Raux, Zaux, Generic_fmt, Ulp, FIX, FLX, FLT, FTZ
    - Calc: Bracket, Div, Sqrt, Plus, Mult
    - Prop: Relative, Sterbenz, Plus_error, Mult_error, Div_error
    - IEEE754: Binary, Bits
-/
@[doc_role]
def coq (xs : TSyntaxArray `inline) : DocM (Inline ElabInline) := do
  let s ← onlyCode xs
  let txt := TSyntax.getString s
  -- Generate Flocq URL if the identifier matches a known pattern
  match Flocq.inferUrl txt with
  | some url => return .link #[.code txt] url
  | none => return .code txt

end VersoCoq.Roles
