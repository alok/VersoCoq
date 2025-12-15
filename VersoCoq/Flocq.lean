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

/-- Prefix-to-module mapping as a tuple: (prefix, modulePath) -/
abbrev PrefixMapping := String × String

/-- Core Flocq module prefix mappings

    Order matters - more specific prefixes should come first.
    This list can be extended to support more Flocq modules.
-/
def corePrefixMappings : List PrefixMapping := [
  -- Fixed-point and floating-point format prefixes
  ("FIX_", "Core.FIX"),
  ("FLX_", "Core.FLX"),
  ("FLT_", "Core.FLT"),
  ("FTZ_", "Core.FTZ"),

  -- Rounding and truncation
  ("Ztrunc", "Core.Raux"),
  ("Zceil", "Core.Raux"),
  ("Zfloor", "Core.Raux"),
  ("Znearest", "Core.Generic_fmt"),
  ("Zrnd", "Core.Generic_fmt"),

  -- ULP (Unit in Last Place) operations
  ("ulp", "Core.Ulp"),
  ("succ", "Core.Ulp"),
  ("pred", "Core.Ulp"),

  -- Generic format operations
  ("generic_format", "Core.Generic_fmt"),
  ("generic_", "Core.Generic_fmt"),
  ("round_", "Core.Generic_fmt"),
  ("scaled_mantissa", "Core.Generic_fmt"),
  ("cexp", "Core.Generic_fmt"),
  ("canonic", "Core.Generic_fmt"),

  -- Basic definitions
  ("bpow", "Core.Defs"),
  ("radix", "Core.Defs"),

  -- Real auxiliary functions
  ("Rabs", "Core.Raux"),
  ("ln_beta", "Core.Raux"),
  ("mag", "Core.Raux"),
  ("Rcompare", "Core.Raux"),

  -- Integer auxiliary functions
  ("Zaux", "Core.Zaux"),
  ("Z", "Core.Zaux")
]

/-- Calculation module prefix mappings -/
def calcPrefixMappings : List PrefixMapping := [
  ("Bracket", "Calc.Bracket"),
  ("bracket_", "Calc.Bracket"),
  ("inbetween", "Calc.Bracket"),
  ("Fdiv", "Calc.Div"),
  ("Fsqrt", "Calc.Sqrt"),
  ("Fplus", "Calc.Plus"),
  ("Fmult", "Calc.Mult")
]

/-- Property module prefix mappings -/
def propPrefixMappings : List PrefixMapping := [
  ("relative_error", "Prop.Relative"),
  ("error_", "Prop.Relative"),
  ("Sterbenz", "Prop.Sterbenz"),
  ("sterbenz", "Prop.Sterbenz"),
  ("Plus_error", "Prop.Plus_error"),
  ("Mult_error", "Prop.Mult_error"),
  ("Div_error", "Prop.Div_error")
]

/-- IEEE 754 module prefix mappings -/
def ieee754PrefixMappings : List PrefixMapping := [
  ("B754_", "IEEE754.Binary"),
  ("binary", "IEEE754.Binary"),
  ("Binary", "IEEE754.Binary"),
  ("Bplus", "IEEE754.Binary"),
  ("Bmult", "IEEE754.Binary"),
  ("Bdiv", "IEEE754.Binary"),
  ("Bsqrt", "IEEE754.Binary"),
  ("Bfma", "IEEE754.Binary"),
  ("bits_of_", "IEEE754.Bits"),
  ("_of_bits", "IEEE754.Bits")
]

/-- All prefix mappings combined, ordered by specificity -/
def allPrefixMappings : List PrefixMapping :=
  corePrefixMappings ++ calcPrefixMappings ++ propPrefixMappings ++ ieee754PrefixMappings

/-- Infer the Flocq module path from a Coq declaration name.

    Searches through prefix mappings to find the best match.
    Returns `none` if no matching prefix is found.
-/
def inferModule (declName : String) : Option String :=
  allPrefixMappings.find? (fun (p, _) => declName.startsWith p) |>.map (·.2)

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
  allPrefixMappings.map (·.2) |>.eraseDups

/-- Register a custom prefix mapping at runtime (for extensibility)

    Note: This is a pure function that returns a new list.
    For persistent registration, store the result.
-/
def addPrefixMapping (mappings : List PrefixMapping) (pfx modulePath : String) : List PrefixMapping :=
  (pfx, modulePath) :: mappings

end VersoCoq.Flocq
