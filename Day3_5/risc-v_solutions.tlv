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
      
      @1
      ?$imem_rd_en
         @1
            $imem_rd_addr[31:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
      
      @1   
         $instr[31:0] = $imem_rd_data[31:0];
         
         //decode (IRSBJU)
         // i - type (immediate)
         $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                       $instr[6:2] ==? 5'b001x0 ||
                       $instr[6:2] === 5'b11001;
         
         // r - type (register type)
         $is_r_instr = $instr[6:2] == 5'b01011 ||
                      $instr[6:2] ==? 5'b011x0 ||
                      $instr[6:2] === 5'b10100;
         
         // s - type (store)
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         
         // b - type (branch-type)
         $is_b_instr = $instr[6:2] === 5'b11000;
         
         // j - type (jump instructions)
         $is_j_instr = $instr[6:2] === 5'b11011;
         
         // u - type (upper immediate)
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
