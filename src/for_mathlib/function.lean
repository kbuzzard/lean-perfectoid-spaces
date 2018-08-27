lemma uncurry_def {α β γ} (f : α → β → γ) : function.uncurry f = (λp, f p.1 p.2) :=
funext $ assume ⟨a, b⟩, rfl