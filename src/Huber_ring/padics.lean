import data.padics
import Huber_ring.basic

noncomputable theory
open_locale classical

variables {p : ℕ} [nat.prime p]

local attribute [-simp] padic.cast_eq_of_rat_of_nat

lemma ideal.one_mem_of_unit_mem {R : Type*} [comm_ring R] {I : ideal R} {u : units R} (h : (u : R) ∈ I) :
(1 : R) ∈ I :=
begin
  have : (u : R)*(u⁻¹ : units R) ∈ I, from I.mul_mem_right h,
  rwa u.mul_inv at this
end

lemma nat.prime_fpow_ne_zero {α : Type*} [discrete_linear_ordered_field α] (n:ℤ) : (p:α)^n ≠ 0 :=
by { apply ne_of_gt, apply fpow_pos_of_pos, exact_mod_cast nat.prime.pos ‹_› }

@[simp] theorem fpow_neg_mul_fpow_self {α : Type*} [discrete_field α] (n : ℕ) {x : α} (h : x ≠ 0) :
x^-(n:ℤ) * x^n = 1 :=
begin
  convert inv_mul_cancel (pow_ne_zero n h),
  rw [fpow_neg, one_div_eq_inv, fpow_of_nat]
end

-- This should be generalised in 10 directions
lemma real.fpow_strict_mono {x : ℝ} (hx : 1 < x) :
  strict_mono (λ n:ℤ, x ^ n) :=
λ m n h, show x ^ m < x ^ n,
begin
  have xpos : 0 < x := by linarith,
  have h₀ : x ≠ 0 := by linarith,
  have hxm : 0 < x^m := fpow_pos_of_pos xpos m,
  have hxm₀ : x^m ≠ 0 := ne_of_gt hxm,
  suffices : 1 < x^(n-m),
  { replace := mul_lt_mul_of_pos_right this hxm,
    simpa [*, fpow_add, mul_assoc, fpow_neg, inv_mul_cancel], },
  apply one_lt_fpow hx, linarith,
end

-- This should be generalised in 10 directions
lemma rat.fpow_strict_mono {x : ℚ} (hx : 1 < x) :
  strict_mono (λ n:ℤ, x ^ n) :=
λ m n h, show x ^ m < x ^ n,
begin
  have xpos : 0 < x := by linarith,
  have h₀ : x ≠ 0 := by linarith,
  have hxm : 0 < x^m := fpow_pos_of_pos xpos m,
  have hxm₀ : x^m ≠ 0 := ne_of_gt hxm,
  suffices : 1 < x^(n-m),
  { replace := mul_lt_mul_of_pos_right this hxm,
    simpa [*, fpow_add, mul_assoc, fpow_neg, inv_mul_cancel], },
  apply one_lt_fpow hx, linarith,
end

-- This should be generalised in 10 directions
@[simp] lemma real.fpow_mono {x : ℝ} (hx : 1 < x) {m n : ℤ} :
  x ^ m < x ^ n ↔ m < n :=
(real.fpow_strict_mono hx).lt_iff_lt

-- This should be generalised in 10 directions
@[simp] lemma rat.fpow_mono {x : ℚ} (hx : 1 < x) {m n : ℤ} :
  x ^ m < x ^ n ↔ m < n :=
(rat.fpow_strict_mono hx).lt_iff_lt

-- This should be generalised in 10 directions
@[simp] lemma rat.fpow_inj'' {x : ℚ} (h₀ : 0 < x) (h₁ : x ≠ 1) {m n : ℤ} :
  x ^ m = x ^ n ↔ m = n :=
begin
  split; intro h, swap, {simp [h]},
  rcases lt_trichotomy x 1 with H|rfl|H,
  { apply (rat.fpow_strict_mono (one_lt_inv h₀ H)).injective,
    show x⁻¹ ^ m = x⁻¹ ^ n,
    rw [← fpow_inv, ← fpow_mul, ← fpow_mul, mul_comm _ m, mul_comm _ n, fpow_mul, fpow_mul, h], },
  { contradiction },
  { exact (rat.fpow_strict_mono H).injective h, },
end

namespace padic_seq

def valuation (f : padic_seq p) : ℤ :=
if hf : f ≈ 0 then 0 else padic_val_rat p (f (stationary_point hf))

