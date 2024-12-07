From mathcomp Require Import all_ssreflect all_algebra.
Require Export Field.
Require Import generic_trajectories.
Require Import math_comp_complements points_and_edges events cells.
Require Import opening_cells cells_alg.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Import NArithRing.
Import Order.TTheory GRing.Theory Num.Theory Num.ExtraDef Num.

Open Scope ring_scope.

Section working_environment.

Variable R : realFieldType.

(* Notation prefix, dupplicated from cells_alg.v *)
Notation pt := (pt (RealField.sort R)).
Notation p_x := (p_x (RealField.sort R)).
Notation p_y := (p_y (RealField.sort R)).
Notation Bpt := (Bpt (RealField.sort R)).
Notation edge := (edge R).
Notation left_pt := (@left_pt R).
Notation right_pt := (@right_pt R).
Notation event := (event (RealField.sort R) edge).
Notation outgoing := (outgoing (RealField.sort R) edge).
Notation point := (point (RealField.sort R) edge).
Notation cell := (cell (RealField.sort R) edge).

Notation dummy_pt := (dummy_pt (RealField.sort R) 1).
Notation dummy_edge := (dummy_edge (RealField.sort R) 1 edge (@unsafe_Bedge _)).
Notation dummy_cell :=
  (dummy_cell (RealField.sort R) 1 edge (@unsafe_Bedge _)).
Notation dummy_event := (dummy_event (RealField.sort R) 1 edge).
Notation edge_below :=
  (generic_trajectories.edge_below (RealField.sort R) eq_op <=%R +%R
    (fun x y => x - y) *%R 1 edge left_pt right_pt).
Notation "x <| y" := (edge_below x y).
Notation valid_edge :=
  (generic_trajectories.valid_edge (RealField.sort R)
   le edge left_pt right_pt).
Notation vertical_intersection_point :=
  (vertical_intersection_point (RealField.sort R)
  le +%R (fun x y => x - y) *%R
  (fun x y => x / y) edge left_pt right_pt).
Notation point_under_edge :=
  (point_under_edge (RealField.sort R) le +%R (fun x y => x - y) *%R 1
  edge left_pt right_pt).
Notation "p <<= g" := (point_under_edge p g).
Notation "p >>> g" := (~~ (point_under_edge p g)).
Notation point_strictly_under_edge :=
  (point_strictly_under_edge  (RealField.sort R) eq_op <=%R +%R
  (fun x y => x - y) *%R 1 edge left_pt right_pt).
Notation "p <<< g" := (point_strictly_under_edge p g).
Notation "p >>= g" := (~~ (point_strictly_under_edge p g)).

Notation contains_point :=
  (contains_point (RealField.sort R) eq_op <=%R +%R (fun x y => x - y) *%R 1
    edge left_pt right_pt).

Notation open_cells_decomposition_contact :=
  (open_cells_decomposition_contact (RealField.sort R) eq_op le +%R
  (fun x y => x - y) *%R 1 edge left_pt right_pt).
Notation open_cells_decomposition_rec :=
  (open_cells_decomposition_rec (RealField.sort R) eq_op le +%R
  (fun x y => x - y) *%R 1 edge (@unsafe_Bedge R) left_pt
  right_pt).
Notation open_cells_decomposition :=
  (open_cells_decomposition (RealField.sort R) eq_op le +%R
  (fun x y => x - y) *%R 1 edge (@unsafe_Bedge R) left_pt
  right_pt).

Notation scan_state := (scan_state (RealField.sort R) edge).
Notation sc_open1 := (sc_open1 (RealField.sort R) edge).
Notation lst_open := (lst_open (RealField.sort R) edge).
Notation sc_open2 := (sc_open2 (RealField.sort R) edge).
Notation sc_closed := (sc_closed (RealField.sort R) edge).
Notation lst_closed := (lst_closed (RealField.sort R) edge).

Notation update_closed_cell :=
  (update_closed_cell (RealField.sort R) 1 edge).

Notation set_left_pts :=
  (set_left_pts (RealField.sort R) edge).

Notation low := (low (RealField.sort R) edge).
Notation high := (high (RealField.sort R) edge).
Notation left_pts := (left_pts (RealField.sort R) edge).
Notation right_pts := (right_pts (RealField.sort R) edge).
Notation Bcell := (Bcell (RealField.sort R) edge).
Notation cell_center :=
  (cell_center (RealField.sort R) +%R (fun x y => x / y) 1%:R edge).

Notation closing_cells :=
  (generic_trajectories.closing_cells (RealField.sort R) eq_op <=%R +%R (fun x y => x - y)
    *%R (fun x y => x / y) edge left_pt right_pt).
Notation close_cell :=
  (generic_trajectories.close_cell (RealField.sort R) eq_op <=%R +%R (fun x y => x - y)
    *%R (fun x y => x / y) edge left_pt right_pt).

Notation set_pts := (set_pts (RealField.sort R) edge).

(* This function is to be called only when the event is in the middle
  of the last opening cell.  The point e needs to be added to the left
  points of one of the newly created open cells, but the one that receives
  the first segment of the last opening cells should keep its existing
  left points.*)
Notation update_open_cell :=
  (update_open_cell (RealField.sort R) eq_op le +%R (fun x y => x - y)
  *%R (fun x y => x / y) 1 edge (@unsafe_Bedge R) left_pt right_pt).

Notation update_open_cell_top :=
  (update_open_cell_top (RealField.sort R) eq_op le +%R (fun x y => x - y)
  *%R (fun x y => x / y) 1
  edge (@unsafe_Bedge R) left_pt right_pt).

Notation Bscan := (Bscan (RealField.sort R) edge).

Notation opening_cells_aux :=
  (opening_cells_aux (RealField.sort R) eq_op <=%R +%R (fun x y => x - y)
  *%R (fun x y => x / y) 1 edge (@unsafe_Bedge R) left_pt right_pt).

Notation simple_step :=
  (generic_trajectories.simple_step (RealField.sort R) eq_op le +%R
  (fun x y => x - y) *%R (fun x y => x / y)
  1 edge (@unsafe_Bedge R) left_pt right_pt).

Notation step :=
  (step (RealField.sort R) eq_op le +%R (fun x y => x - y) *%R
  (fun x y => x / y) 1 edge (@unsafe_Bedge R) left_pt right_pt).
(* 
Definition scan events st : seq cell * seq cell :=
  let final_state := foldl step st events in
  (sc_open1 final_state ++ lst_open final_state :: sc_open2 final_state,
   lst_closed final_state :: sc_closed final_state). *)

Notation start_open_cell :=
  (start_open_cell (RealField.sort R) eq_op le +%R (fun x y => x - y)
  *%R (fun x y => x / y) edge left_pt right_pt).

Notation open_cell_side_limit_ok :=
  (@open_cell_side_limit_ok R).

 (* End of notation prefix. *)
 
Lemma simple_step_common_invariant
  bottom top s fop lsto lop fc cc lcc lc le he cls lstc ev
  lsthe lstx evs :
  bottom <| top ->
  {in bottom :: top :: s &, forall e1 e2, inter_at_ext e1 e2} ->
  {in s, forall g, inside_box bottom top (left_pt g) &&
                   inside_box bottom top (right_pt g)} ->
  open_cells_decomposition (fop ++ lsto :: lop) (point ev) =
    (fc, cc, lcc, lc, le, he) ->
  common_invariant bottom top s
     (Bscan fop lsto lop cls lstc lsthe lstx)
     (ev :: evs) ->
  common_invariant bottom top s
     (simple_step fc cc lc lcc le he cls lstc ev)
    evs.
Proof.
move=> boxwf nocs' inbox_s oe.
move=> []; rewrite /state_open_seq/state_closed_seq/=.
move=> inv lstxq lstheq sub_edges cle out_es uniqout /[dup] inbox0.
move=> /andP[] inbox_e inbox_es.
move=> no_dup lexev oks lexpt1.
move: (inv)=> [] clae [] []; first by [].
move=> sval [] adj [] cbtom rfo.
have oute : out_left_event ev.
  by apply: out_es; rewrite inE eqxx.
have oute' : {in sort edge_below (outgoing ev),
                   forall g, left_pt g == point ev}.
  by move=> g; rewrite mem_sort; apply: oute.
have nocs : {in bottom :: top :: s &, no_crossing R}.
  by apply: inter_at_ext_no_crossing.
have noco : {in all_edges (fop ++ lsto :: lop) (ev :: evs) &,
                 no_crossing R}.
 by  move=> g1 gt2 g1in g2in; apply: nocs; apply: sub_edges.
rewrite /simple_step/generic_trajectories.simple_step.
rewrite -/(opening_cells_aux _ _ _ _).
case oca_eq : (opening_cells_aux _ _ _ _) => [nos lno].
have inv' : inv1_seq bottom top evs ((fc ++ nos) ++ lno :: lc).
  have := invariant1_default_case inbox0 oute rfo cbtom adj sval cle clae
            noco lexev.
  by rewrite oe oca_eq.
have := inv' =>  -[] clae' [] sval' [] adj' []cbtom' rfo'.
have exi := exists_cell cbtom adj (inside_box_between inbox_e).
have [ocd [lcc_ctn [allct [allnct [flcnct [heq [leq [lein hein]]]]]]]] :=
  decomposition_main_properties oe exi.
have [{}pal {}puh vl vp nc]:=
  decomposition_connect_properties rfo sval adj cbtom
    (inside_box_between inbox_e) oe.
have /esym left_last : left_limit lno = p_x (point ev).
  apply: (opening_cells_left oute vl vp).
  by rewrite /opening_cells oca_eq mem_rcons inE eqxx.
have heqo : high lno = he.
  by have := opening_cells_aux_high_last vl vp oute'; rewrite oca_eq.
have sub_edges' : {subset all_edges ((fc ++ nos) ++ lno :: lc) evs <=
                     [:: bottom, top & s]}.
  have := step_keeps_subset_default inbox0 oute rfo cbtom adj sval.
  rewrite oe oca_eq !catA /= /all_edges => main g.
  rewrite mem_cat=> /orP[ | gin]; last first.
    apply: sub_edges; rewrite mem_cat; apply/orP; right.
    by rewrite events_to_edges_cons mem_cat gin orbT.
  rewrite (cell_edges_sub_high cbtom' adj') inE=> /orP[/eqP -> | /main].
    by rewrite inE eqxx.
  rewrite mem_cat=> /orP[] gin; apply: sub_edges; last first.
    by rewrite mem_cat events_to_edges_cons orbC mem_cat gin.
  by rewrite mem_cat mem_cat gin orbT.
have cle' : close_edges_from_events evs by move: cle=> /andP[].
have out_es' : {in evs, forall e, out_left_event e}.
  by move=> e ein; apply: out_es; rewrite inE ein orbT.
have lexev' : sorted (@lexPtEv _) evs by move: lexev=> /path_sorted.
have oks' : all open_cell_side_limit_ok ((fc ++ nos) ++ lno :: lc).
  have := step_keeps_open_side_limit_default inbox0 oute rfo
    cbtom adj sval oks; rewrite oe oca_eq.
  by [].
have lexfutev : {in evs, forall e,
     lexPt (last dummy_pt (left_pts lno)) (point e)}.
  move=> e ein.
  have noce : {in le :: rcons (sort edge_below (outgoing ev)) he &,
           no_crossing R}.
    move=> g1 g2 g1in g2in; apply noco.
      move: g1in; rewrite inE mem_rcons inE mem_sort orbA=> /orP[]g1in.
        by move: g1in=> /orP[] /eqP ->; rewrite mem_cat ?lein ?hein.
      by rewrite mem_cat orbC /events_to_edges /= mem_cat g1in.
    move: g2in; rewrite inE mem_rcons inE mem_sort orbA=> /orP[]g2in.
      by move: g2in=> /orP[] /eqP ->; rewrite mem_cat ?lein ?hein.
    by rewrite mem_cat orbC /events_to_edges /= mem_cat g2in.
  have lebhe : le <| he.
    apply: (edge_below_from_point_above _ vl vp (underWC pal) puh).
    by apply: noce; rewrite !(inE, mem_rcons) eqxx ?orbT.
  have lnoin: lno \in opening_cells (point ev) (outgoing ev) le he.
    by rewrite /opening_cells oca_eq mem_rcons inE eqxx.
  have :=
    opening_cells_last_lexePt oute (underWC pal) puh vl vp noce lebhe lnoin.
  move=> /lexePt_lexPt_trans; apply.
  move: (lexev).
  rewrite -/(sorted _ (ev :: evs)) sorted_lexPtEv_lexPt /=.
  rewrite (path_sortedE (@lexPt_trans _)).
  by move=> /andP[] /allP /(_ _ (map_f _ ein)).
have uniqout' : {in evs, forall e, uniq (outgoing e)}.
  by move=> e ein; apply: uniqout; rewrite inE ein orbT.
