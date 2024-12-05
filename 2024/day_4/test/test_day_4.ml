open OUnit2
open Day_4

let test_get_line _ =
  let matrix = Matrix.build_from_string "abc\n\
                                          def\n\
                                          ghi" in

  (* Test line from (0, 0) to (0, 2): Horizontal line "abc" *)
  let expected1 = Some ['a'; 'b'; 'c'] in
  let result1 = Matrix.get_line matrix 0 0 0 2 in
  assert_equal expected1 result1;

  (* Test line from (0, 0) to (2, 0): Vertical line "adg" *)
  let expected2 = Some ['a'; 'd'; 'g'] in
  let result2 = Matrix.get_line matrix 0 0 2 0 in
  assert_equal expected2 result2;

  (* Test diagonal line from (0, 0) to (2, 2): Diagonal line "aei" *)
  let expected3 = Some ['a'; 'e'; 'i'] in
  let result3 = Matrix.get_line matrix 0 0 2 2 in
  assert_equal expected3 result3;

  (* Test line from (2, 0) to (0, 2): Diagonal line "gec" *)
  let expected4 = Some ['g'; 'e'; 'c'] in
  let result4 = Matrix.get_line matrix 2 0 0 2 in
  assert_equal expected4 result4;

  (* Test out-of-bounds line *)
  let result5 = Matrix.get_line matrix 0 0 3 3 in
  assert_equal None result5


let test_iter _ =
  let matrix = Matrix.build_from_string "abc\n\
                                          def\n\
                                          ghi" in
  let result = Array.make 9 'z' in
  let index = ref 0 in
  Matrix.iter (fun _ c -> Array.set result !index c; index:= !index + 1; ) matrix;
  assert_equal ['a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'; 'h'; 'i'] (Array.to_list result)


let suite =
  "Matrix Test Suite" >::: [
    "test_get_line" >:: test_get_line;
      "test_itter" >:: test_iter
  ]

let () =
  run_test_tt_main suite
