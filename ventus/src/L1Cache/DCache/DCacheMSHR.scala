/*
 * Copyright (c) 2021-2022 International Innovation Center of Tsinghua University, Shanghai
 * Ventus is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 * See the Mulan PSL v2 for more details. */
package L1Cache.DCache

import L1Cache.{HasL1CacheParameters, L1CacheModule, getEntryStatus}
import chisel3._
import chisel3.util._
import config.config.Parameters

trait MSHRParameters{
  def bABits: Int// = tagIdxBits+SetIdxBits   // search in this module for abbreviation meaning
  def tIBits: Int// = widBits+blockOffsetBits+wordOffsetBits
}

trait HasMshrParameters extends HasL1CacheParameters{

}
//abstract class MSHRBundle extends Bundle with L1CacheParameters

class MSHRmissReq(val bABits: Int, val tIWdith: Int, val WIdBits: Int) extends Bundle {// Use this bundle when handle miss issued from pipeline
  val blockAddr = UInt(bABits.W)
  val instrId = UInt(WIdBits.W)
  val targetInfo = UInt(tIWdith.W)
}
class MSHRmissRspIn(val bABits: Int) extends Bundle {//Use this bundle when a block return from Lower cache
  val blockAddr = UInt(bABits.W)
}
class MSHRmissRspOut[T <: Data](val bABits: Int, val tIWdith: Int, val WIdBits: Int) extends Bundle {//Use this bundle when a block return from Lower cache
  val targetInfo = UInt(tIWdith.W)
  val blockAddr = UInt(bABits.W)
  val instrId = UInt(WIdBits.W)
  //val burst = Bool()//This bit indicate the Rsp transaction comes from subentry
  //val last = Bool()
}
class MSHRmiss2mem(val bABits: Int, val WIdBits: Int) extends Bundle {//Use this bundle when a block return from Lower cache
  val blockAddr = UInt(bABits.W)
  val instrId = UInt(WIdBits.W)
}
/*class MSHRmiss2Mem(val bAWidth: Int) extends Bundle{
  val blockAddr = UInt(bAWidth.W)
}*/

class MSHR[T <: Data](val tIgen: T)(implicit val p: Parameters) extends L1CacheModule{
  //TODO parameterization method need improvement
  val tIWidth = tIgen.getWidth
  val io = IO(new Bundle{
    val missReq = Flipped(Decoupled(new MSHRmissReq(bABits,tIWidth,WIdBits)))
    val missRspIn = Flipped(Decoupled(new MSHRmissRspIn(bABits)))
    val missRspOut = Decoupled(new MSHRmissRspOut(bABits,tIWidth,WIdBits))
    val miss2mem = Decoupled(new MSHRmiss2mem(bABits,WIdBits))
  })
  // head of entry, for comparison
  val blockAddr_Access = RegInit(VecInit(Seq.fill(NMshrEntry)(0.U(bABits.W))))
  val instrId_Access = RegInit(VecInit(Seq.fill(NMshrEntry)(VecInit(Seq.fill(NMshrSubEntry)(0.U(WIdBits.W))))))
  val targetInfo_Accesss = RegInit(VecInit(Seq.fill(NMshrEntry)(VecInit(Seq.fill(NMshrSubEntry)(0.U(tIWidth.W))))))

  //def tI_setIdxBits = log2Up(NMshrEntry*NMshrSubEntry)
  /*Structure Diagram
  * bA  : blockAddr
  * tI  : targetInfo
  * e_v : entry_valid, which is the first column of s_v
  * s_v : subentry_valid
  * h_s : has_send2mem
  *
  * reg   +reg   +reg        || syncSRAM + reg array
  * h_s(0)+s_v(0)+bA#0       || tI#0 | s_v(1)+tI#1 | ... | s_v(n)+tI#NMshrSubEntry
  * h_s(1)+s_v(1)+bA#1       || tI#0 | s_v(1)+tI#1 | ... | s_v(n)+tI#NMshrSubEntry
  * .
  * .
  * .
  * h_s(n)+s_v(n)+bA#NMshrEntry  || tI#0 | s_v(1)+tI#1 | ... | s_v(n)+tI#NMshrSubEntry
  * */

  //  ******     decide selected subentries are full or not     ******
  val entryMatchMissRsp = Wire(UInt(NMshrEntry.W))
  val entryMatchMissReq = Wire(UInt(NMshrEntry.W))
  val subentry_valid = RegInit(VecInit(Seq.fill(NMshrEntry)(VecInit(Seq.fill(NMshrSubEntry)(0.U(1.W))))))
  val subentry_selected = subentry_valid(OHToUInt(entryMatchMissRsp))
  val subentryStatus = Module(new getEntryStatus(NMshrSubEntry))// Output: alm_full, full, next
  subentryStatus.io.valid_list := Reverse(Cat(subentry_selected))
  val subentry_next2cancel = Wire(UInt(log2Up(NMshrSubEntry).W))
  subentry_next2cancel := subentry_selected.indexWhere(_===true.B)

  //  ******     decide MSHR is full or not     ******
  val entry_valid = Reverse(Cat(subentry_valid.map(Cat(_).orR)))
  val entryStatus = Module(new getEntryStatus(NMshrEntry))
  entryStatus.io.valid_list := entry_valid

  val missRspBusy = RegInit(false.B)//missRspIn_fire || (!io.missRsp.blockAddr.ready)

