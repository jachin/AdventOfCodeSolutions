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
val find_guard : t -> ((int * int) * space) option
val generate_next_matrix : t -> (t * (int * int)) option

val generate_next_matrix_2 :
  t -> ((int * int) * space) option -> t * ((int * int) * space)

val deep_copy : t -> t
val copy_and_obstruct : t -> int * int -> t

exception Off_the_grid
