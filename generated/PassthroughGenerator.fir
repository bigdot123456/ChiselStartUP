circuit PassthroughGenerator :
  module PassthroughGenerator :
    input clock : Clock
    input reset : UInt<1>
    output io : { flip in : UInt<14>, out : UInt<14>}

    io.out <= io.in @[PassThrough.scala 12:10]

