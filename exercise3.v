From mathcomp Require Import all_ssreflect.
Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

(**
  ----
  ** Exercise 1 *)

(**
Try to define a next function over 'I_n that correspond to the
successor function over the natural plus the special case that
"n -1" is mapped to zero *)

Program Definition onext n (x : 'I_n) : 'I_n :=
  Sub
(* The value *)  (*D*)(x.+1 %% n)
(* The proof *)  _.                         
Next Obligation.
(*D*) by case: x => [m /= ltmn]; rewrite ltn_mod (leq_trans _ ltmn).
(*A*)Qed.

Eval compute in val (onext (Ordinal (isT : 2 < 4))).
Eval compute in val (onext (Ordinal (isT : 3 < 4))).

(**
  ----
  ** Exercise 2 
*)

(**
   Show that injectivity is decidable for a function f : aT -> rT
   with  aT a finite 
*) 

Module MyInj.

Check injective.

Definition injectiveb (aT : finType) (rT : eqType) (f : aT -> rT) : bool :=
(*D*) [forall x : aT, forall y : aT, (f x == f y) ==> (x == y)].

Lemma injectiveP (aT : finType) (rT : eqType) (f : aT -> rT) : 
  reflect (injective f) (injectiveb f).
Proof.
(*D*)apply: (iffP forallP) => [Ibf x y Efxy|If x].
(*D*)  by move: Ibf => /(_ x) /forallP /(_ y); rewrite Efxy eqxx => /eqP.
(*D*)by apply/forallP=> y; apply/implyP => /eqP Efxy; apply/eqP; apply: If.
(*A*)Qed.

End MyInj.

(** 
  ----
  ** Exercise 3 
*)

(** 
   Try to formalize the following problem 
*)

(** 
  Given a parking  where the boolean indicates if the slot is occupied or not 
*)

Definition parking n := 'I_n -> 'I_n -> bool.

(**
   Number of cars at line i 
*)               

Definition sumL n (p : parking n) i := \sum_(j < n) p i j.

(**
   Number of cars at column j 
*)

Definition sumC n (p : parking n) j := \sum_(i < n) p i j.

(**
   Show that if 0 < n there is always two lines, or two columns, or a column and a line
   that have the same numbers of cars 
*)

(* Two intermediate lemmas to use injectivity  *)

Lemma leq_sumL n (p : parking n) i : sumL p i < n.+1.
Proof.
(*D*)have {2}<-: \sum_(i < n) 1 = n by rewrite -[X in _ = X]card_ord sum1_card.
(*D*)by apply: leq_sum => k; case: (p _ _).
(*A*)Qed.

Lemma leq_sumC n (p : parking n) j : sumC p j < n.+1.
Proof.
(*D*)have {2}<-: \sum_(i < n) 1 = n by rewrite -[X in _ = X]card_ord sum1_card.
(*D*)by apply: leq_sum => k; case: (p _ _).
(*A*)Qed.

Lemma inl_inj {A B} : injective (@inl A B). Proof. by move=> x y []. Qed.
Lemma inr_inj {A B} : injective (@inr A B). Proof. by move=> x y []. Qed.

Lemma result n (p : parking n) : 0 < n ->
  exists i, exists j,
   [\/  (i != j) /\ (sumL p i = sumL p j),
        (i != j) /\ (sumC p i = sumC p j) | sumL p i = sumC p j].
Proof.
(*D*)case: n p => [//|[|n]] p _ /=.
(*D*)  exists ord0, ord0; apply: Or33.
(*D*)  by rewrite /sumL /sumC !big_ord_recl !big_ord0.
(*D*)pose sLC (i : 'I_n.+2 + 'I_n.+2) :=
(*D*)  match i with
(*D*)  | inl i => Ordinal (leq_sumL p i)
(*D*)  | inr i => Ordinal (leq_sumC p i) end.
(*D*)have [sC_inj | /injectivePn /=] := altP (injectiveP sLC).
(*D*)  have := max_card (mem (codom sLC)); rewrite card_codom // card_sum !card_ord.
(*D*)  by rewrite !addnS !addSn !ltnS -ltn_subRL subnn ltn0.
(*D*)move=> [[i|i] [[j|j] //=]]; [| |move: i j => j i|];
(*D*)rewrite ?(inj_eq inj_inl, inj_eq inj_inr) => neq_ij [];
(*D*)by exists i, j; do ?[exact: Or31|exact: Or32|exact: Or33].
(*A*)Qed.

(** 
  ----
  ** Exercise 4 
*)

(** 
   Prove the following state by induction and by following Gauss proof.
 *)

Lemma gauss_ex_p1 : forall n, (\sum_(i < n) i).*2 = n * n.-1.
Proof.
(*D*)elim=> [|n IH]; first by rewrite big_ord0.
(*D*)rewrite big_ord_recr /= doubleD {}IH.
(*D*)case: n => [|n /=]; first by rewrite muln0.
(*D*)by rewrite -muln2 -mulnDr addn2 mulnC.
(*A*)Qed.

Lemma gauss_ex_p2 : forall n, (\sum_(i < n) i).*2 = n * n.-1.
Proof.
(*D*)case=> [|n/=]; first by rewrite big_ord0.
(*D*)rewrite -addnn.
(*D*)have Hf i : n - i < n.+1.
(*D*)  by apply: leq_trans (leq_subr _ _) _.
(*D*)pose f (i : 'I_n.+1) := Ordinal (Hf i).
(*D*)have f_inj : injective f.
(*D*)  move=> x y /val_eqP/eqP H.
(*D*)  apply/val_eqP => /=.
(*D*)  rewrite -(eqn_add2l (n - x)) subnK -1?ltnS  //.
(*D*)  by rewrite [n - x]H subnK -1?ltnS.
(*D*)rewrite {1}(reindex_inj f_inj) -big_split /=.
(*D*)rewrite -[X in _ = X * _]card_ord -sum_nat_const.
(*D*)by apply: eq_bigr => i _; rewrite subnK // -ltnS.
(*A*)Qed.

Lemma gauss_ex_p3 : forall n, (\sum_(i < n) i).*2 = n * n.-1.
Proof.
(*D*)case=> [|n/=]; first by rewrite big_ord0.
(*D*)rewrite -addnn {1}(reindex_inj rev_ord_inj) -big_split /=.
(*D*)rewrite -[X in _ = X * _]card_ord -sum_nat_const.
(*D*)by apply: eq_bigr => i _; rewrite subSS subnK // -ltnS.
(*A*)Qed.

(** 
  ----
   ** Exercise 5 
*)

Lemma sum_odd1 : forall n, \sum_(i < n) (2 * i + 1) = n ^ 2.
Proof.
(*D*)case=> [|n/=]; first by rewrite big_ord0.
(*D*)rewrite big_split -big_distrr /= mul2n gauss_ex_p3 sum_nat_const.
(*D*)by rewrite card_ord -mulnDr addn1 mulnn.
(*A*)Qed.

(** 
  ----
  ** Exercise 6 
*)

Lemma sum_exp : forall x n, x ^ n.+1 - 1 = (x - 1) * \sum_(i < n.+1) x ^ i.
Proof.
(*D*)move=> x n.
(*D*)rewrite mulnBl big_distrr mul1n /=.
(*D*)rewrite big_ord_recr [X in _ = _ - X]big_ord_recl /=.
(*D*)rewrite [X in _ = _ - (_ + X)](eq_bigr (fun i : 'I_n =>  x * x ^ i))
(*D*)      => [|i _]; last by rewrite -expnS.
(*D*)rewrite [X in _ = X - _]addnC [X in _ = _ - X]addnC subnDA addnK.
(*D*)by rewrite expnS expn0.
(*A*)Qed.

(**
  ----
 ** Exercise 7 
*)

(** Prove the following state by induction and by using a similar trick
   as for Gauss noticing that n ^ 3 = n * (n ^ 2) *)

Lemma bound_square : forall n, \sum_(i < n) i ^ 2 <= n ^ 3.
Proof.
(*D*)move=> n.
(*D*)rewrite expnS -[X in _ <= X * _]card_ord -sum_nat_const /=.
(*D*)elim/big_ind2: _ => // [* |i]; first exact: leq_add.
(*D*)by rewrite leq_exp2r // ltnW.
(*A*)Qed.

(**
  ----
  ** Exercise 8 
*)

(**
  building a monoid law 
*)

Section cex.

Variable op2 : nat -> nat -> nat.

Hypothesis op2n0 : right_id 0 op2.

Hypothesis op20n : left_id 0 op2.

Hypothesis op2A : associative op2.

Hypothesis op2add : forall x y, op2 x y = x + y.

Canonical Structure op2Mon : Monoid.law 0 :=
  Monoid.Law op2A op20n op2n0.

Lemma ex_op2 : \big[op2/0]_(i < 3) i = 3.
Proof. 
(*D*)by rewrite !big_ord_recr big_ord0 /= !op2add. 
(*A*)Qed.

End cex.
