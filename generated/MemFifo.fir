circuit MemFifo :
  module MemFifo :
    input clock : Clock
    input reset : UInt<1>
    output io : { flip enq : { flip ready : UInt<1>, valid : UInt<1>, bits : { sign : UInt<1>, exponent : UInt<8>, significand : UInt<23>}}, deq : { flip ready : UInt<1>, valid : UInt<1>, bits : { sign : UInt<1>, exponent : UInt<8>, significand : UInt<23>}}}

    smem mem : { sign : UInt<1>, exponent : UInt<8>, significand : UInt<23>} [14] @[MemFifo.scala 21:24]
    wire incrRead : UInt<1>
    incrRead <= UInt<1>("h0")
    wire incrWrite : UInt<1>
    incrWrite <= UInt<1>("h0")
    reg readPtr : UInt<4>, clock with :
      reset => (reset, UInt<4>("h0")) @[MemFifo.scala 13:25]
    node _nextVal_T = eq(readPtr, UInt<4>("hd")) @[MemFifo.scala 14:30]
    node _nextVal_T_1 = add(readPtr, UInt<1>("h1")) @[MemFifo.scala 14:59]
    node _nextVal_T_2 = tail(_nextVal_T_1, 1) @[MemFifo.scala 14:59]
    node nextRead = mux(_nextVal_T, UInt<1>("h0"), _nextVal_T_2) @[MemFifo.scala 14:22]
    when incrRead : @[MemFifo.scala 15:17]
      readPtr <= nextRead @[MemFifo.scala 16:14]
    reg writePtr : UInt<4>, clock with :
      reset => (reset, UInt<4>("h0")) @[MemFifo.scala 13:25]
    node _nextVal_T_3 = eq(writePtr, UInt<4>("hd")) @[MemFifo.scala 14:30]
    node _nextVal_T_4 = add(writePtr, UInt<1>("h1")) @[MemFifo.scala 14:59]
    node _nextVal_T_5 = tail(_nextVal_T_4, 1) @[MemFifo.scala 14:59]
    node nextWrite = mux(_nextVal_T_3, UInt<1>("h0"), _nextVal_T_5) @[MemFifo.scala 14:22]
    when incrWrite : @[MemFifo.scala 15:17]
      writePtr <= nextWrite @[MemFifo.scala 16:14]
    reg emptyReg : UInt<1>, clock with :
      reset => (reset, UInt<1>("h1")) @[MemFifo.scala 28:25]
    reg fullReg : UInt<1>, clock with :
      reset => (reset, UInt<1>("h0")) @[MemFifo.scala 29:24]
    reg stateReg : UInt<2>, clock with :
      reset => (reset, UInt<2>("h0")) @[MemFifo.scala 32:25]
    reg shadowReg : { sign : UInt<1>, exponent : UInt<8>, significand : UInt<23>}, clock with :
      reset => (UInt<1>("h0"), shadowReg) @[MemFifo.scala 33:22]
    node _T = eq(fullReg, UInt<1>("h0")) @[MemFifo.scala 35:25]
    node _T_1 = and(io.enq.valid, _T) @[MemFifo.scala 35:22]
    when _T_1 : @[MemFifo.scala 35:35]
      write mport MPORT = mem[writePtr], clock
      MPORT <= io.enq.bits
      emptyReg <= UInt<1>("h0") @[MemFifo.scala 37:14]
      node _fullReg_T = eq(nextWrite, readPtr) @[MemFifo.scala 38:26]
      fullReg <= _fullReg_T @[MemFifo.scala 38:13]
      incrWrite <= UInt<1>("h1") @[MemFifo.scala 39:15]
    wire _data_WIRE : UInt @[MemFifo.scala 42:22]
    _data_WIRE is invalid @[MemFifo.scala 42:22]
    when UInt<1>("h1") : @[MemFifo.scala 42:22]
      _data_WIRE <= readPtr @[MemFifo.scala 42:22]
      node _data_T = or(_data_WIRE, UInt<4>("h0")) @[MemFifo.scala 42:22]
      node _data_T_1 = bits(_data_T, 3, 0) @[MemFifo.scala 42:22]
      read mport data = mem[_data_T_1], clock @[MemFifo.scala 42:22]
    node _T_2 = eq(UInt<2>("h0"), stateReg) @[MemFifo.scala 45:20]
    when _T_2 : @[MemFifo.scala 45:20]
      node _T_3 = eq(emptyReg, UInt<1>("h0")) @[MemFifo.scala 47:12]
      when _T_3 : @[MemFifo.scala 47:23]
        stateReg <= UInt<2>("h1") @[MemFifo.scala 48:18]
        fullReg <= UInt<1>("h0") @[MemFifo.scala 49:17]
        node _emptyReg_T = eq(nextRead, writePtr) @[MemFifo.scala 50:30]
        emptyReg <= _emptyReg_T @[MemFifo.scala 50:18]
        incrRead <= UInt<1>("h1") @[MemFifo.scala 51:18]
    else :
      node _T_4 = eq(UInt<2>("h1"), stateReg) @[MemFifo.scala 45:20]
      when _T_4 : @[MemFifo.scala 45:20]
        when io.deq.ready : @[MemFifo.scala 55:26]
          node _T_5 = eq(emptyReg, UInt<1>("h0")) @[MemFifo.scala 56:14]
          when _T_5 : @[MemFifo.scala 56:25]
            stateReg <= UInt<2>("h1") @[MemFifo.scala 57:20]
            fullReg <= UInt<1>("h0") @[MemFifo.scala 58:19]
            node _emptyReg_T_1 = eq(nextRead, writePtr) @[MemFifo.scala 59:32]
            emptyReg <= _emptyReg_T_1 @[MemFifo.scala 59:20]
            incrRead <= UInt<1>("h1") @[MemFifo.scala 60:20]
          else :
            stateReg <= UInt<2>("h0") @[MemFifo.scala 62:20]
        else :
          shadowReg <= data @[MemFifo.scala 65:19]
          stateReg <= UInt<2>("h2") @[MemFifo.scala 66:18]
      else :
        node _T_6 = eq(UInt<2>("h2"), stateReg) @[MemFifo.scala 45:20]
        when _T_6 : @[MemFifo.scala 45:20]
          when io.deq.ready : @[MemFifo.scala 71:26]
            node _T_7 = eq(emptyReg, UInt<1>("h0")) @[MemFifo.scala 72:14]
            when _T_7 : @[MemFifo.scala 72:25]
              stateReg <= UInt<2>("h1") @[MemFifo.scala 73:20]
              fullReg <= UInt<1>("h0") @[MemFifo.scala 74:19]
              node _emptyReg_T_2 = eq(nextRead, writePtr) @[MemFifo.scala 75:32]
              emptyReg <= _emptyReg_T_2 @[MemFifo.scala 75:20]
              incrRead <= UInt<1>("h1") @[MemFifo.scala 76:20]
            else :
              stateReg <= UInt<2>("h0") @[MemFifo.scala 78:20]
    node _io_deq_bits_T = eq(stateReg, UInt<2>("h1")) @[MemFifo.scala 85:32]
    node _io_deq_bits_T_1 = mux(_io_deq_bits_T, data, shadowReg) @[MemFifo.scala 85:22]
    io.deq.bits <= _io_deq_bits_T_1 @[MemFifo.scala 85:15]
    node _io_enq_ready_T = eq(fullReg, UInt<1>("h0")) @[MemFifo.scala 86:19]
    io.enq.ready <= _io_enq_ready_T @[MemFifo.scala 86:16]
    node _io_deq_valid_T = eq(stateReg, UInt<2>("h1")) @[MemFifo.scala 87:28]
    node _io_deq_valid_T_1 = eq(stateReg, UInt<2>("h2")) @[MemFifo.scala 87:50]
    node _io_deq_valid_T_2 = or(_io_deq_valid_T, _io_deq_valid_T_1) @[MemFifo.scala 87:38]
    io.deq.valid <= _io_deq_valid_T_2 @[MemFifo.scala 87:16]

