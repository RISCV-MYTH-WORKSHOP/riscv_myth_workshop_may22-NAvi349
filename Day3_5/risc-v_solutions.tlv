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
         
         // Decode each instruction
         $dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
         
         // b-type
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         
         // addi
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         
         // add
         $is_add = $dec_bits === 11'b0_000_0110011;
         
         // Register file read
         
         ?$rs2_valid
            $rf_rd_en2 = 1'b1;
            $rf_rd_index2[4:0] = $rs2[4:0];
            $src2_value[31:0] = $rf_rd_data2[31:0];
         ?$rs1_valid
            $rf_rd_en1 = 1'b1;
            $rf_rd_index1[4:0] = $rs1[4:0];
            $src1_value[31:0] = $rf_rd_data1[31:0];
            
         // Instruction Execution
         
         // ALU Decoder
         
         $result[31:0] = $is_addi ? $src1_value + $imm :
                         $is_add ? $src1_value + $src2_value :
                         32'bx;
            
