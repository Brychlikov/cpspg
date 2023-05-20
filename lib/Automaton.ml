module Terminal : sig
  type t

  val compare : t -> t -> int
  val of_int : int -> t
  val to_int : t -> int
end = struct
  type t = int

  let compare = ( - )
  let of_int x = x
  let to_int x = x
end

module Nonterminal : sig
  type t

  val compare : t -> t -> int
  val of_int : int -> t
  val to_int : t -> int
end = struct
  type t = int

  let compare = ( - )
  let of_int x = x
  let to_int x = x
end

module Symbol = struct
  type t =
    | Term of Terminal.t
    | NTerm of Nonterminal.t

  let compare : t -> t -> int = compare
end

module First = struct
  type t =
    | Term of Terminal.t
    | Empty

  let compare : t -> t -> int = compare

  let to_terminal = function
    | Term t -> Some t
    | _ -> None
  ;;
end

module Follow = struct
  type t =
    | Term of Terminal.t
    | End

  let compare : t -> t -> int = compare

  let to_terminal = function
    | Term t -> Some t
    | _ -> None
  ;;
end

module FirstSet = struct
  include Set.Make (First)

  let of_terminal_seq seq = Seq.map (fun t -> First.Term t) seq |> of_seq
  let to_terminal_seq set = to_seq set |> Seq.filter_map First.to_terminal
end

module FollowSet = struct
  include Set.Make (Follow)

  let of_terminal_seq seq = Seq.map (fun t -> Follow.Term t) seq |> of_seq
  let to_terminal_seq set = to_seq set |> Seq.filter_map Follow.to_terminal
end

module SymbolMap = Map.Make (Symbol)
module IntMap = Map.Make (Int)

type symbol = Symbol.t =
  | Term of Terminal.t
  | NTerm of Nonterminal.t

(** Suffix of LR(0)/LR(1) *)
type item =
  { i_suffix : symbol list
  ; i_action : int (** Production/semantic action id *)
  }

(** Group of LR(0)/LR(1) items with common nonterminal and prefix.
    INVARIANT: Items are sorted bu suffix lenght in increasing order. *)
type group =
  { g_symbol : Nonterminal.t (** Nonterminal. *)
  ; g_prefix : symbol list (** Prefix common to all items in this group. *)
  ; g_items : item list (** Items. *)
  ; g_lookahead : FollowSet.t (** Lookahead symbols. Empty for LR(0) group. *)
  ; g_starting : bool (** Whether symbol is a starting symbol from augmented grammar. *)
  }

type semantic_action =
  { sa_symbol : Nonterminal.t
  ; sa_index : int
  ; sa_args : string option list
  ; sa_code : string
  }

type action =
  | Shift (** Eat one temrinal from input. *)
  | Reduce of (int * int) (** `Reduce (i, j)` - reduce j-th item from i-th group. *)

(** LR(0)/LR(1) state. 
    INVARIANT: groups are sorted by prefix length, in descending order. *)
type state =
  { s_kernel : group list
      (** Item groups, sorted descending by prefix length, and then alphabetically. *)
  ; s_closure : group list
      (** Additional item groups added by CLOSURE, not present in kernel *)
  ; s_goto : int SymbolMap.t (** Successors *)
  ; s_action : (FollowSet.t * action) list
      (** Map from lookahead terminal symbol to
          the corresponding parsing decision. *)
  }

type term_info =
  { ti_name : string
  ; ti_ty : string option
  }

type nterm_info =
  { ni_name : string
  ; ni_starting : bool
  }

type t =
  { a_header : string
  ; a_actions : semantic_action IntMap.t
  ; a_states : state IntMap.t
  ; a_starting : (Nonterminal.t * int) list
  }

let equal_groups a b =
  { a with g_lookahead = FollowSet.empty } = { b with g_lookahead = FollowSet.empty }
  && FollowSet.equal a.g_lookahead b.g_lookahead
;;

let equal_states a b =
  { a with s_kernel = [] } = { b with s_kernel = [] }
  && List.equal equal_groups a.s_kernel b.s_kernel
;;

let merge_groups a b =
  let empty = FollowSet.empty in
  assert ({ a with g_lookahead = empty } = { b with g_lookahead = empty });
  { a with g_lookahead = FollowSet.union a.g_lookahead b.g_lookahead }
;;

let merge_states a b =
  let merge_shift _ a b =
    assert (a = b);
    Some a
  in
  { s_kernel = List.map2 merge_groups a.s_kernel b.s_kernel
  ; s_closure = List.map2 merge_groups a.s_closure b.s_closure
  ; s_goto = SymbolMap.union merge_shift a.s_goto b.s_goto
  ; s_action = []
  }
;;

let shifts_item symbol = function
  | { i_suffix = sym :: _; _ } when sym = symbol -> true
  | _ -> false
;;

let shifts_group symbol group = List.exists (shifts_item symbol) group.g_items

let shift_item symbol item =
  match item.i_suffix with
  | sym :: suffix when sym = symbol -> Some { item with i_suffix = suffix }
  | _ -> None
;;

let shift_group symbol group =
  match List.filter_map (shift_item symbol) group.g_items with
  | [] -> None
  | items -> Some { group with g_items = items; g_prefix = symbol :: group.g_prefix }
;;

let shift_state symbol state =
  match List.filter_map (shift_group symbol) (state.s_kernel @ state.s_closure) with
  | [] -> None
  | kernel ->
    Some { s_kernel = kernel; s_closure = []; s_goto = SymbolMap.empty; s_action = [] }
;;

let item_of_starting_symbol symbol = { i_suffix = [ NTerm symbol ]; i_action = 0 }

let group_of_starting_symbol symbol =
  let g_items = [ item_of_starting_symbol symbol ]
  and g_lookahead = FollowSet.singleton Follow.End in
  { g_symbol = symbol; g_prefix = []; g_items; g_lookahead; g_starting = true }
;;

let state_of_starting_symbol symbol =
  let kernel = [ group_of_starting_symbol symbol ] in
  { s_kernel = kernel; s_closure = []; s_goto = SymbolMap.empty; s_action = [] }
;;