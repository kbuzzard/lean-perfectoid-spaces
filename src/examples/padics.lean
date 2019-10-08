import data.padics

import for_mathlib.field_power
import for_mathlib.finset
import for_mathlib.ideal_operations
import for_mathlib.normed_spaces
import for_mathlib.nnreal
import for_mathlib.padics
import for_mathlib.polynomial

import adic_space

/-!
# The p-adics form a Huber ring

In this file we show that ℤ_[p] and ℚ_[p] are Huber rings.
They are the fundamental examples of Huber rings.

We also show that (ℚ_[p], ℤ_[p]) is a Huber pair,
and that its adic spectrum is a singleton,
consisting of the standard p-adic valuation on ℚ_[p].
-/

noncomputable theory
open_locale classical

local postfix `⁺` : 66 := λ A : Huber_pair, A.plus

namespace linear_ordered_comm_group_with_zero
variables {Γ₀ : Type*} [linear_ordered_comm_group_with_zero Γ₀]

lemma inv_lt_inv {x y : Γ₀} (hx : x ≠ 0) (hy : y ≠ 0) :
  y⁻¹ < x⁻¹ ↔ x < y :=
begin
  suffices : ∀ {x y : Γ₀}, x ≠ 0 → y ≠ 0 → x < y → y⁻¹ < x⁻¹,
  { refine ⟨_, this hx hy⟩, intro h, rw [← inv_inv'' x, ← inv_inv'' y],
    apply this _ _ h; solve_by_elim [inv_ne_zero'], },
  clear hx hy x y,
  intros x y hx hy h,
  have hx' : x⁻¹ ≠ 0 := by solve_by_elim [inv_ne_zero'],
  have hy' : y⁻¹ ≠ 0 := by solve_by_elim [inv_ne_zero'],
  replace h := linear_ordered_structure.mul_lt_right' _ h hx',
  replace h := linear_ordered_structure.mul_lt_right' _ h hy',
  rw [mul_inv_cancel' _ hx, one_mul] at h,
  erw [mul_comm y x⁻¹, mul_assoc, mul_inv_cancel' _ hy, mul_one] at h,
  exact h
end

lemma inv_le_inv {x y : Γ₀} (hx : x ≠ 0) (hy : y ≠ 0) :
  y⁻¹ ≤ x⁻¹ ↔ x ≤ y :=
begin
  have := not_iff_not_of_iff (inv_lt_inv hy hx),
  push_neg at this,
  exact this
end

end linear_ordered_comm_group_with_zero

open local_ring

local attribute [instance] padic_int.algebra

variables (p : ℕ) [nat.prime p]

namespace padic_int

/-- The topology on ℤ_[p] is adic with respect to the maximal ideal.-/
lemma is_adic : is_ideal_adic (nonunits_ideal ℤ_[p]) :=
begin
  rw is_ideal_adic_iff,
  split,
  { intro n,
    show is_open (↑(_ : ideal ℤ_[p]) : set ℤ_[p]),
    rw power_nonunits_ideal_eq_norm_le_pow,
    simp only [norm_le_pow_iff_norm_lt_pow_succ],
    rw ← ball_0_eq,
    exact metric.is_open_ball },
  { intros s hs,
    rcases metric.mem_nhds_iff.mp hs with ⟨ε, ε_pos, hε⟩,
    obtain ⟨n, hn⟩ : ∃ n : ℕ, (p : ℝ)^-(n:ℤ) < ε,
    { have hp : (1:ℝ) < p := by exact_mod_cast nat.prime.one_lt ‹_›,
      obtain ⟨n, hn⟩ : ∃ (n:ℕ), ε⁻¹ < p^n := pow_unbounded_of_one_lt ε⁻¹ hp,
      use n,
      have hp' : (0:ℝ) < p^n,
      { rw ← fpow_of_nat, apply fpow_pos_of_pos, exact_mod_cast nat.prime.pos ‹_› },
      rw [inv_lt ε_pos hp', inv_eq_one_div] at hn,
      rwa [fpow_neg, fpow_of_nat], },
    use n, show (↑(_ : ideal ℤ_[p]) : set ℤ_[p]) ⊆ _,
    refine set.subset.trans _ hε,
    rw power_nonunits_ideal_eq_norm_le_pow,
    rw ball_0_eq,
    intros x hx,
    rw set.mem_set_of_eq at *,
    exact lt_of_le_of_lt hx hn }
end

section
open polynomial

lemma is_integrally_closed : is_integrally_closed ℤ_[p] ℚ_[p] :=
{ inj := subtype.val_injective,
  closed :=
  begin
    rintros x ⟨f, f_monic, hf⟩,
    have bleh : eval₂ (algebra_map ℚ_[p]) x ((finset.range (nat_degree f)).sum (λ (i : ℕ), C (coeff f i) * X^i)) =
      ((finset.range (nat_degree f)).sum (λ (i : ℕ), eval₂ (algebra_map ℚ_[p]) x $ C (coeff f i) * X^i)),
    { exact (finset.sum_hom _).symm },
    erw subtype.val_range,
    show ∥x∥ ≤ 1,
    rw [f_monic.as_sum, aeval_def, eval₂_add, eval₂_pow, eval₂_X] at hf,
    rw [bleh] at hf,
    replace hf := congr_arg (@has_norm.norm ℚ_[p] _) hf,
    contrapose! hf with H,
    apply ne_of_gt,
    rw [norm_zero, padic_norm_e.add_eq_max_of_ne],
    { apply lt_of_lt_of_le _ (le_max_left _ _),
      rw [← fpow_of_nat, norm_fpow],
      apply fpow_pos_of_pos,
      exact lt_trans zero_lt_one H, },
    { apply ne_of_gt,
      apply lt_of_le_of_lt (padic.norm_sum _ _),
      rw finset.fold_max_lt,
      split,
      { rw [← fpow_of_nat, norm_fpow], apply fpow_pos_of_pos, exact lt_trans zero_lt_one H },
      { intros i hi,
        suffices : ∥algebra_map ℚ_[p] (coeff f i)∥ * ∥x∥ ^ i < ∥x∥ ^ nat_degree f,
        by simpa [eval₂_pow],
        refine lt_of_le_of_lt (mul_le_of_le_one_left _ _ : _ ≤ ∥x∥ ^ i) _,
        { rw [← fpow_of_nat], apply fpow_nonneg_of_nonneg, exact norm_nonneg _ },
        { exact (coeff f i).property },
        { rw [← fpow_of_nat, ← fpow_of_nat, (fpow_strict_mono H).lt_iff_lt],
          rw finset.mem_range at hi, exact_mod_cast hi, } } }
  end }

end

/-- The p-adic integers (ℤ_[p])form a Huber ring.-/
instance : Huber_ring ℤ_[p] :=
{ pod := ⟨ℤ_[p], infer_instance, infer_instance, by apply_instance,
  ⟨{ emb := open_embedding_id,
    J := (nonunits_ideal _),
    fin := nonunits_ideal_fg p,
    top := is_adic p,
    .. algebra.id ℤ_[p] }⟩⟩ }

end padic_int

section
variables {α : Type*} {β : Type*} [topological_space α] [topological_space β]
lemma is_open_map.image_nhds {f : α → β} (hf : is_open_map f)
  {x : α} {U : set α} (hU : U ∈ nhds x) : f '' U ∈ nhds (f x) :=
begin
  apply (is_open_map_iff_nhds_le f).mp hf x,
  change f ⁻¹' (f '' U) ∈ nhds x,
  filter_upwards [hU],
  exact set.subset_preimage_image f U
end
end

open local_ring set padic_int

/-- The p-adic numbers (ℚ_[p]) form a Huber ring.-/
instance padic.Huber_ring : Huber_ring ℚ_[p] :=
{ pod := ⟨ℤ_[p], infer_instance, infer_instance, by apply_instance,
  ⟨{ emb := coe_open_embedding,
    J := (nonunits_ideal _),
    fin := nonunits_ideal_fg p,
    top := is_adic p,
    .. padic_int.algebra }⟩⟩ }

/-- The p-adic numbers form a Huber pair (with the p-adic integers as power bounded subring).-/
@[reducible] def padic.Huber_pair : Huber_pair :=
{ plus := ℤ_[p],
  carrier := ℚ_[p],
  intel :=
  { is_power_bounded :=
    begin
      -- this entire goal ought to follow from some is_bounded.map lemma
      -- but we didn't prove that.
      suffices : is_bounded {x : ℚ_[p] | ∥x∥ ≤ 1},
      { rintro _ ⟨x, rfl⟩,
        show is_power_bounded (x:ℚ_[p]),
        refine is_bounded.subset _ this,
        rintro y ⟨n, rfl⟩,
        show ∥(x:ℚ_[p])^n∥ ≤ 1,
        rw _root_.norm_pow, -- TODO: put this in norm_field namespace in mathlib
        exact pow_le_one _ (norm_nonneg _) x.property, },
      have bnd := is_adic.is_bounded ⟨_, is_adic p⟩,
      intros U hU,
      rcases bnd ((coe : ℤ_[p] → ℚ_[p]) ⁻¹' U) _ with ⟨V, hV, H⟩,
      { use [(coe : ℤ_[p] → ℚ_[p]) '' V,
             coe_open_embedding.is_open_map.image_nhds hV],
        rintros _ ⟨v, v_in, rfl⟩ b hb,
        specialize H v v_in ⟨b, hb⟩ (mem_univ _),
        rwa [mem_preimage, coe_mul] at H },
      { rw ← coe_zero at hU,
        exact continuous_coe.continuous_at hU }
    end
    .. coe_open_embedding,
    .. is_integrally_closed p } }
.

-- Valuations take values in a linearly ordered monoid with a minimal element 0,
-- whereas norms in mathlib are defined to take values in ℝ.
-- This is a repackaging of the p-adic norm as a valuation with values in the non-negative reals.

/-- The standard p-adic valuation. -/
def padic.bundled_valuation : valuation ℚ_[p] nnreal :=
{ to_fun := λ x, ⟨∥x∥, norm_nonneg _⟩,
  map_zero' := subtype.val_injective norm_zero,
  map_one' := subtype.val_injective norm_one,
  map_mul' := λ x y, subtype.val_injective $ norm_mul _ _,
  map_add' := λ x y,
  begin
    apply le_trans (padic_norm_e.nonarchimedean x y),
    rw max_le_iff,
    simp [nnreal.coe_max],
    split,
    { apply le_trans (le_max_left ∥x∥ ∥y∥),
      apply le_of_eq, symmetry, convert nnreal.coe_max _ _,
      delta classical.decidable_linear_order nnreal.decidable_linear_order real.decidable_linear_order,
      congr, },
    { apply le_trans (le_max_right ∥x∥ ∥y∥),
      apply le_of_eq, symmetry, convert nnreal.coe_max _ _,
      delta classical.decidable_linear_order nnreal.decidable_linear_order real.decidable_linear_order,
      congr, },
  end }

-- move this
lemma group_with_zero.inv_inj {Γ₀ : Type*} [group_with_zero Γ₀] {g h : Γ₀} :
  g⁻¹ = h⁻¹ ↔ g = h :=
begin
  split,
  { intro H,
    by_cases Hg : g = 0,
    { by_cases Hh : h = 0, { rw [Hg, Hh] },
      have := congr_arg ((*) h) H, rw mul_inv_cancel' _ Hh at this,
      replace := eq_inv_of_mul_left_eq_one' _ _ this,
      rw [this, inv_inv''] },
    { have := congr_arg ((*) g) H, rw mul_inv_cancel' _ Hg at this,
      replace := eq_inv_of_mul_left_eq_one' _ _ this.symm,
      rw [this, inv_inv''] } },
  { exact congr_arg _ }
end

namespace valuation
variables {R : Type*} [comm_ring R]
variables {K : Type*} [discrete_field K]
variables {L : Type*} [discrete_field L] [topological_space L]
variables {Γ₀ : Type*} [linear_ordered_comm_group_with_zero Γ₀]
variables {Γ'₀ : Type*} [linear_ordered_comm_group_with_zero Γ'₀]

-- move this
lemma is_equiv_of_val_le_one (v : valuation K Γ₀) (v' : valuation K Γ'₀)
  (h : ∀ {x:K}, v x ≤ 1 ↔ v' x ≤ 1) :
  v.is_equiv v' :=
begin
  intros x y,
  by_cases hy : y = 0, { simp [hy, zero_iff], },
  rw show y = 1 * y, by rw one_mul,
  rw show x = (x * y⁻¹) * y, { rw [mul_assoc, inv_mul_cancel hy, mul_one], },
  iterate 2 {rw [v.map_mul _ y, v'.map_mul _ y]},
  rw [v.map_one, v'.map_one],
  split; intro H,
  { apply actual_ordered_comm_monoid.mul_le_mul_right',
    replace hy := v.ne_zero_iff.mpr hy,
    replace H := linear_ordered_structure.le_of_le_mul_right hy H,
    rwa h at H, },
  { apply actual_ordered_comm_monoid.mul_le_mul_right',
    replace hy := v'.ne_zero_iff.mpr hy,
    replace H := linear_ordered_structure.le_of_le_mul_right hy H,
    rwa h, },
end

-- move this
lemma canonical_valuation.surjective (v : valuation K Γ₀) :
  function.surjective (v.canonical_valuation) :=
begin
  rintro ⟨⟨⟨r⟩,⟨⟨s⟩,h⟩⟩⟩,
  refine ⟨s⁻¹ * r, _⟩,
  apply quotient.sound,
  refine ⟨1, is_submonoid.one_mem _, _⟩,
  rw [units.coe_one, mul_one],
  apply quotient.sound,
  refine ⟨_, h, _⟩,
  dsimp only [-sub_eq_add_neg],
  convert zero_mul _, rw [sub_eq_zero],
  dsimp, rw ← mul_assoc,
  congr, symmetry,
  show ideal.quotient.mk (supp v) _ * ideal.quotient.mk (supp v) _ = 1,
  rw ← is_ring_hom.map_mul (ideal.quotient.mk (supp v)),
  convert is_ring_hom.map_one (ideal.quotient.mk (supp v)),
  apply mul_inv_cancel,
  contrapose! h, subst s,
  refine (not_iff_not_of_iff localization.fraction_ring.mem_non_zero_divisors_iff_ne_zero).mpr _,
  exact not_not.mpr rfl
end

-- move this
lemma is_continuous_iff {v : valuation L Γ₀} :
  v.is_continuous ↔ ∀ x:L, is_open {y:L | v y < v x} :=
begin
  have help : ∀ x:L, value_monoid.to_Γ₀ v (v.canonical_valuation x) = v x,
  { intro x, show v x * (v 1)⁻¹ = v x, by simp },
  split,
  { intros h x,
    specialize h (v.canonical_valuation x),
    simpa only [(value_monoid.to_Γ₀_strict_mono v).lt_iff_lt.symm, help] using h, },
  { intros h x,
    rcases canonical_valuation.surjective v x with ⟨x, rfl⟩,
    simpa only [(value_monoid.to_Γ₀_strict_mono v).lt_iff_lt.symm, help] using h x, }
end

-- move this

/-- A valuation is trivial if it maps everything to 0 or 1.-/
def is_trivial (v : valuation R Γ₀) : Prop :=
∀ r:R, v r = 0 ∨ v r = 1

--move this
lemma trivial_is_trivial (I : ideal R) [hI : I.is_prime] :
  (trivial I : valuation R Γ₀).is_trivial :=
begin
  intro r,
  by_cases hr : r ∈ I; [left, right],
  all_goals
  { show ite _ _ _ = _,
    rw submodule.mem_coe at hr,
    simp [hr] }
end

variable [topological_ring L]

--move this
lemma is_trivial_is_continuous_iff_discrete (v : valuation L Γ₀) (hv : v.is_trivial) :
  v.is_continuous ↔ discrete_topology L :=
begin
  split; intro h,
  { rw valuation.is_continuous_iff at h,
    suffices : is_open ({(0:L)} : set L),
      from topological_add_group.discrete_iff_open_zero.mpr this,
    specialize h 1,
    rw v.map_one at h,
    suffices : {y : L | v y < 1} = {0}, by rwa this at h,
    ext x,
    rw [set.mem_singleton_iff, ← v.zero_iff],
    show v x < 1 ↔ v x = 0,
    split; intro hx,
    { cases hv x with H H, {assumption},
      { exfalso, rw H at hx, exact lt_irrefl _ hx }, },
    { rw hx, apply lt_of_le_of_ne linear_ordered_structure.zero_le zero_ne_one } },
  { resetI, intro g, exact is_open_discrete _ }
end

--move this
lemma is_trivial_iff {v : valuation K Γ₀} :
  v.is_trivial ↔ ∀ x:K, v x ≤ 1 :=
begin
  split; intros h x,
  { cases h x; simp *, },
  { contrapose! h, cases h with h₁ h₂,
    by_cases hx : v x ≤ 1,
    { refine ⟨x⁻¹, _⟩,
      rw [v.map_inv, ← linear_ordered_comm_group_with_zero.inv_lt_inv one_ne_zero,
        inv_inv'', inv_one'],
      { exact lt_of_le_of_ne hx h₂ },
      { exact inv_ne_zero' _ h₁ } },
    { push_neg at hx, exact ⟨_, hx⟩ } }
end

--move this
-- This is a hack, to avoid an fpow diamond.
lemma map_fpow_eq_one_iff {v : valuation K Γ₀} {x : K} (n : ℤ) (hn : n ≠ 0) :
  v (x^n) = 1 ↔ v x = 1 :=
begin
  have helper : ∀ x (n : ℕ), n ≠ 0 → (v (x^n) = 1 ↔ v x = 1),
  { clear hn n x, intros x n hn,
    erw [is_monoid_hom.map_pow v.to_monoid_hom],
    cases n, { contradiction, },
    show (v x)^(n+1) = 1 ↔ v x = 1,
    by_cases hx : x = 0, { rw [hx, v.map_zero, pow_succ, zero_mul], },
    change x ≠ 0 at hx,
    rw ← v.ne_zero_iff at hx,
    let u : units Γ₀ := group_with_zero.mk₀ _ hx,
    suffices : u^(n+1) = 1 ↔ u = 1,
    { rwa [units.ext_iff, units.ext_iff, units.coe_pow] at this, },
    split; intro h,
    { exact linear_ordered_structure.eq_one_of_pow_eq_one h },
    { rw [h, one_pow], } },
  by_cases hn' : 0 ≤ n,
  { lift n to ℕ using hn', rw [fpow_of_nat], norm_cast at hn, solve_by_elim },
  { push_neg at hn', rw ← neg_pos at hn',
    lift -n to ℕ using le_of_lt hn' with m hm,
    have hm' : m ≠ 0, { apply ne_of_gt, exact_mod_cast hn' },
    rw [← neg_neg n, ← mul_neg_one, fpow_mul, fpow_inv, v.map_inv, ← inv_one',
      group_with_zero.inv_inj, ← hm, inv_one'], solve_by_elim }
end

end valuation

--move this
lemma padic.not_discrete : ¬ discrete_topology ℚ_[p] :=
nondiscrete_normed_field.nondiscrete

--move this
lemma padic_int.not_discrete : ¬ discrete_topology ℤ_[p] :=
begin
  assume h,
  replace h := topological_add_group.discrete_iff_open_zero.mp h,
  apply padic.not_discrete p,
  refine topological_add_group.discrete_iff_open_zero.mpr _,
  have := coe_open_embedding.is_open_map _ h,
  rw image_singleton at this,
  exact_mod_cast this
end

/-- The adic spectrum Spa(ℚ_p, ℤ_p) is inhabited. -/
def padic.Spa_inhabited : inhabited (Spa $ padic.Huber_pair p) :=
{ default := ⟨Spv.mk (padic.bundled_valuation p),
  begin
    refine mk_mem_spa.mpr _,
    split,
    { rw valuation.is_continuous_iff,
      rintro y,
      change is_open {x : ℚ_[p] | ∥x∥ < ∥y∥ },
      rw ← ball_0_eq,
      exact metric.is_open_ball },
    { intro x, change ℤ_[p] at x, exact x.property },
  end⟩ }

/-- The adic spectrum Spa(ℚ_p, ℤ_p) is a singleton:
the only element is the standard p-adic valuation. -/
def padic.Spa_unique : unique (Spa $ padic.Huber_pair p) :=
{ uniq :=
  begin
    intros v,
    ext,
    refine valuation.is_equiv.trans _ (Spv.out_mk _).symm,
    apply valuation.is_equiv_of_val_le_one,
    intros x, change ℚ_[p] at x,
    split; intro h,
    { by_cases hx : ∃ y : ℤ_[p], x = y,
      { rcases hx with ⟨x, rfl⟩, exact x.property },
      { push_neg at hx,
        contrapose! h,
        obtain ⟨y, hy⟩ : ∃ y : ℤ_[p], x⁻¹ = y,
        { refine ⟨⟨x⁻¹, _⟩, rfl⟩, rw norm_inv, apply inv_le_one, apply le_of_lt, exact h },
        refine (linear_ordered_comm_group_with_zero.inv_lt_inv _ _).mp _,
        { exact one_ne_zero },
        { rw valuation.ne_zero_iff, contrapose! hx, use [0, hx] },
        { rw [inv_one', ← valuation.map_inv, hy],
          refine lt_of_le_of_ne (spa.map_plus v y) _,
          assume H,
          apply padic.not_discrete p,
          apply (valuation.is_trivial_is_continuous_iff_discrete _ _).mp v.property.left,
          rw valuation.is_trivial_iff,
          intro z,
          by_cases hx' : x = 0, { contrapose! h, simp [hx'], },
          rcases padic.exists_repr x hx' with ⟨u, m, rfl⟩, clear hx',
          by_cases hz : z = 0, { simp [hz], },
          rcases padic.exists_repr z hz with ⟨v, n, rfl⟩, clear hz,
          erw [valuation.map_mul, spa.map_unit, one_mul],
          by_cases hn : n = 0, { erw [hn, fpow_zero, valuation.map_one], },
          erw [← hy, valuation.map_inv, valuation.map_mul, spa.map_unit,
            one_mul, ← inv_one', group_with_zero.inv_inj,
            valuation.map_fpow_eq_one_iff, ← valuation.map_fpow_eq_one_iff n hn] at H,
          { erw H, exact le_refl _ },
          contrapose! h,
          rw [h, fpow_zero, mul_one, nnreal.coe_le], apply le_of_eq,
          erw ← padic_int.is_unit_iff, exact is_unit_unit _, } } },
    { exact spa.map_plus v ⟨x, h⟩, }
  end,
  .. padic.Spa_inhabited p }
