type t
type space

val create : int -> int -> space -> t
val get : t -> int -> int -> space
val set : t -> int -> int -> space -> unit
val build_from_string : string -> t
val to_string : t -> string
val print : t -> unit
val get_line : t -> int -> int -> int -> int -> space list option
val iter : (int * int -> space -> unit) -> t -> unit
val manhattan_distance : int * int -> int * int -> int
val deep_copy : t -> t
val find_antennas : t -> (char * (int * int)) list

exception Off_the_grid
