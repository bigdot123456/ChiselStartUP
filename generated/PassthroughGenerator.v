module PassthroughGenerator(
  input         clock,
  input         reset,
  input  [13:0] io_in,
  output [13:0] io_out
);
  assign io_out = io_in; // @[PassThrough.scala 12:10]
endmodule
