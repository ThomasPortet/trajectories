Require Import ssreflect ssrfun ssrbool eqtype ssrnat seq choice fintype prime div bigop.
Require Import ssralg poly polydiv polyorder ssrnum zmodp polyrcf qe_rcf_th complex.

Set Implicit Arguments.
Unset Strict Implicit.

Import GRing.Theory Num.Theory Num.Def.
Import Pdiv.Idomain.

Section normal_polynomial.

Variable (R : rcfType).

Fixpoint normal_seq (s : seq R) := 
   if s is (a::l1) then 
      if l1 is (b::l2) then
         if l2 is (c::l3) then 
            (normal_seq l1)
            && ((0 == a) || ((a * c <= b^+2) && (0 < a) && (0 < b)))
         else (0 <= a) && (0 < b)
      else (0 < a)
   else false.

Lemma normal_seq_3 : forall (a b c : R),
   normal_seq [::a; b; c] = 
    (0 <= b) && (0 < c) && ((0 == a) || ((a * c <= b^+2) && (0 < a) && (0 < b))).
Proof. by rewrite /=. Qed.

Definition normal := [qualify p : {poly R} | normal_seq p].

Lemma normalE p : p \is normal = 
   normal_seq p. 
Proof. by []. Qed.

Lemma polyseq_deg1 : forall a b : R, (a != 0) -> (a *: 'X + b%:P) = [::b; a] :>seq R.
Proof.
move=> a b Ha.
rewrite -mul_polyC -cons_poly_def polyseq_cons.
rewrite nil_poly polyC_eq0 Ha.
by rewrite polyseqC Ha.
Qed.

Lemma polyseq_deg2 : forall a b c : R, (a != 0) ->
   (a *: 'X^2 + b *: 'X + c%:P) = [:: c; b; a] :>seq R.
Proof.
move=> a b c Ha.
rewrite -(mul_polyC a) -(mul_polyC b) expr2 mulrA -mulrDl. 
rewrite -cons_poly_def polyseq_cons.
by rewrite mul_polyC polyseq_deg1.
Qed.

Lemma normal_coef_geq0 : forall p : {poly R},
   p \is normal -> (forall k, 0 <= p`_k). 
Proof.
case=> s Hs. 
rewrite normalE=>{Hs} //=.
case: s => // a [].
  move=> Ha [].
    by rewrite ltrW.
  by case.
move=> b l.
elim: l a b => [a b /andP [Ha Hb] | c l IHl a b].
  case=> //=.
  case=> //=.
    by rewrite ltrW.
  by case.
case/andP =>H1 /orP H2 [] /=.
rewrite le0r eq_sym.
case: H2=> [-> | /andP [/andP [_ ->]]] //.
  by rewrite orbT.
exact: (IHl b c H1).
Qed.

Lemma normal_lead_coef_gt0 : forall p : {poly R},
   p \is normal -> lead_coef p > 0.
Proof.
case=> s Hs.
rewrite normalE lead_coefE //= =>{Hs}. 
case: s => a // [].
  move=> Ha.
  by rewrite /=.
move=> b l.
elim: l a b =>[a b /andP [Ha Hb]| c l IHl a b ].
  by rewrite /=.
case/andP=>H1 /orP H2. rewrite /=.
exact: (IHl b c H1).
Qed.

Lemma normal_squares : forall p : {poly R},
   p \is normal -> (forall k, (1 <= k)%N -> p`_(k.-1) * p`_(k.+1) <= p`_k ^+2).
Proof.
case=> s Hs.
rewrite normalE=>{Hs} /=.
case: s=> // a [].
  move=> Ha [] // n Hn.
  rewrite /= mulr0.
  by apply: sqr_ge0.
move=> b l.
elim: l a b => [a b /andP [Ha Hb] | c l IHl a b].
  case=> //=.
  case=> //=.
    move=> _. rewrite mulr0. by apply: sqr_ge0.
  move=> n _. rewrite mulr0. by apply: sqr_ge0.
case/andP=> H1 /orP H2 [] //=.
case=> [H | n Hn] /=.
  case: H2. 
    move/eqP=> H2.
    rewrite -H2 mul0r. by apply: sqr_ge0.
  rewrite -andbA.
  move/andP=> H2.
  by apply: (@proj1 _ ((0<a) && (0<b))). 
apply: (@IHl b c H1 n.+1).
by apply: ltn0Sn.
Qed.

Lemma normal_some_coef_gt0 : forall p : {poly R},
   p \is normal -> (forall i, (0 < p`_i) ->
      (forall j, (i < j)%N -> (j < (size p).-1)%N -> 0 < p`_j)).
Proof.
case=> s Hs. 
rewrite normalE=>{Hs} //=.
case: s => // a [].
  move=> Hp [].
    move=> Ha. by case.  
  by case.
move=> b l.
elim: l a b => [a b /andP [Ha Hb] | c l IHl a b].
  case=> //=.
    move=> _; by case.
  case=> //=.
    move=> _; by case.
  case=> //=.
    move=> _; by case.
  move=> n _; by case.  
case/andP =>H1 /orP H2 [] /=.
(* i = 0 *)
  move=> Ha.
  case=> [ | m Hm1 Hm2] //=.
(* j = m.+1 *)
  have Hb : (0 < b).
    apply: (@proj2 (0 < a)); apply/andP.
    apply: (@proj2 (a * c <= b ^+ 2)); apply/andP.
    rewrite andbA.
    rewrite (ltr_eqF Ha) in H2.
    by case: H2. 
  case: m Hm1 Hm2=> [_ _  | k Hk1 Hk2] //=.    
(* m = k.+1 *)
  apply:  (IHl b c H1 0%N Hb k.+1) => //=.
(* i = n.+1 *)
move=> n Hn.
case=> [ |m Hm1 Hm2] //=.
(* j = m.+1 *)
by apply: (IHl b c H1 n Hn) => //=.
Qed.

Lemma prop_normal : forall p : {poly R},
   (forall k, 0 <= p`_k) /\
   (lead_coef p > 0) /\
   (forall k, (1 <= k)%N -> p`_(k.-1) * p`_(k.+1) <= (p`_k) ^+2) /\
   (forall i, (0 < p`_i) ->
      (forall j, (i < j)%N -> (j < (size p).-1)%N -> 0 < p`_j)) -> p \is normal.
Proof.
case=> s Hs.
rewrite normalE => /=.
case: s Hs => [ Hs | a l Hs] //=.
  case=> Hpos; case=> Hleadcoef; case=> Hcarre Hstpos.
  by rewrite -(@ltrr R 0).
case: l a Hs => [a Hs | b l a Hs] /=.
  case=> Hpos; case=> Hleadcoef; case=> Hcarre Hstpos.
  exact: Hleadcoef.
elim: l a b Hs=> [a b Hs | c l IHl a b Hs] /=.
  case=> Hpos; case=> Hleadcoef; case=> Hcarre Hstpos.
  apply/andP; split.
    exact: (Hpos 0%N).
  exact: Hleadcoef.
case=> Hpos; case=> Hleadcoef; case=> Hcarre Hstpos.
apply/andP; split.
  apply: (IHl b c).
  split. move=> k. exact: (Hpos k.+1).
  split. exact: Hleadcoef.
  split.
    case => [ | j Hj] //=.
    apply: (Hcarre j.+2). by apply: ltn0Sn.
  move=> i Hi j Hij Hj.
  apply: (Hstpos i.+1 Hi j.+1).
    by rewrite -(addn1 i) -(addn1 j) ltn_add2r.
  by rewrite -(addn1 (size l).+1) -(addn1 j) ltn_add2r.
case H : (0 == a) => //=.
have Ha : (0 < a).
  rewrite lt0r; apply/andP; split.
    move/eqP : H => H.
    apply/eqP; by apply: not_eq_sym.
  exact: (Hpos 0%N). clear H.
apply/andP; split.
  apply/andP; split.
    apply: (Hcarre 1%N). by apply: ltn0Sn.
  by done.
apply: (Hstpos 0%N Ha 1%N (ltn0Sn 0)).
rewrite -(addn1 0) -(addn1 (size l).+1) (@ltn_add2r 1).
by apply: ltn0Sn.
Qed.