have no_dup' : {in [seq high c | c <- (fc ++ nos) ++ lno :: lc] & evs,
  forall g e, g \notin outgoing e}.
  move=> /= g e + ein; rewrite -catA -cat_rcons !map_cat !mem_cat orbCA.
  move=> /orP[cnew | cold]; last first.
    apply: no_dup; last by rewrite inE ein orbT.
    rewrite ocd !map_cat /= !mem_cat inE.
    by move: cold=> /orP[] ->; rewrite ?orbT.
  have := opening_cells_aux_high vl vp oute'; rewrite oca_eq /=.
  have := opening_cells_aux_high_last vl vp oute'; rewrite oca_eq /=.
  move=> lnoq nosq.
  apply/negP=> gout.
  have lefte : left_pt g = point e.
    exact: (eqP (out_es' _ ein _ gout)).
  have ein2 : e \in (ev :: evs) by rewrite inE ein orbT.
  move: cnew; rewrite map_rcons mem_rcons inE=> /orP[/eqP ghe | gnos].
    have := no_dup g e _ ein2.
    rewrite ocd !map_cat /= gout ghe lnoq heq !mem_cat inE eqxx !orbT.
    by move=> /(_ isT).
  rewrite nosq mem_sort in gnos.
  move: lexev; rewrite (path_sortedE (@lexPtEv_trans _))=> /andP[] + _.
  move=> /allP /(_ _ ein).
  by rewrite /lexPtEv -lefte (eqP (oute g gnos)) lexPt_irrefl.
by constructor.
Qed.

Lemma simple_step_common_non_gp_invariant
  bottom top s fop lsto lop cls lstc ev lsthe lstx evs
  fc cc lcc lc le he:
  bottom <| top ->
  {in bottom :: top :: s &, forall e1 e2, inter_at_ext e1 e2} ->
  {in s, forall g, inside_box bottom top (left_pt g) &&
                   inside_box bottom top (right_pt g)} ->
  (lstx <> p_x (point ev) \/ (lstx = p_x (point ev) /\ point ev >>> lsthe)) ->
  open_cells_decomposition (fop ++ lsto :: lop) (point ev) =
    (fc, cc, lcc, lc, le, he) ->
  common_non_gp_invariant bottom top s
     (Bscan fop lsto lop cls lstc lsthe lstx)
     (ev :: evs) ->
  common_non_gp_invariant bottom top s
     (simple_step fc cc lc lcc le he cls lstc ev)
    evs.
Proof.
move=> boxwf nocs inbox_s simple_cond oe comng.
have comi := ngcomm comng.
have inv := inv1 comi.
move: (inv)=> [] clae [] []; first by [].
move=> sval [] adj [] cbtom rfo.
have inbox_es := inbox_events comi.
have evin : ev \in ev :: evs by rewrite inE eqxx.
have inbox_e : inside_box bottom top (point ev).
  by apply: (allP inbox_es); rewrite map_f.
have exi := exists_cell cbtom adj (inside_box_between inbox_e).
have [ocd [lcc_ctn [allct [allnct [flcnct [heq [leq [lein hein]]]]]]]] :=
  decomposition_main_properties oe exi.
have out_es := out_events comi.
have oute : out_left_event ev by apply: out_es; rewrite inE eqxx.
case oca_eq : (opening_cells_aux (point ev) (sort edge_below (outgoing ev))
  le he) => [nos lno].
have [{}pal {}puh vl vp nc]:=
  decomposition_connect_properties rfo sval adj cbtom
  (inside_box_between inbox_e) oe.
have := last_opening_cells_left_pts_prefix vl vp puh oute.
  rewrite oca_eq /= => /(_ _ _ erefl) [] sll' snd_cond.
have comi' : common_invariant bottom top s
  (simple_step fc cc lc lcc le he cls lstc ev) evs.
  by apply: (simple_step_common_invariant boxwf nocs inbox_s oe comi).
(* have sll :
  (1 < size (left_pts (lst_open
      (simple_step fc cc lc lcc le he cls lstc ev))))%N.
  have := last_opening_cells_left_pts_prefix vl vp puh oute.
  by rewrite /simple_step oca_eq /= => /(_ _ _ erefl) []. *)
have lst_side_lex' : path (@lexPt _) (nth dummy_pt (left_pts lno) 1)
  [seq point e | e <- evs].
  move: snd_cond; case: (left_pts lno) sll' => [ | a [ | b tl]] //= _.
  move=> -[] _ -> _.
  suff :(sorted (@lexPt _) [seq point e | e <- ev :: evs]) by [].
  by rewrite -sorted_lexPtEv_lexPt; apply: (lex_events comi).
move:comi'; rewrite /simple_step/= oca_eq=> comi'.
by constructor.
Qed.

Lemma simple_step_disjoint_non_gp_invariant
  bottom top s fop lsto lop cls lstc ev lsthe lstx evs
  fc cc lcc lc le he:
  bottom <| top ->
  {in bottom :: top :: s &, forall e1 e2, inter_at_ext e1 e2} ->
  {in s, forall g, inside_box bottom top (left_pt g) &&
                   inside_box bottom top (right_pt g)} ->
  (lstx <> p_x (point ev) \/ (lstx = p_x (point ev) /\ point ev >>> lsthe)) ->
  open_cells_decomposition (fop ++ lsto :: lop) (point ev) =
    (fc, cc, lcc, lc, le, he) ->
  disjoint_non_gp_invariant bottom top s
     (Bscan fop lsto lop cls lstc lsthe lstx)
     (ev :: evs) ->
  disjoint_non_gp_invariant bottom top s
     (simple_step fc cc lc lcc le he cls lstc ev)
    evs.
Proof.
move=> boxwf nocs' inbox_s simple_cond oe.
move=> /[dup] /closed_at_left_non_gp_compat.
move=> + []; rewrite /state_open_seq/state_closed_seq/=.
move=> rl oc_dis c_dis comng pw rlx sr ucc wcl.
have := comng=> -[] /= comi lft_cond1 lft_cond2.
have := comi=> -[]; rewrite /state_open_seq/state_closed_seq/=.
move=> inv1 lstxq lstheq sub_edges cle out_es uniqout inbox_es
  no_dup lexev oks.
move=> bottom_left_cond cl_ok rllstc hlstcq midptlstc btm_leftops leftops.
move=> btm_left_lex_snd center_in uniq_high.
move: (inv1) => [] clae [] sval' [] adj [] cbtom rfo.
move: sval' => [ //| sval].
have inbox_e : inside_box bottom top (point ev).
  by have  := inbox_events comi=> /= /andP[].
have exi := exists_cell cbtom adj (inside_box_between inbox_e).
have [ocd [lcc_ctn [allct [allnct [flcnct [heq [leq [lein hein]]]]]]]] :=
    decomposition_main_properties oe exi.
have bet_e : between_edges bottom top (point ev).
  by apply: inside_box_between.
have [/= pal puh vle vhe ncont] :=
  connect_properties  cbtom adj rfo sval bet_e ocd allnct allct
  lcc_ctn flcnct.
rewrite /simple_step.
case oca_eq: opening_cells_aux => [nos lno].
have evin : ev \in ev :: evs by rewrite inE eqxx.
have lstxle: lstx <= p_x (point ev).
  have := bottom_left_cond _ evin.
  rewrite lstxq /left_limit=> /orP[].
    by rewrite le_eqVlt orbC => ->.
  by move => /andP[] /eqP -> _; apply: le_refl.
have cl_at_left' : {in rcons cls lstc,
        forall c, right_limit c <= p_x (point ev)}.
  by move=> c cin; apply: rl; rewrite // inE eqxx.
have oute : out_left_event ev by apply: out_es; rewrite inE eqxx.
have oute' : {in sort edge_below (outgoing ev),
  forall g, left_pt g == point ev}.
  by move=> g; rewrite mem_sort; apply: oute.
have := step_keeps_disjoint_default inbox_es oute rfo
         cbtom adj sval pw oks oc_dis c_dis cl_at_left'.
have lstoin : lsto \in fop ++ lsto :: lop.
  by rewrite !(mem_cat, inE) eqxx !orbT.
have vho : valid_edge (high lsto) (point ev).
  by move: (allP sval lsto lstoin)=> /andP[].
rewrite oe oca_eq /= !cat_rcons -!cats1 /= => disjointness.
have op_cl_dis':
  {in (fc ++ nos) ++ lno :: lc & rcons (cls ++ lstc ::
           closing_cells (point ev) cc) (close_cell (point ev) lcc),
         disjoint_open_closed_cells _}.
   move=> c1 c2; rewrite -!(cats1, catA)=> c1in c2in.
   by apply: (proj2 (disjointness)).
have cl_dis : {in  rcons (cls ++ lstc :: closing_cells (point ev) cc)
                 (close_cell (point ev) lcc) &, disjoint_closed_cells R}.
  by rewrite -!(cats1, catA); apply: (proj1 disjointness).
have nocs : {in bottom :: top :: s &, no_crossing R}.
  by apply: inter_at_ext_no_crossing.
have noc : {in all_edges (fop ++ lsto :: lop) (ev :: evs) &,
                 no_crossing R}.
  by move=> g1 gt2 g1in g2in; apply: nocs; apply: sub_edges.
have /andP [vllcc vhlcc] : valid_edge (low lcc) (point ev) &&
  valid_edge (high lcc) (point ev).
  by apply: (allP sval); rewrite ocd !(mem_cat, inE) eqxx !orbT.
have pwo' : pairwise edge_below
           (bottom :: [seq high c | c <- (fc ++ nos) ++ lno :: lc]).
have := step_keeps_pw_default inbox_es oute rfo cbtom adj sval
      noc pw.
  by rewrite oe oca_eq -catA.
have right_limit_closed' :
  {in  rcons(cls ++
          lstc :: closing_cells (point ev) cc) (close_cell (point ev) lcc),
     forall c, right_limit c <= p_x (point ev)}.
  have:= step_keeps_right_limit_better inbox_es cbtom adj
    sval cl_at_left'.
  by rewrite oe oca_eq /=.
have cngi : common_non_gp_invariant bottom top s
              (Bscan (fc ++ nos) lno lc
                (cls ++ (lstc :: closing_cells (point ev) cc))
                (close_cell (point ev) lcc) he (p_x (point ev))) evs.
  have := simple_step_common_non_gp_invariant boxwf nocs' inbox_s
    simple_cond oe comng.
  by rewrite /simple_step oca_eq.
have midrlstc : (1 < size (right_pts (close_cell (point ev) lcc)))%N.
  have evnin:
    point ev != Bpt (p_x (point ev)) (pvert_y (point ev) (high lcc)).
    apply/eqP=> abs.
    have := pvert_on vhlcc; rewrite -abs => {}abs.
    by have := puh; rewrite strict_nonAunder // abs.
  rewrite /close_cell.
  rewrite !pvertE //.
  cbn [no_dup_seq_aux].
  case: ifP=> [/eqP /esym/eqP| diff]; first by rewrite (negbTE evnin).
  by case: ifP.
