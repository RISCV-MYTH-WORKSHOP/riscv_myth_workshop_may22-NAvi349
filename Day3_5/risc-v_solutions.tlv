\m4_TLV_version 1d: tl-x.org
\SV
//RISC-V labs solutions here
   |cpu
      @0
         $reset = *reset;
         $pc[31:0] = (>>1$reset) ? 32'b0 : >>1$pc + 32'd4;
         $imem_rd_en = ~($reset);
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
      
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
         
         //immediate decode     
         
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
                      $is_u_instr ? { $instr[31:12], 12'b0 } :
                      $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } :
                      32'bx; // default value
         
         // other fields decode
         // decode only when type of instruction is found
         
         // R, S, B
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         // R, I, S, B
         $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;         
         // R, I, U, J
         $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
         // R-type only
         $funct7_valid = $is_r_instr;
         // R, I, S, B
         $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         
         
         ?$rs2_valid
            $rs2[4:0] = $instr[24:20];
         ?$rs1_valid
            $rs1[4:0] = $instr[19:15];
         ?$rd_valid
            $rd[4:0] = $instr[11:7];
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
            
         $opcode[6:0] = $instr[6:0];   
