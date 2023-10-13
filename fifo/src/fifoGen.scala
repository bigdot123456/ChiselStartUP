package fifo
import chisel3._
import chisel3.util._
import chisel3.internal.firrtl._
import chisel3.internal.firrtl.Width
import chisel3.stage.{ChiselGeneratorAnnotation, ChiselStage}
import firrtl.options.TargetDirAnnotation
import chisel3.stage.ChiselStage.emitFirrtl

class MyFloat extends Bundle {
	val sign = Bool()
	val exponent = UInt(8.W) 
	val significand = UInt(23.W)
}

// Let's now generate modules with different widths
object MemFifoGen extends App {
  println(getVerilogString(new MemFifo(new MyFloat(),10)))
  println(getVerilogString(new MemFifo(new MyFloat(),20)))
  println(emitFirrtl(new MemFifo(new MyFloat(),10)))
}

//class MemFifo[T <: Data](gen: T, depth: Int) extends Fifo(gen: T, depth: Int) 
object MemFifoGen1 extends App {
  emitVerilog(new MemFifo(new MyFloat(), 14), Array("--target-dir", "generated"))
  //    emitVerilog(new PassthroughGenerator(args(0).toInt), Array("--target-dir", "generated"))
}
