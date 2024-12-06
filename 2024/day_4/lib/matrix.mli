type t

val create : int -> int -> char -> t
val get : t -> int -> int -> char
val set : t -> int -> int -> char -> unit
val build_from_string : string -> t
val to_string : t -> string
val print : t -> unit
val get_line : t -> int -> int -> int -> int -> char list option
val iter : (int * int -> char -> unit) -> t -> unit
