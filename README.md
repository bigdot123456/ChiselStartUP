# Startup from Ventus(承影) GPGPU

Here we use ventus GPU as a train point.
when use this repository, first run cmd is as following:
```
make bsp
make idea
mill resolve _
mill fifo.runMain fifo.memFifoGen

```

mill version should be 0.10.8

- Ubuntu  
```shell
apt-get install make parallel wget cmake verilator git llvm clang lld protobuf-compiler antlr4 numactl
curl -L https://github.com/com-lihaoyi/mill/releases/download/0.10.8/0.10.8 > mill && chmod +x mill
```

```shell
make init
make patch
```



