/-
VersoCoq - Flocq Documentation Utilities

URL inference and module mapping for Flocq (Floats for Coq) documentation.
https://flocq.gitlabpages.inria.fr/

This module provides utilities for auto-linking Coq identifiers to their
documentation in the Flocq library.
-/

namespace VersoCoq.Flocq

/-- Base URL for Flocq HTML documentation -/
def baseUrl : String := "https://flocq.gitlabpages.inria.fr/html/Flocq."

/-- Flocq module categories for organized prefix mapping -/
inductive ModuleCategory
  /-- Core modules: fundamental definitions and operations -/
  | core
  /-- Calc modules: calculation and operation implementations -/
  | calc
  /-- Prop modules: properties and error analysis -/
  | prop
  /-- IEEE754 modules: IEEE 754 standard implementations -/
  | ieee754
  deriving Repr, DecidableEq

/-- A mapping entry from declaration prefix to Flocq module path -/
structure PrefixMapping where
  /-- The prefix to match against declaration names -/
  prefix : String
  /-- The Flocq module path (e.g., "Core.Ulp") -/
  modulePath : String
  /-- Category for organizational purposes -/
  category : ModuleCategory
  deriving Repr

/-- Core Flocq module prefix mappings

    Order matters - more specific prefixes should come first.
    This list can be extended to support more Flocq modules.
-/
def corePrefixMappings : List PrefixMapping := [
  -- Fixed-point and floating-point format prefixes
  ⟨"FIX_", "Core.FIX", .core⟩,
  ⟨"FLX_", "Core.FLX", .core⟩,
  ⟨"FLT_", "Core.FLT", .core⟩,
  ⟨"FTZ_", "Core.FTZ", .core⟩,

  -- Rounding and truncation
  ⟨"Ztrunc", "Core.Raux", .core⟩,
  ⟨"Zceil", "Core.Raux", .core⟩,
  ⟨"Zfloor", "Core.Raux", .core⟩,
  ⟨"Znearest", "Core.Generic_fmt", .core⟩,
  ⟨"Zrnd", "Core.Generic_fmt", .core⟩,

  -- ULP (Unit in Last Place) operations
  ⟨"ulp", "Core.Ulp", .core⟩,
  ⟨"succ", "Core.Ulp", .core⟩,
  ⟨"pred", "Core.Ulp", .core⟩,

  -- Generic format operations
  ⟨"generic_format", "Core.Generic_fmt", .core⟩,
  ⟨"generic_", "Core.Generic_fmt", .core⟩,
  ⟨"round_", "Core.Generic_fmt", .core⟩,
  ⟨"scaled_mantissa", "Core.Generic_fmt", .core⟩,
  ⟨"cexp", "Core.Generic_fmt", .core⟩,
  ⟨"canonic", "Core.Generic_fmt", .core⟩,

  -- Basic definitions
  ⟨"bpow", "Core.Defs", .core⟩,
  ⟨"radix", "Core.Defs", .core⟩,

  -- Real auxiliary functions
  ⟨"Rabs", "Core.Raux", .core⟩,
  ⟨"ln_beta", "Core.Raux", .core⟩,
  ⟨"mag", "Core.Raux", .core⟩,
  ⟨"Rcompare", "Core.Raux", .core⟩,

  -- Integer auxiliary functions
  ⟨"Zaux", "Core.Zaux", .core⟩,
  ⟨"Z", "Core.Zaux", .core⟩
]

/-- Calculation module prefix mappings -/
def calcPrefixMappings : List PrefixMapping := [
  ⟨"Bracket", "Calc.Bracket", .calc⟩,
  ⟨"bracket_", "Calc.Bracket", .calc⟩,
  ⟨"inbetween", "Calc.Bracket", .calc⟩,
  ⟨"Fdiv", "Calc.Div", .calc⟩,
  ⟨"Fsqrt", "Calc.Sqrt", .calc⟩,
  ⟨"Fplus", "Calc.Plus", .calc⟩,
  ⟨"Fmult", "Calc.Mult", .calc⟩
]

/-- Property module prefix mappings -/
def propPrefixMappings : List PrefixMapping := [
  ⟨"relative_error", "Prop.Relative", .prop⟩,
  ⟨"error_", "Prop.Relative", .prop⟩,
  ⟨"Sterbenz", "Prop.Sterbenz", .prop⟩,
  ⟨"sterbenz", "Prop.Sterbenz", .prop⟩,
  ⟨"Plus_error", "Prop.Plus_error", .prop⟩,
  ⟨"Mult_error", "Prop.Mult_error", .prop⟩,
  ⟨"Div_error", "Prop.Div_error", .prop⟩
]

/-- IEEE 754 module prefix mappings -/
def ieee754PrefixMappings : List PrefixMapping := [
  ⟨"B754_", "IEEE754.Binary", .ieee754⟩,
  ⟨"binary", "IEEE754.Binary", .ieee754⟩,
  ⟨"Binary", "IEEE754.Binary", .ieee754⟩,
  ⟨"Bplus", "IEEE754.Binary", .ieee754⟩,
  ⟨"Bmult", "IEEE754.Binary", .ieee754⟩,
  ⟨"Bdiv", "IEEE754.Binary", .ieee754⟩,
  ⟨"Bsqrt", "IEEE754.Binary", .ieee754⟩,
  ⟨"Bfma", "IEEE754.Binary", .ieee754⟩,
  ⟨"bits_of_", "IEEE754.Bits", .ieee754⟩,
  ⟨"_of_bits", "IEEE754.Bits", .ieee754⟩
]

/-- All prefix mappings combined, ordered by specificity -/
def allPrefixMappings : List PrefixMapping :=
  corePrefixMappings ++ calcPrefixMappings ++ propPrefixMappings ++ ieee754PrefixMappings

/-- Infer the Flocq module path from a Coq declaration name.

    Searches through prefix mappings to find the best match.
    Returns `none` if no matching prefix is found.
-/
def inferModule (declName : String) : Option String :=
  allPrefixMappings.find? (fun m => declName.startsWith m.prefix) |>.map (·.modulePath)

/-- Infer the Flocq module category from a Coq declaration name. -/
def inferCategory (declName : String) : Option ModuleCategory :=
  allPrefixMappings.find? (fun m => declName.startsWith m.prefix) |>.map (·.category)

/-- Generate a full Flocq documentation URL for a declaration.

    Example: `inferUrl "generic_format"` returns
    `some "https://flocq.gitlabpages.inria.fr/html/Flocq.Core.Generic_fmt.html#generic_format"`
-/
def inferUrl (declName : String) : Option String :=
  inferModule declName |>.map fun modulePath =>
    s!"{baseUrl}{modulePath}.html#{declName}"

/-- Check if a declaration name is likely from Flocq -/
def isFlocqDecl (declName : String) : Bool :=
  inferModule declName |>.isSome

/-- Get all known Flocq modules -/
def knownModules : List String :=
  allPrefixMappings.map (·.modulePath) |>.eraseDups

/-- Register a custom prefix mapping at runtime (for extensibility)

    Note: This is a pure function that returns a new list.
    For persistent registration, store the result.
-/
def addPrefixMapping (mappings : List PrefixMapping) (m : PrefixMapping) : List PrefixMapping :=
  m :: mappings

end VersoCoq.Flocq
