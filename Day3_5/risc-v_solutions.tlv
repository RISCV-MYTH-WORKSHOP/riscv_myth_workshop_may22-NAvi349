\m4_TLV_version 1d: tl-x.org
\SV
//RISC-V labs solutions here
   |cpu
      @0
         $reset = *reset;
      // YOUR CODE HERE
      // ...
      
         $pc[31:0] = (>>1$reset) ? 32'b0 : >>1$pc + 32'd4;
         $imem_rd_en = ~($reset);

      ?$imem_rd_en
         @1
            $imem_rd_addr[31:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
            $instr[31:0] = $imem_rd_data[31:0];