lemma norm_eq_pow_val {f : padic_seq p} (hf : ¬ f ≈ 0) :
  f.norm = p^(-f.valuation : ℤ) :=
begin
  delta norm valuation,
  rw [dif_neg hf, dif_neg hf],
  delta padic_norm,
  rw if_neg,
  assume H, apply cau_seq.not_lim_zero_of_not_congr_zero hf,
  intros ε hε,
  use (stationary_point hf),
  intros n hn,
  rw stationary_point_spec hf (le_refl _) hn,
  simpa [H] using hε,
end

lemma val_eq_iff_norm_eq {f g : padic_seq p} (hf : ¬ f ≈ 0) (hg : ¬ g ≈ 0) :
  f.valuation = g.valuation ↔ f.norm = g.norm :=
begin
  rw [norm_eq_pow_val hf, norm_eq_pow_val hg, ← neg_inj', rat.fpow_inj''],
  { exact_mod_cast nat.prime.pos ‹_› },
  { exact_mod_cast nat.prime.ne_one ‹_› },
end

end padic_seq

namespace padic

variable {p}

@[simp] lemma norm_p : ∥(p : ℚ_[p])∥ = p⁻¹ :=
begin
  have p₀ : p ≠ 0 := nat.prime.ne_zero ‹_›,
  have p₁ : p ≠ 1 := nat.prime.ne_one ‹_›,
  simp [p₀, p₁, norm, padic_norm, padic_val_rat, fpow_neg, padic.cast_eq_of_rat_of_nat],
end

@[simp] lemma norm_p_pow (n : ℤ) : ∥(p^n : ℚ_[p])∥ = p^-n :=
by rw [norm_fpow, norm_p, fpow_neg, one_div_eq_inv,
  ← fpow_inv, ← fpow_inv, ← fpow_mul, ← fpow_mul, mul_comm]

def valuation : ℚ_[p] → ℤ :=
quotient.lift (@padic_seq.valuation p _) (λ f g h,
begin
  by_cases hf : f ≈ 0,
  { have hg : g ≈ 0, from setoid.trans (setoid.symm h) hf,
    simp [hf, hg, padic_seq.valuation] },
  { have hg : ¬ g ≈ 0, from (λ hg, hf (setoid.trans h hg)),
    rw padic_seq.val_eq_iff_norm_eq hf hg,
    exact padic_seq.norm_equiv h },
end)

@[simp] lemma valuation_zero : valuation (0 : ℚ_[p]) = 0 :=
dif_pos ((const_equiv p).2 rfl)

@[simp] lemma valuation_one : valuation (1 : ℚ_[p]) = 0 :=
begin
  change dite (cau_seq.const (padic_norm p) 1 ≈ _) _ _ = _,
  have h : ¬ cau_seq.const (padic_norm p) 1 ≈ 0,
  { assume H, erw const_equiv p at H, exact one_ne_zero H },
  rw dif_neg h,
  simp,
end

@[simp, move_cast] theorem cast_fpow {α : Type*} [discrete_field α] [char_zero α] (q) (k : ℤ) :
  ((q ^ k : ℚ) : α) = q ^ k :=
begin
  cases k,
  { erw fpow_of_nat,
    rw rat.cast_pow,
    erw fpow_of_nat },
  { rw fpow_neg_succ_of_nat,
    rw fpow_neg_succ_of_nat,
    norm_cast }
end

lemma num_aux (p : ℕ) (n : ℤ) :  (coe : ℚ → ℝ) ((p : ℚ) ^ n) = (p : ℝ) ^ n :=
begin
  rw cast_fpow,
  congr' 1,
  norm_cast
end

lemma norm_eq_pow_val {x : ℚ_[p]} (hx : x ≠ 0) :
  ∥x∥ = p^(-x.valuation) :=
begin
  revert hx, apply quotient.induction_on' x, clear x,
  intros f hf,
  change (padic_seq.norm _ : ℝ) = (p : ℝ) ^ -padic_seq.valuation _,
  rw padic_seq.norm_eq_pow_val,
  change ↑((p : ℚ) ^ -padic_seq.valuation f) = (p : ℝ) ^ -padic_seq.valuation f,
  { apply num_aux },
  { apply cau_seq.not_lim_zero_of_not_congr_zero,
    contrapose! hf, apply quotient.sound, simpa using hf, }
end

@[simp] lemma valuation_p : valuation (p : ℚ_[p]) = 1 :=
begin
  have h : (1 : ℝ) < p := by exact_mod_cast nat.prime.one_lt ‹_›,
  apply neg_inj,
  apply (real.fpow_strict_mono h).injective,
  dsimp only,
  rw ← norm_eq_pow_val,
  { simp [fpow_inv], },
  { exact_mod_cast nat.prime.ne_zero ‹_›, }
end

end padic

namespace padic_int
open local_ring

variable {p}

@[simp] lemma norm_p : ∥(p : ℤ_[p])∥ = p⁻¹ :=
show ∥((p : ℤ_[p]) : ℚ_[p])∥ = p⁻¹, by exact_mod_cast padic.norm_p

@[simp] lemma norm_p_pow (n : ℕ) : ∥(p : ℤ_[p])^n∥ = p^(-n:ℤ) :=
show ∥((p^n : ℤ_[p]) : ℚ_[p])∥ = p^(-n:ℤ),
by { convert padic.norm_p_pow n, simp, }

def valuation (x : ℤ_[p]) := padic.valuation (x : ℚ_[p])

lemma norm_eq_pow_val {x : ℤ_[p]} (hx : x ≠ 0) :
  ∥x∥ = p^(-x.valuation) :=
begin
  convert padic.norm_eq_pow_val _,
  contrapose! hx,
  exact subtype.val_injective hx
end

@[simp] lemma valuation_zero : valuation (0 : ℤ_[p]) = 0 :=
padic.valuation_zero

@[simp] lemma valuation_one : valuation (1 : ℤ_[p]) = 0 :=
padic.valuation_one

@[simp] lemma valuation_p : valuation (p : ℤ_[p]) = 1 :=
by { delta valuation, exact_mod_cast padic.valuation_p }

lemma valuation_nonneg (x : ℤ_[p]) : 0 ≤ x.valuation :=
begin
  by_cases hx : x = 0,
  { simp [hx] },
  have h : (1 : ℝ) < p := by exact_mod_cast nat.prime.one_lt ‹_›,
  rw [← neg_nonpos, ← (real.fpow_strict_mono h).le_iff_le],
  show ↑p ^ -valuation x ≤ ↑p ^ 0,
  rw [← norm_eq_pow_val hx],
  simpa using x.property,
end

def mk_units {u : ℚ_[p]} (h : ∥u∥ = 1) : units ℤ_[p] :=
let z : ℤ_[p] := ⟨u, le_of_eq h⟩ in ⟨z, z.inv, mul_inv h, inv_mul h⟩

@[simp]
lemma mk_units_eq {u : ℚ_[p]} (h : ∥u∥ = 1) : ((mk_units h : ℤ_[p]) : ℚ_[p]) = u :=
rfl

lemma exists_repr {x : ℤ_[p]} (hx : x ≠ 0) :
  ∃ (u : units ℤ_[p]) (n : ℕ), x = u*p^n :=
begin
  let u : ℚ_[p] := x*p^(-x.valuation),
  have repr : (x : ℚ_[p]) = u*p^x.valuation,
  { rw [mul_assoc, ← fpow_add],
    { simp },
    { exact_mod_cast nat.prime.ne_zero ‹_› } },
  have hu : ∥u∥ = 1,
    by simp [hx, nat.prime_fpow_ne_zero x.valuation, norm_eq_pow_val, fpow_neg, inv_mul_cancel],
  obtain ⟨n, hn⟩ : ∃ n : ℕ, valuation x = n,
    from int.eq_coe_of_zero_le (valuation_nonneg x),
  use [mk_units hu, n],
  apply subtype.val_injective,
  simp [hn, repr]
end

variable (p)

lemma span_p_is_maximal :
  (ideal.span ({p} : set ℤ_[p])).is_maximal :=
begin
  rw ideal.is_maximal_iff,
  split,
  { rw ideal.mem_span_singleton', push_neg, intro x,
    assume eq_one,
    suffices : ∥x * p∥ < 1,
    { apply ne_of_lt this, simp [eq_one] },
    have norm_p_lt_one : ∥(p:ℤ_[p])∥ < 1,
    { rw [norm_p], apply inv_lt_one, exact_mod_cast nat.prime.one_lt ‹_›, },
    simpa using mul_lt_mul' x.property norm_p_lt_one (norm_nonneg _) zero_lt_one, },
  { intros I x hI hx_ne hx_mem,
    rw ideal.mem_span_singleton' at hx_ne, push_neg at hx_ne,
    have x_ne_zero : x ≠ 0,
    { intro h,
      apply hx_ne 0,
      simp [h] },
    rcases exists_repr x_ne_zero with ⟨u, n, rep⟩,
    cases n,
    { rw [show x = u, by simpa using rep] at hx_mem,
      exact ideal.one_mem_of_unit_mem hx_mem },
    { exfalso,
      apply hx_ne (u*p^n),
      rw [rep],
      ring }, }
end

lemma nonunits_ideal_eq_span :
  nonunits_ideal ℤ_[p] = ideal.span {p} :=
unique_of_exists_unique (max_ideal_unique ℤ_[p])
  (nonunits_ideal.is_maximal _) (span_p_is_maximal p)

lemma nonunits_ideal_fg :
  (nonunits_ideal ℤ_[p]).fg :=
by { rw nonunits_ideal_eq_span, exact ⟨{p}, rfl⟩, }

lemma is_adic : is_ideal_adic (nonunits_ideal ℤ_[p]) :=
begin
  rw is_ideal_adic_iff, split,
  { intro n,
    sorry },
  { intros s hs,
    rw mem_nhds_sets_iff at hs,
    rcases hs with ⟨U, hU, x, hx⟩,
    sorry }
end

variable {p}

instance coe_is_ring_hom : is_ring_hom (coe : ℤ_[p] → ℚ_[p]) :=
{ map_one := rfl,
  map_mul := coe_mul,
  map_add := coe_add }

def algebra : algebra ℤ_[p] ℚ_[p] :=
@algebra.of_ring_hom ℤ_[p] _ _ _ (coe) padic_int.coe_is_ring_hom

lemma aux (p : ℚ) (n : ℤ) (hp : 1 ≤ p) (h : p ^ n < p) : p ^ n ≤ 1 :=
by simpa using fpow_le_of_le hp (le_of_not_lt $ λ h' : 0 < n, not_le_of_lt h $
  by simpa using fpow_le_of_le hp (int.add_one_le_iff.2 h'))

lemma coe_open_embedding : open_embedding (coe : ℤ_[p] → ℚ_[p]) :=
{ induced := rfl, inj := subtype.val_injective, open_range :=
    begin
      show is_open (set.range subtype.val),
      rw subtype.val_range,
      rw show {x : ℚ_[p] | ∥x∥ ≤ 1} = {x : ℚ_[p] | ∥x∥ < p},
      { ext x, split; intro h ; rw set.mem_set_of_eq at h ⊢,
        { calc  ∥x∥ ≤ 1 : h
               ... < _ : by exact_mod_cast (nat.prime.one_lt ‹_›) },
        { by_cases hx : x = 0,
          { simp [hx, zero_le_one] },
          { rcases padic_norm_e.image hx with ⟨n, hn⟩,
            have hp : 1 < p, from nat.prime.one_lt ‹_›,
            rw hn at h ⊢,
            norm_cast at h ⊢,
            apply aux, {exact_mod_cast le_of_lt hp}, {exact h} } } },
      rw ← ball_0_eq,
      exact metric.is_open_ball
    end }

variable (p)

def Huber_ring : Huber_ring ℤ_[p] :=
{ pod := ⟨ℤ_[p], infer_instance, infer_instance, by apply_instance,
  ⟨{ emb := open_embedding_id,
    J := (nonunits_ideal _),
    fin := nonunits_ideal_fg p,
    top := is_adic p,
    .. algebra.id ℤ_[p] }⟩⟩ }

end padic_int

namespace padic
open local_ring padic_int

def Huber_ring : Huber_ring ℚ_[p] :=
{ pod := ⟨ℤ_[p], infer_instance, infer_instance, by apply_instance,
  ⟨{ emb := padic_int.coe_open_embedding,
    J := (nonunits_ideal _),
    fin := nonunits_ideal_fg p,
    top := is_adic p,
    .. padic_int.algebra }⟩⟩ }

end padic