(* Lemma 2.41 *)
Lemma monicXsubC_normal : forall a : R, ('X - a%:P) \is normal = (a <= 0).
move=> a.
rewrite normalE polyseqXsubC /=.
case Ha: (a <= 0).
  by rewrite oppr_ge0 Ha ltr01 andTb.
by rewrite oppr_ge0 Ha andFb.
Qed.

Definition inB (z : complex R) :=
   ((Re z) <= 0) && (Im(z) ^+2 <= 3%:R * Re(z) ^+2).

Lemma inBE : forall (z : complex R), (inB z) =
   ((Re z) <= 0) && (Im(z) ^+2 <= 3%:R * Re(z) ^+2).
Proof. by []. Qed.

(* Lemma 2.42 *)
Lemma quad_monic_normal : forall (z : complex R),
   (('X^2 + (- 2%:R * Re(z)) *: 'X + (Re(z) ^+2 + Im(z) ^+2)%:P) \is normal)
   = (inB z).
Proof.
move=> z.
apply/idP/idP.
(*first direction*)
  rewrite normalE  -(mulr1 'X^2) mulrC mul_polyC polyseq_deg2.
    rewrite inBE /=.
    case/andP=> H. case/andP : H => H1 H2 H3.
    apply/andP. split.
      rewrite -(@nmulr_rge0 _ (- 2%:R)) //.
      rewrite -oppr_gt0 opprK.  by apply: ltr0Sn.
    case/orP: H3=> H3.
      rewrite eq_sym addrC addr_eq0 in H3.
      move/eqP : H3=> H3.
      rewrite H3 -subr_ge0 opprK -{2}(mulr1 ((Re z)^+2)) (mulrC _ 1)
        -(mulrDl _ 1 (Re(z)^+2)).
      apply: mulr_ge0.
        apply: addr_ge0. 
          by apply ler0n.
        by apply: ler01.
      by apply:  sqr_ge0.
    case/andP : H3 => H3 _.
    case/andP : H3 => H3 _.
    rewrite mulr1 ComplexField.exprM sqrrN addrC -(ler_subr_addr)
       -{2}(mulr1 ((Re z)^+2)) (mulrC _ 1) -mulrBl -natrX // in H3.
    by rewrite mulrSr -addrA subrr addr0 in H3.
  by apply: oner_neq0.
(*second direction*)
rewrite inBE.
case/andP => Hrez Himz.
rewrite normalE  -(mulr1 'X^2) mulrC mul_polyC polyseq_deg2 /=.
  apply: andb_true_intro; split.
    apply: andb_true_intro; split.
      apply: mulr_le0 => //.
      rewrite (oppr_le0 2%:R). by apply: ler0n.
    by rewrite ltr01.
  rewrite eq_sym.
  case H : (Re z ^+2 + Im z ^+2 == 0).
    by apply: orTb.
  rewrite Bool.orb_false_l.
  apply: andb_true_intro; split.
    apply: andb_true_intro; split.
      rewrite mulr1.
      apply: (@ler_trans R (Re(z) ^+2 + (3%:R * Re(z)^+2))).
        by apply: (@ler_add R (Re(z)^+2) (Re(z)^+2) (Im(z)^+2) _).
      rewrite -{1}(mulr1 ((Re z)^+2)) (mulrC _ 1) -(mulrDl 1 _ (Re(z)^+2))
          ComplexField.exprM.
      by rewrite addrC sqrrN (expr2 2%:R) -natrM -(@natrD R 3 1).
    rewrite ltr_def.  
    apply: andb_true_intro; split.
      by rewrite H.
    apply: addr_ge0; by apply sqr_ge0.
  rewrite ltr_def.  
  apply: andb_true_intro; split.
    rewrite GRing.mulrI_eq0.
      case Himz2 : ((Im z) ^+2 == 0).
        move/eqP : Himz2 => Himz2.
        rewrite Himz2 addr0 in H.
        rewrite -sqrf_eq0.
        apply/eqP.
        by move/eqP : H.
      rewrite -sqrf_eq0.
      rewrite gtr_eqF //.
      have Himz3 : (0 < (Im z)^+2).
        rewrite ltr_def.
        apply/andP; split.
          by rewrite Himz2.
        by apply: sqr_ge0.
      rewrite -(@pmulr_rgt0 _ 3%:R).
        by apply: (ltr_le_trans Himz3 Himz).
      by apply: ltr0Sn.
    apply: lregN.
    apply/lregP.
    by rewrite pnatr_eq0.
  apply: mulr_le0 => //.
  rewrite oppr_le0. by apply: ler0n.
by apply: oner_neq0.
Qed.

Lemma normal_neq0 : forall (p : {poly R}), p \is normal -> p != 0.
Proof.
move=> p Hpnormal; rewrite -lead_coef_eq0.
by case: ltrgtP (normal_lead_coef_gt0 Hpnormal).
Qed.

Lemma normal_MX : forall (p : {poly R}),
   (*(p != 0) ->*) p \is normal -> p * 'X \is normal.
Proof.
move=> p Hpnormal.
have Hpneq0 := (normal_neq0 Hpnormal).
case : p Hpneq0 Hpnormal => s Hs.
(*case=> s Hs.*)
rewrite !normalE /= => Hp Hsnormal.
rewrite polyseqMX //=.
case : s Hs Hp Hsnormal => // a.
case => [Hs Hp Ha| b l].
  rewrite /= in Ha.
  apply/andP; split; by done.
elim: l a b => [b c Hs Hp Hab | c l Hcl a b Hs Hp Habcl].
  apply/andP; split.
    by done.
  apply/orP; by left.
apply/andP; split.
  by done.
apply/orP; by left.
Qed.

Lemma normal_MXn : forall (p : {poly R}) (n : nat),
   (*(p != 0) ->*) p \is normal -> p * 'X^n \is normal.
Proof.
move=> p n Hpnormal.
have Hpneq0 := (normal_neq0 Hpnormal).
elim : n => [ | n Hn].
  by rewrite expr0 mulr1.
rewrite exprSr mulrA.
apply: normal_MX.
(*  apply: mulf_neq0 => //.
  by rewrite -size_poly_gt0 size_polyXn.*)
apply: Hn => //.
Qed.

Lemma normal_MX_2 : forall (p : {poly R}),
   p * 'X \is normal -> p \is normal.
Proof.
move=> p HpXnormal.
have HpXneq0 := (normal_neq0 HpXnormal).
have Hpneq0 : p != 0.
  by rewrite -lead_coef_eq0 -lead_coefMX lead_coef_eq0.
(* one coef *)
case : p Hpneq0 HpXneq0 HpXnormal => s Hs.
rewrite !normalE /= => Hp HpX Hsnormal.
rewrite polyseqMX // in Hsnormal.
case : s Hs Hp HpX Hsnormal => [Hs Hp HpX H | a].
  rewrite /=.
  by rewrite /= ltrr in H.
(* two coeffs *)
case => [Hs Hp HpX Ha| b l].
  rewrite /= in Ha.
  rewrite /=.
  by move/andP : Ha; case =>_ ->.
(* at least 3 coeffs *)
elim: l a b => [b c Hs Hp HpX Hab | c l Hcl a b Hs Hp HpX Habcl].
  rewrite /= in Hab.
  rewrite /=.
  move/andP : Hab; case=> Hab _.
  move/andP : Hab; case=> Ha Hb.
  apply/andP; by split.
rewrite /= -/(normal_seq [::a, b, c & l]) in Habcl.
by move/andP : Habcl; case => H1 H2.
Qed.

Lemma normal_MXn_2 : forall (p : {poly R}) (n : nat),
   p * 'X^n \is normal -> p \is normal.
Proof.
move=> p n HpXnnormal.
have HpXnneq0 := (normal_neq0 HpXnnormal).
elim : n HpXnneq0 HpXnnormal => [H1 H2  | n Hn H1 H2].
  by rewrite expr0 mulr1 in H2.
rewrite exprSr mulrA in H2.
rewrite exprSr mulrA in H1.
apply: Hn.
  by rewrite -lead_coef_eq0 -lead_coefMX lead_coef_eq0.
by apply: normal_MX_2.
Qed.

Lemma normal_size_le1 : forall (p : {poly R}), (p \is normal) ->
   (size p <= 1%N)%N = (size p == 1%N)%N.
Proof.
move=> p Hpnormal.
apply/idP/idP.
  move=> Hpsize.
  rewrite eqn_leq.
  apply/andP; split => //.
  rewrite ltnNge leqn0 size_poly_eq0.
  by apply: normal_neq0.
move=> Hpsize.
rewrite leq_eqVlt.
by apply/orP; left.
Qed.

(* 0 is a root with multiplicity k iff the first k coefs are = 0 *)
Lemma normal_root0 : forall (p : {poly R}),
   (root p 0) -> (forall k, (k < (\mu_0 p))%N -> p`_k = 0).
Proof.
move=> p Hproot k Hkmu.
have H := (root_mu p 0).
rewrite subr0 Pdiv.IdomainMonic.dvdp_eq in H.
  move/eqP : H => H.
  by rewrite H coefMXn Hkmu.
by apply: monicXn.
Qed. 

(* for p normal : 0 is not a root iff all coefs are >0 *)
Lemma normal_0notroot_b : forall (p : {poly R}), p \is normal ->
   (~~(root p 0) = [forall k : 'I_((size p).-1), 0 < p`_k]).
Proof.
move=> p Hpnormal.
apply/idP/idP.
(* => *)
  move/rootPf=> H.
  rewrite horner_coef0 in H.
  move/eqP/eqP : H => H.
  have Hp0 : 0 < p`_0.
    rewrite ltr_def. apply/andP; split.
      by done.
    exact: (normal_coef_geq0 Hpnormal 0).
  apply/forallP.
  case. case=> [ | n Hn] //. 
  by apply: (normal_some_coef_gt0 Hpnormal Hp0 (ltn0Sn n)).
(* <= *)
apply: contraL.
move=> Hproot0.
rewrite negb_forall; apply/existsP.
have H0 : (0 < (size p).-1)%N.
  rewrite -subn1 -(ltn_add2r 1) !addn1 subn1 prednK.
    apply: (@root_size_gt1 _ 0 p).
      apply: normal_neq0.
      by done.
    by done.
  apply: (@ltn_trans 1).
    by [].
  apply: (@root_size_gt1 _ 0 p).
    by apply: normal_neq0.
  by [].
exists (Ordinal H0).
rewrite -lerNgt ler_eqVlt.
apply/orP; left.
move/rootPt : Hproot0=> Hproot0.
by rewrite horner_coef0 in Hproot0.
Qed.

Lemma normal_0notroot : forall (p : {poly R}), p \is normal ->
   ~~(root p 0) -> (forall k, (k < (size p).-1)%N -> 0 < p`_k).
Proof.
move=> p Hpnormal H.
rewrite normal_0notroot_b // in H.
move/forallP : H => H k Hk.
apply: (H (Ordinal Hk)).
Qed. 

(* product of 2 polynomials with coefs >0  has coefs >0 *)
Lemma prod_all_ge0 : forall (p : {poly R}) (q : {poly R}),
   (p != 0) -> (q != 0) ->
   (forall i, (i <= (size p).-1)%N -> 0 < p`_i) ->
   (forall j, (j <= (size q).-1)%N -> 0 < q`_j) ->
   forall k, (k <= (size (p * q)%R).-1)%N -> 0 < (p * q)`_k.
Proof.
move=> p q.
wlog: p q / ((size p).-1 <= (size q).-1)%N => H Hp Hq Hpcoef Hqcoef k Hk. 
  case/orP : (leq_total (size p).-1 (size q).-1) => H2.
    by apply: H. 
 rewrite mulrC; rewrite mulrC in Hk.
  by apply: (H q p H2).
case Hk2 : (k <= (size p).-1)%N.
  rewrite coefM.
  rewrite (bigD1 ord0) //= subn0.
  apply: (ltr_le_trans (y := (p`_0 * q`_k))).
    rewrite pmulr_lgt0.
      apply: Hpcoef.
      by rewrite polySpred.
    apply: Hqcoef.
    by apply: (@leq_trans ((size p).-1)).
  rewrite ler_addl sumr_ge0 //.
  case => /= i Hi Hi2.
  rewrite pmulr_rge0.
    case Hki : (k - i <= (size q).-1)%N.
      apply: ltrW. by apply: Hqcoef.
    rewrite le0r; apply/orP; left.
    rewrite -(coefK q) coef_poly /=.
    have Hki2 : ((k - i < (size q))%N = false).
      rewrite -[(size q)]prednK.
        by rewrite ltnS.
      by rewrite size_poly_gt0.
    by rewrite Hki2.
  apply: Hpcoef.
  by apply: (leq_trans (n:=k)). 
have Hk3 := (negbT Hk2).
rewrite -ltnNge in Hk3.
rewrite coefM.
have Hk4 : ((size p).-1 < k.+1)%N.
  by apply: (ltn_trans (n:=k)).
rewrite (bigD1 (Ordinal Hk4)) //=.
apply: (ltr_le_trans (y := (p`_(size p).-1 * q`_(k - (size p).-1)))).
  have Helpme: (k - (size p).-1 <= (size q).-1)%N.
    rewrite leq_subLR.
    by rewrite size_mul // -[size p]prednK ?size_poly_gt0 //
      -[size q]prednK ?size_poly_gt0 // addSn addnS -!pred_Sn in Hk.
  rewrite pmulr_rgt0.
    by apply: Hqcoef.
  by apply: Hpcoef.
rewrite ler_addl sumr_ge0 //.
case => /= i Hi Hi2.
apply: mulr_ge0.
  case Hi3 : (i <= (size p).-1)%N.
    apply: ltrW. by apply: Hpcoef.
  rewrite le0r; apply/orP; left.
  rewrite -(coefK p) coef_poly /=.
  have Hi4 : (i < size p)%N = false. 
    rewrite -[(size p)]prednK.
      by rewrite ltnS.
    by rewrite size_poly_gt0.
  by rewrite Hi4.
case Hki : (k - i <= (size q).-1)%N.
    apply: ltrW. by apply: Hqcoef.
  rewrite le0r; apply/orP; left.
  rewrite -(coefK q) coef_poly /=.
  have Hki2 : (k - i < size q)%N = false. 
    rewrite -[(size q)]prednK.
    by rewrite ltnS.
  by rewrite size_poly_gt0.
by rewrite Hki2. 
Qed.

(* exchange two sums *)
Lemma xchange : forall (T : Type) (idx : T) (op : Monoid.com_law idx) 
  (m n : nat) (F : nat -> nat -> T),
   \big[op/idx]_(m <= i < n) (\big[op/idx]_(m <= j < i.+1) F i j) =
      \big[op/idx]_(m <= h < n) \big[op/idx]_(h <= j < n) (F j h).
Proof.
Admitted. (**********)

Lemma normal_coef_chain_1 : forall (p : {poly R}), ~~(root p 0) ->
   (p \is normal) -> forall k, (0 < k)%N -> forall i,
     p`_k.-1 * p`_(k.+1 +i) <= p`_(k + i) * p`_k .
Proof.
move=> p Hp0notroot Hpnormal k Hk.
elim => [ |i Hi ] //.
  rewrite !addn0 -expr2.
  by apply: normal_squares.
rewrite -subr_ge0.
case Hik : (k + i.+1 < size p)%N.
  rewrite -(pmulr_lge0 (x:= p`_(k + i.+1))) //. 
    rewrite mulrDl mulNr subr_ge0.
    apply: (ler_trans (y:= p`_(k + i) * p`_k * p`_(k.+2 + i))).
      rewrite -[x in (x <= _)]mulrA [x in (_ * x)]mulrC !mulrA -!addSnnS
        -subr_ge0 -mulNr -mulrDl.
      case H : (p`_(k.+2 + i) == 0).
        move/eqP : H => ->.
        by rewrite mulr0.
      rewrite pmulr_lge0.
        by rewrite subr_ge0.
      rewrite ltr_def. apply/andP; split.
        by apply:negbT.
      by apply: normal_coef_geq0.
    have H := (normal_squares Hpnormal (k := k + i.+1)).
    rewrite addnS -pred_Sn in H.
    rewrite !addnS !addSn [x in (x * _)]mulrC [x in (_ <= x * _)]mulrC 
      -subr_ge0 -!(mulrA p`_k) -mulrN -mulrDr mulrC pmulr_lge0.
      rewrite subr_ge0 -expr2.
      apply: H.
      by apply: ltn0Sn.
    apply: normal_0notroot => //.
    apply: (leq_ltn_trans (n:=(k + i))).    
      by apply: leq_addr.
    by rewrite -subn1 ltn_subRL addnC addn1 -addnS.
   
  case Hik2 : (k + i.+1 == (size p).-1)%N.
     move/eqP : Hik2 => ->.
     rewrite -lead_coefE.
     by exact: normal_lead_coef_gt0.
   apply: normal_0notroot => //.
   rewrite ltn_neqAle.
   apply/andP; split.
     by apply: negbT.
   rewrite -ltnS prednK // size_poly_gt0.
   by apply: normal_neq0.
rewrite addSnnS.
have Hik2 := (negbT Hik).
rewrite -leqNgt in Hik2.
have Hik3 : (size p <= k + i.+2)%N.
  apply: (leq_trans (n := (k + i.+1))) => //.
  rewrite !addnS.
  by apply: leqnSn.
rewrite -{4}(coefK p) coef_poly //=.
rewrite leqNgt in Hik3.
by rewrite (negbTE Hik3) mulr0 oppr0 addr0 -{1}(coefK p) coef_poly  Hik mul0r.
Qed.

Lemma normal_coef_chain_2 : forall (p : {poly R}), ~~(root p 0) ->
   (p \is normal) -> forall k, (0 < k)%N -> forall i, (k <= i)%N ->
     p`_k.-1 * p`_(i.+1) <= p`_i * p`_k .
Proof.
move=> p Hp0notroot Hpnormal k Hk i Hi.
have H := (normal_coef_chain_1 Hp0notroot Hpnormal Hk (i - k)).
by rewrite !addnBA // addnC (addnC k i) -addnBA // subSnn addn1 addnK in H.
Qed.

(* Lemma 2.43, restricted version *)
Lemma normal_mulr_r : forall p q : {poly R}, ~~(root p 0) -> ~~(root q 0) ->
   p \is normal -> q \is normal -> (p * q) \is normal.
Proof.
move=> p q Hpzero Hqzero Hpnormal Hqnormal.
apply: prop_normal.
split.
(* first property *)
  move=> k.
  rewrite coefM.
  apply: sumr_ge0 => [i _] /=.
  apply: mulr_ge0.
    exact: (@normal_coef_geq0 _ Hpnormal i).
  exact: (@normal_coef_geq0 _ Hqnormal (k - i)).
split.
(* second property *)
  rewrite lead_coefM pmulr_lgt0.
    exact: (normal_lead_coef_gt0 Hpnormal).
  exact: (normal_lead_coef_gt0 Hqnormal).
split.
(* third property *)
  move=> k Hk. 
  rewrite -subr_ge0 !coefM prednK // expr2.
  rewrite !big_distrlr /=.
  (* separate first double sum in 3 parts *)
  rewrite -(big_mkord (fun i : nat => true)
    (fun i : nat => \sum_(j < k.+1) (p`_i * q`_(k - i) * (p`_j * q`_(k - j))))).
  rewrite -(big_mkord (fun i : nat => true)
    (fun i : nat => \sum_(j < k.+2) (p`_i * q`_(k.-1 - i) * (p`_j * q`_(k.+1 - j))))).
  rewrite (eq_bigr
   (fun i => \sum_(0 <= j < k.+1) p`_i * q`_(k - i) * (p`_j * q`_(k - j))));
  last by move => ? _ ; rewrite big_mkord.
  rewrite [x in _ - x](eq_bigr
   (fun i => \sum_(0 <= j < k.+2) p`_i * q`_(k.-1 - i) * (p`_j * q`_(k.+1 - j))));
  last by move => ? _ ; rewrite big_mkord.
  have H : \sum_(0 <= i < k.+1)
      \sum_(0 <= j < k.+1) p`_i * q`_(k - i) * (p`_j * q`_(k - j)) =
      \sum_(2 <= h < k.+1)
      \sum_(0 <= j < h.-1) p`_h * q`_(k - h) * (p`_j * q`_(k - j)) +
      \sum_(1 <= h < k.+1)
        p`_h * q`_(k - h) * (p`_(h.-1) * q`_(k - h.-1)) +
      \sum_(0 <= h < k.+1)
      \sum_(h <= j < k.+1) p`_h * q`_(k - h) * (p`_j * q`_(k - j)).
    have H2:  \sum_(0 <= i < k.+1)
      \sum_(0 <= j < k.+1) p`_i * q`_(k - i) * (p`_j * q`_(k - j)) =
       \sum_(0 <= i < k.+1)
        \sum_(0 <= j < i.-1) p`_i * q`_(k - i) * (p`_j * q`_(k - j)) +
        \sum_(0 <= i < k.+1)
         \sum_(i.-1 <= j < i) p`_i * q`_(k - i) * (p`_j * q`_(k - j)) +
         \sum_(0 <= i < k.+1)
          \sum_(i <= j < k.+1) p`_i * q`_(k - i) * (p`_j * q`_(k - j)).
      rewrite -big_split -big_split. 
      rewrite big_nat [x in (_ = x)]big_nat; apply: eq_bigr => i Hi.
      rewrite -big_cat_nat //.
        rewrite -big_cat_nat //.
        apply: ltnW; by move/andP : Hi; case=> _ ->.
      by apply: leq_pred.
    rewrite H2 {H2}.
    congr (_ + _).
    rewrite big_nat_recl.
    rewrite big_geq ?add0r; last by apply: leq_pred.
    rewrite big_nat_recl.
    rewrite (big_geq (m:=0.-1) (n:=0)) // ?add0r. 
    have H2 : \sum_(0 <= i < k) \sum_(i.+1.-1 <= j < i.+1)
       p`_i.+1 * q`_(k - i.+1) * (p`_j * q`_(k - j)) =
       \sum_(1 <= h < k.+1) p`_h * q`_(k - h) * (p`_h.-1 * q`_(k - h.-1)).
      rewrite big_add1 -pred_Sn big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr=> i Hi.
      by rewrite -pred_Sn big_nat1.
    rewrite H2 {H2}.
    congr (_ + _).
    rewrite -{1}(prednK Hk).
    rewrite big_nat_recl.
    rewrite big_geq // add0r.
    by rewrite big_add1 big_add1 -pred_Sn.
  rewrite H {H}.
  (* separate second double sum in 3 parts *)
  have H :  \sum_(0 <= i < k)
      \sum_(0 <= j < k.+2) p`_i * q`_(k.-1 - i) * (p`_j * q`_(k.+1 - j)) =
       \sum_(0 <= h < k)
      \sum_(0 <= j < h.+1) p`_h * q`_(k.-1 - h) * (p`_j * q`_(k.+1 - j)) +
      \sum_(1 <= i < k.+1) p`_(i.-1) * q`_(k - i) * (p`_i * q`_(k.+1 - i)) +
      \sum_(0 <= h < k)
      \sum_(h.+2 <= j < k.+2) p`_h * q`_(k.-1 - h) * (p`_j * q`_(k.+1 - j)).
    rewrite big_add1 -pred_Sn -!big_split big_nat [x in (_ = x)]big_nat.
    apply: eq_bigr => h Hh.    
    rewrite (big_cat_nat (n:= h.+1) (GRing.add_comoid R) (fun j => true) 
      (fun j => p`_h * q`_(k.-1 - h) * (p`_j * q`_(k.+1 - j))) ).
        rewrite (big_cat_nat (n:= h.+2) (m:=h.+1) (GRing.add_comoid R) (fun j => true) 
          (fun j => p`_h * q`_(k.-1 - h) * (p`_j * q`_(k.+1 - j))) ).
            rewrite big_nat1 -pred_Sn /= -/(nth 0 _ (h.+1)) !addrA.
            congr (_ + _); congr (_ + _).
            by rewrite -(addn1 h) (addnC h 1%N) (subnDA 1 k h) subn1.
          apply: (ltn_trans (n:=h.+1)); by apply: ltnSn.
        move/andP: Hh; case => Hh1 Hh2.
        apply: (ltn_trans (n:=h.+2)). by apply: ltnSn.
        by rewrite -(addn2 h) -(addn2 k) ltn_add2r.
      by done.
    move/andP: Hh; case => Hh1 Hh2.
    by apply: (ltn_trans (n:=k)).
  (* canceling one of the three terms *)
  rewrite H {H}
  [x in ((x + _) - _)]addrC -[x in (_ - x)]addrA [x in (_ - (_ + x))]addrC
  !opprD !addrA addrC -sumrN !addrA -big_split.
  have H : \big[GRing.add_comoid R/0]_(1 <= i < k.+1)
      (GRing.add_comoid R)
        (- (p`_i.-1 * q`_(k - i) * (p`_i * q`_(k.+1 - i))))
        (p`_i * q`_(k - i) * (p`_i.-1 * q`_(k - i.-1))) = 0.
    rewrite big_split sumrN /= addrC.
    apply/eqP. rewrite subr_eq0. apply/eqP.
    rewrite big_nat [x in (_ = x)]big_nat.
    apply: eq_bigr => i Hi.
    rewrite mulrC -[x in (x = _)]mulrA [x in (_ * x = _)]mulrC
      [x in (_ * (x * _) = _)]mulrC !mulrA.
    congr (_ * _).
    rewrite -subn1 subnBA ?addn1 //.
    move/andP : Hi; by case => ->.
  (* rotating sums around and splitting off bits of them *)
  rewrite H {H} add0r big_add1 -pred_Sn.
  rewrite (eq_big 
    (F1 := fun i =>  \sum_(0 <= j < i.+1.-1) p`_i.+1 * q`_(k - i.+1)
           * (p`_j * q`_(k - j)))
    (P1 := fun i => true)
    (fun i => true)
    (fun i => \sum_(1 <= l < i.+1) p`_i.+1 * q`_(k - i.+1) 
         * (p`_(l.-1) * q`_(k - (l.-1))))) //.
    have H :  \sum_(0 <= h < k)
      \sum_(h.+2 <= j < k.+2) p`_h * q`_(k.-1 - h) * (p`_j * q`_(k.+1 - j)) =
       \sum_(1 <= i < k.+1)
      \sum_(i <= l < k.+1) p`_i.-1 * q`_(k - i) * (p`_l.+1 * q`_(k - l)).
      rewrite big_add1 -pred_Sn.
      apply: eq_big_nat => i Hi.
      rewrite big_add1 -pred_Sn.
      apply: eq_big_nat => l Hl.
      by rewrite -pred_Sn subSS -(addn1 i) (addnC i 1%N) subnDA -subn1.
    rewrite H {H} xchange big_nat_recl.
    have H : \sum_(0 <= i < k)
       \sum_(i.+1 <= j < k.+1) p`_i.+1 * q`_(k - i.+1) * (p`_j * q`_(k - j)) =
       \sum_(1 <= h < k.+1)
       \sum_(h <= j < k.+1) p`_h * q`_(k - h) * (p`_j * q`_(k - j)).
      by rewrite big_add1 -pred_Sn.
    rewrite H {H} [x in (_ + (_ + _) - x - _)]xchange
      -{12}(prednK Hk) [x in (_ + (_ + _) - x - _)]big_nat_recl.
    have H :(\big[GRing.add_comoid R/0]_(0 <= i < k.-1)
         \big[GRing.add_comoid R/0]_(i.+1 <= j < k)
            (p`_j * q`_(k.-1 - j) * (p`_i.+1 * q`_(k.+1 - i.+1))) =
         \sum_(1 <= h < k)
      \sum_(h <= j < k) p`_h * q`_(k.+1 - h) * (p`_j * q`_(k.-1 - j))).
      rewrite big_add1 big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => i Hi.
      rewrite big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => j Hj.
      by rewrite mulrC.
    rewrite H {H}.
    have H : \sum_(1 <= i < k.+1)
      \sum_(i <= l < k.+1) p`_i.-1 * q`_(k - i) * (p`_l.+1 * q`_(k - l)) =
      \sum_(1 <= h < k)
        \sum_(h <= j < k) p`_h.-1 * q`_(k - h) * (p`_j.+1 * q`_(k - j)) +
      \sum_(1 <= i < k.+1) p`_i.-1 * q`_(k - i) * (p`_k.+1 * q`_0).
      rewrite (big_cat_nat (GRing.add_comoid R) (n:= k)) //
        big_nat1 big_nat1
        [x in (_ = _ + x)](big_cat_nat (GRing.add_comoid R) (n:= k)) //
        big_nat1 (addnK k 0%N) Monoid.addmA.
      congr (_ + _).
      rewrite -big_split big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => i Hi.
      rewrite  (big_cat_nat (GRing.add_comoid R) (n:= k)) //.
        rewrite big_nat1.
        by rewrite (addnK k 0%N).
      apply: ltnW.
      by move/andP : Hi; case =>  _ ->.
    rewrite H {H}.
    have H : \sum_(1 <= h < k.+1)
       \sum_(h <= j < k.+1) p`_h * q`_(k - h) * (p`_j * q`_(k - j)) =
       \sum_(1 <= h < k)
         \sum_(h <= j < k) p`_h * q`_(k - h) * (p`_j * q`_(k - j)) +
       \sum_(1 <= i < k.+1) p`_i * q`_(k - i) * (p`_k * q`_0).
      rewrite (big_cat_nat (GRing.add_comoid R) (n:= k)) //
        big_nat1 big_nat1
        [x in (_ = _ + x)](big_cat_nat (GRing.add_comoid R) (n:= k)) //
        big_nat1 (addnK k 0%N) Monoid.addmA.
      congr (_ + _).
      rewrite -big_split big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => i Hi.
      rewrite  (big_cat_nat (GRing.add_comoid R) (n:= k)) //.
        rewrite big_nat1.
        by rewrite (addnK k 0%N).
      apply: ltnW.
      by move/andP : Hi; case =>  _ ->.
    rewrite H {H} !opprD -!sumrN !addrA
      -[x in (x + _)]addrA -big_split
      -[x in ((((x + _) + _) + _) + _)]addrA
      [x in (((((_ + x) + _) + _) + _) + _)]addrC
      !addrA -big_split
      -addrA [x in (_ + x)]addrC !addrA addrC !addrA -big_split.
    have H : \big[GRing.add_comoid R/0]_(1 <= i < k)
      (GRing.add_comoid R)
        ((GRing.add_comoid R)
           (-
            (\sum_(i <= j < k) p`_i * q`_(k.+1 - i) * (p`_j * q`_(k.-1 - j))))
           (-
            (\sum_(i <= j < k) p`_i.-1 * q`_(k - i) * (p`_j.+1 * q`_(k - j)))))
        ((GRing.add_comoid R)
           (\big[GRing.add_comoid R/0]_(i <= j < k)
               (p`_j.+1 * q`_(k - j.+1) * (p`_i.-1 * q`_(k - i.-1))))
           (\sum_(i <= j < k) p`_i * q`_(k - i) * (p`_j * q`_(k - j)))) =
        \sum_(1 <= h < k) \sum_(h <= j < k) (p`_h * p`_j - p`_h.-1 * p`_j.+1) *
          (q`_(k - h) * q`_(k - j) - q`_(k.+1 - h) * q`_(k.-1 - j)).
      rewrite big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => i Hi.
      move/andP: Hi; case => Hi1 Hi2.  
      rewrite -!sumrN -!big_split big_nat [x in (_ = x)]big_nat.
      apply: eq_bigr => j Hj.
      move/andP: Hj; case => Hj1 Hj2.
      rewrite /= -/(nth 0 _ j.+1) !addrA addrC.
      by rewrite -mulrN -!mulrA !addrA  -(mulrDr p`_i)
        -mulrN !mulrA (mulrC _ p`_j) (mulrC _ p`_j) -!mulrA
        -(mulrDr p`_j) mulrN mulrA
        -[x in ((_ * _) + x + _ = _)]mulNr [x in (_ + (_ * x) + _ = _)]mulrA
        [x in (_ + (_ * (x * _)) + _ = _)]mulrC !mulrA 
        [x in (_ + ((x * _) * _) + _ = _)]mulNr
        -[x in (_ + _ + (x * _) = _)]mulrA 
        [x in (_ + _ + (_ * x * _) = _)]mulrC !mulrA 
        [x in (_ + _ + (x * _ * _) = _)]mulrC 
        -{2}(opprK (p`_i.-1 * p`_j.+1)) 
        -[x in (_ + _ + x = _)]mulrA 
        (mulNr (-(p`_i.-1 * p`_j.+1))) 
        -[x in (_ + _ + x  = _)]mulrN -addrA 
        -[x in (_ + (x + _) = _)]mulrA 
        -(mulrDr (- (p`_i.-1 * p`_j.+1))) 
        [x in (_ + _ * (_ - x) = _)]mulrC
        -{2}(subn1 i) subnBA // addn1 -{2}(addn1 j) (addnC j 1%N) 
        subnDA subn1 -mulrDl.
    rewrite H {H} -!addrA.
    apply: addr_ge0.
      rewrite big_nat; apply: sumr_ge0 => i Hi.
      rewrite big_nat; apply: sumr_ge0 => j Hj.
      apply: mulr_ge0.
      rewrite subr_ge0 [x in (_ <= x)]mulrC.
      apply: (normal_coef_chain_2 Hpzero Hpnormal).
        by move/andP : Hi; case => ->.
      by move/andP : Hj; case => ->.
    rewrite subr_ge0 [x in (x <= _)]mulrC.
    rewrite -subn1 -subnDA addnC addn1 subnS subSn.
      apply: (normal_coef_chain_2 Hqzero Hqnormal).
          rewrite subn_gt0.
          by move/andP : Hj; case => _ ->.
        apply: leq_sub => //.
        by move/andP : Hj; case => ->.
      apply: ltnW.
      by move/andP : Hi; case => _ ->.
    rewrite addrA [x in (0 <= _ + x)]addrC.
    rewrite -!addrA. rewrite [x in (0 <= _ + x)]addrA.
    rewrite -big_split addrC -!addrA.
    apply: addr_ge0.
      rewrite big_nat; apply: sumr_ge0 => i Hi.
      rewrite /= -/(nth 0 _ (k.+1)) -/(nth 0 _ 0)
        [x in (0 <= x * _ - _)]mulrC
        [x in (0 <= _ - x * _)]mulrC -!mulrA -mulrBr.
      apply: mulr_ge0.
        by apply: normal_coef_geq0.
      rewrite !mulrA -mulrBl.
      apply: mulr_ge0.
        rewrite subr_ge0 [x in (_ <= x)]mulrC.
        apply: (normal_coef_chain_2 Hpzero Hpnormal) => //.
          by move/andP : Hi; case=> ->.
        rewrite -ltnS; by move/andP : Hi; case=> _ ->.
      by apply: normal_coef_geq0.
    rewrite big_nat_recr addrA -big_split.
    apply: addr_ge0.
      rewrite big_nat; apply: sumr_ge0 => i Hi.
      rewrite /= -/(nth 0 _ (k.+1)) -/(nth 0 _ (i.+1)) -/(nth 0 _ 0)
        mulrC addrC -!mulrA -mulrBr.
      apply: mulr_ge0.
        by apply: normal_coef_geq0.
      rewrite mulrC mulrA [x in (0 <= x * _ - _)]mulrC -!mulrA -mulrBr.
      apply: mulr_ge0.
        by apply: normal_coef_geq0.
      rewrite subn0 subr_ge0 -subn1 -subnDA addnC subnDA subn1.
      apply: (normal_coef_chain_2 Hqzero Hqnormal).
        rewrite subn_gt0; by move/andP : Hi; case => _ ->.
      rewrite -{2}(subn0 k).
      by apply: leq_sub.
    rewrite subn0 (addnK k 0%N).
    apply: mulr_ge0; apply: mulr_ge0; by apply: normal_coef_geq0.
  move=> i _.
  rewrite big_add1 -pred_Sn.
  apply: eq_bigr => j _.
  by rewrite -pred_Sn.
(* fourth property *)
move=> i Hpqi j Hij Hj.
apply: prod_all_ge0 => //.
        by apply: normal_neq0.
      by apply: normal_neq0.
    move=> k.
    case Hk2 : ((size p).-1 <= k)%N => Hk1.
      have Hk : (k == (size p).-1).
        rewrite eqn_leq; apply/andP; by split.
      move/eqP : Hk => ->.
      rewrite -lead_coefE.
      exact: (normal_lead_coef_gt0 Hpnormal).
    have Hk3 := (negbT Hk2).
    rewrite -ltnNge in Hk3.
    by apply: normal_0notroot.
  move=> k.
  case Hk2 : ((size q).-1 <= k)%N => Hk1.
    have Hk : (k == (size q).-1).
      rewrite eqn_leq; apply/andP; by split.
    move/eqP : Hk => ->.
    rewrite -lead_coefE.
    exact: (normal_lead_coef_gt0 Hqnormal).
  have Hk3 := (negbT Hk2).
  rewrite -ltnNge in Hk3.
  by apply: normal_0notroot. 
by apply: ltnW.
Qed.

(* Lemma 2.43 *)
Lemma normal_mulr : forall p q : {poly R},
   p \is normal -> q \is normal -> (p * q) \is normal.
Proof.
move=> p q Hpnormal Hqnormal.
have Hp0 := (root_mu p 0).
have Hq0 := (root_mu q 0).
rewrite Pdiv.Field.dvdp_eq in Hp0.
rewrite Pdiv.Field.dvdp_eq in Hq0.
have Hp0notroot1 : (~~(root (p %/ ('X - 0%:P) ^+ \mu_0 p) 0) ).
  rewrite -mu_gt0.
    rewrite mu_div //.
    by rewrite (addnK (\mu_0 p) 0%N) ltnn.
  rewrite dvdp_div_eq0.
    by apply: normal_neq0.
  by apply: root_mu.
have Hq0notroot1 : (~~(root (q %/ ('X - 0%:P) ^+ \mu_0 q) 0) ).
  rewrite -mu_gt0.
    rewrite mu_div //.
    by rewrite (addnK (\mu_0 q) 0%N) ltnn.
  rewrite dvdp_div_eq0.
    by apply: normal_neq0.
  by apply: root_mu.
move/eqP : Hp0 => Hp0.
move/eqP : Hq0 => Hq0.
rewrite Hp0 Hq0.
rewrite [x in (x * _)]mulrC.
rewrite !mulrA. rewrite (mulrC _ (('X - 0%:P) ^+ \mu_0 q)) !mulrA.
rewrite -exprD.
rewrite {1}oppr0 addr0 -mulrA mulrC.
apply: normal_MXn.
apply: normal_mulr_r => //.
  rewrite Hp0 {2}oppr0 addr0 in Hpnormal.
  by apply: (normal_MXn_2 (n:=\mu_0 p)).  
rewrite Hq0 {2}oppr0 addr0 in Hqnormal.
by apply: (normal_MXn_2 (n:=\mu_0 q)).  
Qed.

(*Lemma real_complex_conjc : forall (x : R),
   (x%:C)^* = x%:C.
Proof.
move=> x.
by rewrite /= oppr0.
Qed.*)

Lemma normc_re_im : forall z : complex R,
   (normr z) ^+2 = ((Re z)^+2 + (Im z)^+2)%:C. 
Proof.
case.
move=> a b.
rewrite sqr_normc /=. simpc.
by rewrite -!expr2 mulrC -(addr0 (- (b * a) + b * a)) -addrA (@addKr R _ 0).
Qed.

Lemma re_conj : forall z : complex R,
   2%:R * (Re z)%:C = z + z^*.
Proof.
move=> z.
rewrite ReJ_add mulrC. apply: mulfVK.
by rewrite pnatr_eq0.
Qed.

Lemma im_conj : forall z : complex R,
   z - z^* = 2%:R * (Im z)%:C * 'i.
Proof.
move=> z.
rewrite ImJ_sub -!mulrA -expr2 sqr_i (mulrC _ (-1)) (mulrA _ (-1) _)
   mulrN1 opprB mulrC mulfVK.
  by [].
by rewrite pnatr_eq0.
Qed.

Lemma real_complex_conjc : forall p : {poly R},
   map_poly ((@conjc R) \o (real_complex R)) p  = 
   map_poly (real_complex R) p.
Proof.
elim/poly_ind.
  by rewrite !rmorph0.
move=> p c H.
by rewrite !rmorphD !rmorphM /= H !map_polyC !map_polyX /= -conjc_real.
Qed.

Lemma complex_root_conj_polyR : forall (p : {poly R}) (z : complex R),
   root (map_poly (real_complex R) p) z =
   root (map_poly (real_complex R) p) z^*.
Proof.
move=> p z.
apply/idP/idP => Hz.
  rewrite -complex_root_conj /= -map_poly_comp_id0.
    by rewrite real_complex_conjc.
  by rewrite conjc0.
rewrite -(conjcK z).
  rewrite -complex_root_conj /= -map_poly_comp_id0.
    by rewrite real_complex_conjc.
  by rewrite conjc0.
Qed.

Lemma factor_complex_roots : forall (z : complex R),
   map_poly (real_complex R) ('X^2 + (1 *- 2 * Re z) *: 'X +
   (Re z ^+ 2 + Im z ^+ 2)%:P) = ('X - z%:P) * ('X - (z^*)%:P).
Proof.
move=> z.
rewrite mulrBr !mulrBl opprB (addrC (z%:P * (z^*)%:P) _) addrA (mulrC _ (z^*)%:P)
     -(addrA ('X * 'X) _) -expr2 -(opprD (z%:P * 'X) ((z^*)%:P * 'X))
     -(mulrDl z%:P _ 'X) -(polyC_add z z^*) -(polyC_mul z z^*) -sqr_normc
     -re_conj normc_re_im mul_polyC.
rewrite -(opprK (Re z ^+ 2 + Im z ^+ 2)%:P) map_poly_is_additive.
rewrite -polyC_opp -mul_polyC map_polyC.
  (***)
rewrite -(opprK ((1 *- 2 * Re z)%:P * 'X)) map_poly_is_additive map_polyXn.
rewrite -(opprK (Re z ^+ 2 + Im z ^+ 2)%:C%:P).
rewrite -(polyC_opp (Re z ^+ 2 + Im z ^+ 2)%:C).
have H : (- (Re z ^+ 2 + Im z ^+ 2)%:C) = (- (Re z ^+ 2 + Im z ^+ 2))%:C.
  by rewrite !real_complexE -{2}oppr0.
rewrite H {H}.
  (***)
rewrite -mulNr -(@polyC_opp _ (1 *- 2 * Re z)) .
rewrite mul_polyC map_polyZ map_polyX mulNr opprK.
have H : 2%:R * (Re z)%:C = (2%:R * (Re z))%:C.
  rewrite !real_complexE. by simpc.
by rewrite H {H}.
Qed.

Lemma complex_root_div_poly_deg2 : forall (p : {poly R}) (z : complex R),
   (Im(z) != 0) -> root (map_poly (real_complex R) p) z ->
   ('X^2 + (- 2%:R * (Re z)) *: 'X + ((Re z) ^+2 + (Im z)^+2)%:P) %| p.
Proof.
move=> p z Hz Hrootz.
have Hrootzbar : root (map_poly (aR:=R) (rR:=complex_Ring R) (real_complex R) p) z^*.
  by rewrite -complex_root_conj_polyR.
have Hp := (factor_complex_roots z).
rewrite -(dvdp_map ((ComplexField.real_complex_rmorphism R))) /= Hp.
rewrite Gauss_dvdp.
  apply/andP; split; by rewrite -root_factor_theorem.
apply: Pdiv.ClosedField.root_coprimep => x.
rewrite root_XsubC =>/eqP ->. clear x.
rewrite hornerXsubC im_conj.
rewrite eq_complex ReiNIm ImiRe /= !addr0 !mulr0 subr0 add0r mul0r oppr0.
rewrite negb_and; apply/orP; apply: or_intror.
rewrite mulrI_eq0 //.
apply/lregP.
rewrite paddr_eq0. 
    rewrite negb_and; apply/orP; apply :or_intror. by apply: oner_neq0.
  by apply: ler01.   
by apply: ler01.
Qed.

Lemma real_root_div_poly_deg1 : forall (p : {poly R}) (z : complex R),
   (Im(z) = 0) -> root (map_poly (real_complex R) p) z ->
   ('X - (Re z)%:P) %| p.
Proof.
move=> p z Himz Hroot.
rewrite root_factor_theorem in Hroot.
rewrite (@complexE _ z) Himz mulr0 addr0 in Hroot.
rewrite -(dvdp_map ((ComplexField.real_complex_rmorphism R))) /=.
have H : map_poly (aR:=R) (rR:=complex_iDomain R) (real_complex R) ('X - (Re z)%:P) = 'X - ((Re z)%:C)%:P.
  by rewrite map_poly_is_additive map_polyC map_polyX.
by rewrite H.
Qed. 

(* Proposition 2.40 *)
Lemma normal_root_inB : forall (p : {poly R}),
   (p \is monic) -> (forall z : (complex R),
      root (map_poly (real_complex R) p) z -> inB z) -> p \is normal.
Proof.
move=> p Hpmonic.
move: {2}(size p) (leqnn (size p))=> n.
elim: n p Hpmonic.
(* size p <= 0 *)
  move=> p Hpmonic Hpsize Hproot. 
  rewrite size_poly_leq0 in Hpsize.
  move/eqP : Hpsize => Hpnull.
  rewrite Hpnull monicE lead_coef0 in Hpmonic.
  by rewrite Hpnull normalE polyseq0 /= -(oner_eq0 R) eq_sym.
(* size p <= n.+1 *)
move=> n IH p Hpmonic Hpsize Hproots.
case Hpsize2 : (size (map_poly (real_complex R) p) == 1%N).
  (* size p == 1 *)
  move/eqP : Hpsize2 => Hpsize2.
  rewrite size_map_poly_id0 in Hpsize2.  
  have Hpsize3 := (eq_leq Hpsize2).
    have Hp := (size1_polyC Hpsize3).
    rewrite Hp in Hpsize2.
    rewrite Hp monicE lead_coefE Hpsize2 -pred_Sn polyseqC in Hpmonic.
    rewrite size_polyC in Hpsize2.
    rewrite Hpsize2 /= in Hpmonic.
    move/eqP : Hpmonic => Hpmonic.
    rewrite Hp /= Hpmonic. 
    rewrite normalE polyseqC oner_neq0 /=.
    by apply: ltr01.
  rewrite eq_sym; apply: negbT; apply: ltr_eqF.
  rewrite monicE in Hpmonic.
  move/eqP : Hpmonic => Hpmonic.
  rewrite ltcR Hpmonic.
  by apply: ltr01.
(* size p != 1 *)
have HpCsize := (negbT Hpsize2).
move/closed_rootP : HpCsize.
case=> x Hrootx.
case: (altP (Im x =P 0)) => Himx. 
(* real root *)
  have H := monicXsubC (Re x).
  have Hp := real_root_div_poly_deg1 Himx Hrootx.
  rewrite Pdiv.IdomainMonic.dvdp_eq // in Hp.
  move/eqP : Hp => Hp. rewrite Hp.
  apply: normal_mulr.
    apply: IH.
        rewrite monicE -(@lead_coef_Mmonic _ (p %/ ('X - (Re x)%:P)) ('X - (Re x)%:P)) //. 
        by rewrite -Hp -monicE.
      rewrite size_divp.
        rewrite size_XsubC.
        by rewrite leq_subLR addnC addn1.
      by apply: monic_neq0.
    move=> z Hz.
    apply: Hproots.
    rewrite Hp rmorphM rootM.
    apply/orP. by left.
  rewrite monicXsubC_normal.
  have H' := (Hproots x Hrootx). rewrite inBE in H'.
  move/andP : H'=>H'.
  by apply: (proj1 H').
(* pair of complex roots *)
have H : 'X^2 + (1 *- 2 * Re x) *: 'X + (Re x ^+ 2 + Im x ^+ 2)%:P \is monic.
  rewrite -(mul1r 'X^2) mul_polyC monicE lead_coefE polyseq_deg2 //=.
  by apply: oner_neq0.
have H2 : size ('X^2 + (1 *- 2 * Re x) *: 'X + (Re x ^+ 2 + Im x ^+ 2)%:P) = 3.
  rewrite -(mul1r 'X^2) mul_polyC polyseq_deg2 //=.
  by apply: oner_neq0.
have Hp := complex_root_div_poly_deg2 Himx Hrootx.
rewrite Pdiv.IdomainMonic.dvdp_eq // in Hp.
move/eqP : Hp => Hp. rewrite Hp.
apply: normal_mulr.  
  apply: IH.
       rewrite monicE -(@lead_coef_Mmonic _ (p %/ ('X^2 + (1 *- 2 * Re x) *: 'X +
         (Re x ^+ 2 + Im x ^+ 2)%:P)) ('X^2 + (1 *- 2 * Re x) *: 'X +
           (Re x ^+ 2 + Im x ^+ 2)%:P)) //. 
        by rewrite -Hp -monicE.
     rewrite size_divp.
       rewrite H2 leq_subLR addnC addn2. 
       apply: (@leq_trans n.+1) => //.
     by apply: monic_neq0.
    move=> z Hz.
    apply: Hproots.
    rewrite Hp rmorphM rootM.
    apply/orP. by left.
  rewrite quad_monic_normal.
  by apply: (Hproots x Hrootx).
Qed.

(*
Lemma normal_neq0 : forall (p : {poly R}), p \is normal -> p != 0.
Proof.
move=> p Hpnormal.
rewrite -lead_coef_eq0.
apply: (@negbT (lead_coef p == 0)); apply: gtr_eqF.
by apply: normal_lead_coef_gt0.
Qed.

Lemma normal_size_le1 : forall (p : {poly R}), (p \is normal) ->
   (size p <= 1%N)%N = (size p == 1%N)%N.
Proof.
move=> p Hpnormal.
apply/idP/idP.
  move=> Hpsize.
  rewrite eqn_leq.
  apply/andP; split => //.
  rewrite ltnNge leqn0 size_poly_eq0.
  by apply: normal_neq0.
move=> Hpsize.
rewrite leq_eqVlt.
by apply/orP; left.
Qed.

Lemma normal_root0 : forall (p : {poly R}), p \is normal ->
   (root p 0) -> (forall k, (k < (\mu_0 p))%N -> p`_k = 0).
Proof.
move=> p Hpnormal Hproot k Hkmu.
have H := (root_mu p 0).
rewrite subr0 Pdiv.IdomainMonic.dvdp_eq in H.
  move/eqP : H => H.
  by rewrite H coefMXn Hkmu.
by apply: monicXn.
Qed. 

Lemma normal_0notroot_b : forall (p : {poly R}), p \is normal ->
   (~~(root p 0) = [forall k : 'I_((size p).-1), 0 < p`_k]).
Proof.
move=> p Hpnormal.
apply/idP/idP.
(* => *)
  move/rootPf=> H.
  rewrite horner_coef0 in H.
  move/eqP/eqP : H => H.
  have Hp0 : 0 < p`_0.
    rewrite ltr_def. apply/andP; split.
      by done.
    exact: (normal_coef_geq0 Hpnormal 0).
  apply/forallP.
  case. case=> [ | n Hn] //. 
  by apply: (normal_some_coef_gt0 Hpnormal Hp0 (ltn0Sn n)).
(* <= *)
apply: contraL.
move=> Hproot0.
rewrite negb_forall; apply/existsP.
have H0 : (0 < (size p).-1)%N.
  rewrite -subn1 -(ltn_add2r 1) !addn1 subn1 prednK.
    apply: (@root_size_gt1 _ 0 p).
      apply: normal_neq0.
      by done.
    by done.
  apply: (@ltn_trans 1).
    by [].
  apply: (@root_size_gt1 _ 0 p).
    by apply: normal_neq0.
  by [].
exists (Ordinal H0).
rewrite -lerNgt ler_eqVlt.
apply/orP; left.
move/rootPt : Hproot0=> Hproot0.
by rewrite horner_coef0 in Hproot0.
Qed.

Lemma normal_0notroot : forall (p : {poly R}), p \is normal ->
   ~~(root p 0) -> (forall k, (k < (size p).-1)%N -> 0 < p`_k).
Proof.
move=> p Hpnormal H.
rewrite normal_0notroot_b // in H.
move/forallP : H => H k Hk.
apply: (H (Ordinal Hk)).
Qed. 
*)
Lemma normal_red_0noroot : forall (p : {poly R}), p \is normal ->
   root p 0 -> (~~(root (p %/ 'X^(\mu_0 p)) 0) && ((p %/ 'X^(\mu_0 p)) \is normal)).  
Proof.
move=> p Hpnormal Hproot0.
apply/andP; split.
(* 0 is not root of p%/ 'X^(mu_0) *)
  rewrite -(@addr0 _ 'X) -oppr0 -mu_gt0.
    rewrite -eqn0Ngt (@mu_div _ _ _ (\mu_0 p)) //=.
    by rewrite (subnn).
  rewrite divpN0.
    apply: dvdp_leq.
      by apply: normal_neq0.
    by apply: root_mu.
  rewrite -size_poly_gt0.
  rewrite size_exp_XsubC.
  rewrite -mu_gt0 in Hproot0.
    apply: (@ltn_trans (\mu_0 p)).
      by done.
    by [].
  by apply: normal_neq0.
(* p %/ 'X^mu_0 is normal *)
have Hcoefs : forall k, ((p %/ 'X^(\mu_0 p))`_k = p`_(k + (\mu_0 p))).
  have H := (root_mu p 0).
  rewrite oppr0 addr0 Pdiv.IdomainMonic.dvdp_eq in H.
    move/eqP : H => H.
    rewrite {3}H.
    move=> k {H}.
    rewrite coefMXn /=.
    have H : ((k + \mu_0 p < \mu_0 p)%N = false).
      by rewrite -{2}(add0n (\mu_0 p)) (@ltn_add2r).
    by rewrite H addnK.
  by apply: monicXn.
have Hsize : ((size (p %/ ('X^(\mu_0 p)))) = ((size p) - (\mu_0 p))%N).
  rewrite size_divp.
    rewrite size_polyXn -pred_Sn.
    by done.
  rewrite -size_poly_gt0 size_polyXn.
  by apply: ltn0Sn.
apply: prop_normal.
split.
  move=> k; rewrite Hcoefs. exact: normal_coef_geq0.
split.
  rewrite lead_coefE Hcoefs Hsize -subnS addnC addnBA.
    rewrite addnC subnS addnK.
    exact: normal_lead_coef_gt0.
  rewrite -(size_polyXn R (\mu_0 p)).
  apply: dvdp_leq.
    by apply: normal_neq0.
  rewrite -(addr0 'X) -oppr0.
  by apply: root_mu.
split.
  move=> k Hk.
  rewrite !Hcoefs (@addnC k.+1) addnS (@addnC k.-1) (@addnC k) -subn1 addnBA //.
  rewrite subn1.
  apply: normal_squares.
    by done.
  apply: (@ltn_trans k).
    by done.
  rewrite -{1}(add0n k) ltn_add2r mu_gt0.
    by done.
  by apply normal_neq0.
move=> i.
rewrite Hcoefs.
move=> Hi j Hj1.
rewrite Hsize. 
move=> Hj2.
rewrite Hcoefs.
apply: (@normal_some_coef_gt0 p Hpnormal (i + (\mu_0 p)) Hi).
  by rewrite ltn_add2r.
by rewrite addnC -ltn_subRL -subn1 -subnDA addnC addn1 subnS.
Qed.

Fixpoint all_pos (s : seq R) : bool :=
   if s is a ::tl then (0 < a) && (all_pos tl) else true.

Lemma normal_all_pos : forall (p : {poly R}), p \is normal ->
   ~~(root p 0) -> all_pos p.
Proof.
case=> s Hs.
rewrite normalE=> //=.
case: s Hs => // a [].
  rewrite /=.
  move=> _ Ha _.
  by rewrite Ha.
move=> b l.
elim: l a b => [a b Hs/andP [Ha Hb] | c l IHl a b Hs].  
  rewrite rootE horner_coef0 /= Hb => Ha2.
  rewrite ltr_neqAle.
  by rewrite Ha eq_sym Ha2.
rewrite rootE horner_coef0.
case/andP =>H1 H2 [] /= => Ha.
rewrite eq_sym (negbTE Ha) Bool.orb_false_l in H2.
move/andP : H2 => H2.
have Hb := (proj2 H2).
rewrite lt0r in Hb.
move/andP : Hb => Hb.
move/andP : (proj1 H2) => H3.
rewrite (proj2 H3).
rewrite /= in IHl. rewrite (IHl b c Hs H1).
  by done.
rewrite rootE horner_coef0 /=.
by exact: (proj1 Hb).
Qed.

End normal_polynomial.

Implicit Arguments normal_seq [R].
Implicit Arguments normal [R].
Implicit Arguments all_pos [R].

Section more_on_sequences.

Variable R : rcfType.

(* all_pos is all positive *)
Lemma all_pos_gt0 : forall (s : seq R), (all_pos s) ->
   (forall k, (k < size s)%N -> 0 < s`_k).
Proof.
elim => [|a l IHl Halpos] //.
rewrite /= in Halpos.
move/andP : Halpos => Halpos.
case => [H0 |n Hn ] //.
  exact: (proj1 Halpos).
apply: (IHl _ n).
  exact: (proj2 Halpos).
by rewrite -(ltn_add2r 1%N) !addn1.
Qed.

Lemma gt0_all_pos : forall (s : seq R), (forall k, (k < size s)%N -> 0 < s`_k) ->
   (all_pos s).
elim => [|a l IHl Hal] //.
rewrite /=.
apply/andP; split.
  by apply: (Hal 0%N).
apply: IHl=> k Hk.
apply: (Hal k.+1).
by rewrite -(@addn1 k) addnC -ltn_subRL subn1 -pred_Sn.
Qed.

Lemma all_pos_subseq : forall (s1 s2 : seq R), (all_pos s2) -> (subseq s1 s2) ->
   (all_pos s1).
Proof.
move=> s s2.
elim: s2 s => [s _ Hsubseq |a l IHl s1 Halpos Hs1subseqal] //.
  rewrite subseq0 in Hsubseq.
  move/eqP: Hsubseq => Hsubseq.
  by rewrite Hsubseq.
have Halsubseq2 : exists2 m : seq bool, size m = size (a::l) & s1 = mask m (a::l).
  by apply/subseqP. 
case: Halsubseq2. 
case => [ |b0 btl Hbsize Hs1_as_mask] //.  
move/andP : Halpos => Halpos. 
case Hb0 : b0. 
  rewrite mask_cons Hb0 cat1s in Hs1_as_mask.
  rewrite Hs1_as_mask.
  apply/andP; split.
    exact: (proj1 Halpos).
  apply: IHl.
    exact: (proj2 Halpos).  
  apply/subseqP; exists btl.
    by apply/eqP; rewrite -(eqn_add2r 1) !addn1; apply/eqP.
  by done.
rewrite mask_cons Hb0 cat0s in Hs1_as_mask.
apply: IHl.
  exact: (proj2 Halpos).
rewrite Hs1_as_mask.
apply/subseqP; exists btl.
  by apply/eqP; rewrite -(eqn_add2r 1) !addn1; apply/eqP.
by done.
Qed.

(* sequence without 0's : filter (fun x => x != 0) s) *)
Definition seqn0 (s : seq R) := [seq x <- s | x != 0].

Lemma seqn0E : forall s : seq R,
   seqn0 s = [seq x <- s | x != 0].
Proof.
move=> s. by done.
Qed.

Lemma seqn0_as_mask : forall s : seq R, seqn0 s = mask (map (fun x => x != 0) s) s.
Proof.
move=> s. by rewrite seqn0E filter_mask.
Qed.

Lemma seqn0_cons : forall (s : seq R) (a : R), (a != 0) ->
   seqn0 (a :: s) = a :: (seqn0 s).
Proof.
move=> s a Ha.
by rewrite /= Ha.
Qed.

Lemma seqn0_size : forall s: seq R, (s`_(size s).-1 != 0) ->
   (0 < size (seqn0 s))%N.
Proof.
move=> s Hs.
have Hssize : (0 < size s)%N.
  case: s Hs => [ | ] //=.
  by rewrite eqxx.
elim: s Hs Hssize => [|a] //=.
case=> [_ Ha _|b l IHbl Hln Hablsize ] //=.
  by rewrite Ha.
case Ha : (a != 0).
  by done.
by apply: IHbl.
Qed.

Lemma seqn0_size_2 : forall (s : seq R), (s`_0 < 0) -> (0 < s`_(size s).-1) ->
   (1 < size (seqn0 s))%N.
Proof.
move=> s Hs1 Hs2.
have Hssize : (0 < size s)%N.
  case: s Hs1 Hs2 => [ | ] //=.
  by rewrite ltrr.
case: s Hs1 Hs2 Hssize => [|a ] //.
case => [ Ha1 Ha2 _|b l Ha Hln Hablsize] //.
  have: false.
  rewrite -(ltr_asym 0 a).
  by apply/andP.
by done.
rewrite seqn0_cons /=.
  rewrite -(addn1 0) -(addn1 (size (seqn0 (b ::l)))) ltn_add2r.
  apply: seqn0_size.
  have H : (size [:: a, b & l]).-1 = (size (b :: l)).-1.+1.
    by rewrite /=.
  rewrite H ltr_def in Hln.
  move/andP : Hln => Hln.
  exact: (proj1 Hln).
rewrite ltr_def eq_sym in Ha.
move/andP : Ha => Ha.
exact: (proj1 Ha).
Qed.

Fixpoint all_neq0 (s : seq R) : bool :=
  if s is a ::tl then (a != 0) && (all_neq0 tl) else true.

Lemma all_neq0_neq0_1 : forall s : seq R,
   (all_neq0 s) -> forall k, (k < size s)%N -> s`_k != 0.
Proof.
elim => [ | a tl IHtl Hatl] //=.
rewrite /= in Hatl.
move/andP : Hatl => Hatl.
case => [ Hk0 | k Hk] //=.
  exact : (proj1 Hatl).
apply: (IHtl (proj2 Hatl) k).
by rewrite -(ltn_add2r 1) !addn1.
Qed.

Lemma all_neq0_neq0_2 : forall s : seq R,
   (forall k, (k < size s)%N -> (s`_k != 0)) -> (all_neq0 s).
Proof.
elim => [ | a l IHl H] //=.
apply/andP; split.
  by apply: (H 0%N).
apply: IHl.
move=> k Hk.
apply: (H k.+1).
by rewrite /= -(addn1 k) -(addn1 (size l)) ltn_add2r. 
Qed.

Lemma all_neq0_gt0F : forall (s : seq R) k, (k < (size s))%N -> (all_neq0 s) ->
   ((0 < s`_k) == false) = (s`_k < 0).
Proof.
move=> s k Hk Hsneq0.
apply/idP/idP.
(* => *)
  move=> Hs.
  rewrite ltr_def.  
  apply/andP; split.
    rewrite eq_sym.
    by apply: (@all_neq0_neq0_1 _ Hsneq0 k Hk).
  move/eqP : Hs => Hs.
  rewrite lerNgt.
  exact : (negbT Hs).
(* <= *)
move=> Hs.
apply/eqP. apply:negbTE.
rewrite -lerNgt.
by apply: ltrW.
Qed.

Lemma all_neq0_gt0neg : forall (s : seq R) k, (k < (size s))%N -> (all_neq0 s) ->
   (~~(0 < s`_k)) = (s`_k < 0).
Proof.
move=> s k Hk Hsneq0; rewrite -all_neq0_gt0F //.
apply/idP/idP.
  move=> Hs; apply/eqP. by apply: negbTE.
move/eqP => Hs. by apply: negbT.
Qed.

Lemma all_neq0_lt0F : forall (s : seq R) k, (k < (size s))%N -> (all_neq0 s) ->
   ((s`_k < 0) == false) = (0 < s`_k).
Proof.
move=> s k Hk Hsneq0.
apply/idP/idP.
(* => *)
  move=> Hs.
  rewrite ltr_def.  
  apply/andP; split.
    by apply: (@all_neq0_neq0_1 _ Hsneq0 k Hk).
  move/eqP : Hs => Hs.
  rewrite lerNgt.
  exact : (negbT Hs).
(* <= *)
move=> Hs.
apply/eqP. apply:negbTE.
rewrite -lerNgt.
by apply: ltrW.
Qed.

Lemma all_neq0_lt0neg : forall (s : seq R) k, (k < (size s))%N -> (all_neq0 s) ->
   (~~(s`_k < 0)) = (0 < s`_k).
Proof.
move=> s k Hk Hsneq0; rewrite -all_neq0_lt0F //.
apply/idP/idP.
  move=> Hs; apply/eqP. by apply: negbTE.
move/eqP => Hs. by apply: negbT.
Qed.

Lemma seqn0_all_neq0 : forall s : seq R, all_neq0 (seqn0 s).
Proof.
elim=> [ | a l H] //.
case Ha : (a != 0).
  rewrite /= Ha /=.
  apply/andP; split => //.
by rewrite /= Ha /=.
Qed.

Lemma seqn0_0 : forall (s : seq R), s`_0 != 0 -> (seqn0 s)`_0 = s`_0.
Proof.
case => [ | a l IHl] //.
by rewrite seqn0_as_mask /= IHl.
Qed.

Lemma seqn0_n : forall (s : seq R), s`_(size s).-1 != 0 ->
   (seqn0 s)`_(size (seqn0 s)).-1 = s`_(size s).-1.
Proof.
move=> s Hs.
have Hssize : (0 < size s)%N.
  case: s Hs => [ | ] //=.
  by rewrite eqxx.
elim : s Hs Hssize => [| a] //.
case => [_ Ha _ |b l IHbl Hln Hablsize  ] //.
  by rewrite /= Ha.
have H2 : (size [::a, b & l]).-1 = (size (b ::l)).-1.+1.
  by rewrite prednK.
rewrite H2 /=. rewrite -IHbl //.
case Ha : (a != 0).
  have H3 : ((size (a :: (if b != 0 then b :: seqn0 l else seqn0 l))).-1
     = (size (seqn0 (b :: l))).-1.+1).
    rewrite prednK.
      by done.
    by apply: seqn0_size.
  by rewrite H3.
by done.
Qed.

Fixpoint increasing (s : seq R) : bool :=
   if s is a :: tl then
      if tl is b :: l then (a <= b) && increasing tl else true
   else true.

Lemma increasing_is_increasing1 : forall (s : seq R),
   (increasing s) -> (forall k, (k < (size s).-1)%N -> s`_k <= s`_k.+1). 
Proof.
case=> [ | a ] // => l.
elim : l a => [ | b tl IHl a Habtl] //.
case => [_ | n Hn] //=.
  move/andP : Habtl => Habtl.
  exact: (proj1 Habtl). 
move/andP : Habtl => Habtl.
apply: (IHl b (proj2 Habtl)).
by rewrite -(ltn_add2r 1%N) !addn1 prednK.
Qed.

Lemma increasing_is_increasing2 : forall (s : seq R),
   (forall (k : nat), (k < (size s).-1)%N ->
   (s`_k <= s`_k.+1)) -> increasing s.
Proof.
case=> [ | a] => // => l.
elim : l a => [ | b l IHs a] //.
move=> Hk.
apply/andP; split.
  apply: (Hk 0%N) => //.
apply: (IHs b) => k Hkk.
apply: (Hk k.+1).  
by rewrite -(addn1 k) addnC -ltn_subRL subn1.
Qed.

Lemma increasing_is_increasing3 : forall (s : seq R), (increasing s) -> 
   (forall k l, (k < (size s))%N -> 
      (l < (size s))%N -> (k <= l)%N -> s`_k <= s`_l). 
Proof.
case=> [ | a ] // => l.
elim : l a => [a Hs k | b tl IHl a Habtl k] //.
case => [_ _ Hk | n Hn] //=.
  rewrite leqn0 in Hk; move/eqP : Hk => -> //.
case => [_ _ Hk | l] //=.
  rewrite leqn0 in Hk; move/eqP : Hk => -> //. 
move/andP : Habtl => Habtl.
case : k => [Hk Hl Hkl| k Hk Hl Hkl] //=.
  case : l Hl Hkl => [Hl Hkl |l Hl Hkl].
    exact: (proj1 Habtl).  
  apply: (@ler_trans _ b).
    exact: (proj1 Habtl).
  apply: (IHl b (proj2 Habtl) 0%N l.+1) => //.
by apply: (IHl b (proj2 Habtl)).
Qed.

Local Notation is1 := (fun x : bool => x == true). 

Lemma mask_find_1 : forall (s : seq R) (b : bitseq), (size s = size b) ->
   ((find is1 b) < size s)%N ->
      mask b s = 
      s`_(find is1 b) :: mask (drop (find is1 b).+1 b) (drop (find is1 b).+1 s).
Proof.
elim => [ |a l IHl] //.
case => [ |b0 btl Hsize Hfind] //.
case Hb0 : b0.
  by rewrite mask_cons cat1s /= !drop0.
rewrite mask_cons cat0s !drop_cons (IHl btl) //.      
  by apply/eqP; rewrite -(eqn_add2r 1%N) !addn1; apply/eqP.
rewrite -(ltn_add2r 1%N) !addn1.
by rewrite Hb0 in Hfind.
Qed.

Lemma mask_find_0 : forall (s : seq R) (b : bitseq), (size s = size b) ->
    (size s <= find is1 b)%N -> mask b s = [::].
Proof.
elim => [b _ _ |a l IHl] //.
  by rewrite mask0.
case => [ |b0 btl Hsize Hfind] //.
case Hb0 : b0.
  by rewrite Hb0 /= ltn0 in Hfind.
rewrite mask_cons cat0s (IHl btl) //.      
  by apply/eqP; rewrite -(eqn_add2r 1%N) !addn1; apply/eqP.
by rewrite Hb0 /= in Hfind.
Qed.

Lemma increasing_cons : forall (a : R) (s : seq R),
   increasing (a :: s) = match s with
   | nil => true
   | b :: _ => (a <= b) && increasing s
   end.
Proof. by rewrite /=. Qed.

Lemma subseq_incr : forall (s1 s2 : seq R), (increasing s2) -> 
   (subseq s1 s2) -> (increasing s1).
Proof.
move=> s s2.
elim: s2 s => [s _ Hsubseq |a] //.
  rewrite subseq0 in Hsubseq.
  move/eqP: Hsubseq => Hsubseq.
  by rewrite Hsubseq.
case=> [_ |b l IHbl s1 Hablincr Hs1subseqabl] //.
  case => [ |b l Haincr Hblsubseqa] //.
  rewrite /= in Hblsubseqa.
  case Hab : (b == a); rewrite Hab in Hblsubseqa;
  by move/eqP : Hblsubseqa => ->.
have Hablsubseq2 : exists2 m : seq bool, size m = size [::a, b & l] & 
   s1 = mask m [::a, b & l].
  by apply/subseqP. 
case: Hablsubseq2.
case => [ |b0 btl Hbsize Hs1_as_mask] //.
have Hbtl_size : size btl = size (b :: l).
  by apply/eqP; rewrite -(eqn_add2r 1) !addn1; apply/eqP.
case Hb0 : b0. 
  rewrite mask_cons Hb0 cat1s in Hs1_as_mask.
  case Hfind : ((find is1 btl) < size (b :: l))%N.
    rewrite mask_find_1 // in Hs1_as_mask.
    rewrite Hs1_as_mask.
    apply/andP; split.
      apply: (@increasing_is_increasing3 [::a, b & l] _ 0%N (find is1 btl).+1) => //.
    move/andP : Hablincr => Hablincr.
    rewrite -increasing_cons -mask_find_1 //.
    apply: IHbl => //.
      exact: (proj2 Hablincr).
    apply/subseqP; by exists btl.
  have Hfind2 := (negbT Hfind).
  rewrite -leqNgt in Hfind2.
  rewrite mask_find_0 // in Hs1_as_mask.
  by rewrite Hs1_as_mask.
move/andP : Hablincr => Hablincr.
rewrite mask_cons Hb0 cat0s in Hs1_as_mask.
apply: IHbl.
  exact: (proj2 Hablincr).
rewrite Hs1_as_mask.
apply/subseqP; by exists btl.
Qed.

Lemma changes_seq_incr_0 : forall (s : seq R), (0 < size s)%N ->
   (increasing s) -> (all_neq0 s) ->
   ((changes s == 0%N) = (0 < s`_0 * s`_((size s).-1))).
Proof.
move=> s Hssize Hsincr Hsneq0.
apply/idP/idP.
(* => *)
  elim: s Hssize Hsincr Hsneq0 => [ | a] //.
  case => [_ _ _ Ha _ | b l IHl Hablsize Hablincr Hablneq0] //.
    rewrite /= Bool.andb_true_r in Ha.
    rewrite /= -expr2 ltr_def.
    apply/andP; split.
      by rewrite sqrf_eq0.
    by apply: sqr_ge0.
  move => Hchanges.
  rewrite /= addn_eq0 in Hchanges.
  move/andP : Hchanges => [] Hab Hblchanges.
  rewrite eqb0 -lerNgt in Hab.
  (* 0 < a *)
  case Ha : (0 < a).
    rewrite pmulr_lgt0 => //.
    rewrite -(@pmulr_rgt0 _ b).
    apply: IHl => //.
        rewrite /= in Hablincr; move/andP : Hablincr => Hablincr.
        exact: (proj2 Hablincr).
      rewrite /= in Hablneq0; move/andP : Hablneq0 => Hablneq0.
      exact: (proj2 Hablneq0).
    rewrite ltr_def; apply/andP; split.
      apply: (@all_neq0_neq0_1 _ Hablneq0 1%N) => //.
    by rewrite -(@pmulr_rge0 _ a).
  (* a <= 0 *)
have Ha2 := (negbT Ha).
rewrite -lerNgt in Ha2.
clear Ha; have Ha : (a < 0).
  rewrite ltr_def; apply/andP; split => //.
    rewrite /= in Hablneq0.
    move/andP : Hablneq0 => Hablneq0.
    rewrite eq_sym.
    exact: (proj1 Hablneq0).
  clear Ha2.
  rewrite nmulr_lgt0 => //.
  rewrite -(@nmulr_rgt0 _ b).
    apply: IHl => //.
      rewrite /= in Hablincr; move/andP : Hablincr => Hablincr.
      exact: (proj2 Hablincr).
    rewrite /= in Hablneq0; move/andP : Hablneq0 => Hablneq0.
    exact: (proj2 Hablneq0).
  rewrite ltr_def; apply/andP; split.
    rewrite eq_sym.
      by apply: (@all_neq0_neq0_1 _ Hablneq0 1%N).
    by rewrite -(@nmulr_rge0 _ a).
(* <= *)
elim: s Hssize Hsincr Hsneq0 => [ | a] //.
case => [_ _ _ _ _ |b l IHbl Hablsize Hablincr Hablneq0 H] //.
  by rewrite /= mulr0 addn0 ltrr.
rewrite /= addn_eq0; apply/andP; split.
  rewrite eqb0 -lerNgt le0r.
  apply/orP; right.
  case Ha : (0 < a).
    rewrite pmulr_rgt0 //.  
    apply: (@ltr_le_trans _ a).
      by done.
    by apply: (@increasing_is_increasing1 _ Hablincr 0%N).
  move/eqP : Ha => Ha. rewrite (@all_neq0_gt0F _ 0%N _ Hablneq0) //= in Ha.
  rewrite nmulr_rgt0 //.
  apply: (@ler_lt_trans _ ([::a, b & l]`_(size [::a, b & l]).-1)).
    by apply: (@increasing_is_increasing3 _ Hablincr 1%N (size [::a, b & l]).-1).
  by rewrite -(@nmulr_rgt0 _ a). 
apply: IHbl => //.
    rewrite /= in Hablincr; move/andP : Hablincr => Hablincr.
    exact: (proj2 Hablincr).   
  rewrite /= in Hablneq0; move/andP : Hablneq0 => Hablneq0.
  exact: (proj2 Hablneq0).
case Ha : (0 < a).
  rewrite pmulr_lgt0.
    apply: (@ltr_le_trans _ a) => //.
    by apply: (@increasing_is_increasing1 _ Hablincr 0). 
  apply: (@ltr_le_trans _ a) => //.
  by apply: (@increasing_is_increasing3 _ Hablincr 0%N (size [::a, b & l]).-1).
move/eqP : Ha => Ha.
rewrite (@all_neq0_gt0F _ 0%N _ Hablneq0) //= in Ha.
rewrite nmulr_rgt0.
  by rewrite -(@nmulr_rgt0 _ a). 
apply: (@ler_lt_trans _ ([::a, b & l]`_(size [:: a, b & l]).-1) ).
  by apply: (@increasing_is_increasing3 _ Hablincr 1%N (size [::a, b & l]).-1). 
by rewrite -(@nmulr_rgt0 _ a).
Qed.

Lemma changes_seq_incr_1 : forall (s : seq R), (1%N < size s)%N ->
   (increasing s) -> (all_neq0 s) ->
      ((changes s) == 1%N) = (s`_0 < 0) && (0 < s`_((size s).-1)).
Proof.
move=> s Hssize Hsincr Hsneq0.
apply/idP/idP.
(* => *)
  elim: s Hssize Hsincr Hsneq0 => [ | a] //.
  case => [ |b l IHl Hablsize Hablincr Hablneq0 Hchanges] //.
    rewrite /=.
  rewrite /= in Hchanges.
  case H : (a * b < 0)%R.
    rewrite H add1n in Hchanges.
    move/eqP : Hchanges => Hchanges.
    have Hblchanges :=(eq_add_S _ _ Hchanges).
    apply/ andP; split.
      case Ha : (a < 0) => //.
      move/eqP : Ha => Ha.
      rewrite (@all_neq0_lt0F _ 0%N _ Hablneq0) /= in Ha.
        rewrite -(ltr_asym 0 b); apply/andP; split.
          apply: (@ltr_le_trans _ a) => //.
          by apply: (@increasing_is_increasing1 _ Hablincr 0%N).
        by rewrite -(@pmulr_rlt0 _ a).
      by done.
    case Ha : (a < 0).
      apply: (@ltr_le_trans _ b).
        by rewrite -(@nmulr_rlt0 _ a). 
      by apply: (@increasing_is_increasing3 _ Hablincr 1%N (size [::a, b & l]).-1).
    move/eqP : Ha => Ha.
    rewrite (@all_neq0_lt0F _ 0%N _ Hablneq0) /= in Ha.  
      apply: contraT => Hln.
      rewrite (@all_neq0_gt0neg _ (size [::a, b & l]).-1 _ Hablneq0) in Hln.
        rewrite -(ltr_asym 0 a); apply/andP; split => //.
        apply: (@ler_lt_trans _ ([::a, b & l]`_((size [::a, b & l]).-1))) => //.          
        apply: (@increasing_is_increasing3 _ Hablincr 0%N (size [::a, b & l]).-1) => //.
      by done.
    by done.
  case : l IHl Hablsize Hablincr Hablneq0 Hchanges =>
     [IH Hsize Hincr Hneq0 Hchanges | c l IHcl Habclsize Habclincr Habclneq0 Hchanges] //.
    rewrite /=.
    rewrite H in Hchanges.
    by rewrite add0n /= addn0 mulr0 ltrr eqb1 in Hchanges.
  rewrite /= in Habclincr.
  move/andP : Habclincr => Habclincr.
  rewrite /= in Habclneq0.
  move/andP : Habclneq0 => Habclneq0.
  rewrite H add0n in Hchanges.
  have Hbclsize : (1%N < (size [::b, c & l]))%N.
    by done.
  have H2 := (IHcl Hbclsize (proj2 Habclincr) (proj2 Habclneq0) Hchanges).
  move/andP : H2 => [] Hb Hln.  
  apply/andP; split => //.
  apply: (@ler_lt_trans _ b) => //.
  exact: (proj1 Habclincr).
(* <= *)
elim: s Hssize Hsincr Hsneq0 => [ | a] //.
case => [ |b] //.
case => [_ _ _ _ H |c l IHl Habclsize Habclincr Habclneq0 H] //.
  rewrite /= addn0 mulr0 ltrr addn0.
  rewrite /= in H.
  move/andP : H => [] Ha Hb.
  by rewrite eqb1 pmulr_llt0.
have Hbclsize : (1%N < size [::b, c & l])%N. 
  by done.
rewrite /= in Habclincr; move/andP : Habclincr => Habclincr.
rewrite /= in Habclneq0; move/andP : Habclneq0 => Habclneq0.
rewrite /=.
move/andP : H => [] Ha Hln.
case Hab : (a * b < 0).
  rewrite addnC addn1.  
  apply/eqP; apply: eq_S; apply/eqP.  
  rewrite (@changes_seq_incr_0 [::b, c & l] _ (proj2 Habclincr) (proj2 Habclneq0)).
    rewrite pmulr_rgt0 => //.
    by rewrite -(@nmulr_rlt0 _ a).
  by done.
rewrite add0n.
apply: IHl => //.
    exact: (proj2 Habclincr).
  exact: (proj2 Habclneq0).
apply/andP; split => //.
have Hab2 := (negbT Hab).
rewrite -lerNgt in Hab2.
rewrite ltr_def; apply/andP; split.
  move/andP : (proj2 Habclneq0) => [] Hbneq0 Hclneq0.
  by rewrite eq_sym.
by rewrite -(@nmulr_rge0 _ a).
Qed.

Lemma changes_seq_incr : forall (s : seq R), (increasing s) -> (all_neq0 s) ->
  (changes s == 1%N) || (changes s == 0%N).
Proof.
case => [ |a ] //.
case => [Haincr Haneq0 |b l Hablincr Hablneq0] //.
  apply/orP. right.
  rewrite changes_seq_incr_0 //=.
  rewrite -expr2 ltr_def.
  apply/andP; split.  
    rewrite sqrf_eq0.
    by rewrite /= Bool.andb_true_r in  Haneq0.
  by apply: sqr_ge0.
case Haln : (0 < a * ([::a, b & l]`_(size [::a, b & l]).-1)).
  apply/orP; right.
  rewrite changes_seq_incr_0 //.
apply/orP; left.
rewrite changes_seq_incr_1 //.
have Haln2 := (negbT Haln).
rewrite -lerNgt in Haln2.
case Ha : (a < 0).
  rewrite Bool.andb_true_l ltr_def.  
  apply/andP; split.
    by apply: (@all_neq0_neq0_1 _ _ (size [::a, b & l]).-1).
  by rewrite -(@nmulr_rle0 _ a).
move/eqP : Ha => Ha.
rewrite (@all_neq0_lt0F _ 0%N _ Hablneq0) //= in Ha.
rewrite Bool.andb_false_l -(@ltr_asym _ ([::a, b & l]`_(size [::a, b & l]).-1) 0).
apply/andP; split.
  rewrite ltr_def.  
  apply/andP; split.
    rewrite eq_sym.
    by apply: (@all_neq0_neq0_1 _ _ (size [::a, b & l]).-1).
  by rewrite -(@pmulr_rle0 _ a).
apply: (@ltr_le_trans _ a) => //.
by apply: (@increasing_is_increasing3 _ Hablincr 0%N (size [:: a, b & l]).-1).
Qed.

Lemma changes_size3 : forall (s : seq R), (all_neq0 s) -> (size s = 3)%N -> (s`_0 < 0) ->
   (0 < s`_2) -> changes s = 1%N.
Proof.
case => [ | a] //. case => [ | b] //. case => [ | c] //.
case => [Hallneq Hsize Ha Hc | ] //=.
rewrite addn0 mulr0 ltrr addn0.
case Hab : (a * b < 0).
  rewrite addnC addn1 .  apply: eq_S.
  apply/eqP. rewrite eqb0.
  rewrite -lerNgt pmulr_lge0 // -(@nmulr_lle0 _ a b) // ltrW.
    by done.
  by rewrite mulrC.
rewrite add0n. apply/eqP. rewrite eqb1.
rewrite pmulr_llt0 // -(@nmulr_rgt0 _ a) // ltr_def.
apply/andP. split.
  apply: mulf_neq0.
    by apply: (@all_neq0_neq0_1 _ Hallneq 0%N).
  by apply: (@all_neq0_neq0_1 _ Hallneq 1%N).
rewrite lerNgt. by apply: negbT.
Qed.

(* sequence without first and last element *) 
Definition mid := fun (s : seq R) => (drop 1 (take (size s).-1 s)).

Lemma midE : forall (s : seq R), mid s = (drop 1 (take (size s).-1 s)).
Proof. by done. Qed.

Lemma mid_2 : forall (s : seq R), mid s = (take (size s).-2 (drop 1 s)).
Proof.
elim=> [ |a l IHl ] //=.
case: l IHl => [ |b l IHbl ] //.
rewrite drop0 midE.
have Hsize : ((size [::a, b & l]).-1 = (size (b :: l)).-1.+1).
  by rewrite prednK.
by rewrite Hsize /= drop0.
Qed.

Lemma mid_size : forall (s : seq R), size (mid s) = (size s).-2.
Proof.
elim => [|a l IHl] => //=.
rewrite midE size_drop size_takel //=.
by rewrite subn1.
Qed.

Lemma mid_nil : forall (s : seq R),
   (mid s == [::]) = ((s == [:: s`_0 ; s`_1]) || (s == [:: s`_0]) || (s == [::])).
Proof.
move=> s.
apply/idP/idP.
  case : s => [ |a] //.
    case => [/eqP Hmida | b ] //=.
    by apply/orP; left; apply/orP; right.
  case => [/eqP Hmidsb | ] //=.
  by apply/orP; left; apply/orP; left.
move/orP => H; case: H.
  move/orP => H; case: H; by move/eqP => Hs; rewrite Hs midE.
by move/eqP => Hs; rewrite Hs midE.
Qed.

Lemma mid_cons : forall (s : seq R) (a : R),
   mid (a :: s) = take (size s).-1 s.
Proof.
move=> s a.
by rewrite mid_2 /= drop0.
Qed.

Lemma mid_coef_1 : forall (s : seq R) k, (k < size (mid s))%N ->
   (mid s)`_k = s`_k.+1.
Proof.
move=> s k Hk.
rewrite midE nth_drop addnC addn1 nth_take //.
by rewrite -(@addn1 k) addnC -ltn_subRL subn1 -mid_size.
Qed.

Lemma mid_coef_2 : forall (s : seq R) k, (0%N < k)%N -> (k < (size s).-1)%N ->
   (mid s)`_k.-1 = s`_k.
Proof.
move=> s k Hk1 Hk2.
rewrite mid_coef_1 prednK // mid_size -(@prednK k) // -(@ltn_add2r 1%N) !addn1
   !prednK //.
by apply: (@ltn_trans k).
Qed.
 
Lemma drop1_seqn0_C : forall (s : seq R), (s`_0 != 0) ->
   drop 1 (seqn0 s) = seqn0 (drop 1 s).
Proof.
case => [ | a l Ha] //=.
by rewrite Ha /= !drop0.
Qed.

Lemma take1_seqn0_C : forall (s : seq R), (s`_(size s).-1 != 0) ->
   take (size (seqn0 s)).-1 (seqn0 s) = seqn0 (take (size s).-1 s).
Proof.
elim=> [ | a] //.
case=> [_ Ha | b l IHbl Hln] //.
  by rewrite /= Ha.
have H : (size [::a, b & l]).-1 = (size (b :: l)).-1.+1.
  by rewrite prednK.
rewrite H take_cons.
case Ha : (a != 0).
  rewrite /= Ha -IHbl => //.
  have H2 : (size (a :: (if b != 0 then b :: seqn0 l else seqn0 l))).-1 =
   (size (seqn0 (b ::l))).-1.+1.
    rewrite prednK /=.
      by done.
    by apply: (@seqn0_size (b :: l)).
  by rewrite H2 take_cons.
by rewrite /= Ha -IHbl.
Qed.

Lemma mid_seqn0_C : forall (s : seq R), (s`_0 != 0) -> (s`_(size s).-1 != 0) ->
   mid (seqn0 s) = seqn0 (mid s).
Proof.
elim => [ |a] //.
case => [_ Ha _ |b l Hbl Ha Hln] //=.
  by rewrite Ha midE /=.
rewrite Ha midE -drop1_seqn0_C => //. 
rewrite -take1_seqn0_C => //.
have H : ((size (a :: (if b != 0 then b :: seqn0 l else seqn0 l))).-1 =
   (size (seqn0 (b :: l))).-1.+1).
  rewrite prednK.
    by done.
  by apply: seqn0_size.
by rewrite H take_cons /= drop0 Ha H take_cons /= drop0.
Qed.

Lemma changes_take : forall (s : seq R) (a b : R), (s != [::]) ->
   (all_neq0 [::a, b & s]) ->
   (changes (take (size (b :: s)) ([::a, b & s])) =
   ((a * b < 0)%R + changes (take (size s) (b :: s)))%N).   
Proof. by elim. Qed.

Lemma changes_decomp_sizegt2 : forall (s : seq R), (all_neq0 s) -> (2 < size s)%N ->
   changes s =
      ((s`_0 * s`_1 < 0)%R +
          (changes (mid s))%R + 
            (s`_((size s).-2) * s`_((size s).-1) < 0)%R)%N.
Proof.
case=> [|a ] //.
case=> [ | b l] //. 
elim: l a b => [ |c l] //.
case: l c => [c IHempty a b Habcneq0 Habcsize| d l c IHdl a b Habcdlneq0 Habcdlsize ].
  by rewrite /= !mulr0 !ltrr !addn0.
move/andP : Habcdlneq0 => Habcdlneq0.
have H1 : (changes [:: a, b, c, d & l] = ((a * b < 0)%R + changes [:: b, c, d & l])%N).
 by done.
rewrite H1 (IHdl b c) //.
  rewrite -addnA -addnA addnC (@addnC (a * b < 0)%R).
  apply/eqP.
  rewrite eqn_add2r addnA eqn_add2r (@mid_cons _ a).
  have H2 : (size [:: b, c, d & l]).-1 = size [::c, d & l].
    by done.
  rewrite H2 (@changes_take _ b c) //.
  exact : (proj2 Habcdlneq0).
exact: (proj2 Habcdlneq0).  
Qed.

Lemma changes_decomp_size2 : forall (s : seq R), (all_neq0 s) -> (size s == 2)%N ->
   changes s = (s`_0 * s`_1 < 0)%R.
Proof.
case => [ |a] //. case => [ |b] //. case => [Hneq0 Hsize | ] //.
by rewrite /= mulr0 ltrr !addn0.
Qed.

(* pointwise multiplication of two lists *)
Definition seqmul :=
   (fun s1 s2 : seq R => map (fun x : R * R => x.1 * x.2) (zip s1 s2)).

Lemma seqmulE : forall (s1 s2 : seq R),
   seqmul s1 s2 = map (fun x : R * R => x.1 * x.2) (zip s1 s2).
Proof. by done. Qed.

Lemma seqmul_size : forall (s1 s2 : seq R),
   size (seqmul s1 s2) = minn (size s1) (size s2).
Proof.
move=> s1 s2.
by rewrite seqmulE size_map size_zip.
Qed.

Lemma seqmul_coef : forall (s1 s2 : seq R) k, (k < minn (size s1) (size s2))%N ->
   (seqmul s1 s2)`_k = s1`_k * s2`_k.
Proof.
move=> s1 s2 k Hk.
rewrite (nth_map 0).
  by rewrite nth_zip_cond size_zip Hk /=.
by rewrite size_zip.
Qed.

Lemma zip_nil_1 : forall (s : seq R),
   zip (@nil R) s = [::].
Proof. by case. Qed.

Lemma zip_nil_2 : forall (s : seq R),
   zip s (@nil R) = [::].
Proof. by case. Qed.

Lemma mask_zip : forall (b : bitseq) (s1 s2 : seq R),
   mask b (zip s1 s2) = zip (mask b s1) (mask b s2).
Proof.
elim => [ | a l IHl] //.
case => [s2 |x s1 ] //.
  by rewrite /= !zip_nil_1.  
case=> [ |y s2 ] //.
  by rewrite zip_nil_2 !mask0 zip_nil_2.
rewrite /=.
case Ha : a.
  by rewrite IHl.
by done.
Qed.

Lemma mask_seqmul : forall (b : bitseq) (s1 s2 : seq R),
   mask b (seqmul s1 s2) = seqmul (mask b s1) (mask b s2).
Proof.
move=> b s1 s2.
by rewrite -map_mask mask_zip.
Qed. 

Lemma seqmul0 : forall s : seq R, seqmul [::] s = [::].
Proof.
move=> s. 
by rewrite seqmulE zip_nil_1 /=.
Qed.

Lemma seqmul_cons : forall (s1 s2 : seq R) (a b : R),
   seqmul (a::s1) (b::s2) = (a * b) :: (seqmul s1 s2).
Proof.
move=> s1 s2 a b.
by rewrite seqmulE /=.
Qed.

Lemma changes_mult : forall (s c : seq R), all_pos c -> (size s = size c) ->
   changes (seqmul s c) = changes s.
Proof.
elim=> [c Hc  Hsize |a1 s IHs] //.
  by rewrite seqmul0.
case => [ |b1 l Hblpos Hsize] //.
rewrite seqmul_cons /=.
case: s IHs Hsize => [IH Hsize|a2 s IHa2s Hsize] //.
  by rewrite seqmul0 /= !addn0 !mulr0.
case : l Hblpos Hsize => [ | b2 l Hb1b2lpos Hsize] //.
rewrite !seqmul_cons -(@IHa2s (b2::l)).
    rewrite seqmul_cons -(@pmulr_llt0 _ b1 (a1 * head 0 (a2 :: s ))).
      rewrite -(@mulrA _ a1 _ b1) (@mulrC _ (head 0 (a2::s)) b1) (@mulrA _ a1 b1 _)
         -(@pmulr_llt0 _ b2 (a1 * b1 * head 0 (a2 :: s ))).
        by rewrite -!mulrA (@mulrC _ _ b2).
      by apply: (@all_pos_gt0 [::b1, b2 & l] Hb1b2lpos 1%N).
    by apply: (@all_pos_gt0 [::b1, b2 & l] Hb1b2lpos 0%N).  
  rewrite /= in Hb1b2lpos.
  move/andP : Hb1b2lpos => Hb1b2lpos.
  exact: (proj2 Hb1b2lpos).
by apply: eq_add_S.
Qed.

Lemma map_seqmul : forall (s c : seq R), all_pos c -> (size s = size c) ->
   map (fun x => x != 0) (seqmul s c) = map (fun x => x != 0) s.
Proof.
elim=> [c Hc Hsize |a s IHs ] //.
  by rewrite seqmul0.
case=> [ | b l Hblpos Hsize] //.
rewrite seqmul_cons.
rewrite !map_cons.
rewrite mulIr_eq0.
  rewrite IHs //.
    move/andP : Hblpos => Hblpos.
    exact: (proj2 Hblpos).
  rewrite /= in Hsize.
  by apply: eq_add_S.
apply/rregP. move/andP : Hblpos => Hblpos.
apply: (@proj1 _ (0 <= b)). apply/andP.
rewrite -lt0r.
exact: (proj1 Hblpos).
Qed.

End more_on_sequences.

Implicit Arguments mid [R].
Implicit Arguments seqn0 [R].
Implicit Arguments all_neq0 [R].
Implicit Arguments increasing [R].

(*****************************)

Section Proof_Prop_2_44.

Variables (R : rcfType) (a : R) (p : {poly R}).

Variables (Ha : 0 < a) (Hpnormal : p \is normal) (Hp0noroot : ~~(root p 0)).

Local Notation q := (p * ('X - a%:P)).

Local Notation d := (size q).

Lemma q_0 :  q`_0 = -a * p`_0.
Proof.
rewrite mulrDr coefD -polyC_opp (mulrC p ((-a)%:P)) mul_polyC coefZ.
rewrite polyseqMX /=.
  by rewrite add0r.
by apply: normal_neq0.
Qed.

Lemma q_0_lt0 : q`_0 < 0.
Proof.
rewrite q_0 // mulNr oppr_lt0 pmulr_rgt0 //.
case Hpsize : (1%N < size p)%N.
  apply: (@normal_0notroot R p Hpnormal Hp0noroot).
  rewrite -(ltn_add2r 1) !addn1 prednK.
    by rewrite Hpsize.
   apply: (@ltn_trans 1%N); by done.
have H := (negbT Hpsize). rewrite -leqNgt in H.
have Hp0 := (normal_neq0 Hpnormal).
rewrite -size_poly_leq0 -ltnNge -(ltn_add2r 1%N) !addn1 in Hp0.
have H1 : (size p) = 1%N.
  apply/eqP. rewrite eqn_leq. apply/andP. by split.
rewrite (pred_Sn 0) -H1 -lead_coefE.
by apply: normal_lead_coef_gt0.
Qed.

Lemma q_0_neq0 : q`_0 != 0.
Proof.
apply: negbT. apply: ltr_eqF. exact: q_0_lt0.
Qed. 

Lemma q_size : d = (size p).+1 .
Proof.
rewrite mulrDr size_addl.
  rewrite size_mulX //.
  by apply: normal_neq0.
rewrite mulrC -polyC_opp mul_polyC size_mulX.
  apply: (@leq_ltn_trans (size p)) => //.
  by apply: size_scale_leq.
by apply: normal_neq0.
Qed.

Lemma p_size : size p = d.-1.
Proof.
by rewrite (@pred_Sn (size p)) q_size.
Qed.

Lemma q_n : q`_d.-1 = p`_(d.-2).
Proof.
rewrite -p_size mulrDr coefD -polyC_opp (mulrC p ((-a)%:P)) mul_polyC coefZ.
rewrite coefMX.
have H : (((size p) == 0%N) = false).
  rewrite size_poly_eq0.
  apply/eqP/eqP.
  by apply: normal_neq0.
rewrite H /= {H}.
by rewrite -{3}(coefK p) coef_poly ltnn mulr0 addr0.
Qed.

Lemma q_n_gt0 : (0 < q`_d.-1).
Proof.
rewrite q_n -p_size // -lead_coefE. 
by apply: normal_lead_coef_gt0.
Qed.

Lemma q_n_neq0 : q`_d.-1 != 0.
Proof.
apply: negbT. apply: gtr_eqF. (*rewrite q_size -pred_Sn.*) exact: q_n_gt0.
Qed.

Lemma q_k : forall k, (0%N < k)%N -> (k < d.-1)%N ->
   q`_k =  (p`_k.-1/p`_k - a) * p`_k.
Proof.
move=> k Hk1 Hk2.
rewrite mulrDr coefD -polyC_opp (mulrC p ((-a)%:P)) mul_polyC coefZ.
rewrite coefMX.
have H : ((k==0%N) = false).
apply/eqP/eqP.
  by rewrite -lt0n.
rewrite H /= {H} mulrDl divrK.
  by done.
apply: unitf_gt0.
case Hk3 : (k == (size p).-1).
  move/eqP : Hk3=> Hk3.
  rewrite Hk3.
  by apply: (normal_lead_coef_gt0 Hpnormal).
apply: (normal_0notroot Hpnormal Hp0noroot).
rewrite ltn_neqAle.
apply/andP; split.
  by move/eqP/eqP : Hk3 ->.
by rewrite -ltnS (@ltn_predK k) p_size.
Qed.

Lemma seqn0q_size : (1 < size (seqn0 q))%N.
Proof.
apply: seqn0_size_2.
  exact: q_0_lt0.
exact: q_n_gt0.
Qed.

Definition spseq := map (fun x : R * R => x.1 / x.2 - a) (zip p (drop 1 p)).

Lemma spseqE : spseq = [seq x.1 / x.2 - a | x <- zip p (drop 1 p)].
Proof. by done. Qed.

Lemma spseq_size : size spseq = d.-2.
Proof.
rewrite spseqE size_map size_zip size_drop subn1 -p_size minnE subKn //.
by apply: leq_pred.
Qed.

Lemma spseq_coef : forall k, (*(1%N < size p)%N ->*) (k < d.-2)%N ->
   spseq`_k = p`_k / p`_k.+1 - a. 
Proof.
move=> k (*Hpsize*) Hk.
have H : minn (size p) ((size p) - 1%N) = ((size p) - 1%N)%N.
  rewrite minnE subKn // subn1 -{2}(@prednK (size p)).
  apply: leqnSn.
  rewrite ltnNge leqn0 size_poly_eq0.
  by apply: normal_neq0.
rewrite spseqE.
rewrite (@nth_map _ 0).
  rewrite nth_zip_cond /= size_zip !size_drop. 
  rewrite H subn1 p_size Hk /=.
  by rewrite !nth_drop (addnC 1%N) addn1.
by rewrite size_zip !size_drop H subn1 p_size. 
Qed.

(* probably a distinction of case needed for k.+2: if it is head_coef or not *)
Lemma spseq_increasing : increasing spseq.
Proof.
(*case Hpsize : (1 < size p)%N.*)
  apply: increasing_is_increasing2 => k Hk.
  rewrite spseq_size in Hk.
  rewrite (@spseq_coef k) //.
    rewrite (@spseq_coef k.+1) //.
      apply: ler_sub => //.
      rewrite ler_pdivr_mulr.
        rewrite mulrC mulrA ler_pdivl_mulr.
          rewrite -expr2.
          by apply: (@normal_squares _ _ Hpnormal k.+1).
        apply: (@normal_0notroot _ _ Hpnormal Hp0noroot k.+2).
        rewrite -(@addn2 k). rewrite addnC -ltn_subRL.
        rewrite p_size.
        admit. (**********)
      apply: (@normal_0notroot _ _ Hpnormal Hp0noroot k.+1).
      rewrite -(@addn1 k). rewrite addnC -ltn_subRL p_size -subn2.
      by rewrite -subnDA addnC subnDA subn2 subn1.
    rewrite -(@addn1 k). rewrite addnC -ltn_subRL -subn2.
    by rewrite -subnDA addnC subnDA subn2 subn1.
  apply: (@leq_trans (size q).-1.-2) => //.
  by rewrite -(@subn2 (size q)) -subn1 (leq_subLR) addnC addn1.
(*have Hpsize2 := (negbT Hpsize).
rewrite -leqNgt normal_size_le1 // in Hpsize2.
move/eqP : Hpsize2 => Hpsize2.
apply: increasing_is_increasing2 => k Hk.
by rewrite spseq_size -p_size Hpsize2 ltn0 in Hk.*)
Qed. (**********)


(* the middle coefficients of q as a product *) 
Lemma seqmul_spseq_dropp : mid q = seqmul spseq (drop 1 p).
Proof.
apply: (@eq_from_nth _ 0) => [ | k Hk].
  by rewrite mid_size seqmul_size spseq_size size_drop p_size subn1 minnE subKn.
rewrite mid_coef_1 // q_k //.
  rewrite seqmul_coef.
    rewrite nth_drop addnC addn1 spseq_coef //.
    by rewrite -mid_size.
  rewrite spseq_size size_drop p_size subn1 minnE subKn //.
  by rewrite -mid_size.
by rewrite -(@addn1 k) addnC -ltn_subRL subn1 -mid_size.
Qed.

Lemma all_pos_dropp : all_pos (drop 1 p).
Proof.
apply : gt0_all_pos => k Hk.
rewrite nth_drop addnC addn1.
apply: (@all_pos_gt0 _ p _ k.+1).
  by apply: normal_all_pos.
rewrite size_drop in Hk.
by rewrite -(@addn1 k) addnC -ltn_subRL.
Qed.

(* (mid q)`_k = 0 iff spseq`_k = 0 *)
Lemma map_midq_spseq :
(map (fun x => x != 0) (mid q)) = map (fun x => x != 0) spseq.
Proof.
rewrite seqmul_spseq_dropp map_seqmul //.
  exact: all_pos_dropp.
by rewrite spseq_size size_drop p_size subn1.
Qed.

Lemma spseq_seqn0 :
   (mask (map (fun x => x != 0) (mid q)) spseq) = seqn0 spseq.
Proof.
by rewrite seqn0_as_mask map_midq_spseq.
Qed.

(* the middle coefficients of q without the 0's are as well a product *) 
Lemma mid_seqn0q_decomp : 
   mid (seqn0 q) =
   seqmul (seqn0 spseq)
          (mask (map (fun x => x != 0) (mid q)) (drop 1 p)).
Proof.
rewrite mid_seqn0_C.
    by rewrite {1}seqmul_spseq_dropp {1}seqn0_as_mask mask_seqmul -spseq_seqn0 seqmul_spseq_dropp.
  exact: q_0_neq0.
exact: q_n_neq0.
Qed.

Lemma mid_seqn0q_size :
   size (mid (seqn0 q)) = size (seqn0 spseq).
Proof.
rewrite mid_seqn0_C.
    rewrite !seqn0_as_mask !size_mask.
        by rewrite map_midq_spseq.
      by rewrite size_map.
    by rewrite size_map.
  exact: q_0_neq0.
exact: q_n_neq0.
Qed.

Lemma size_seqn0spseq_maskdropp : size (seqn0 spseq) =
   size (mask [seq x != 0 | x <- mid q] (drop 1 p)).
Proof.
rewrite -mid_seqn0q_size mid_seqn0_C.
    rewrite seqn0_as_mask !size_mask.
        by done.
      by rewrite size_map size_drop mid_size p_size subn1.
    by rewrite size_map.
  exact: q_0_neq0.
exact: q_n_neq0.
Qed.

Lemma minn_seqn0spseq_maskdropp :  (minn (size (seqn0 (R:=R) spseq))
    (size (mask [seq x != 0 | x <- mid (R:=R) q] (drop 1 p)))) = (size (seqn0 spseq)).
Proof.
by rewrite -size_seqn0spseq_maskdropp minnE subKn.
Qed.

(* this is increasing since spseq is increasing *)
Lemma subspseq_increasing : increasing (seqn0 spseq).
Proof.
apply: (@subseq_incr R _ spseq).
  by apply: spseq_increasing.
by apply: filter_subseq.
Qed.

(* this is all positive because p is all positive *)
Lemma subp_all_pos : all_pos (mask (map (fun x => x != 0) (mid q)) (drop 1 p)).
Proof.
apply: (@all_pos_subseq R _ (drop 1 p)).
  by apply: all_pos_dropp.
apply/subseqP.
exists [seq x != 0 | x <- mid (R:=R) q] => //.
rewrite size_map.
by rewrite mid_size size_drop p_size subn1.
Qed.

Lemma seqn0q_1 : (1 < (size (seqn0 q)).-1)%N ->
   (seqn0 q)`_1 = (mid (seqn0 q))`_0.
Proof.
move=> Hk.
by rewrite -mid_coef_2.
Qed.

Lemma seqn0q_n :  (0 < (size (seqn0 (R:=R) q)).-2)%N ->
      (seqn0 q)`_(size (seqn0 q)).-2 =
      (mid (seqn0 q))`_((size (mid (seqn0 q))).-1)%N.
Proof.
move=> Hsize_2.
have Hsize_1 : (0 < (size (seqn0 q)).-1)%N.
  rewrite -subn1 ltn_subRL addn0 in Hsize_2.
  by apply: (@ltn_trans 1%N).
have Hsize : (0 < size (seqn0 q))%N.
  rewrite -subn1 ltn_subRL addn0 in Hsize_1.
  by apply: (@ltn_trans 1%N).
rewrite mid_coef_2; rewrite mid_size //.
by rewrite -(subn1 (size (seqn0 q))) ltn_subRL addnC addn1 subn1 prednK //
   {2}(pred_Sn (size (seqn0 q))) -(subn1 (size (seqn0 q)).+1) ltn_subRL addnC addn1
   prednK.
Qed.

(* Proposition 2.44 *)
Lemma normal_changes : changes (seqn0 q) = 1%N.
Proof.
(* 3 < size (seqn0 q) *)
case Hsizeseqn0q : (3 < size (seqn0 q))%N.
  have Hincreasing1 := spseq_increasing;
  have Hincreasing2 := subspseq_increasing;
  have Hallpos := (subp_all_pos);
  have Hseqn0q := (seqn0_all_neq0 q);
  have Hseqn0spseq := (seqn0_all_neq0 spseq);
  have Hqsize := q_size;
  have Hqsize2 := p_size;
  have Hsizemidq := mid_seqn0q_size;
  have Hsizespseq := size_seqn0spseq_maskdropp;
  have Hqn1 := q_n_gt0;
  have Hqn2 := q_n_neq0;
  have Hq01 := q_0_lt0;
  have Hq02 := q_0_neq0.
  have H_1 : (0%N < (size (seqn0 q)).-1)%N.
    rewrite -(ltn_add2r 1%N) !addn1 prednK; by apply: (@ltn_trans 3).
  have H_2 : (0%N < (size (seqn0 q)).-2)%N.
    rewrite -(ltn_add2r 2) !addn2 prednK // prednK; by apply: (@ltn_trans 3).
  
  rewrite changes_decomp_sizegt2 //.
    rewrite mid_seqn0q_decomp changes_mult // seqn0_0 // seqn0q_1 //.
      rewrite {1}mid_seqn0q_decomp seqmul_coef.
        rewrite seqn0_n // seqn0q_n // {1}mid_seqn0q_decomp seqmul_coef.

          (* case *)
          case Hchanges : (changes (seqn0 spseq) == 1%N).
          (* one change in mid q *)
            move/eqP : Hchanges => Hchanges.
            rewrite Hchanges.
            move/eqP : Hchanges => Hchanges.
            rewrite changes_seq_incr_1 // in Hchanges.
              move/andP : Hchanges => [] H0 H1.
              have H2: (q`_0 *
                  ((seqn0 spseq)`_0 *
                  (mask [seq x != 0 | x <- mid q] (drop 1 p))`_0) < 0) = false.
                apply: negbTE.
                rewrite -lerNgt nmulr_rge0 // nmulr_rle0 //.
                apply: ltrW.
                apply: (@all_pos_gt0 _ _ Hallpos 0%N).
                by rewrite -Hsizespseq -Hsizemidq mid_size.
              rewrite H2 mid_seqn0q_size.
              have H3 : ((seqn0 spseq)`_(size (seqn0 spseq)).-1 *
                 (mask [seq x != 0 | x <- mid q] (drop 1 p))`_
                 (size (seqn0 spseq)).-1 * q`_(size q).-1 < 0) = false.
                apply: negbTE.
                rewrite -lerNgt mulrC pmulr_lge0.
                  by apply: ltrW.
                rewrite pmulr_lgt0 //.
                apply: (@all_pos_gt0 _ _ Hallpos (size (seqn0 spseq)).-1).
                rewrite -Hsizespseq -Hsizemidq mid_size -{2}(subn2 (size (seqn0 q))) ltn_subRL
                    addnC addn2 prednK // prednK //.
                rewrite {2}(pred_Sn (size (seqn0 q))) -(subn1 (size (seqn0 q)).+1) ltn_subRL 
                  addnC addn1 prednK //.
                by apply: (@ltn_trans 3).
              by rewrite H3.
            by rewrite -mid_seqn0q_size mid_size -subn2 ltn_subRL addn1.
          (* no change in mid q *)
          have Hchanges2 : (changes (seqn0 spseq)) == 0%N.
            rewrite -(Bool.orb_false_l ((changes (seqn0 spseq)) == 0%N)).
            rewrite -Hchanges.
            exact: changes_seq_incr.
          clear Hchanges.
          move/eqP : Hchanges2 => Hchanges.
          rewrite Hchanges.
          move/eqP : Hchanges => Hchanges.
          rewrite changes_seq_incr_0 // in Hchanges.
            (* case *)
            case Hspseq0_pos : (0 < (seqn0 spseq)`_0).
            (* first of spseq pos *)
              have H1 : ((q`_0 *
                 ((seqn0 spseq)`_0 *
                 (mask [seq x != 0 | x <- mid q] (drop 1 p))`_0) < 0) = true).
                apply/eqP; rewrite eqb_id.
                rewrite nmulr_rlt0 // mulrC pmulr_lgt0 //.
                apply: (@all_pos_gt0 _ _ Hallpos 0%N).
                by rewrite -Hsizespseq -Hsizemidq mid_size.
              rewrite H1 mid_seqn0q_size.
              have H2 : (0 < (seqn0 spseq)`_(size (seqn0 spseq)).-1).
                by rewrite -(@pmulr_lgt0 _ (seqn0 spseq)`_0) // mulrC.
              have H3 : ((seqn0 spseq)`_(size (seqn0 spseq)).-1 *
                 (mask [seq x != 0 | x <- mid q] (drop 1 p))`_
                 (size (seqn0 spseq)).-1 * q`_(size q).-1 < 0) = false.
                apply: negbTE. rewrite -lerNgt mulrC pmulr_lge0.
                  by apply: ltrW.
                rewrite pmulr_lgt0 //.
                apply: (@all_pos_gt0 _ _ Hallpos (size (seqn0 spseq)).-1).
                rewrite -Hsizespseq -Hsizemidq mid_size -{2}(subn2 (size (seqn0 q))) ltn_subRL
                   addnC addn2 prednK // prednK //.
                rewrite {2}(pred_Sn (size (seqn0 q))) -(subn1 (size (seqn0 q)).+1) ltn_subRL 
                   addnC addn1 prednK //.
                by apply: (@ltn_trans 3).
              by rewrite H3.
            (* first of spseq neg *)
            have H1 : ((q`_0 *
               ((seqn0 spseq)`_0 *
               (mask [seq x != 0 | x <- mid q] (drop 1 p))`_0) < 0) = false).
              apply: negbTE. rewrite -lerNgt nmulr_lge0.
                by apply: ltrW.
              rewrite nmulr_rlt0.
                apply: (@all_pos_gt0 _ _ Hallpos 0%N).
                by rewrite -Hsizespseq -Hsizemidq mid_size.
              rewrite ltr_def. apply/andP; split.
                rewrite eq_sym. apply: (@all_neq0_neq0_1 _ _ Hseqn0spseq 0%N) => //.
                by rewrite -Hsizemidq mid_size.
              rewrite lerNgt. by apply: negbT.
            rewrite H1.
            have H2 : ((seqn0 spseq)`_(size (mid (seqn0 q))).-1 < 0).
              rewrite Hsizemidq -(@nmulr_rgt0 _ (seqn0 spseq)`_0) // ltr_def.
              apply/andP; split.
                rewrite eq_sym. apply: (all_neq0_neq0_1) => //.
                by rewrite -Hsizemidq mid_size.
              rewrite lerNgt. by apply: negbT.
            have H3 : (((seqn0 spseq)`_(size (mid (seqn0 q))).-1 *
              (mask [seq x != 0 | x <- mid q] (drop 1 p))`_
              (size (mid (seqn0 q))).-1 * q`_(size q).-1 < 0) = true).
              apply/eqP; rewrite eqb_id.
              rewrite nmulr_rlt0 // nmulr_rlt0 //.
              apply: (@all_pos_gt0 _ _ Hallpos (size (mid (seqn0 q))).-1).
              rewrite -Hsizespseq -Hsizemidq mid_size -{2}(subn2 (size (seqn0 q))) ltn_subRL
                    addnC addn2 prednK // prednK //.
              rewrite {2}(pred_Sn (size (seqn0 q))) -(subn1 (size (seqn0 q)).+1) ltn_subRL 
                  addnC addn1 prednK //.
              by apply: (@ltn_trans 3).
            by rewrite H3.
          by rewrite -Hsizemidq mid_size.
        by rewrite -Hsizespseq -Hsizemidq mid_size minnE subKn // -(ltn_add2r 3) !addn3 prednK.    
      by rewrite -Hsizespseq -Hsizemidq minnE subKn // mid_size //.
    rewrite -(ltn_add2r 1%N) !addn1 prednK //; by apply: (@ltn_trans 3).
  by apply: (@ltn_trans 3).
(* size (seqn0 q) <= 3 *)
case H : (2 < size (seqn0 q))%N. 
(* 2 < size (seqn0 q) *)
  have Hsizeseqn0q2 : (size (seqn0 q) == 3).
    rewrite eqn_leq. apply/andP; split => //.
    rewrite leqNgt. by apply: negbT.
  move/eqP : Hsizeseqn0q2 => Hsizeseqn0q2.
  apply: changes_size3 => //.
      by apply: seqn0_all_neq0.
    rewrite seqn0_0.
      exact: q_0_lt0.
    exact: q_0_neq0.
  rewrite (@pred_Sn 2) -Hsizeseqn0q2 seqn0_n.
    exact: q_n_gt0.
  exact: q_n_neq0.
(* size (seqn0 q) <= 2 *)
have Hsizeseqn0q2 : (size (seqn0 q) == 2).
  rewrite eqn_leq. apply/andP; split.
    rewrite leqNgt. by apply: negbT.
  by apply: seqn0q_size.  
rewrite changes_decomp_size2 //.
  move/eqP : Hsizeseqn0q2 => Hsizeseqn0q2.
  rewrite seqn0_0.
    rewrite {1}(@pred_Sn 1) -Hsizeseqn0q2 seqn0_n.
      apply/eqP. rewrite eqb1.
      rewrite pmulr_llt0.
        exact: q_0_lt0.
      exact: q_n_gt0.
    exact: q_n_neq0.
  exact: q_0_neq0.
by apply: seqn0_all_neq0.
Qed.

End Proof_Prop_2_44.