have wcl' : {in rcons (cls ++ (lstc :: closing_cells (point ev) cc))
                                (close_cell (point ev) lcc),
          forall c, left_limit c < right_limit c}.
  move=> c; rewrite -cats1 !(mem_cat, inE) -!orbA orbA => /orP[cold | cnew].
    by apply: wcl; rewrite -cats1 !(mem_cat, inE).
  have [c' c'in cc'] : exists2 c', c' \in rcons cc lcc &
        c = close_cell (point ev) c'.
    move: cnew=> /orP[/mapP [c' c'in ->] | /eqP ->].
      by exists c'; rewrite // mem_rcons inE c'in orbT.
    by exists lcc; rewrite // mem_rcons inE eqxx.
  rewrite cc' {c cc' cnew}.
  have c'in2 : c' \in fop ++ lsto :: lop.
      by rewrite ocd -cat_rcons !mem_cat c'in !orbT.
  have /andP/= [vlc' vhc'] := allP sval _ c'in2.
  rewrite (right_limit_close_cell vlc' vhc') /=.
  have llt : left_limit c' <= lstx.
    by apply: leftops; rewrite ocd -cat_rcons !mem_cat c'in ?orbT.
  rewrite /left_limit.
  have [_ _ ->]:= close_cell_preserve_3sides (point ev) c'.
  move: simple_cond=> -[/eqP simple_cond | [atlstx abovelsthe]].
     by apply: (le_lt_trans llt); rewrite lt_neqAle simple_cond.
  have c'high : c' \in lop.
    have cont : contains_point (point ev) c'.
      move: c'in; rewrite mem_rcons inE=> /orP[/eqP -> //| ].
      apply allct.
    move: c'in2; rewrite !(mem_cat, inE) orbA=> /orP[abs | ]; last by [].
    case/negP: abovelsthe; rewrite -lstheq.
    move: abs=> /orP[ c'fop | /eqP <-]; last first.
      by move: cont=> /andP[].
    have /andP[_] := pw.
    have lstoin2 : lsto \in lsto :: lop by rewrite inE eqxx.
    rewrite map_cat /= pairwise_cat=> /andP[] + _.
    move=> /allrelP /(_ _ _ (map_f _ c'fop) (map_f _ lstoin2)) hc'blsto.
    apply: (order_edges_viz_point' vhc' vho hc'blsto).
    by move/andP: cont=>[].
  move: llt; rewrite /left_limit atlstx le_eqVlt=> /orP[/eqP abs|]; last by [].
  have nth1in : nth dummy_pt (left_pts lsto) 1 \in (left_pts lsto).
     by apply: mem_nth.
  (* TODO: make this a lemma. *)
  have xnth1 : p_x (nth dummy_pt (left_pts lsto) 1) = p_x (point ev).
    have := allP oks lsto lstoin=> /andP[] _ /andP[] + _.
    by move=> /allP /(_ _ nth1in) /eqP ->; rewrite -lstxq.
  have : lexePt (bottom_left_corner c') (nth dummy_pt (left_pts lsto) 1).
    by apply: (btm_left_lex_snd c' c'in2).
  rewrite /lexePt /bottom_left_corner lt_neqAle abs xnth1 eqxx /= leNgt.
  case/negP.
  have nth1b: p_y (nth dummy_pt (left_pts lsto) 1) <
         pvert_y (nth dummy_pt (left_pts lsto) 1) lsthe.
    have := allP oks lsto lstoin=> /andP[] _ /andP[] Q /andP[] S /andP[] hdon _.
    have xh : p_x (head dummy_pt (left_pts lsto)) =
      p_x (nth dummy_pt (left_pts lsto) 1).
      move: lft_cond1 Q; case: (left_pts lsto)=> [ | a [ | b tl]] //= _.
      by move=> /andP[] /eqP -> /andP[] /eqP <-.
    have := on_pvert hdon.
    have := same_pvert_y (proj2 (andP hdon)) xh => ->.
    rewrite lstheq => ->.
    move: lft_cond1 S.
    by case: (left_pts lsto) => [ | a [ | b tl]] //= _ /andP[].
  apply: (lt_le_trans nth1b).
  have [c'2 c'2in c'2q] : exists2 c'2, c'2 \in lsto::lop & high c'2 = low c'.
    have /mem_seq_split [s1 [s2 s1s2q]] := c'high.
    exists (last lsto s1).
      rewrite s1s2q -[_ :: _]/((lsto :: s1) ++ (c' :: s2)).
      by rewrite mem_cat mem_last.
    move: adj; rewrite s1s2q=> /adjacent_catW /= => -[] _.
    by rewrite cat_path /= => /andP[] _ /andP[] /eqP + _.
  have lstoin2 : lsto \in rcons fop lsto by rewrite mem_rcons inE eqxx.
  have lstobc' : high lsto <| low c'.
    rewrite -c'2q.
    move: c'2in; rewrite inE=> /orP[/eqP -> | c'2in].
      by apply: edge_below_refl.
    move:pw=> /andP[] _.
    rewrite -cat_rcons map_cat pairwise_cat => /andP[] + _.
    by move=>/allrelP /(_ _ _ (map_f _ lstoin2) (map_f _ c'2in)).
  have vhob: valid_edge (high lsto) (last dummy_pt (left_pts c')).
    by have := same_x_valid (high lsto) (esym abs); rewrite vho => <-.
    have vlc'b : valid_edge (low c') (nth dummy_pt (left_pts lsto) 1).
    by have := same_x_valid (low c') (esym xnth1) => <-.
  have lq1 : p_x (last dummy_pt (left_pts c')) =
      p_x (nth dummy_pt (left_pts lsto) 1).
    by rewrite xnth1 abs.
  have := (same_pvert_y vhob lq1); rewrite lstheq => <-.
  rewrite leNgt.
  have vlc'l : valid_edge (low c') (last dummy_pt (left_pts c')).
    by rewrite -(same_x_valid (low c') (esym abs)).
  have lon : last dummy_pt (left_pts c') === low c'.
    by have := allP oks c' c'in2 => /andP[] _ /andP[] _ /andP[] _ /andP[] _ ->.
  have : last dummy_pt (left_pts c') >>= high lsto.
    apply/negP=> HH.
    have := (order_edges_strict_viz_point' vhob vlc'l lstobc' HH).
    rewrite strict_nonAunder; last by [].
    by rewrite lon.
  have := strict_under_pvert_y vhob; rewrite lstheq.
  by move=> ->.
have ldifmain c : c \in fop ++ lsto :: lop -> low c != high c.
    move=> cin2.
    have [s1 [s2 sq]]:= mem_seq_split cin2.
    elim/last_ind: {-1} (s1) (erefl s1) => [ | s1' c2 _] s1q.
      apply/eqP=> abs.
      have := cbtom; rewrite /cells_bottom_top/cells_low_e_top.
      move=> /andP[] /andP[] _ + _; rewrite sq s1q /= => /eqP lb.
      have lcin : low c \in [:: bottom, top & s].
        by apply: sub_edges; rewrite !mem_cat map_f.
      by have := uniq_high => /andP[] + _; rewrite -lb abs map_f.
    have lq : low c = high c2.
      move: adj; rewrite sq s1q cat_rcons.
      by move=> /adjacent_catW /= => -[] _ /andP[] /eqP/esym + _.
    have := uniq_high => /andP[] _; rewrite sq s1q cat_rcons.
    rewrite map_cat cat_uniq=> /andP[] _ /andP[] _ /=  /andP[] + _.
    by rewrite inE negb_or -lq => /andP[] + _.
have center_in' :
  {in rcons (cls ++ lstc :: closing_cells (point ev) cc)
    (close_cell (point ev) lcc), forall c, inside_closed' (cell_center c) c}.
  move=> c; rewrite -cats1. rewrite -(cat_rcons lstc) -catA mem_cat.
  move=> /orP[cold | cnew]; first by apply: center_in.
  move: cnew.
  rewrite /closing_cells -(map_cat (close_cell (point ev)) cc [:: lcc]).
  move=> /[dup] cin /mapP [c' + /[dup] cc' ->]; rewrite cats1 => c'in.
  have c'in2 : c' \in fop ++ lsto :: lop.
    by rewrite ocd -cat_rcons !mem_cat c'in orbT.
  have inter_at_extc' : inter_at_ext (low c') (high c').
    by apply/nocs'; apply: sub_edges; rewrite mem_cat; apply/orP; left;
    rewrite mem_cat map_f ?orbT.
  have ldif : low c' != high c' by apply: ldifmain.
    (* have [s1 [s2 sq]]:= mem_seq_split c'in2.
    elim/last_ind: {-1} (s1) (erefl s1) => [ | s1' c2 _] s1q.
      apply/eqP=> abs.
      have := cbtom; rewrite /cells_bottom_top/cells_low_e_top.
      move=> /andP[] /andP[] _ + _; rewrite sq s1q /= => /eqP lb.
      move: inbox_es=> /andP[] /andP[] /andP[] + _ _ _ => /negP; apply.
      rewrite -lb abs.
      have /= incc := open_cells_decomposition_point_on cbtom adj bet_e sval oe.
      move: c'in; rewrite mem_rcons inE => /orP[/eqP c'lcc | /incc].
        by rewrite c'lcc underW.
      move=> /[dup] /andP[] _ vhc'.
      by rewrite under_onVstrict//  => ->.
    have := adj; rewrite sq s1q cat_rcons.
    move=> /adjacent_catW [] _ /= /andP[] /eqP <- _.
    have := uniq_high; rewrite sq s1q cat_rcons map_cat /=.
    rewrite cat_uniq => /andP[] _ /andP[] _ /= /andP[] + _.
    by rewrite inE negb_or => /andP[] + _. *)
  have rfc' : low c' <| high c'.
    by apply: (allP rfo).
  have c'ok : open_cell_side_limit_ok c'.
    by apply: (allP oks).
  have [vlc' vhc'] : valid_edge (low c') (point ev) /\
     valid_edge (high c') (point ev).
    by apply/andP; apply (allP sval).
  have leftc' : left_limit c' < p_x (point ev).
    have cin2 : c \in rcons (closing_cells (point ev) cc)
      (close_cell (point ev) lcc).
      by rewrite -cats1 -(map_cat (close_cell (point ev)) cc [:: lcc]).
    have:= wcl' c; rewrite -cats1 -catA /= cats1.
    rewrite !(mem_cat, inE) cin2 !orbT.
    rewrite cc' /left_limit.
    have [_ _ ->] := close_cell_preserve_3sides (point ev) c'.
    rewrite close_cell_right_limit; first by apply.
    by split.
  apply: (cell_center_close_cell_inside inter_at_extc' ldif rfc' c'ok
             vlc' vhc' leftc').
(* TODO avoid duplication #1 *)
have allcont : all (contains_point (point ev)) (rcons cc lcc).
  by rewrite -cats1 all_cat /= lcc_ctn !andbT; apply/allP.

have cl_ok' : {in rcons (cls ++ (lstc :: closing_cells (point ev) cc))
                                  (close_cell (point ev) lcc),
            forall c, closed_cell_side_limit_ok c}.
  have svalcc : seq_valid (rcons cc lcc) (point ev).
    apply/allP=> c cin; apply: (allP sval); rewrite ocd !mem_cat.
    move: cin; rewrite mem_rcons inE.
    by move=> /orP[/eqP |] ->; rewrite ?inE ?eqxx ?orbT.
  have adjcc : adjacent_cells (rcons cc lcc).
    move: adj.
    by rewrite ocd -cat_rcons =>/adjacent_catW[] _ /adjacent_catW[].
  have rfocc : s_right_form (rcons cc lcc).
    apply/allP=> c cin; apply: (allP rfo); rewrite ocd !mem_cat.
    move: cin; rewrite mem_rcons inE.
    by move=> /orP[/eqP |] ->; rewrite ?inE ?eqxx ?orbT //.
  have closed_map : closing_cells (point ev) (rcons cc lcc) =
      rcons [seq close_cell (point ev) c | c <- cc]
          (close_cell (point ev) lcc).
    rewrite -closing_cellsE.
    by rewrite /cells.closing_cells map_rcons.
  have ccok : all open_cell_side_limit_ok (rcons cc lcc).
    apply/allP=> c cin; apply: (allP oks); rewrite ocd !mem_cat.
    move: cin; rewrite mem_rcons inE.
    by move=> /orP[/eqP |] ->; rewrite ?inE ?eqxx ?orbT //.
  have := closing_cells_side_limit' rfocc svalcc adjcc ccok allcont.
  rewrite head_rcons pal last_rcons puh=> /(_ isT isT).
  rewrite [X in all _ X]closed_map=> /allP cl_sok.
  move=> c; rewrite -cat_rcons -cats1 -catA mem_cat=> /orP[cold | cnew].
    by apply: cl_ok.
  apply: cl_sok.
  move: cnew; rewrite /closing_cells -[List.map]/@seq.map -cat_rcons cats0.
  by [].

have ucc' : uniq [seq cell_center c | c <-
                          rcons (cls ++ (lstc :: closing_cells (point ev) cc))
                                (close_cell (point ev) lcc)].
  set wcls := rcons _ _.
  have wclsq : wcls = rcons cls lstc ++ rcons (closing_cells (point ev) cc)
    (close_cell (point ev) lcc).
    by rewrite /wcls cat_rcons -!cats1 -!catA.
  rewrite wclsq => {wcls wclsq}.
  rewrite map_cat cat_uniq ucc /=.
  apply/andP; split.
    rewrite /closing_cells -map_rcons; apply/negP=> /hasP[p].
    move=> /mapP [c2 c2new pc2].
    move=> /mapP [c1 c1old pc1].
    move: c2new=> /mapP [c3 c3o c2c3].
    have c3o2 : c3 \in fop ++ lsto :: lop.
      by rewrite ocd -cat_rcons !mem_cat c3o orbT.
    have noc3 : inter_at_ext (low c3) (high c3).
      by apply: nocs'; apply: (sub_edges); rewrite 2!mem_cat map_f ?orbT.
    have dif3 : low c3 != high c3.
      have [[ | c0 s3][s4 sq]] := mem_seq_split c3o2.
        have c3b : low c3 = bottom.
          by move: cbtom=> /andP[] /andP[] _ /eqP + _; rewrite sq.
        move: uniq_high=> /= /andP[] + _; rewrite sq /= inE negb_or c3b.
        by move=> /andP[].
      have -> : low c3 = high (last c0 s3).
        by have := adj; rewrite sq /= cat_path => /andP[] _ /= /andP[] /eqP -> _.
      apply/eqP=> abs.
      have := uniq_high; rewrite sq => /andP[] _.
      rewrite map_cat cat_uniq => /andP[] _ /andP[] /negP + _; apply.
      apply/hasP; exists (high (last c0 s3)).
        by rewrite abs map_f // inE eqxx.
      by apply: map_f; rewrite mem_last.
    have wf3 : low c3 <| high c3 by apply (allP rfo).
    have ok3 : open_cell_side_limit_ok c3 by apply: (allP oks).
    have vc3 : valid_cell c3 (point ev).
      by apply: (andP (allP sval c3 c3o2)).
    have [vlc3 vhc3] := vc3.
    have c2in : c2 \in rcons (cls ++ lstc :: closing_cells (point ev) cc)
                       (close_cell (point ev) lcc).
      rewrite -cats1 -catA mem_cat /= inE /closing_cells cats1 -map_rcons.
      by rewrite orbA orbC; apply/orP; left; apply/mapP; exists c3.
    have lc3ltp : left_limit c3 < p_x (point ev).
      have := wcl' c2 c2in.
      rewrite c2c3 /left_limit.
      have [_ _ ->] := close_cell_preserve_3sides (point ev) c3.
      by rewrite right_limit_close_cell.
    have ok2 := cl_ok' c2 c2in.
    have :=
      cell_center_close_cell_inside noc3 dif3 wf3 ok3 vlc3 vhc3 lc3ltp.
    rewrite -[cells.close_cell _ _]/(close_cell _ _).
    rewrite -c2c3=> ccin.
    have := close'_subset_contact vc3; rewrite -c2c3 => /(_ _ ok2 ccin) ccin'.
    have := oc_dis c3 c1 c3o2 c1old (cell_center c2)=> /negP.
    by rewrite ccin' -pc2 pc1 center_in.
  apply/(uniqP dummy_pt).
  rewrite  /closing_cells !(size_map, size_rcons).
  set L := [seq cell_center c | c <- _].
  have main : forall i j, (i <= j < (size cc).+1)%N ->
    nth dummy_pt L i = nth dummy_pt L j -> i = j.
    move=> i j /[dup] ijs /andP[ij js] abs.
    have i_s : (i < (size cc).+1)%N by apply: leq_ltn_trans js.
    move: ij; rewrite leq_eqVlt=> /orP[/eqP -> | ij]; first by [].
    have jpred : j = j.-1.+1 by rewrite (ltn_predK ij).
    have i_sm : (i < size cc)%N.
      by apply: (leq_trans ij); rewrite -ltnS.
    have is' : (i < size [seq high c | c <- rcons cc lcc])%N.
      by rewrite size_map size_rcons.
    have js' : (j < size [seq high c | c <- rcons cc lcc])%N.
      by rewrite size_map size_rcons.
    have js2 : (j < size (rcons cc lcc))%N by rewrite size_rcons.
    have jps : (j.-1 < (size cc).+1)%N.
      by apply : (ltn_trans _ js); rewrite -jpred leqnn.
    have jps2 : (j.-1 < size (rcons cc lcc))%N by rewrite size_rcons.
    have jps3 : (j.-1 < size [seq high c | c <- rcons cc lcc])%N.
      by rewrite size_map size_rcons.
    move: pw; rewrite ocd !map_cat pairwise_cat=> /andP[] _ /andP[] _.
    move=> /andP[] _.
    rewrite /= -cat_rcons pairwise_cat=> /andP[] _ /andP[] + _.
    rewrite -map_rcons.
    move=> /(pairwiseP dummy_edge)/(_ _ _ is' jps3) => ibelj.
    have nth_in k : (k < (size cc).+1)%N ->
      nth dummy_cell (rcons cc lcc) k \in fop ++ lsto :: lop.
      move=> ks.
      rewrite ocd -cat_rcons !mem_cat; apply/orP; right; apply/orP; left.
      by rewrite mem_nth // size_rcons.
    have vlk k : (k < (size cc).+1)%N ->
      valid_edge (nth dummy_edge [seq high c | c <- rcons cc lcc] k) (point ev).
      move=> ks.
      have ks' : (k < size (rcons cc lcc))%N by rewrite size_rcons.
      set ck := nth dummy_cell (rcons cc lcc) k.
      rewrite (nth_map dummy_cell dummy_edge high) //.
      by have := allP sval _ (nth_in k ks)=> /andP[].
    have vllk k : (k < (size cc).+1)%N ->
      valid_edge (low (nth dummy_cell (rcons cc lcc) k)) (point ev).
      move=> ks.
      have ks' : (k < size (rcons cc lcc))%N by rewrite size_rcons.
      set ck := nth dummy_cell (rcons cc lcc) k.
      by have := allP sval _ (nth_in k ks)=> /andP[].
    have vli := vlk i i_s.
    have incl k: (k < (size cc).+1)%N -> inside_closed' (nth dummy_pt L k)
            (nth dummy_cell [seq close_cell (point ev) c | c <- rcons cc lcc] k).
      move=> ks.
      rewrite /L (nth_map dummy_cell); last first.
        by rewrite size_rcons size_map.
      rewrite -map_rcons.
      apply: center_in'.
      rewrite -(cats1 _ (close_cell _ _)) -catA /= cats1.
      rewrite mem_cat inE orbA; apply/orP; right.
      by rewrite /closing_cells -map_rcons mem_nth // size_map size_rcons.
    have inclj := incl j js.
    have incli := incl i i_s.
    have lowjq : low (nth dummy_cell [seq close_cell (point ev) c | c <- rcons cc lcc] j)
      = high (nth dummy_cell [seq close_cell (point ev) c | c <- rcons cc lcc] j.-1).
      have := (nth_map dummy_cell dummy_cell (close_cell (point ev))).
      move=> /(_ j (rcons cc lcc) js2) => ->.
      have := (nth_map dummy_cell dummy_cell (close_cell (point ev))).
      move=> /(_ j.-1 (rcons cc lcc) jps2) => ->.
      have [-> _ _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) j).
      have [ _ -> _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) j.-1).
      have jint : (0 < j < size (rcons cc lcc))%N.
        by rewrite (leq_ltn_trans (leq0n _) (ij)).
      have := adj; rewrite /adjacent_cells ocd -cat_rcons=>/adjacent_catW.
      move=>[] _ /adjacent_catW [] + _.
      by move=> /adjacent_path_nth /(_ jint).
    move: inclj=> /andP[] /andP[] _ B /andP[] abovelow _.
    move: incli=> /andP[] /andP[] /andP[] _ belowhigh C _.
    have vni : valid_edge (high (nth dummy_cell [seq close_cell (point ev) c | c <- rcons cc lcc] i))
      (nth dummy_pt L i).
      apply/andP; split.
        apply: (le_trans _ (proj1 (andP C))).
        rewrite (nth_map dummy_cell); last by rewrite size_rcons.
        rewrite /left_limit.
        have [_ -> ->] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) i).
        have := allP oks _ (nth_in _ i_s) => /andP[] lf_size /andP[] xs
        /andP[] _ /andP[] hdon _.
        case: left_pts lf_size xs hdon => [ | a tl] // _ xs hdon.
        have ain : a \in (a :: tl) by rewrite inE eqxx.
        have lstin : last a tl \in (a :: tl) by rewrite mem_last.
        have /eqP ax := allP xs _ ain.
        have /eqP lx := allP xs _ lstin.
        rewrite /= lx -ax.
        by move: hdon; rewrite /= => /andP[] _ /andP[] it _.
      apply: (le_trans (proj2 (andP C))).
      rewrite (nth_map dummy_cell); last by rewrite size_rcons.
      rewrite right_limit_close_cell //; last first.
          by move: vli; rewrite (nth_map dummy_cell) // size_rcons.
        by apply: vllk.
      have [_ -> _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) i).
      have /andP[ _ ]:= vli.
      by rewrite (nth_map dummy_cell); last by rewrite size_rcons.
    have vnj : valid_edge
      (low (nth dummy_cell [seq close_cell (point ev) c | c <- rcons cc lcc] j))
      (nth dummy_pt L i).
      rewrite abs {C belowhigh abovelow incl}.
      apply/andP; split.
      apply: (le_trans _ (proj1 (andP B))).
      rewrite (nth_map dummy_cell); last by rewrite size_rcons.
        rewrite /left_limit.
        have [-> _ ->] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) j).
        have := allP oks _ (nth_in _ js) => /andP[] lf_size /andP[] xs
        /andP[] _ /andP[] hdon lston.
        by move: lston=> /andP[] _ /andP[].
      apply: (le_trans (proj2 (andP B))).
      rewrite (nth_map dummy_cell) {B}; last by rewrite size_rcons.
      rewrite right_limit_close_cell //; last first.
          by move: (vlk _ js); rewrite (nth_map dummy_cell) // size_rcons.
        by apply: vllk.
      have [-> _ _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) j).
      by have /andP[ _ ]:= vllk _ js.
    move: abovelow=> /negP; case.
    rewrite -abs.
    have := ij; rewrite jpred ltnS; rewrite leq_eqVlt=> /orP[/eqP ijq| ijp].
      by rewrite -jpred lowjq -ijq.
    have {}ibelj := (ibelj ijp).
    have ibelj' : high (nth dummy_cell [seq (close_cell (point ev)) c | c <- rcons cc lcc] i) <|
        low (nth dummy_cell [seq (close_cell (point ev)) c | c <- rcons cc lcc] j).
    move: ibelj; rewrite lowjq.
    repeat (rewrite (nth_map dummy_cell); last by rewrite size_rcons).
    have [_ -> _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) j.-1).
    by have [_ -> _] := close_cell_preserve_3sides (point ev)
            (nth dummy_cell (rcons cc lcc) i).
    have := order_edges_viz_point' vni vnj ibelj'.
    rewrite -jpred; apply.
    by apply: belowhigh.
  move=> i j; rewrite ?inE /= => i_s js eqcc.
  case: (ltnP i j) => [ij | ji].
    have ijint : (i <= j < (size cc).+1)%N by rewrite (ltnW ij) js.
    by apply: (main _ _ ijint).
  have jiint : (j <= i < (size cc).+1)%N by rewrite ji i_s.
  by apply/esym/(main _ _ jiint).

have rlstc' : right_limit (close_cell (point ev) lcc) = (p_x (point ev)).
  by apply: close_cell_right_limit.
have hlstcq' : high (close_cell (point ev) lcc) = he.
  have := close_cell_preserve_3sides (point ev) lcc.
  rewrite -[cells.close_cell _ _]/(close_cell _ _)=> -[] _ -> _.
  by rewrite heq.
have midptlstc' :
  path (@lexPt _) (nth dummy_pt (right_pts (close_cell (point ev) lcc)) 1)
  [seq point x | x <- evs].
  rewrite /close_cell (pvertE vllcc) (pvertE vhlcc) /=.
  rewrite -[X in if X then _ else _]
    /({|generic_trajectories.p_x := p_x (point ev);
   generic_trajectories.p_y := (pvert_y (point ev) (high lcc))|} ==
     (point ev)).
  rewrite pt_eqE /=.
  have := puh; rewrite /= (strict_under_pvert_y vhlcc) lt_neqAle eq_sym.
  move=> /andP[] /negbTE -> _; rewrite andbF.
  rewrite [nth _ _ _](_ : _ = point ev); last first.
    by case: ifP=> [/eqP abs | diff].
  move: lexev; rewrite -/(sorted (@lexPtEv _) (ev :: evs)).
  by rewrite sorted_lexPtEv_lexPt.
have btm_leftops' : {in (fc ++ nos) ++ lno :: lc & evs,
  forall c e, lexPt (bottom_left_corner c) (point e)}.
  move=> c e + ein; rewrite -catA=> cin.
  have lexeev : lexPt (point ev) (point e).
    have := lexev; rewrite (path_sortedE (@lexPtEv_trans _))=> /andP[] + _.
    by move=> /allP /(_ e ein).
  have btm_left_ev: {in fop ++ lsto :: lop, forall c,
    lexPt (bottom_left_corner c) (point ev)}.
    by move=> ? ?; apply: btm_leftops; rewrite // inE eqxx.
  have := step_keeps_btom_left_corners_default inbox_es oute rfo cbtom adj sval
    noc btm_left_ev.
  by rewrite oe oca_eq=> /(_ (point e) lexeev) => /(_ c cin).
have leftops' : {in ((fc ++ nos) ++ lno :: lc), forall c,
      left_limit c <= p_x (point ev)}.
  move=> c; rewrite -catA -cat_rcons !mem_cat orbCA orbC => /orP[cold | cnew].
    have : lstx <= p_x (point ev).
      rewrite lstxq /left_limit.
      have := bottom_left_cond ev evin=> /orP[ | /andP[/eqP -> _]].
        by rewrite lt_neqAle=> /andP[].
      by apply: le_refl.
    apply: le_trans.
    by apply: leftops; rewrite ocd -cat_rcons !mem_cat orbCA cold orbT.
  have := opening_cells_left oute vle vhe.
  rewrite /opening_cells -leq -heq oca_eq le_eqVlt.
  by move=> /(_ c cnew) /eqP => ->.
have lebhe : le <| he.
  rewrite leq heq.
  have ba : below_alt le he.
    by apply/nocs; apply/sub_edges; rewrite mem_cat; apply/orP; left.
  move: ba; rewrite leq heq=> ba.
  by apply: (edge_below_from_point_above ba vle vhe (underWC pal) puh).
have nth1q : nth dummy_pt (left_pts lno) 1 = point ev.
  have := last_opening_cells_left_pts_prefix vle vhe puh oute.
  rewrite -leq -heq oca_eq=> /(_ _ _ erefl) [].
  by case: (left_pts _) => [ | a [ | b tl]] //= _ -[].
have btm_left_lex1 : {in (fc++nos) ++ lno :: lc,
  forall c, lexePt (bottom_left_corner c) (nth dummy_pt (left_pts lno) 1)}.
  move=> c; rewrite -catA -cat_rcons !mem_cat orbCA orbC=> /orP[cold | cnew].
  rewrite nth1q; apply/lexPtW.
  apply: btm_leftops; last by rewrite inE eqxx.
  by rewrite ocd -cat_rcons !mem_cat orbCA orbC cold.
  have noc1 : {in rcons (le :: sort edge_below (outgoing ev)) he &,
                no_crossing R}.
    by apply: (no_crossing_event nocs' sub_edges lein hein evin).
  have := opening_cells_last_lexePt oute (underWC pal) puh vle vhe.
  rewrite -heq -leq /opening_cells oca_eq=> /(_ _ noc1 lebhe cnew).
  by rewrite nth1q.
have := opening_cells_aux_high vle vhe oute'.
  rewrite -leq -heq oca_eq /= => unos.
- have uniqhigh' : uniq (bottom :: [seq high c | c <- (fc ++ nos) ++ lno :: lc]).
  rewrite -catA.
  have newq : [seq high c | c <- rcons nos lno] =
    rcons (sort edge_below (outgoing ev)) (high lcc).
  have := opening_cells_aux_high_last vle vhe oute'.
  have := opening_cells_aux_high vle vhe oute'.
  rewrite -leq -heq oca_eq /= => <- <-.
  by rewrite map_rcons.
  have unew : uniq [seq high c | c <- rcons nos lno].
    rewrite newq rcons_uniq sort_uniq uniqout // andbT.
    rewrite mem_sort; apply/negP=> /oute /eqP abs.
    by move: puh; rewrite strict_nonAunder // -abs left_on_edge.
  rewrite -cat_rcons !map_cat newq.
  move: uniq_high; rewrite ocd !map_cat /= => uniq_high.
  apply: (uniq_insert_edges edge_below uniq_high).
      exact: (uniqout _ evin).
  move=> g; rewrite inE=> /orP[/eqP -> | gin]; last first.
    apply: no_dup=> //.
    by rewrite ocd !map_cat.
  apply/negP=>/oute /eqP abs.
  have vbt : valid_edge bottom (point ev).
    move : cbtom; rewrite /cells_bottom_top/cells_low_e_top.
    case sq : (fop ++ lsto :: lop) => [ | c0 tl] //= /andP[] /eqP lc0q _.
    rewrite <- lc0q.
    by apply: (proj1 (andP (allP sval c0 _))); rewrite sq inE eqxx.
  move: inbox_e=> /andP[] + _; rewrite under_onVstrict // -abs.
  by rewrite left_on_edge.
by constructor.
Qed.

Record edge_covered_non_gp_invariant (bottom top : edge)
 (edge_set : seq edge) (processed_set : seq event)
 (s : scan_state) (events : seq event) :=
 { edge_covered_ec : {in processed_set, forall e,
       {in outgoing e, forall g,
       edge_covered g (state_open_seq s) (state_closed_seq s)}};
   processed_covered : {in processed_set, forall e,
       exists2 c, c \in (state_closed_seq s) &
           point e \in (right_pts c : seq pt) /\ point e >>> low c}  ;
   common_inv_ec : common_non_gp_invariant bottom top edge_set
     s events;
   non_in_ec :
      {in edge_set & events, forall g e, non_inner g (point e)};
   inj_high : {in state_open_seq s &, injective high};
   bot_left_cells :
       {in state_open_seq s & events,
          forall c e, lexPt (bottom_left_corner c) (point e)};
   }.

(* TODO: this proof is simply duplicated from the general position,
  with a very minor change. *)
Lemma simple_step_edge_covered_non_gp_invariant
  bottom top s cov_set fop lsto lop fc cc lcc lc le he cls lstc ev
  lsthe lstx evs :
  bottom <| top ->
  {in bottom :: top :: s &, forall e1 e2, inter_at_ext e1 e2} ->
  {in s, forall g, inside_box bottom top (left_pt g) &&
                   inside_box bottom top (right_pt g)} ->
  open_cells_decomposition (fop ++ lsto :: lop) (point ev) =
    (fc, cc, lcc, lc, le, he) ->
  edge_covered_non_gp_invariant bottom top s
   cov_set (Bscan fop lsto lop cls lstc lsthe lstx)
   (ev :: evs) ->
  (lstx <> p_x (point ev) \/
        (lstx = p_x (point ev) /\ (point ev >>> lsthe))) ->
  edge_covered_non_gp_invariant bottom top s
    (rcons cov_set ev) (simple_step fc cc lc lcc le he cls lstc ev)
    evs.
Proof.
move=> boxwf nocs' inbox_s.
have nocs : {in bottom :: top :: s &, no_crossing R}.
  by apply: inter_at_ext_no_crossing.
set st := Bscan _ _ _ _ _ _ _.
move=> oe + simple_cond.
move=> [] covered p_covered /[dup] Cinv [] [] /[dup] inv_s [] clae.
move=> - [] []; first by [].
rewrite /state_open_seq/state_closed_seq /= => sval [] adj [] cbtom rfo.
move=> lstxq lstheq sub_edges cle out_es uniq_evs.
move=> /[dup] inbox0 /andP[] inbox_e inbox_es no_dup lexev oks.
move=> bottom_left_corner_cond slt.
move=> /andP[] lexnth1 pathlex n_inner inj_high btm_left_lex.
have out_e : out_left_event ev by apply: out_es; rewrite inE eqxx.
have noc : {in all_edges (state_open_seq st) (ev :: evs) &, no_crossing R}.
  by move=> g1 g2 g1in g2in; apply: nocs; apply: sub_edges.
case oca_eq :
  (opening_cells_aux (point ev) (sort edge_below (outgoing ev)) le he) =>
      [nos lno].
have Cinv' :=
  simple_step_common_non_gp_invariant boxwf nocs' inbox_s simple_cond oe Cinv.
have btm_left_lex_e : {in (state_open_seq st), forall c,
                         lexPt (bottom_left_corner c) (point ev)}.
  by move=> c cin; apply: btm_left_lex; rewrite // inE eqxx.
have n_inner2 : {in state_open_seq st,
         forall c, non_inner (high c) (point ev)}.
  move=> c cin.
  have /sub_edges : high c \in all_edges (state_open_seq st) (ev :: evs).
    by rewrite 2!mem_cat map_f ?orbT.
  have /inside_box_non_inner [nib nit] : inside_box bottom top (point ev).
    by move: inbox0 => /andP[].
  rewrite !inE => /orP[/eqP -> | /orP [/eqP -> | hcin ]] //.
  by apply: n_inner; rewrite // inE eqxx.
have cov' : {in rcons cov_set ev,forall e',
  {in outgoing e', forall g, edge_covered g (state_open_seq
                              (simple_step fc cc lc lcc le he cls lstc ev))
                  (state_closed_seq
                     (simple_step fc cc lc lcc le he cls lstc ev))}}.
  have main:= step_keeps_edge_covering_default
    inbox0 out_e rfo cbtom adj sval oks inj_high btm_left_lex_e n_inner2
         oe oca_eq.
  have := main (state_closed_seq st) => {}main.
  move=> e' e'in g gin.
  have /main : edge_covered g (fop ++ lsto :: lop) (state_closed_seq st) \/
         g \in outgoing ev.
    move: e'in; rewrite -cats1 mem_cat=> /orP[/covered|]; last first.
      by move: gin=> /[swap]; rewrite inE=> /eqP ->; right.
    by move=> /(_ _ gin); left.
  rewrite /state_open_seq /state_closed_seq /=.
  apply: edge_covered_sub.
    rewrite /simple_step/generic_trajectories.simple_step.
    rewrite -/(opening_cells_aux _ _ _ _).
    by rewrite oca_eq /= -catA.
  rewrite /simple_step/generic_trajectories.simple_step.
  rewrite -/(opening_cells_aux _ _ _ _).
  by rewrite oca_eq /= !cat_rcons -!cats1 -!catA.
have n_inner' : {in s & evs, forall g e, non_inner g (point e)}.
  by move=> g e gin ein; apply: n_inner; rewrite // inE ein orbT.
have uniq' : {in evs, forall e, uniq (outgoing e)}.
  by move=> g gin; apply: uniq_evs; rewrite inE gin orbT.
have uniq_ev : uniq (outgoing ev) by apply: uniq_evs; rewrite inE eqxx.
have inj_high' :
  {in state_open_seq (simple_step fc cc lc lcc le he cls lstc ev) &,
     injective high}.
  have := step_keeps_injective_high_default inbox0 out_e rfo cbtom adj sval
     oks uniq_ev inj_high btm_left_lex_e.
  rewrite /simple_step/generic_trajectories.simple_step.
  rewrite -/(open_cells_decomposition _ _).
  rewrite -/(opening_cells_aux _ _ _ _).
  by rewrite oe oca_eq /state_open_seq /= -catA.
have btm_left_lex' :
  {in state_open_seq (simple_step fc cc lc lcc le he cls lstc ev) & evs,
     forall c e, lexPt (bottom_left_corner c) (point e)}.
  have := step_keeps_btom_left_corners_default inbox0 out_e rfo cbtom adj
     sval noc btm_left_lex_e.
  rewrite /simple_step/= /= oe oca_eq /= /state_open_seq /=.
  rewrite catA=> main.
  move=> c e cin ein; apply: main=> //=.
  move: lexev; rewrite path_sortedE; last by apply: lexPtEv_trans.
  by move=> /andP[] /allP /(_ e ein).
have p_cov' : {in rcons cov_set ev, forall e, exists2 c,
   c \in state_closed_seq (simple_step fc cc lc lcc le he cls lstc ev) &
   point e \in (right_pts c : seq pt) /\ point e >>> low c}.
  have exi := exists_cell cbtom adj (inside_box_between inbox_e).
  have [ocd [lcc_ctn [allct [allnct [flcnct [heq [leq [lein hein]]]]]]]] :=
    decomposition_main_properties oe exi.
  have [{}pal {}puh vle vhe nc]:=
    decomposition_connect_properties rfo sval adj cbtom
    (inside_box_between inbox_e) oe.
  move=> e; rewrite mem_rcons inE=> /orP[]; last first.
    move=> /p_covered [] c cin pin.
    rewrite /state_closed_seq/simple_step/generic_trajectories.simple_step.
    rewrite -/(opening_cells_aux _ _ _ _).
    rewrite oca_eq /=.
    exists c; last by [].
    by rewrite -cats1 /= appE -(cat_rcons lstc) !mem_cat cin.
  move=> /eqP -> {e}.
  exists (close_cell (point ev) (head lcc cc)).
    rewrite /state_closed_seq /simple_step/generic_trajectories.simple_step.
    rewrite -/(opening_cells_aux _ _ _ _).
    rewrite oca_eq /= -cats1 -catA /=.
    rewrite -cat_rcons mem_cat; apply/orP; right.
    by case: (cc) => [ | ? ?]; rewrite /= mem_head.
  have hdin : head lcc cc \in fop ++ lsto :: lop.
    rewrite ocd mem_cat; apply/orP; right.
    by case: (cc)=> [ | ? ?]; rewrite /= mem_head.
  split.
    by apply/close_cell_in/andP/(allP sval).
  have [-> _ _] := close_cell_preserve_3sides (point ev) (head lcc cc).
  by rewrite -leq.
by constructor.
Qed.

Record safe_side_non_gp_invariant (bottom top : edge)
 (edge_set : seq edge) (processed_set : seq event)
 (s : scan_state) (events : seq event) :=
 {disjoint_ss :
    disjoint_non_gp_invariant bottom top edge_set s events;
    covered_ss :
     edge_covered_non_gp_invariant bottom top edge_set
       processed_set s events;
    left_proc : {in processed_set & events, forall e1 e2, lexPtEv e1 e2};
    rf_closed : {in state_closed_seq s, forall c, low c <| high c};
    diff_edges :
       {in state_open_seq s ++ state_closed_seq s, forall c, low c != high c};
    sub_closed :
      {subset cell_edges (state_closed_seq s) <= bottom :: top :: edge_set};
    closed_ok :
        all (@closed_cell_side_limit_ok R) (state_closed_seq s);
   (* TODO : disjoint_non_gp has the weaker right_limit <= p_x point  *)
    cl_at_left_ss :
     {in sc_closed s,
        forall c, lexePt (head dummy_pt (right_pts c))
          (nth dummy_pt (left_pts (lst_open s)) 1)};
    safe_side_closed_edges :
     {in events_to_edges processed_set & state_closed_seq s, forall g c p,
         in_safe_side_left p c || in_safe_side_right p c -> ~ p === g};
    safe_side_open_edges :
     {in events_to_edges processed_set & state_open_seq s, forall g c p,
         in_safe_side_left p c -> ~p === g};
    safe_side_closed_points :
     {in processed_set & state_closed_seq s, forall e c p,
         in_safe_side_left p c || in_safe_side_right p c ->
         p != point e :> pt};
    safe_side_open_points :
     {in processed_set & state_open_seq s, forall e c p,
         in_safe_side_left p c ->
         p != point e :> pt};
}.

Lemma cl_at_left_ss_compat bottom top edge_set processed_set
  s events :
  safe_side_non_gp_invariant bottom top edge_set processed_set s events ->
  {in sc_closed s & events, 
    forall c e, lexPt (head dummy_pt (right_pts c)) (point e)}.
Proof.
move=> ssng c e cin ein.
apply: (lexePt_lexPt_trans (cl_at_left_ss ssng cin)).
have := (lst_side_lex (common_non_gp_inv_dis (disjoint_ss ssng))).
rewrite (path_sortedE (@lexPt_trans _)).
by move=> /andP[] /allP /(_ _ (map_f _ ein)).
Qed.

Lemma disjoint_non_gp_left_side_le_lsto bottom top s events st:
  disjoint_non_gp_invariant bottom top s st events ->
  {in state_open_seq st,
    forall c, left_limit c <= left_limit (lst_open st)}.
Proof.
move=> dng c cin.
rewrite -(lstx_eq (ngcomm (common_non_gp_inv_dis dng))).
by apply: (left_opens dng).
Qed.

Lemma disjoint_non_gp_left_side_lsto bottom top s events st:
  disjoint_non_gp_invariant bottom top s st events ->
  {in events,
    forall ev, left_limit (lst_open st) <= p_x (point ev)}.
Proof.
move=> dng ev ein.
have lx : lexPt (nth dummy_pt (left_pts (lst_open st)) 1) (point ev).
  have := lst_side_lex (common_non_gp_inv_dis dng).
  rewrite (path_sortedE (@lexPt_trans _))=> /andP[] /allP /(_ (point ev)).
  by rewrite map_f ?ein // => /(_ isT).
have sl := has_snd_lst (common_non_gp_inv_dis dng).
have px1 : 
  p_x (nth dummy_pt (left_pts (lst_open st)) 1) = left_limit (lst_open st).
  apply/eqP.
  have : open_cell_side_limit_ok (lst_open st).
    apply: (allP (sides_ok (ngcomm (common_non_gp_inv_dis dng)))).
    by rewrite mem_cat inE eqxx orbT.
  move=> /andP[] _ /andP[] + _.
  by move=> /allP; apply; rewrite mem_nth.
rewrite -px1; move: lx=> /orP[/ltW // | /andP[] + _].
by rewrite le_eqVlt => ->.
Qed.

Lemma simple_step_safe_side_non_gp_invariant bottom top
  s previous_events ev future_events
  fop lsto lop cls lstc lsthe lstx fc cc lcc lc le he:
  bottom <| top ->
  {in bottom :: top :: s &, forall e1 e2, inter_at_ext e1 e2} ->
  {in s, forall g, inside_box bottom top (left_pt g) &&
                   inside_box bottom top (right_pt g)} ->
  all (inside_box bottom top) [seq point e | e <- ev :: future_events] ->
  sorted (@lexPtEv _) (ev :: future_events) ->
  {subset events_to_edges (ev :: future_events) <= s} ->
  {in ev :: future_events, forall ev, out_left_event ev} ->
  close_edges_from_events (ev :: future_events) ->
  {in s & ev :: future_events, forall g e, non_inner g (point e)} ->
  {in ev :: future_events, forall e, uniq (outgoing e)} ->
   open_cells_decomposition (fop ++ lsto :: lop) (point ev) =
    (fc, cc, lcc, lc, le, he) ->
(lstx <> p_x (point ev) \/
        (lstx = p_x (point ev) /\ (point ev >>> lsthe))) ->
safe_side_non_gp_invariant bottom top s previous_events 
  (Bscan fop lsto lop cls lstc lsthe lstx) (ev :: future_events) ->
safe_side_non_gp_invariant bottom top s (rcons previous_events ev)
  (simple_step fc cc lc lcc le he cls lstc ev) future_events.
Proof.
move=> boxwf nocs' inbox_s evin lexev evsub out_evs cle
  n_inner uniq_edges.
have evinevs : ev \in ev :: future_events by rewrite inE eqxx.
remember (Bscan _ _ _ _ _ _ _) as st eqn:stq.
move=> oe simple_cond ssng.
move: (ssng) => [] d_inv e_inv old_lt_fut rf_cl d_e subc clok rl
 A B C D.
have c_inv := common_non_gp_inv_dis d_inv.
have lstoin : lsto \in state_open_seq st.
  by rewrite stq /state_open_seq/= mem_cat inE eqxx orbT.
have xevgelstx : lstx <= p_x (point ev).
  have := (lstx_eq (ngcomm c_inv)); rewrite stq /= => ->.
  have := allP (sides_ok (ngcomm c_inv)) _ lstoin.
  move=> /andP[] lfn0 /andP[] /allP sx _.
  have := has_snd_lst c_inv; rewrite stq /= => slf.
  have := lst_side_lex c_inv => /= /andP[] + _.
  have /eqP <- := sx _ (mem_nth dummy_pt slf); rewrite stq /=.
  move=> /orP[/ltW //|/andP[] + _ ].
  by rewrite le_eqVlt => ->.
have [clae [pre_sval [adj [cbtom rfo]]]] := inv1 (ngcomm c_inv).
move: pre_sval=> [| sval]; first by[].
have hlsto : high lsto = lsthe.
  by have := high_lsto_eq (ngcomm c_inv); rewrite stq /=.
have /andP [vlo vho]: valid_edge (low lsto) (point ev) &&
                  valid_edge (high lsto) (point ev).
          by apply: (allP sval).
have vlsthe : valid_edge lsthe (point ev).
      by rewrite -hlsto.
have nth1in : nth dummy_pt (left_pts lsto) 1 \in (left_pts lsto).
    have slft : (1 < size (left_pts lsto))%N.
      by have := has_snd_lst c_inv; rewrite stq.
    by apply: mem_nth.
have xnth1 : p_x (nth dummy_pt (left_pts lsto) 1) = lstx.
  have := allP (sides_ok (ngcomm c_inv)) lsto lstoin=> /andP[] _ /andP[] + _.
  move=> /allP /(_ _ nth1in) /eqP ->.
  by have :=(lstx_eq (ngcomm c_inv)); rewrite stq /= => <-.
have inbox_es := inbox_events (ngcomm c_inv).
have inbox_e : inside_box bottom top (point ev) by move: inbox_es=>/andP[].
move: (oe); rewrite (_ : fop ++ lsto :: lop = state_open_seq st); last first.
  by rewrite stq.
move=> oe'.
have exi' := exists_cell cbtom adj (inside_box_between inbox_e).
move: (exi'); rewrite stq => exi.
have [ocd [lcc_ctn [allct [allnct [flcnct [heq [leq [lein hein]]]]]]]] :=
  decomposition_main_properties oe' exi'.
have [{}pal {}puh vl vp nc]:=
  decomposition_connect_properties rfo sval adj cbtom
    (inside_box_between inbox_e) oe'.
have oute : out_left_event ev.
  by apply: (out_events (ngcomm c_inv)).
have oute' :
  {in (sort edge_below (outgoing ev)), forall g, left_pt g == point ev}.
  by move=> g; rewrite mem_sort; apply: oute.
rewrite /simple_step.
case oca_eq : opening_cells_aux => [nos lno].
set rstate := Bscan _ _ _ _ _ _ _.
have d_inv':
  disjoint_non_gp_invariant bottom top s rstate future_events.
  move: (d_inv); rewrite stq=> d_inv'.
  have := simple_step_disjoint_non_gp_invariant boxwf nocs'
      inbox_s simple_cond oe d_inv'.
  rewrite /simple_step/generic_trajectories.simple_step/=.
  by rewrite -/(opening_cells_aux _ _ _ _) oca_eq.
have e_inv' :edge_covered_non_gp_invariant bottom top s
    (rcons previous_events ev) rstate future_events.
  move: e_inv; rewrite stq=> e_inv.
  have := simple_step_edge_covered_non_gp_invariant boxwf nocs'
      inbox_s oe e_inv simple_cond.
  rewrite /simple_step/generic_trajectories.simple_step/=.
  by rewrite oca_eq.
(* Proving that low and high edges of every cell are distinct. *)
have low_diff_high' :
  {in state_open_seq rstate ++
      state_closed_seq rstate, forall c : cell, low c != high c}.
  move=> c; rewrite mem_cat=> /orP[].
    rewrite /state_open_seq /= -catA -cat_rcons !mem_cat orbCA.
    move=> /orP[ | cold]; last first.
      by apply: d_e; rewrite ocd -cat_rcons !mem_cat orbCA cold orbT.
    have uo : uniq (outgoing ev).
     by apply: (uniq_ec (ngcomm c_inv)) (mem_head _ _).
    have := opening_cells_low_diff_high oute uo vl vp pal puh.
    by rewrite /opening_cells oca_eq; apply.
  rewrite /state_closed_seq /= -cats1 -!catA /= -cat_rcons.
  rewrite mem_cat => /orP[cold | ].
    by apply: d_e; rewrite mem_cat stq /state_closed_seq/= cold orbT.
  rewrite cats1 -map_rcons=> /mapP[c' c'in ->].
  have [-> -> _] := close_cell_preserve_3sides (point ev) c'.
  by apply: d_e; rewrite mem_cat ocd -cat_rcons !mem_cat c'in !orbT.
(* Provint that closed cells used edges only from the initial set. *)
have subc' :
  {subset cell_edges (state_closed_seq rstate) <= [:: bottom, top & s]}.
  move=> g; rewrite /state_closed_seq/= -cats1 -catA /= -cat_rcons.
  rewrite cell_edges_cat mem_cat=> /orP[gold | ].
    by apply: subc; rewrite stq.
  have subo := edges_sub (ngcomm c_inv).
  rewrite cats1 -map_rcons mem_cat=> /orP[] /mapP[c'] /mapP[c2 c2in ->] ->.
    have [-> _ _] := close_cell_preserve_3sides (point ev) c2.
    apply: subo; rewrite !mem_cat; apply/orP; left; apply/orP; left.
    by rewrite map_f // ocd -cat_rcons !mem_cat c2in orbT.
  have [_ -> _] := close_cell_preserve_3sides (point ev) c2.
  apply: subo; rewrite !mem_cat; apply/orP; left; apply/orP; right.
  by rewrite map_f // ocd -cat_rcons !mem_cat c2in orbT.
(* proving a closed_cell ok invariant. *)
have clok' : all (@closed_cell_side_limit_ok _) (state_closed_seq rstate).
  apply/allP; rewrite /state_closed_seq/= -cats1 -catA /= -cat_rcons.
    move=> c; rewrite mem_cat=> /orP[cin | cin].
    by apply: (allP clok); rewrite stq.
  move: cin; rewrite /closing_cells cats1 -map_rcons=> /mapP[c' c'in ->].
  have ccont : contains_point (point ev) c'.
    by move: c'in; rewrite mem_rcons inE => /orP[/eqP -> | /allct].
  have c'in' : c' \in state_open_seq st.
    by rewrite ocd -cat_rcons !mem_cat c'in orbT.
  have /(allP sval) /= /andP[vlc' vhc'] := c'in'.
  have c'ok : open_cell_side_limit_ok c'.
    by apply: (allP (sides_ok (ngcomm c_inv))).
  by apply close_cell_ok.
have safe_side_bound : {in rcons cls lstc, forall c p,
       in_safe_side_left p c || in_safe_side_right p c ->
       p_x p <= right_limit c}.
  move=> c p cin /orP[] /andP[] /eqP -> _; last by rewrite le_refl.
  by apply/ltW/(cl_large d_inv); rewrite /state_closed_seq stq.
have not_safe_event : {in rcons (closing_cells (point ev) cc)
                                 (close_cell (point ev) lcc), forall c,
   ~~ (in_safe_side_left  (point ev) c || in_safe_side_right (point ev) c)}.
  move=> c cin; apply/negP.
  move: (cin); rewrite -map_rcons=> /mapP[c' c'in cq].
  have c'in' : c' \in state_open_seq st.
    by rewrite ocd -cat_rcons !mem_cat c'in orbT.
  move=> /orP[ /andP[] + _ | /andP[] _ /andP[] _ /andP[] _ ].
    apply/negP.
    have /andP [vlc' vhc'] : valid_edge (low c') (point ev) &&
            valid_edge (high c') (point ev).
      by apply: (allP sval).
    rewrite -(right_limit_close_cell vlc' vhc') eq_sym.
    have /(cl_large d_inv'): c \in state_closed_seq rstate.
      by rewrite /rstate/state_closed_seq/= rcons_cat /= mem_cat inE cin !orbT.
    rewrite -[cells.close_cell _ _]/(close_cell _ _) -cq.
    by rewrite lt_neqAle=> /andP[].
  by rewrite cq close_cell_in //; apply/andP/(allP sval).
have in_safe_side_left_close_cell :
  {in rcons cc lcc, forall c p, in_safe_side_left p (close_cell (point ev) c) =
        in_safe_side_left p c}.
  move=> c cin p; rewrite /in_safe_side_left.
  have [-> -> ->] := close_cell_preserve_3sides (point ev) c.
  by rewrite left_limit_close_cell.

have lex_top_right_main : (* TODO: this should be the invariant, where
  (point ev) is the second point on left_pts lsto, or the second point on
  right_pts lstc. *)
  {in sc_closed rstate, forall c,
    lexePt (head dummy_pt (right_pts c)) (point ev)}.
  move=> c cin.
  move: cin; rewrite /rstate/= mem_cat inE orbA=> /orP[cold | cnew].
    move: cold => /orP[cold | ].
      have cold' : c \in sc_closed st by rewrite stq.
      (* have ein' : e \in (ev :: future_events) by rewrite inE ein orbT. *)
      by have /lexPtW :=(cl_at_left_ss_compat ssng cold' evinevs).
    move=> /eqP ->.
    rewrite /lexePt.
    have lstcin : lstc \in state_closed_seq st.
      by rewrite /state_closed_seq stq /= mem_rcons inE eqxx.
    have := cl_side d_inv lstcin =>
        /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[] +
        /andP[] _ /andP[] hdon _.
    have := (high_lstc d_inv); rewrite stq /= => hlstc.
    rewrite hlstc in hdon.
    move=> /allP sx.
    have := size_right_cls d_inv; rewrite stq /= => sr.
    have hdin : head dummy_pt (right_pts lstc) \in right_pts lstc.
      by move: sr; case: (right_pts lstc) => [ | a tl] //; rewrite inE eqxx.
    have hdlstx : p_x (head dummy_pt (right_pts lstc)) = lstx.
      have -> : p_x (head dummy_pt (right_pts lstc)) = right_limit lstc.
        by rewrite (eqP (sx _ hdin)).
      by have := (cl_at_lstx d_inv); rewrite stq /= => ->.
    case: simple_cond=> [/eqP xdif | [] atx yab].
      apply/orP; left.
      rewrite lt_neqAle.
      by rewrite hdlstx xdif.
    apply/orP; right.
    rewrite hdlstx atx eqxx /=.
    have hlstxev : p_x (head dummy_pt (right_pts lstc)) = p_x (point ev).
      by rewrite hdlstx atx.
    have ulsthe := under_edge_lower_y (esym hlstxev) hdon.
    rewrite ulsthe -ltNge in yab.
    by apply ltW.
  move: cnew=> /mapP [c' c'in cc'].
  have evonc' := open_cells_decomposition_point_on cbtom adj 
    (inside_box_between inbox_e) sval oe' c'in.
  have c'in2 : c' \in state_open_seq st.
    by rewrite ocd !mem_cat c'in orbT.
  have vlc' : valid_edge (low c') (point ev).
    by apply: (proj1 (andP (allP sval _ c'in2))).
  have <- := top_right_close_cell evonc' vlc'.
  by rewrite lexePt_eqVlt cc' eqxx.
(* Now comes the real important property. *)
have cl_safe_edge :
  {in events_to_edges (rcons previous_events ev) & state_closed_seq rstate,
    forall (g : edge) (c : cell) (p : pt),
    in_safe_side_left p c || in_safe_side_right p c -> ~ p === g}.
  rewrite events_to_edges_rcons /state_closed_seq/=.
  move=> g c gin cin p pin.
  move: cin; rewrite -cats1 -catA /= -cat_rcons mem_cat=> /orP[cold | cnew].
    move: gin; rewrite mem_cat=> /orP[gold | gnew].
      (* the edge and the cell are old *)
      by apply: (A g c); rewrite // stq /state_closed_seq/=.
    move=> pong.
    have pxge : p_x (point ev) <= p_x p.
      by move: pong=> /andP[] _ /andP[]; rewrite (eqP (oute _ gnew)).
    have cin' : c \in state_closed_seq st by rewrite stq.
  have := (closed_at_left_non_gp_compat d_inv cin')=> /(_ ev).
    rewrite inE eqxx=> /(_ isT) rll.
    move: pin=> /orP[] /andP[] /eqP eqlx Extra.
      have ltlr := (cl_large d_inv cin').
      move: pxge; rewrite eqlx leNgt=> /negP; apply.
      by apply: lt_le_trans ltlr rll.
    have pxq : p_x p = p_x (point ev).
      by apply: le_anti; rewrite pxge eqlx rll.
    have pev : p = point ev.
      apply/eqP; rewrite pt_eqE pxq eqxx /=; apply/eqP.
      apply: (on_edge_same_point pong _ pxq).
      by rewrite -(eqP (oute _ gnew)) left_on_edge.
    have pxlst : p_x p = lst_x _ _ st.
      apply: le_anti.
      rewrite [X in (X <= _)]eqlx pev (closed_at_left_non_gp d_inv cin').
      by rewrite stq xevgelstx.
    have := simple_cond.
    rewrite -pxq pxlst stq /= => -[]; first by case.
    move=> -[] _.
    move: cold; rewrite mem_rcons inE => /orP[/eqP clstc | incls].
      have := high_lstc d_inv; rewrite stq /= => /[dup] eqlsthe <-.
      have vhl : valid_edge (high lstc) (point ev).
        rewrite eqlsthe -hlsto.
        apply: (proj2 (andP (allP sval lsto _))).
        by rewrite stq /state_open_seq /= mem_cat inE eqxx orbT.
      rewrite (under_onVstrict vhl).
      rewrite -pev -clstc; move: Extra => /andP[] ->.
      by rewrite orbT.
    have := cl_at_left_ss_compat ssng=> /(_ c ev).
    rewrite stq /= inE eqxx => /(_ incls isT)=> lextopright.
    have := cl_side d_inv=> /(_ c).
    rewrite stq /state_closed_seq/= mem_rcons inE incls orbT=> /(_ isT).
    move=> /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[].
    move=> sr /andP[] sxr /andP[] _ /andP[] headon _.
    have xh : p_x (head dummy_pt (right_pts c)) = p_x p.
      rewrite eqlx; apply/eqP.
      by move: sr sxr; case: (right_pts) => [ |a  tl] //=  _/andP[].
    move : lextopright=> /orP[].
      by rewrite xh pxq ltxx.
    move=> /andP[] _ ylow.
    have := strict_under_edge_lower_y (esym xh) headon.
    move: (Extra) => /andP[] -> _ => /esym.
    by rewrite pev ltNge (ltW ylow).
  move: cnew pin; rewrite cats1 /closing_cells -map_rcons.
  move=> /mapP[c' c'in ->].
  have c'in' : c' \in state_open_seq st.
    by rewrite ocd -cat_rcons !mem_cat c'in orbT.
  have clc'in : close_cell (point ev) c' \in
      state_closed_seq rstate.
      rewrite /rstate/state_closed_seq/= rcons_cat /= /closing_cells -map_rcons.
      by rewrite !mem_cat inE map_f // ?orbT.
  have clc'large := cl_large d_inv' clc'in. 
  have /andP[vlc' vhc'] := allP sval _ c'in'.
  move=> /orP[pin | pin].
    have pin': in_safe_side_left p c'.
      by move: pin; rewrite in_safe_side_left_close_cell.
    move: pin=> /andP[]; rewrite left_limit_close_cell => pl _.
    move: gin; rewrite mem_cat=> /orP[gin | ].
      by apply: B pin'.
    move=> /oute /eqP lgq /andP[] _ /andP[]; rewrite lgq leNgt=> /negP[].
    have := clc'large; rewrite /left_limit.
    have [_ _ ->] := close_cell_preserve_3sides (point ev) c'.
    rewrite -/(left_limit c').
    by rewrite (eqP pl) right_limit_close_cell  ?(eqP pl).
  have vc' : valid_cell c' (point ev) by apply/andP/(allP sval).
  have /eqP samex : p_x p == p_x (point ev).
    by move: pin=> /andP[] + _; rewrite close_cell_right_limit.
  move: gin; rewrite mem_cat=> /orP[gin | /oute/eqP lgq ]; last first.
    have peg : point ev === g by rewrite -lgq left_on_edge.
    move=> pong.
    have /eqP samey := on_edge_same_point pong peg samex.
    have pev : p = point ev by apply/eqP; rewrite pt_eqE samex samey eqxx.
    have := not_safe_event (close_cell (point ev) c').
    rewrite -[e in in_safe_side_right e _]pev pin orbT.
    by rewrite /closing_cells -map_rcons map_f // => /(_ isT).
  move: gin=> /flatten_mapP[e' e'in gin] pong.
  have := edge_covered_ec e_inv e'in gin=> -[]; last first.
    move=> [[ | pcc0 pcc] []]; first by [].
    move=> _ /= [pccsub [pcchigh [_ [_ rlpcc]]]].
    have /[dup] lsin : last_cell (pcc0 :: pcc) \in state_closed_seq st.
      by apply/pccsub; rewrite /last_cell /= mem_last.
    have := same_x_valid lsthe samex; rewrite vlsthe=> vplsthe.
    have pxhd : p_x p = p_x (right_pt g).
      apply: le_anti.
      move: pong=> /andP[] _ /andP[] _ -> /=.
      have := closed_at_left_non_gp_compat d_inv lsin=> /(_ _ evinevs).
      by rewrite rlpcc samex.
    have [/eqP xhd hdon]:
          p_x (head dummy_pt (right_pts (last_cell (pcc0 :: pcc)))) ==
                  right_limit (last_cell (pcc0 :: pcc)) /\
          head dummy_pt (right_pts (last_cell (pcc0 :: pcc))) === g.
      rewrite -(pcchigh _ (mem_last _  _)).
      have := cl_side d_inv lsin.
      move=> /andP[] _ /andP[] _ /andP[] _ /andP[] _ /andP[] _.
      move=> /andP[] sr /andP[] /allP xs /andP[] _ /andP[] hdon _.
      split; last by [].
      apply: xs; move: sr.
      by case: right_pts => [ | a tl] //= _; rewrite inE eqxx.
    have pxhd' : p_x p = 
         p_x (head dummy_pt (right_pts (last_cell (pcc0 :: pcc)))).
         by rewrite pxhd xhd rlpcc.
    have atlstx : lstx = p_x (point ev).
      apply: le_anti.
      have := closed_at_left_non_gp d_inv lsin; rewrite rlpcc stq /= => rple.
      have -> : p_x (point ev) <= lstx.
        by rewrite -samex (le_trans (proj2 (andP (proj2 (andP pong))))).
      by rewrite andbT.
    case: simple_cond; first by rewrite atlstx.
    move=> -[] _ evabhsthe.
    have step3 : lsto \in fc.
      (* TODO : this is a lemma about open_cells_decomposition*)
      have := lstoin; rewrite ocd.
      rewrite !(mem_cat, inE)=> /orP[] //.
      move=> /orP[].
        move=> /allct; rewrite /contains_point hlsto.
        by rewrite (negbTE evabhsthe) andbF.
      move=> /orP[/eqP islcc | inlc].
        move: lcc_ctn; rewrite /contains_point.
        by rewrite -islcc hlsto (negbTE evabhsthe) andbF.
      have lbho := allP rfo _ lstoin.
      have evbllsto := decomposition_under_low_lc oe' cbtom adj
        (inside_box_between inbox_e) rfo sval inlc.
      have abs := order_edges_strict_viz_point' vlo vho lbho evbllsto.
      by case/negP: evabhsthe; rewrite -hlsto (underW abs).
    have lstheble : lsthe <| le.
      have := (pairwise_open_non_gp d_inv); rewrite ocd.
      rewrite !map_cat /= => /andP[] _.
      have [s1 [s2 fcq]] := mem_seq_split step3.
        have [lstolstfc | lstodif] := eqVneq s2 [::].
          have := adj; rewrite ocd fcq lstolstfc /= -catA /=.
          move=> /adjacent_catW=> -[] _ /= fact1 _.
          have sameg : high lsto = low (head lcc cc).
            by move: fact1; case (cc) => [ | a tl] //= /andP[] /eqP.
          by rewrite -hlsto sameg leq edge_below_refl.
        rewrite fcq map_cat /=.
        rewrite pairwise_cat=> /andP[] _ /andP[] + _.
        rewrite pairwise_cat=> /andP[] _ /andP[] _ /= /andP[] /allP fact _.
        have lin : last lsto s2 \in s2 by apply: last_in_not_nil.
        have := fact _ (map_f _ lin).
        rewrite hlsto.
      have := adj; rewrite ocd fcq -catA=> /adjacent_catW [] _/=.
      rewrite cat_path=> /andP[] _ main.
      have -> : high (last lsto s2) = low (head lcc cc).
        by move: main; case: (cc) => [ | a tl] /= /andP[] /eqP.
      by rewrite leq.
    have phd : p = head dummy_pt (right_pts (last_cell (pcc0 :: pcc))).
      apply/eqP; rewrite pt_eqE.
      rewrite pxhd' eqxx /=.
      by rewrite (on_edge_same_point pong hdon pxhd').
    have pble_if : p <<= lsthe -> p <<= le.
      move=> pblsthe.
      have vple : valid_edge le p by rewrite (same_x_valid _ samex).
      have vpho : valid_edge lsthe p by rewrite (same_x_valid _ samex).
        by apply: (order_edges_viz_point' vpho vple lstheble pblsthe).
    have last_step_lt : p <<= lsthe -> p_y (point ev) < p_y p -> False.
      move=> pblsthe abs.
      have := same_x_under_edge_lt_y_trans
            vplsthe samex abs pblsthe => abs'.
      by case/negP: evabhsthe; apply/underW.
      have main: p <<= lsthe -> False.
        move=> /[dup]pblsthe /pble_if pble.
      move: oe'; case ccq : cc => [ | cc1 ccs] oe'.
        have := single_closing_side_char evin rfo cbtom adj sval p oe'.
        move: c'in; rewrite ccq /= inE => /eqP <-.
        rewrite pin=> /esym /orP[]; last first.
          by move=> /andP[] _ /andP[] _ /(last_step_lt pblsthe).
        move=> /andP[] _ /andP[].
        by rewrite pble.
      move: c'in; rewrite mem_rcons inE => /orP[/eqP c'lcc | ].
        have /esym := last_closing_side_char evin rfo cbtom adj sval p oe' isT.
        rewrite -c'lcc pin => /andP[] _ /andP[].
        by move=>/(last_step_lt pblsthe).
      rewrite ccq inE=> /orP[/eqP c'cc1 | c'ccs].
        have /esym := first_closing_side_char evin rfo cbtom adj sval p oe'.
        by rewrite -c'cc1 pin=> /andP[] _ /andP[]; rewrite pble.
      have := middle_closing_side_char evin rfo cbtom adj sval p oe'=> /negP.
      case; apply/hasP; exists (close_cell (point ev) c')=> //.
      by apply: map_f.
    rewrite stq /state_closed_seq /=; rewrite mem_rcons inE orbC=> /orP[].
      move=> lincls.
      have hdlx : lexPt (head dummy_pt (right_pts (last_cell (pcc0 :: pcc))))
              (point ev).
        by apply: (cl_at_left_ss_compat ssng); rewrite // stq.
      have lincls' : last_cell (pcc0 :: pcc) \in sc_closed st by rewrite stq.
      have step1 : lexePt p (nth dummy_pt (left_pts lsto) 1).
        have := cl_at_left_ss ssng lincls'; rewrite stq /=.
        by rewrite -phd.
      have step2 : p <<< lsthe.
        have := same_x_valid lsthe (etrans xnth1 atlstx).
        rewrite vlsthe=> v1.
        have pyle1 : p_y p <= p_y (nth dummy_pt (left_pts lsto) 1).
          by move: step1; rewrite /lexePt xnth1 atlstx -samex ltxx eqxx.
        have := open_cell_side_limit_ok_left_pt_strict_under
          (allP (sides_ok (ngcomm c_inv)) _ lstoin).
        have := has_snd_lst c_inv; rewrite stq /= => /[swap] /[apply] nth1u.
        apply: (same_x_strict_under_edge_le_y_trans v1
           (etrans xnth1 (etrans atlstx (esym samex))) pyle1).
        by rewrite -hlsto.
      by apply: (main (underW step2)).
    move=> /eqP atlstc.
    have glsthe : g = lsthe.
      rewrite -(pcchigh _ (mem_last _ _)) [last _ _]atlstc.
      by have := high_lstc d_inv; rewrite stq.
    suff pblsthe : p <<= lsthe by apply: (main pblsthe).
    rewrite -glsthe under_onVstrict ?pong //.
    by move: pong => /andP[].
  move=> [] opc [] pcc [] _ [] opch [] _ [] opco _.
  have [vlc'p vhc'p] : valid_edge (low c') p /\ valid_edge (high c') p.
    by move: vc'; rewrite /valid_cell !(same_x_valid _ samex).
  have pinc' : contains_point' p c'.
    rewrite /contains_point'.
    have [<- <- _] := close_cell_preserve_3sides (point ev) c'.
    by have /andP[_ /andP[] /underW -> /andP[] ->] := pin.
  have {}opch : high opc = g by apply: opch; rewrite mem_rcons inE eqxx.
  have [vplc vphc] : valid_edge (low opc) p /\ valid_edge (high opc) p.
    by rewrite !(same_x_valid _ samex); apply/andP/(allP sval).
  have rfc : low opc <| high opc by apply: (allP rfo).
  have cnt : contains_point p opc.
    rewrite contains_pointE; apply/andP; rewrite under_onVstrict; last first.
      by have := (allP sval _ opco) => /andP[].
    rewrite opch pong; split; last by [].
    apply/negP=> pun.
    have := order_edges_strict_viz_point' vplc vphc rfc pun.
    by apply/negP/onAbove; rewrite opch.
  have pw : pairwise edge_below [seq high c | c <- state_open_seq st].
    by move: (pairwise_open_non_gp d_inv)=> /= /andP[].
  have [puhc' palc'] : p <<< high c' /\ p >>> low c'.
    apply/andP;  move: pin=> /andP[] _ /andP[] + /andP[] + _.
    by have [-> -> _] := close_cell_preserve_3sides (point ev) c' => ->.
  have : p >>= low opc by move: cnt=> /andP[].
  rewrite strict_nonAunder // negb_and negbK=> /orP[ | stricter]; last first.
    have := disoc adj pw (sides_ok (ngcomm c_inv)).
    move=> /(_ opc c' opco c'in') [ab' | ].
      by move: puhc'; rewrite strict_nonAunder // -ab' opch pong.
    move=> /(_ p) + ; move=>/negP.
    rewrite inside_open'E stricter valid_open_limit //.
    move: cnt; rewrite contains_pointE=> /andP[] _ ->.
    (* rewrite samex lolt //=; last by rewrite inE eqxx.
    rewrite inside_open'E (underW puhc') palc' valid_open_limit //.
    by rewrite samex lolt // inE eqxx. *)
    admit.
  move=> ponl.
  have vbp : valid_edge bottom p.
    by rewrite (same_x_valid _ samex) (inside_box_valid_bottom inbox_e).
  have vtp : valid_edge top p.
    rewrite (same_x_valid _ samex) /valid_edge/generic_trajectories.valid_edge.
    by move: inbox_e=> /andP[] _ /andP[] _ /andP[] /ltW -> /ltW ->.
  have bottom_b_c' : bottom <| low c'.
    have [-> | ] := eqVneq bottom (low c'); first by apply: edge_below_refl.
    have  [s1 [s2]] := mem_seq_split c'in'.
    elim/last_ind: s1 => [ | s1 op' _] /= => odec.
      by move: cbtom => /andP[]; rewrite odec /= => /eqP ->; rewrite eqxx.
    have := adj.
    rewrite odec cat_rcons=> /adjacent_catW /= [] _ /andP[] /eqP <- _ _.
    have := pairwise_open_non_gp d_inv=> /= /andP[] /allP /(_ (high op')) + _.
    apply; apply/mapP; exists op'=> //.
    by rewrite // odec !mem_cat mem_rcons inE eqxx.
  have pab : p >>> bottom.
    apply/negP=> pub.
    have:= order_edges_viz_point' vbp vlc'p bottom_b_c' pub.
    by move: palc'=> /[swap] => ->.
  have ldifh : low opc != high opc by apply: d_e; rewrite mem_cat opco.
  have low_opc_s : low opc \in [:: bottom, top & s].
    by apply: (edges_sub (ngcomm c_inv)); rewrite !mem_cat map_f.
  have high_opc_s : high opc \in [:: bottom, top & s].
    by apply: (edges_sub (ngcomm c_inv)); rewrite !mem_cat map_f ?orbT.
  have := nocs' (low opc) (high opc) low_opc_s high_opc_s.
  move=> [Q | ]; first by rewrite Q eqxx in ldifh.
  have ponh : p === high opc by rewrite opch.
  have opcok : open_cell_side_limit_ok opc.
    by apply: (allP (sides_ok (ngcomm c_inv))).
  move=> /(_ _ ponl ponh); rewrite !inE=> /orP[/eqP pleft | /eqP].
    (* have : left_limit opc < p_x p.
      by rewrite samex; apply: lolt; rewrite // inE eqxx.
    have := left_limit_max opcok.
    have [_ | ] := lerP (p_x (left_pt (high opc)))(p_x (left_pt (low opc))).
      by move=> /le_lt_trans /[apply]; rewrite pleft lt_irreflexive.
    move=> /lt_le_trans /[apply]=> /lt_trans /[apply].
    by rewrite pleft lt_irreflexive. *)
    admit.
(* Here p is vertically aligned with p_x, but it must be an event,
   because it is the end of an edge. *)
  move=> prl.
  have put : p <<< top.
    apply: (order_edges_strict_viz_point' vhc'p vtp _ puhc').
    move: cbtom=> /andP[] _.
    have := pw.
    have [s1 [s2 s1q]] := mem_seq_split c'in'.
    rewrite s1q last_cat /= map_cat pairwise_cat /=.
    move=> /andP[] _ /andP[] _ /andP[] allabovec' _ /eqP highlast.
    case s2q : s2 => [ | c2 s3].
      by rewrite -highlast s2q edge_below_refl.
    have /(allP allabovec') : (high (last c' s2)) \in [seq high c | c <- s2].
      by rewrite map_f // s2q /= mem_last.
    by rewrite highlast.
  have := (allP clae _ opco)=> /andP[] + _ => /orP[].
    rewrite !inE => /orP[] /eqP=> ab'.
      by move: pab; rewrite under_onVstrict // -ab' ponl.
    by move: put; rewrite strict_nonAunder // -ab' ponl.
  move=> /hasP[e2 + /eqP pe2]; rewrite inE=> /orP[/eqP e2ev | e2in].
  (* if e' cannot be ev, because p cannot be ev because of pin *)
    have := pin=> /andP[].
    by rewrite prl pe2 e2ev close_cell_in // ?andbF.
  have [ [] | [plstx pablsthe]]:= simple_cond.
    admit.
  admit.
have op_safe_edge :
  {in events_to_edges (rcons previous_events ev) & state_open_seq rstate,
    forall g c p, in_safe_side_left p c -> ~ p === g}.
(* We should re-use the proof that was just done. *)
  move=> g c gin; rewrite /rstate/state_open_seq/=.
  rewrite -catA -cat_rcons !mem_cat orbCA=> /orP[cnew | cold]; last first.
    have cin : c \in state_open_seq st.
      by rewrite ocd -cat_rcons !mem_cat orbCA cold orbT.
    move: gin; rewrite events_to_edges_rcons mem_cat=> /orP[gold | gnew].
      by apply: (B _ _ gold cin).
    move=> p pin /andP[] _ /andP[] pong _.
    (* have := lolt _ _ cin (mem_head _ _).
    move: (pin)=> /andP[] /eqP <- _.
    rewrite ltNge=> /negP; apply.
    by move: pong; rewrite (eqP (oute _ gnew)). *)
    admit.
  move=> p pin.
  have : has (in_safe_side_left p)
           (opening_cells (point ev) (outgoing ev) le he).
    by apply/hasP; exists c; rewrite // /opening_cells oca_eq.
  have := sides_equiv inbox_es oute rfo cbtom adj sval; rewrite stq /=.
  move=> /(_ _ _ _ _ _ _ oe p) /eqP <- => /hasP[] c' c'in pin'.
  have := cl_safe_edge _ c' gin; apply.
    by rewrite /rstate /state_closed_seq/= rcons_cat /= mem_cat inE c'in ?orbT.
  by rewrite pin' orbT.
have cl_safe_event :
  {in rcons previous_events  ev & state_closed_seq rstate, forall e c (p : pt),
     in_safe_side_left p c || in_safe_side_right p c -> p != point e}.
  move=> e c; rewrite mem_rcons inE=> /orP[/eqP -> | ein].
    move=> cin p pin; apply/negP=> /eqP pev.
    move: cin.
    rewrite /rstate/state_closed_seq/= -cats1 -catA /= -cat_rcons mem_cat.
    move=> /orP[]; last by rewrite cats1=> /not_safe_event; rewrite -pev pin.
    move=> cin; have cin' : c \in state_closed_seq st by rewrite stq.
    move: (cin)=> /safe_side_bound/(_ _ pin); rewrite pev leNgt=> /negP; apply.
    (* by apply: (rl _ _ cin' (mem_head _ _)). *)
    admit.
  rewrite /rstate/state_closed_seq/= -cats1 -catA /= -cat_rcons mem_cat.
  move=> /orP[cin | ].
    have cin' : c \in state_closed_seq st by rewrite stq.
    by apply: (C _ _ ein cin').
  rewrite cats1 -map_rcons=> /mapP[c' c'in /[dup] cq ->].
  have c'in' : c' \in state_open_seq st.
    by rewrite ocd -cat_rcons !mem_cat c'in orbT.
  move=> p /orP[] pin.
    apply: (D e c' ein c'in').
    by move: pin; rewrite in_safe_side_left_close_cell.
  have /andP[vlc' vhc'] : valid_edge (low c') (point ev) &&
                                   valid_edge (high c') (point ev).
    by apply: (allP sval).
  move: (pin) => /andP[] + _.
  rewrite right_limit_close_cell // => /eqP pxq.
  apply/eqP=> abs.
  have := old_lt_fut _ _ ein (mem_head _ _).
  (* by rewrite -abs pxq lt_irreflexive. *)
  admit.
have op_safe_event :
{in rcons previous_events ev & state_open_seq rstate,
    forall (e : event) (c : cell) (p : pt),
    in_safe_side_left p c -> p != point e}.
  move=> e c ein; rewrite /rstate/state_open_seq/=.
  rewrite -catA -cat_rcons !mem_cat orbCA=> /orP[cnew | cold]; last first.
    have cin : c \in state_open_seq st.
      by rewrite ocd -cat_rcons !mem_cat orbCA cold orbT.
    move: ein; rewrite mem_rcons inE=> /orP[/eqP -> | eold]; last first.
      by apply: (D _ _ eold cin).
    (* have := lolt _ _ cin (mem_head _ _)=> llt p /andP[] /eqP pll _.
    apply/eqP=> pev.
    by move: llt; rewrite -pll pev lt_irreflexive. *)
    admit.
  move=> p pin.
  have : has (in_safe_side_left p)
           (opening_cells (point ev) (outgoing ev) le he).
    by apply/hasP; exists c; rewrite // /opening_cells oca_eq.
  have := sides_equiv inbox_es oute rfo cbtom adj sval; rewrite stq /=.
  move=> /(_ _ _ _ _ _ _ oe p) /eqP <- => /hasP[] c' c'in pin'.
  have := cl_safe_event _ c' ein; apply.
    by rewrite /rstate /state_closed_seq/= rcons_cat /= mem_cat inE c'in ?orbT.
  by rewrite pin' orbT.
have old_lt_fut' :
  {in rcons previous_events ev & future_events,
     forall e1 e2, p_x (point e1) < p_x (point e2)}.
  move=> e1 e2; rewrite mem_rcons inE=>/orP[/eqP -> | e1old] e2fut; last first.
    (* by apply: old_lt_fut; rewrite // inE e2fut orbT. *)
    admit.
  admit.
have rf_closed1 : {in state_closed_seq rstate, forall c, low c <| high c}.
  move=> c; rewrite /rstate/state_closed_seq/=.
  rewrite appE -cat_rcons -cats1 -catA.
  rewrite mem_cat=> /orP[cin | ].
    by apply: rf_cl; rewrite /state_closed_seq stq/=.
  rewrite cats1 -map_rcons=> /mapP[c' c'in ->].
  have [-> -> _] := close_cell_preserve_3sides (point ev) c'.
  have := inv1 (ngcomm c_inv).
  move=> [] _ [] _ [] _ [] _ /allP; apply.
  by rewrite ocd -cat_rcons !mem_cat c'in orbT.
have lo_lb' : {in state_open_seq rstate, forall c,
               left_limit c < min (p_x (right_pt bottom)) (p_x (right_pt top))}.
  move=>c; rewrite /state_open_seq/= -catA -cat_rcons !mem_cat orbCA.
  move=> /orP[cnew | cold]; last first.
    (* by apply: lo_lb; rewrite ocd -cat_rcons !mem_cat orbCA cold orbT. *)
    admit.
  have := opening_cells_left oute vl vp ; rewrite /opening_cells oca_eq.
  move=> /(_ _ cnew) ->.
  by apply: inside_box_lt_min_right.
have lexPtevents :
 {in rcons previous_events ev & future_events, forall e1 e2, lexPtEv e1 e2}.
  move=> e1 e2 + e2in.
  rewrite mem_rcons inE => /orP[/eqP -> | e1in]; last first.
    by apply: (left_proc ssng); rewrite // inE e2in orbT.
  have := lexev=> /=; rewrite (path_sortedE (@lexPtEv_trans _)).
  by move=> /andP[] /allP /(_ _ e2in).
have lex_top_right :
  {in sc_closed rstate & future_events,
    forall c e, lexPt (head dummy_pt (right_pts c)) (point e)}.
  move=> c e cin ein.
  have := lexev; rewrite /= (path_sortedE (@lexPtEv_trans _)).
  move=> /andP[] /allP /(_ _ ein) + _; rewrite /lexPtEv.
  apply: lexePt_lexPt_trans.
  by apply: lex_top_right_main.
constructor=> //.
Admitted.

End working_environment.