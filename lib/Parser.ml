[@@@warning "-unused-rec-flag"]

open Grammar

type token =
  | ID of string
  | TID of string
  | TYPE of string
  | CODE of string
  | DTOKEN
  | DSTART
  | DSEP
  | COLON
  | SEMI
  | BAR
  | EQ
  | EOF

module Actions = struct
  let a1_grammar rules decls header () = { header; decls; rules }
  let a2_header header () = header
  let a3_decls decls decl () = decl :: decls
  let a4_decls () = []
  let a5_decl tids tp () = DeclToken (Some tp, tids)
  let a6_decl ids tp () = DeclStart (Some tp, ids)
  let a7_decl tids () = DeclToken (None, tids)
  let a8_decl ids () = DeclStart (None, ids)
  let a9_tids tids id () = id :: tids
  let a10_tids () = []
  let a11_ids ids id () = id :: ids
  let a12_ids () = []
  let a13_rules rules rule () = rule :: rules
  let a14_rules () = []
  let a15_rule prods id () = { id; prods }
  let a16_rule_prods productions production () = production :: productions
  let a17_rule_prods productions () = productions
  let a18_productions productions production () = production :: productions
  let a19_productions () = []
  let a20_production action prod () = { prod; action }
  let a21_producers producers producer () = producer :: producers
  let a22_producers () = []
  let a23_producer actual id () = { id = Some id; actual }
  let a24_producer actual () = { id = None; actual }
  let a25_actual name () = NTerm name
  let a26_actual name () = Term name
end