  val firedRspInBlockAddr = RegEnable(io.missRspIn.bits.blockAddr,io.missRspIn.fire())
  val muxedRspInBlockAddr = Mux(missRspBusy,firedRspInBlockAddr,io.missRspIn.bits.blockAddr)//存在多subentry时使用寄存的值
  entryMatchMissRsp := Reverse(Cat(blockAddr_Access.map(_===muxedRspInBlockAddr))) & entry_valid
  assert(PopCount(entryMatchMissRsp) <= 1.U)
  entryMatchMissReq := Reverse(Cat(blockAddr_Access.map(_===io.missReq.bits.blockAddr))) & entry_valid
  assert(PopCount(entryMatchMissReq) <= 1.U)
  //  ******     decide a primary miss or a secondary miss     ******
  val secondary_miss = entryMatchMissReq.orR
  val primary_miss = !secondary_miss

  //  ******     update MSHR when missReq     ******
  io.missReq.ready := !(((entryStatus.io.full || missRspBusy || io.missRspIn.valid) && primary_miss) ||
    (subentryStatus.io.full && secondary_miss))
  //missRsp + secondary miss holding at st1 should be accept
  //Priority: secondary missReq > missRspIn > primary missReq?
  //20220214 move missRspIn.valid into primary_miss
  val missReq_fire = io.missReq.fire()
  val real_SRAMAddrUp = Mux(secondary_miss,OHToUInt(entryMatchMissReq),entryStatus.io.next)
  val real_SRAMAddrDown = Mux(secondary_miss,subentryStatus.io.next,0.U)
  when (missReq_fire){
    targetInfo_Accesss(real_SRAMAddrUp)(real_SRAMAddrDown) := io.missReq.bits.targetInfo
  }


  //  ******      when missRsp    ******
  // priority: missRspIn > missReq
  //io.missRspOut.bits.busy := missRsp_busy
  //io.missRspOut.bits.burst := subentryStatus.io.used >= 2.U
  //io.missRspOut.bits.last := (missRsp_busy || missRspIn_fire) && subentryStatus.io.used === 1.U && io.missRspOut.ready
  assert(!io.missRspIn.fire || (io.missRspIn.fire && subentryStatus.io.used >= 1.U))
  when(io.missRspIn.fire && (subentryStatus.io.used =/= 1.U || !io.missRspOut.ready)){
    missRspBusy := true.B
  }.elsewhen(missRspBusy && subentryStatus.io.used === 1.U && io.missRspOut.ready){
    missRspBusy := false.B
  }
  io.missRspIn.ready := !missRspBusy && io.missRspOut.ready// | (subentryStatus.io.used === 1.U && io.missRspOut.fire())
  // cond after OR is a comb bypass for last cycle
  io.missRspOut.bits.targetInfo := targetInfo_Accesss(OHToUInt(entryMatchMissRsp))(subentry_next2cancel)
  io.missRspOut.bits.blockAddr := blockAddr_Access(OHToUInt(entryMatchMissRsp))
  val rInstrId = Wire(UInt(WIdBits.W))
  io.missRspOut.bits.instrId := rInstrId
  io.missRspOut.valid := io.missRspIn.valid || missRspBusy

  //  ******     maintain subentries    ******
  for (iofEn <- 0 until NMshrEntry){
    for (iofSubEn <- 0 until NMshrSubEntry){
      when(iofEn.asUInt===entryStatus.io.next &&
        iofSubEn.asUInt===0.U && missReq_fire && primary_miss){
        subentry_valid(iofEn)(iofSubEn) := true.B
      }.elsewhen(iofEn.asUInt===OHToUInt(entryMatchMissRsp)){
        when(iofSubEn.asUInt===subentry_next2cancel &&
          io.missRspOut.fire()){
          subentry_valid(iofEn)(iofSubEn) := false.B
        }.elsewhen(iofSubEn.asUInt===subentryStatus.io.next &&
          missReq_fire && secondary_miss){
          subentry_valid(iofEn)(iofSubEn) := true.B
        }
      }//order of when & elsewhen matters, as elsewhen cover some cases of when, but no op to them
    }
  }
  //original style can't modify 2 valid simultaneously
  when(missReq_fire && secondary_miss){
    instrId_Access(OHToUInt(entryMatchMissReq))(subentryStatus.io.next) := io.missReq.bits.instrId
  }.elsewhen(missReq_fire && primary_miss){
    blockAddr_Access(entryStatus.io.next) := io.missReq.bits.blockAddr
    instrId_Access(entryStatus.io.next)(0.U) := io.missReq.bits.instrId
  }

  //  ******      handle miss to lower mem    ******
  val has_send2mem = RegInit(VecInit(Seq.fill(NMshrEntry)(0.U(1.W))))
  val hasSendStatus = Module(new getEntryStatus(NMshrEntry))
  hasSendStatus.io.valid_list := Reverse(Cat(has_send2mem))
  io.miss2mem.valid := !has_send2mem(hasSendStatus.io.next) && entry_valid(hasSendStatus.io.next)
  val miss2mem_fire = io.miss2mem.valid && io.miss2mem.ready

  for (i <- 0 to NMshrEntry){
    when(miss2mem_fire && i.U === hasSendStatus.io.next){
      has_send2mem(i.U) := true.B
    }.elsewhen(io.missRspOut.fire() && subentryStatus.io.used===1.U && i.U === OHToUInt(entryMatchMissRsp)){
      has_send2mem(i.U) := false.B//missRsp, L2 to core
    }
  }
  rInstrId := instrId_Access(Mux(missRspBusy || io.missRspIn.valid,
    OHToUInt(entryMatchMissRsp),hasSendStatus.io.next))(Mux(missRspBusy || io.missRspIn.valid,subentry_next2cancel,0.U))
  io.miss2mem.bits.blockAddr := blockAddr_Access(hasSendStatus.io.next)
  io.miss2mem.bits.instrId := rInstrId
}
