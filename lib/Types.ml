type kind =
  | LR0
  | SLR
  | LR1
  | LALR

module IntMap = Map.Make (Int)

module type Logger = sig
  (* Warning and error reporting *)
  val report_err : ?loc:Automaton.span -> ('a, Format.formatter, unit) format -> 'a
  val report_warn : ?loc:Automaton.span -> ('a, Format.formatter, unit) format -> 'a
  val report_conflict : int -> Automaton.Terminal.t -> Automaton.action list -> unit
end

module type BackendSettings = sig
  include Logger

  val debug : string
  val kind : kind
end

module type BackEndSettings = sig
  include Logger

  val debug : string
  val locations : bool
  val compat : bool
  val line_directives : bool
  val comments : bool
  val readable_ids : bool

  (* Output *)
  val name : string
  val out : out_channel
end

module type Raw = sig
  val raw : Raw.t
end

module type Grammar = sig
  val header : string Automaton.node list
  val term : Automaton.Terminal.t -> Automaton.term_info
  val nterm : Automaton.Nonterminal.t -> Automaton.nterm_info
  val group : Automaton.Nonterminal.t -> Automaton.group
  val symbols : Automaton.symbol list
  val actions : Automaton.semantic_action IntMap.t
end

module type Automaton = sig
  val automaton : Automaton.t
end

module type Code = sig
  val write : unit -> unit
end