module States = struct
  let lexfun = ref (fun _ -> assert false)
  let lexbuf = ref (Lexing.from_string String.empty)
  let lookahead = ref None

  let setup lf lb =
    lexfun := lf;
    lexbuf := lb;
    lookahead := None
  ;;

  let shift () =
    let t = Option.get !lookahead in
    lookahead := None;
    t
  ;;

  let lookahead () =
    match !lookahead with
    | Some t -> t
    | None ->
      let t = !lexfun !lexbuf in
      lookahead := Some t;
      t
  ;;

  (* ITEMS:
       grammar' → . header decls DSEP rules EOF
       header → . CODE /DTOKEN /DSTART /DSEP
     GOTO:
       CODE -> 1
       header -> 2
     ACTION:
       CODE -> shift *)
  let rec state_0 c0_grammar_starting =
    let rec c1_header x = state_2 x c0_grammar_starting in
    match lookahead () with
    (* Shift *)
    | CODE x ->
      let _ = shift () in
      state_1 x c1_header
    | _ -> raise (Failure "error in state 0")

  (* ITEMS:
       header → CODE . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_1 a0_CODE c0_header =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a2_header a0_CODE () in
      c0_header x
    | _ -> raise (Failure "error in state 1")

  (* ITEMS:
       grammar' → header . decls DSEP rules EOF
       decls → . decl decls /DSEP
       decls → . /DSEP
       decl → . DTOKEN TYPE tids /DTOKEN /DSTART /DSEP
       decl → . DSTART TYPE ids /DTOKEN /DSTART /DSEP
       decl → . DTOKEN tids /DTOKEN /DSTART /DSEP
       decl → . DSTART ids /DTOKEN /DSTART /DSEP
     GOTO:
       DTOKEN -> 3
       DSTART -> 9
       decls -> 15
       decl -> 41
     ACTION:
       DSEP -> reduce 1 1
       DTOKEN DSTART -> shift *)
  and state_2 a0_header c0_grammar_starting =
    let rec c1_decls x = state_15 x a0_header c0_grammar_starting
    and c2_decl x = state_41 x c1_decls in
    match lookahead () with
    (* Reduce *)
    | DSEP ->
      let x = Actions.a4_decls () in
      c1_decls x
    (* Shift *)
    | DTOKEN ->
      let _ = shift () in
      state_3 c2_decl
    (* Shift *)
    | DSTART ->
      let _ = shift () in
      state_9 c2_decl
    | _ -> raise (Failure "error in state 2")

  (* ITEMS:
       decl → DTOKEN . TYPE tids /DTOKEN /DSTART /DSEP
       decl → DTOKEN . tids /DTOKEN /DSTART /DSEP
       tids → . TID tids /DTOKEN /DSTART /DSEP
       tids → . /DTOKEN /DSTART /DSEP
     GOTO:
       TID -> 4
       TYPE -> 6
       tids -> 8
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       TID TYPE -> shift *)
  and state_3 c0_decl =
    let rec c1_tids x = state_8 x c0_decl in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a10_tids () in
      c1_tids x
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_4 x c1_tids
    (* Shift *)
    | TYPE x ->
      let _ = shift () in
      state_6 x c0_decl
    | _ -> raise (Failure "error in state 3")

  (* ITEMS:
       tids → TID . tids /DTOKEN /DSTART /DSEP
       tids → . TID tids /DTOKEN /DSTART /DSEP
       tids → . /DTOKEN /DSTART /DSEP
     GOTO:
       TID -> 4
       tids -> 5
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       TID -> shift *)
  and state_4 a0_TID c0_tids =
    let rec c1_tids x = state_5 x a0_TID c0_tids in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a10_tids () in
      c1_tids x
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_4 x c1_tids
    | _ -> raise (Failure "error in state 4")

  (* ITEMS:
       tids → TID tids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_5 a0_tids a1_TID c0_tids =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a9_tids a0_tids a1_TID () in
      c0_tids x
    | _ -> raise (Failure "error in state 5")

  (* ITEMS:
       decl → DTOKEN TYPE . tids /DTOKEN /DSTART /DSEP
       tids → . TID tids /DTOKEN /DSTART /DSEP
       tids → . /DTOKEN /DSTART /DSEP
     GOTO:
       TID -> 4
       tids -> 7
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       TID -> shift *)
  and state_6 a0_TYPE c0_decl =
    let rec c1_tids x = state_7 x a0_TYPE c0_decl in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a10_tids () in
      c1_tids x
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_4 x c1_tids
    | _ -> raise (Failure "error in state 6")

  (* ITEMS:
       decl → DTOKEN TYPE tids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_7 a0_tids a1_TYPE c0_decl =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a5_decl a0_tids a1_TYPE () in
      c0_decl x
    | _ -> raise (Failure "error in state 7")

  (* ITEMS:
       decl → DTOKEN tids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_8 a0_tids c0_decl =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a7_decl a0_tids () in
      c0_decl x
    | _ -> raise (Failure "error in state 8")

  (* ITEMS:
       decl → DSTART . TYPE ids /DTOKEN /DSTART /DSEP
       decl → DSTART . ids /DTOKEN /DSTART /DSEP
       ids → . ID ids /DTOKEN /DSTART /DSEP
       ids → . /DTOKEN /DSTART /DSEP
     GOTO:
       ID -> 10
       TYPE -> 12
       ids -> 14
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       ID TYPE -> shift *)
  and state_9 c0_decl =
    let rec c1_ids x = state_14 x c0_decl in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a12_ids () in
      c1_ids x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_10 x c1_ids
    (* Shift *)
    | TYPE x ->
      let _ = shift () in
      state_12 x c0_decl
    | _ -> raise (Failure "error in state 9")

  (* ITEMS:
       ids → ID . ids /DTOKEN /DSTART /DSEP
       ids → . ID ids /DTOKEN /DSTART /DSEP
       ids → . /DTOKEN /DSTART /DSEP
     GOTO:
       ID -> 10
       ids -> 11
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       ID -> shift *)
  and state_10 a0_ID c0_ids =
    let rec c1_ids x = state_11 x a0_ID c0_ids in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a12_ids () in
      c1_ids x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_10 x c1_ids
    | _ -> raise (Failure "error in state 10")

  (* ITEMS:
       ids → ID ids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_11 a0_ids a1_ID c0_ids =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a11_ids a0_ids a1_ID () in
      c0_ids x
    | _ -> raise (Failure "error in state 11")

  (* ITEMS:
       decl → DSTART TYPE . ids /DTOKEN /DSTART /DSEP
       ids → . ID ids /DTOKEN /DSTART /DSEP
       ids → . /DTOKEN /DSTART /DSEP
     GOTO:
       ID -> 10
       ids -> 13
     ACTION:
       DTOKEN DSTART DSEP -> reduce 1 1
       ID -> shift *)
  and state_12 a0_TYPE c0_decl =
    let rec c1_ids x = state_13 x a0_TYPE c0_decl in
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a12_ids () in
      c1_ids x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_10 x c1_ids
    | _ -> raise (Failure "error in state 12")

  (* ITEMS:
       decl → DSTART TYPE ids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_13 a0_ids a1_TYPE c0_decl =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a6_decl a0_ids a1_TYPE () in
      c0_decl x
    | _ -> raise (Failure "error in state 13")

  (* ITEMS:
       decl → DSTART ids . /DTOKEN /DSTART /DSEP
     GOTO:
       
     ACTION:
       DTOKEN DSTART DSEP -> reduce 0 0 *)
  and state_14 a0_ids c0_decl =
    match lookahead () with
    (* Reduce *)
    | DTOKEN | DSTART | DSEP ->
      let x = Actions.a8_decl a0_ids () in
      c0_decl x
    | _ -> raise (Failure "error in state 14")

  (* ITEMS:
       grammar' → header decls . DSEP rules EOF
     GOTO:
       DSEP -> 16
     ACTION:
       DSEP -> shift *)
  and state_15 a0_decls a1_header c0_grammar_starting =
    match lookahead () with
    (* Shift *)
    | DSEP ->
      let _ = shift () in
      state_16 a0_decls a1_header c0_grammar_starting
    | _ -> raise (Failure "error in state 15")

  (* ITEMS:
       grammar' → header decls DSEP . rules EOF
       rules → . rule rules /EOF
       rules → . /EOF
       rule → . ID COLON rule_prods SEMI /ID /EOF
     GOTO:
       ID -> 17
       rules -> 37
       rule -> 39
     ACTION:
       EOF -> reduce 1 1
       ID -> shift *)
  and state_16 a1_decls a2_header c0_grammar_starting =
    let rec c1_rules x = state_37 x a1_decls a2_header c0_grammar_starting
    and c2_rule x = state_39 x c1_rules in
    match lookahead () with
    (* Reduce *)
    | EOF ->
      let x = Actions.a14_rules () in
      c1_rules x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_17 x c2_rule
    | _ -> raise (Failure "error in state 16")

  (* ITEMS:
       rule → ID . COLON rule_prods SEMI /ID /EOF
     GOTO:
       COLON -> 18
     ACTION:
       COLON -> shift *)
  and state_17 a0_ID c0_rule =
    match lookahead () with
    (* Shift *)
    | COLON ->
      let _ = shift () in
      state_18 a0_ID c0_rule
    | _ -> raise (Failure "error in state 17")

  (* ITEMS:
       rule → ID COLON . rule_prods SEMI /ID /EOF
       rule_prods → . production productions /SEMI
       rule_prods → . productions /SEMI
       productions → . BAR production productions /SEMI
       productions → . /SEMI
       production → . producers CODE /SEMI /BAR
       producers → . producer producers /CODE
       producers → . /CODE
       producer → . ID EQ actual /ID /TID /CODE
       producer → . actual /ID /TID /CODE
       actual → . ID /ID /TID /CODE
       actual → . TID /ID /TID /CODE
     GOTO:
       ID -> 19
       TID -> 22
       BAR -> 24
       rule_prods -> 32
       productions -> 34
       production -> 35
       producers -> 27
       producer -> 29
       actual -> 31
     ACTION:
       CODE -> reduce 4 1
       SEMI -> reduce 2 1
       ID TID BAR -> shift *)
  and state_18 a1_ID c0_rule =
    let rec c1_rule_prods x = state_32 x a1_ID c0_rule
    and c2_productions x = state_34 x c1_rule_prods
    and c3_production x = state_35 x c1_rule_prods
    and c4_producers x = state_27 x c3_production
    and c5_producer x = state_29 x c4_producers
    and c6_actual x = state_31 x c5_producer in
    match lookahead () with
    (* Reduce *)
    | CODE _ ->
      let x = Actions.a22_producers () in
      c4_producers x
    (* Reduce *)
    | SEMI ->
      let x = Actions.a19_productions () in
      c2_productions x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_19 x c5_producer c6_actual
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_22 x c6_actual
    (* Shift *)
    | BAR ->
      let _ = shift () in
      state_24 c2_productions
    | _ -> raise (Failure "error in state 18")

  (* ITEMS:
       producer → ID . EQ actual /ID /TID /CODE
       actual → ID . /ID /TID /CODE
     GOTO:
       EQ -> 20
     ACTION:
       ID TID CODE -> reduce 1 0
       EQ -> shift *)
  and state_19 a0_ID c0_producer c1_actual =
    match lookahead () with
    (* Reduce *)
    | ID _ | TID _ | CODE _ ->
      let x = Actions.a25_actual a0_ID () in
      c1_actual x
    (* Shift *)
    | EQ ->
      let _ = shift () in
      state_20 a0_ID c0_producer
    | _ -> raise (Failure "error in state 19")

  (* ITEMS:
       producer → ID EQ . actual /ID /TID /CODE
       actual → . ID /ID /TID /CODE
       actual → . TID /ID /TID /CODE
     GOTO:
       ID -> 21
       TID -> 22
       actual -> 23
     ACTION:
       ID TID -> shift *)
  and state_20 a1_ID c0_producer =
    let rec c1_actual x = state_23 x a1_ID c0_producer in
    match lookahead () with
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_21 x c1_actual
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_22 x c1_actual
    | _ -> raise (Failure "error in state 20")

  (* ITEMS:
       actual → ID . /ID /TID /CODE
     GOTO:
       
     ACTION:
       ID TID CODE -> reduce 0 0 *)
  and state_21 a0_ID c0_actual =
    match lookahead () with
    (* Reduce *)
    | ID _ | TID _ | CODE _ ->
      let x = Actions.a25_actual a0_ID () in
      c0_actual x
    | _ -> raise (Failure "error in state 21")

  (* ITEMS:
       actual → TID . /ID /TID /CODE
     GOTO:
       
     ACTION:
       ID TID CODE -> reduce 0 0 *)
  and state_22 a0_TID c0_actual =
    match lookahead () with
    (* Reduce *)
    | ID _ | TID _ | CODE _ ->
      let x = Actions.a26_actual a0_TID () in
      c0_actual x
    | _ -> raise (Failure "error in state 22")

  (* ITEMS:
       producer → ID EQ actual . /ID /TID /CODE
     GOTO:
       
     ACTION:
       ID TID CODE -> reduce 0 0 *)
  and state_23 a0_actual a2_ID c0_producer =
    match lookahead () with
    (* Reduce *)
    | ID _ | TID _ | CODE _ ->
      let x = Actions.a23_producer a0_actual a2_ID () in
      c0_producer x
    | _ -> raise (Failure "error in state 23")

  (* ITEMS:
       productions → BAR . production productions /SEMI
       production → . producers CODE /SEMI /BAR
       producers → . producer producers /CODE
       producers → . /CODE
       producer → . ID EQ actual /ID /TID /CODE
       producer → . actual /ID /TID /CODE
       actual → . ID /ID /TID /CODE
       actual → . TID /ID /TID /CODE
     GOTO:
       ID -> 19
       TID -> 22
       production -> 25
       producers -> 27
       producer -> 29
       actual -> 31
     ACTION:
       CODE -> reduce 2 1
       ID TID -> shift *)
  and state_24 c0_productions =
    let rec c1_production x = state_25 x c0_productions
    and c2_producers x = state_27 x c1_production
    and c3_producer x = state_29 x c2_producers
    and c4_actual x = state_31 x c3_producer in
    match lookahead () with
    (* Reduce *)
    | CODE _ ->
      let x = Actions.a22_producers () in
      c2_producers x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_19 x c3_producer c4_actual
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_22 x c4_actual
    | _ -> raise (Failure "error in state 24")

  (* ITEMS:
       productions → BAR production . productions /SEMI
       productions → . BAR production productions /SEMI
       productions → . /SEMI
     GOTO:
       BAR -> 24
       productions -> 26
     ACTION:
       SEMI -> reduce 1 1
       BAR -> shift *)
  and state_25 a0_production c0_productions =
    let rec c1_productions x = state_26 x a0_production c0_productions in
    match lookahead () with
    (* Reduce *)
    | SEMI ->
      let x = Actions.a19_productions () in
      c1_productions x
    (* Shift *)
    | BAR ->
      let _ = shift () in
      state_24 c1_productions
    | _ -> raise (Failure "error in state 25")

  (* ITEMS:
       productions → BAR production productions . /SEMI
     GOTO:
       
     ACTION:
       SEMI -> reduce 0 0 *)
  and state_26 a0_productions a1_production c0_productions =
    match lookahead () with
    (* Reduce *)
    | SEMI ->
      let x = Actions.a18_productions a0_productions a1_production () in
      c0_productions x
    | _ -> raise (Failure "error in state 26")

  (* ITEMS:
       production → producers . CODE /SEMI /BAR
     GOTO:
       CODE -> 28
     ACTION:
       CODE -> shift *)
  and state_27 a0_producers c0_production =
    match lookahead () with
    (* Shift *)
    | CODE x ->
      let _ = shift () in
      state_28 x a0_producers c0_production
    | _ -> raise (Failure "error in state 27")

  (* ITEMS:
       production → producers CODE . /SEMI /BAR
     GOTO:
       
     ACTION:
       SEMI BAR -> reduce 0 0 *)
  and state_28 a0_CODE a1_producers c0_production =
    match lookahead () with
    (* Reduce *)
    | SEMI | BAR ->
      let x = Actions.a20_production a0_CODE a1_producers () in
      c0_production x
    | _ -> raise (Failure "error in state 28")

  (* ITEMS:
       producers → producer . producers /CODE
       producers → . producer producers /CODE
       producers → . /CODE
       producer → . ID EQ actual /ID /TID /CODE
       producer → . actual /ID /TID /CODE
       actual → . ID /ID /TID /CODE
       actual → . TID /ID /TID /CODE
     GOTO:
       ID -> 19
       TID -> 22
       producers -> 30
       producer -> 29
       actual -> 31
     ACTION:
       CODE -> reduce 1 1
       ID TID -> shift *)
  and state_29 a0_producer c0_producers =
    let rec c1_producers x = state_30 x a0_producer c0_producers
    and c2_producer x = state_29 x c1_producers
    and c3_actual x = state_31 x c2_producer in
    match lookahead () with
    (* Reduce *)
    | CODE _ ->
      let x = Actions.a22_producers () in
      c1_producers x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_19 x c2_producer c3_actual
    (* Shift *)
    | TID x ->
      let _ = shift () in
      state_22 x c3_actual
    | _ -> raise (Failure "error in state 29")

  (* ITEMS:
       producers → producer producers . /CODE
     GOTO:
       
     ACTION:
       CODE -> reduce 0 0 *)
  and state_30 a0_producers a1_producer c0_producers =
    match lookahead () with
    (* Reduce *)
    | CODE _ ->
      let x = Actions.a21_producers a0_producers a1_producer () in
      c0_producers x
    | _ -> raise (Failure "error in state 30")

  (* ITEMS:
       producer → actual . /ID /TID /CODE
     GOTO:
       
     ACTION:
       ID TID CODE -> reduce 0 0 *)
  and state_31 a0_actual c0_producer =
    match lookahead () with
    (* Reduce *)
    | ID _ | TID _ | CODE _ ->
      let x = Actions.a24_producer a0_actual () in
      c0_producer x
    | _ -> raise (Failure "error in state 31")

  (* ITEMS:
       rule → ID COLON rule_prods . SEMI /ID /EOF
     GOTO:
       SEMI -> 33
     ACTION:
       SEMI -> shift *)
  and state_32 a0_rule_prods a2_ID c0_rule =
    match lookahead () with
    (* Shift *)
    | SEMI ->
      let _ = shift () in
      state_33 a0_rule_prods a2_ID c0_rule
    | _ -> raise (Failure "error in state 32")

  (* ITEMS:
       rule → ID COLON rule_prods SEMI . /ID /EOF
     GOTO:
       
     ACTION:
       ID EOF -> reduce 0 0 *)
  and state_33 a1_rule_prods a3_ID c0_rule =
    match lookahead () with
    (* Reduce *)
    | ID _ | EOF ->
      let x = Actions.a15_rule a1_rule_prods a3_ID () in
      c0_rule x
    | _ -> raise (Failure "error in state 33")

  (* ITEMS:
       rule_prods → productions . /SEMI
     GOTO:
       
     ACTION:
       SEMI -> reduce 0 0 *)
  and state_34 a0_productions c0_rule_prods =
    match lookahead () with
    (* Reduce *)
    | SEMI ->
      let x = Actions.a17_rule_prods a0_productions () in
      c0_rule_prods x
    | _ -> raise (Failure "error in state 34")

  (* ITEMS:
       rule_prods → production . productions /SEMI
       productions → . BAR production productions /SEMI
       productions → . /SEMI
     GOTO:
       BAR -> 24
       productions -> 36
     ACTION:
       SEMI -> reduce 1 1
       BAR -> shift *)
  and state_35 a0_production c0_rule_prods =
    let rec c1_productions x = state_36 x a0_production c0_rule_prods in
    match lookahead () with
    (* Reduce *)
    | SEMI ->
      let x = Actions.a19_productions () in
      c1_productions x
    (* Shift *)
    | BAR ->
      let _ = shift () in
      state_24 c1_productions
    | _ -> raise (Failure "error in state 35")

  (* ITEMS:
       rule_prods → production productions . /SEMI
     GOTO:
       
     ACTION:
       SEMI -> reduce 0 0 *)
  and state_36 a0_productions a1_production c0_rule_prods =
    match lookahead () with
    (* Reduce *)
    | SEMI ->
      let x = Actions.a16_rule_prods a0_productions a1_production () in
      c0_rule_prods x
    | _ -> raise (Failure "error in state 36")

  (* ITEMS:
       grammar' → header decls DSEP rules . EOF
     GOTO:
       EOF -> 38
     ACTION:
       EOF -> shift *)
  and state_37 a0_rules a2_decls a3_header c0_grammar_starting =
    match lookahead () with
    (* Shift *)
    | EOF ->
      let _ = shift () in
      state_38 a0_rules a2_decls a3_header c0_grammar_starting
    | _ -> raise (Failure "error in state 37")

  (* ITEMS:
       grammar' → header decls DSEP rules EOF .
     GOTO:
       
     ACTION:
       -> reduce 0 0 *)
  and state_38 a1_rules a3_decls a4_header c0_grammar_starting =
    (* Reduce *)
    let x = Actions.a1_grammar a1_rules a3_decls a4_header () in
    c0_grammar_starting x

  (* ITEMS:
       rules → rule . rules /EOF
       rules → . rule rules /EOF
       rules → . /EOF
       rule → . ID COLON rule_prods SEMI /ID /EOF
     GOTO:
       ID -> 17
       rules -> 40
       rule -> 39
     ACTION:
       EOF -> reduce 1 1
       ID -> shift *)
  and state_39 a0_rule c0_rules =
    let rec c1_rules x = state_40 x a0_rule c0_rules
    and c2_rule x = state_39 x c1_rules in
    match lookahead () with
    (* Reduce *)
    | EOF ->
      let x = Actions.a14_rules () in
      c1_rules x
    (* Shift *)
    | ID x ->
      let _ = shift () in
      state_17 x c2_rule
    | _ -> raise (Failure "error in state 39")

  (* ITEMS:
       rules → rule rules . /EOF
     GOTO:
       
     ACTION:
       EOF -> reduce 0 0 *)
  and state_40 a0_rules a1_rule c0_rules =
    match lookahead () with
    (* Reduce *)
    | EOF ->
      let x = Actions.a13_rules a0_rules a1_rule () in
      c0_rules x
    | _ -> raise (Failure "error in state 40")

  (* ITEMS:
       decls → decl . decls /DSEP
       decls → . decl decls /DSEP
       decls → . /DSEP
       decl → . DTOKEN TYPE tids /DTOKEN /DSTART /DSEP
       decl → . DSTART TYPE ids /DTOKEN /DSTART /DSEP
       decl → . DTOKEN tids /DTOKEN /DSTART /DSEP
       decl → . DSTART ids /DTOKEN /DSTART /DSEP
     GOTO:
       DTOKEN -> 3
       DSTART -> 9
       decls -> 42
       decl -> 41
     ACTION:
       DSEP -> reduce 1 1
       DTOKEN DSTART -> shift *)
  and state_41 a0_decl c0_decls =
    let rec c1_decls x = state_42 x a0_decl c0_decls
    and c2_decl x = state_41 x c1_decls in
    match lookahead () with
    (* Reduce *)
    | DSEP ->
      let x = Actions.a4_decls () in
      c1_decls x
    (* Shift *)
    | DTOKEN ->
      let _ = shift () in
      state_3 c2_decl
    (* Shift *)
    | DSTART ->
      let _ = shift () in
      state_9 c2_decl
    | _ -> raise (Failure "error in state 41")

  (* ITEMS:
       decls → decl decls . /DSEP
     GOTO:
       
     ACTION:
       DSEP -> reduce 0 0 *)
  and state_42 a0_decls a1_decl c0_decls =
    match lookahead () with
    (* Reduce *)
    | DSEP ->
      let x = Actions.a3_decls a0_decls a1_decl () in
      c0_decls x
    | _ -> raise (Failure "error in state 42")
  ;;
end

let grammar lexbuf lexfun =
  States.setup lexfun lexbuf;
  States.state_0 (fun x -> x)
;;
