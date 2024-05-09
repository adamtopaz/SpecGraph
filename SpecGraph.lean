import SpecGraph.Widget

universe u

/--
The *category* of schemes.
Recall that a scheme $X = (X,\mathcal{O}_X)$ consists of the following data:

- A topological space $X$.
- A sheaf of local rings $\mathcal{O}_X$ on $X$.

such that $X$ is locally isomorphic to $\operatorname{Spec}(A)$ for some ring $A$.

Recall that one has
```math
\operatorname{Spec}(A) = \{ \mathfrak{p} \ \text{prime} \}.
```
-/
@[spec_decl]
def Scheme : Type u := sorry

/--
The category of pointed.
-/
@[spec_decl]
def PointedScheme : Type u := sorry

/--
We can associate a scheme to any pointed scheme.
-/
@[spec_decl]
def PointedScheme.toScheme (X : PointedScheme.{u}) : Scheme.{u} := sorry

/--
The category of profinite groups.
-/
@[spec_decl]
def ProfiniteGroup : Type u := sorry

/--
The etale fundamental group of a pointed Scheme.
-/
@[spec_decl]
def etalePi1 : PointedScheme.{u} → ProfiniteGroup.{u} := sorry

@[spec_decl]
def Scheme.IsHyperbolicCurve (X : Scheme.{u}) : Prop := sorry


@[spec_decl]
structure HyperbolicCurve where
  scheme : Scheme
  isHyperbolicCurve : scheme.IsHyperbolicCurve

attribute [spec_decl] HyperbolicCurve.mk

#spec_graph_of Scheme 2
