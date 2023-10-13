module MemFifo(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input         io_enq_bits_sign,
  input  [7:0]  io_enq_bits_exponent,
  input  [22:0] io_enq_bits_significand,
  input         io_deq_ready,
  output        io_deq_valid,
  output        io_deq_bits_sign,
  output [7:0]  io_deq_bits_exponent,
  output [22:0] io_deq_bits_significand
);
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_9;
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_8;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
`endif // RANDOMIZE_REG_INIT
  reg  mem_sign [0:13]; // @[MemFifo.scala 21:24]
  wire  mem_sign_data_en; // @[MemFifo.scala 21:24]
  wire [3:0] mem_sign_data_addr; // @[MemFifo.scala 21:24]
  wire  mem_sign_data_data; // @[MemFifo.scala 21:24]
  wire  mem_sign_MPORT_data; // @[MemFifo.scala 21:24]
  wire [3:0] mem_sign_MPORT_addr; // @[MemFifo.scala 21:24]
  wire  mem_sign_MPORT_mask; // @[MemFifo.scala 21:24]
  wire  mem_sign_MPORT_en; // @[MemFifo.scala 21:24]
  reg  mem_sign_data_en_pipe_0;
  reg [3:0] mem_sign_data_addr_pipe_0;
  reg [7:0] mem_exponent [0:13]; // @[MemFifo.scala 21:24]
  wire  mem_exponent_data_en; // @[MemFifo.scala 21:24]
  wire [3:0] mem_exponent_data_addr; // @[MemFifo.scala 21:24]
  wire [7:0] mem_exponent_data_data; // @[MemFifo.scala 21:24]
  wire [7:0] mem_exponent_MPORT_data; // @[MemFifo.scala 21:24]
  wire [3:0] mem_exponent_MPORT_addr; // @[MemFifo.scala 21:24]
  wire  mem_exponent_MPORT_mask; // @[MemFifo.scala 21:24]
  wire  mem_exponent_MPORT_en; // @[MemFifo.scala 21:24]
  reg  mem_exponent_data_en_pipe_0;
  reg [3:0] mem_exponent_data_addr_pipe_0;
  reg [22:0] mem_significand [0:13]; // @[MemFifo.scala 21:24]
  wire  mem_significand_data_en; // @[MemFifo.scala 21:24]
  wire [3:0] mem_significand_data_addr; // @[MemFifo.scala 21:24]
  wire [22:0] mem_significand_data_data; // @[MemFifo.scala 21:24]
  wire [22:0] mem_significand_MPORT_data; // @[MemFifo.scala 21:24]
  wire [3:0] mem_significand_MPORT_addr; // @[MemFifo.scala 21:24]
  wire  mem_significand_MPORT_mask; // @[MemFifo.scala 21:24]
  wire  mem_significand_MPORT_en; // @[MemFifo.scala 21:24]
  reg  mem_significand_data_en_pipe_0;
  reg [3:0] mem_significand_data_addr_pipe_0;
  reg [3:0] readPtr; // @[MemFifo.scala 13:25]
  wire [3:0] _nextVal_T_2 = readPtr + 4'h1; // @[MemFifo.scala 14:59]
  wire [3:0] nextRead = readPtr == 4'hd ? 4'h0 : _nextVal_T_2; // @[MemFifo.scala 14:22]
  reg [1:0] stateReg; // @[MemFifo.scala 32:25]
  reg  emptyReg; // @[MemFifo.scala 28:25]
  wire  _T_3 = ~emptyReg; // @[MemFifo.scala 47:12]
  wire  _GEN_26 = io_deq_ready & _T_3; // @[MemFifo.scala 55:26]
  wire  _GEN_45 = 2'h1 == stateReg ? _GEN_26 : 2'h2 == stateReg & _GEN_26; // @[MemFifo.scala 45:20]
  wire  incrRead = 2'h0 == stateReg ? _T_3 : _GEN_45; // @[MemFifo.scala 45:20]
  reg [3:0] writePtr; // @[MemFifo.scala 13:25]
  wire [3:0] _nextVal_T_5 = writePtr + 4'h1; // @[MemFifo.scala 14:59]
  wire [3:0] nextWrite = writePtr == 4'hd ? 4'h0 : _nextVal_T_5; // @[MemFifo.scala 14:22]
  reg  fullReg; // @[MemFifo.scala 29:24]
  wire  _T = ~fullReg; // @[MemFifo.scala 35:25]
  wire  incrWrite = io_enq_valid & ~fullReg; // @[MemFifo.scala 35:22]
  reg  shadowReg_sign; // @[MemFifo.scala 33:22]
  reg [7:0] shadowReg_exponent; // @[MemFifo.scala 33:22]
  reg [22:0] shadowReg_significand; // @[MemFifo.scala 33:22]
  wire  _GEN_9 = incrWrite ? 1'h0 : emptyReg; // @[MemFifo.scala 35:35 37:14 28:25]
  wire  _GEN_10 = incrWrite ? nextWrite == readPtr : fullReg; // @[MemFifo.scala 35:35 38:13 29:24]
  wire  _GEN_16 = ~emptyReg ? 1'h0 : _GEN_10; // @[MemFifo.scala 47:23 49:17]
  wire  _GEN_17 = ~emptyReg ? nextRead == writePtr : _GEN_9; // @[MemFifo.scala 47:23 50:18]
  wire [1:0] _GEN_19 = _T_3 ? 2'h1 : 2'h0; // @[MemFifo.scala 56:25 57:20 62:20]
  wire  _GEN_24 = io_deq_ready ? _GEN_16 : _GEN_10; // @[MemFifo.scala 55:26]
  wire  _GEN_25 = io_deq_ready ? _GEN_17 : _GEN_9; // @[MemFifo.scala 55:26]
  wire [1:0] _GEN_34 = io_deq_ready ? _GEN_19 : stateReg; // @[MemFifo.scala 32:25 71:26]
  wire  _GEN_40 = 2'h2 == stateReg ? _GEN_25 : _GEN_9; // @[MemFifo.scala 45:20]
  wire  _GEN_44 = 2'h1 == stateReg ? _GEN_25 : _GEN_40; // @[MemFifo.scala 45:20]
  wire  _GEN_51 = 2'h0 == stateReg ? _GEN_17 : _GEN_44; // @[MemFifo.scala 45:20]
  wire  _io_deq_bits_T = stateReg == 2'h1; // @[MemFifo.scala 85:32]
  assign mem_sign_data_en = mem_sign_data_en_pipe_0;
  assign mem_sign_data_addr = mem_sign_data_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_sign_data_data = mem_sign[mem_sign_data_addr]; // @[MemFifo.scala 21:24]
  `else
  assign mem_sign_data_data = mem_sign_data_addr >= 4'he ? _RAND_1[0:0] : mem_sign[mem_sign_data_addr]; // @[MemFifo.scala 21:24]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_sign_MPORT_data = io_enq_bits_sign;
  assign mem_sign_MPORT_addr = writePtr;
  assign mem_sign_MPORT_mask = 1'h1;
  assign mem_sign_MPORT_en = io_enq_valid & _T;
  assign mem_exponent_data_en = mem_exponent_data_en_pipe_0;
  assign mem_exponent_data_addr = mem_exponent_data_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_exponent_data_data = mem_exponent[mem_exponent_data_addr]; // @[MemFifo.scala 21:24]
  `else
  assign mem_exponent_data_data = mem_exponent_data_addr >= 4'he ? _RAND_5[7:0] : mem_exponent[mem_exponent_data_addr]; // @[MemFifo.scala 21:24]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_exponent_MPORT_data = io_enq_bits_exponent;
  assign mem_exponent_MPORT_addr = writePtr;
  assign mem_exponent_MPORT_mask = 1'h1;
  assign mem_exponent_MPORT_en = io_enq_valid & _T;
  assign mem_significand_data_en = mem_significand_data_en_pipe_0;
  assign mem_significand_data_addr = mem_significand_data_addr_pipe_0;
  `ifndef RANDOMIZE_GARBAGE_ASSIGN
  assign mem_significand_data_data = mem_significand[mem_significand_data_addr]; // @[MemFifo.scala 21:24]
  `else
  assign mem_significand_data_data = mem_significand_data_addr >= 4'he ? _RAND_9[22:0] :
    mem_significand[mem_significand_data_addr]; // @[MemFifo.scala 21:24]
  `endif // RANDOMIZE_GARBAGE_ASSIGN
  assign mem_significand_MPORT_data = io_enq_bits_significand;
  assign mem_significand_MPORT_addr = writePtr;
  assign mem_significand_MPORT_mask = 1'h1;
  assign mem_significand_MPORT_en = io_enq_valid & _T;
  assign io_enq_ready = ~fullReg; // @[MemFifo.scala 86:19]
  assign io_deq_valid = _io_deq_bits_T | stateReg == 2'h2; // @[MemFifo.scala 87:38]
  assign io_deq_bits_sign = stateReg == 2'h1 ? mem_sign_data_data : shadowReg_sign; // @[MemFifo.scala 85:22]
  assign io_deq_bits_exponent = stateReg == 2'h1 ? mem_exponent_data_data : shadowReg_exponent; // @[MemFifo.scala 85:22]
  assign io_deq_bits_significand = stateReg == 2'h1 ? mem_significand_data_data : shadowReg_significand; // @[MemFifo.scala 85:22]
  always @(posedge clock) begin
    if (mem_sign_MPORT_en & mem_sign_MPORT_mask) begin
      mem_sign[mem_sign_MPORT_addr] <= mem_sign_MPORT_data; // @[MemFifo.scala 21:24]
    end
    mem_sign_data_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mem_sign_data_addr_pipe_0 <= readPtr;
    end
    if (mem_exponent_MPORT_en & mem_exponent_MPORT_mask) begin
      mem_exponent[mem_exponent_MPORT_addr] <= mem_exponent_MPORT_data; // @[MemFifo.scala 21:24]
    end
    mem_exponent_data_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mem_exponent_data_addr_pipe_0 <= readPtr;
    end
    if (mem_significand_MPORT_en & mem_significand_MPORT_mask) begin
      mem_significand[mem_significand_MPORT_addr] <= mem_significand_MPORT_data; // @[MemFifo.scala 21:24]
    end
    mem_significand_data_en_pipe_0 <= 1'h1;
    if (1'h1) begin
      mem_significand_data_addr_pipe_0 <= readPtr;
    end
    if (reset) begin // @[MemFifo.scala 13:25]
      readPtr <= 4'h0; // @[MemFifo.scala 13:25]
    end else if (incrRead) begin // @[MemFifo.scala 15:17]
      if (readPtr == 4'hd) begin // @[MemFifo.scala 14:22]
        readPtr <= 4'h0;
      end else begin
        readPtr <= _nextVal_T_2;
      end
    end
    if (reset) begin // @[MemFifo.scala 32:25]
      stateReg <= 2'h0; // @[MemFifo.scala 32:25]
    end else if (2'h0 == stateReg) begin // @[MemFifo.scala 45:20]
      if (~emptyReg) begin // @[MemFifo.scala 47:23]
        stateReg <= 2'h1; // @[MemFifo.scala 48:18]
      end
    end else if (2'h1 == stateReg) begin // @[MemFifo.scala 45:20]
      if (io_deq_ready) begin // @[MemFifo.scala 55:26]
        stateReg <= _GEN_19;
      end else begin
        stateReg <= 2'h2; // @[MemFifo.scala 66:18]
      end
    end else if (2'h2 == stateReg) begin // @[MemFifo.scala 45:20]
      stateReg <= _GEN_34;
    end
    emptyReg <= reset | _GEN_51; // @[MemFifo.scala 28:{25,25}]
    if (reset) begin // @[MemFifo.scala 13:25]
      writePtr <= 4'h0; // @[MemFifo.scala 13:25]
    end else if (incrWrite) begin // @[MemFifo.scala 15:17]
      if (writePtr == 4'hd) begin // @[MemFifo.scala 14:22]
        writePtr <= 4'h0;
      end else begin
        writePtr <= _nextVal_T_5;
      end
    end
    if (reset) begin // @[MemFifo.scala 29:24]
      fullReg <= 1'h0; // @[MemFifo.scala 29:24]
    end else if (2'h0 == stateReg) begin // @[MemFifo.scala 45:20]
      fullReg <= _GEN_16;
    end else if (2'h1 == stateReg) begin // @[MemFifo.scala 45:20]
      fullReg <= _GEN_24;
    end else if (2'h2 == stateReg) begin // @[MemFifo.scala 45:20]
      fullReg <= _GEN_24;
    end else begin
      fullReg <= _GEN_10;
    end
    if (!(2'h0 == stateReg)) begin // @[MemFifo.scala 45:20]
      if (2'h1 == stateReg) begin // @[MemFifo.scala 45:20]
        if (!(io_deq_ready)) begin // @[MemFifo.scala 55:26]
          shadowReg_sign <= mem_sign_data_data; // @[MemFifo.scala 65:19]
        end
      end
    end
    if (!(2'h0 == stateReg)) begin // @[MemFifo.scala 45:20]
      if (2'h1 == stateReg) begin // @[MemFifo.scala 45:20]
        if (!(io_deq_ready)) begin // @[MemFifo.scala 55:26]
          shadowReg_exponent <= mem_exponent_data_data; // @[MemFifo.scala 65:19]
        end
      end
    end
    if (!(2'h0 == stateReg)) begin // @[MemFifo.scala 45:20]
      if (2'h1 == stateReg) begin // @[MemFifo.scala 45:20]
        if (!(io_deq_ready)) begin // @[MemFifo.scala 55:26]
          shadowReg_significand <= mem_significand_data_data; // @[MemFifo.scala 65:19]
        end
      end
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_GARBAGE_ASSIGN
  _RAND_1 = {1{`RANDOM}};
  _RAND_5 = {1{`RANDOM}};
  _RAND_9 = {1{`RANDOM}};
`endif // RANDOMIZE_GARBAGE_ASSIGN
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {1{`RANDOM}};
  for (initvar = 0; initvar < 14; initvar = initvar+1)
    mem_sign[initvar] = _RAND_0[0:0];
  _RAND_4 = {1{`RANDOM}};
  for (initvar = 0; initvar < 14; initvar = initvar+1)
    mem_exponent[initvar] = _RAND_4[7:0];
  _RAND_8 = {1{`RANDOM}};
  for (initvar = 0; initvar < 14; initvar = initvar+1)
    mem_significand[initvar] = _RAND_8[22:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  mem_sign_data_en_pipe_0 = _RAND_2[0:0];
  _RAND_3 = {1{`RANDOM}};
  mem_sign_data_addr_pipe_0 = _RAND_3[3:0];
  _RAND_6 = {1{`RANDOM}};
  mem_exponent_data_en_pipe_0 = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  mem_exponent_data_addr_pipe_0 = _RAND_7[3:0];
  _RAND_10 = {1{`RANDOM}};
  mem_significand_data_en_pipe_0 = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  mem_significand_data_addr_pipe_0 = _RAND_11[3:0];
  _RAND_12 = {1{`RANDOM}};
  readPtr = _RAND_12[3:0];
  _RAND_13 = {1{`RANDOM}};
  stateReg = _RAND_13[1:0];
  _RAND_14 = {1{`RANDOM}};
  emptyReg = _RAND_14[0:0];
  _RAND_15 = {1{`RANDOM}};
  writePtr = _RAND_15[3:0];
  _RAND_16 = {1{`RANDOM}};
  fullReg = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  shadowReg_sign = _RAND_17[0:0];
  _RAND_18 = {1{`RANDOM}};
  shadowReg_exponent = _RAND_18[7:0];
  _RAND_19 = {1{`RANDOM}};
  shadowReg_significand = _RAND_19[22:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
