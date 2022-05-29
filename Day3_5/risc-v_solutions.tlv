\m4_TLV_version 1d: tl-x.org
\SV
//RISC-V labs solutions here
   |cpu
      @0
         $reset = *reset;
         $pc[31:0] = (>>1$reset) ? 32'b0 :
                     (>>3$valid_load) ? >>3$pc : // load instr - go back in PC - equi - stall
                     (>>3$valid_taken_br) ? >>3$br_tgt_pc : // take branch from third stage
                     (>>3$is_jal && >>3$valid_jump) ? >>3$br_tgt_pc :
                     (>>3$is_jalr && >>3$valid_jump) ? >>3$jalr_tgt_pc :
                     >>1$pc + 32'd4;
         
         
         
         $imem_rd_en = ~$reset;
         
         
         // First attempt at solving hazards
         // Insert a new instruction at every third cycle
         $start = ~($reset) && >>1$reset;
         //$valid = $reset ? 0 : $start ? 1 : >>3$valid;
         
         
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];         
      
      
      @1
         
         $instr[31:0] = $imem_rd_data[31:0];
         
         //decode (IRSBJU)
         // i - type (immediate)
         $is_i_instr = ($instr[6:2] ==? 5'b0000x) || ($instr[6:2] ==? 5'b001x0) || ($instr[6:2] == 5'b11001);
         
         // r - type (register type)
         $is_r_instr = ($instr[6:2] == 5'b01011) || ($instr[6:2] ==? 5'b011x0) || ($instr[6:2] == 5'b10100);
         
         // s - type (store)
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         
         // b - type (branch-type)
         $is_b_instr = $instr[6:2] == 5'b11000;
         
         // j - type (jump instructions)
         $is_j_instr = $instr[6:2] == 5'b11011;
         
         // u - type (upper immediate)
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         
         //immediate decode     
         
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
                      $is_u_instr ? { $instr[31:12], 12'b0 } :
                      $is_j_instr ? { {12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:21], 1'b0 } :
                      32'b0; // default value
         
         // other fields decode
         // decode only when type of instruction is found
         
         // R, S, B
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         // R, I, S, B
         $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         
         // R, I, U, J
         // valid only during $valid
         
         $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr ;
         
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
         
         // arthmetic
         $is_add = $dec_bits === 11'b0_000_0110011;
         
         $is_sub = $dec_bits === 11'b1_000_0110011;
         $is_sll = $dec_bits === 11'b0_001_0110011;
         
         $is_slt = $dec_bits === 11'b0_010_0110011;
         $is_sltu = $dec_bits === 11'b0_011_0110011;
         $is_xor = $dec_bits === 11'b0_100_0110011;
         
         $is_srl = $dec_bits === 11'b0_101_0110011; // logical shift left - zero extend         
         $is_sra = $dec_bits === 11'b1_101_0110011; // arthimetic shift right - sign extend
         $is_or = $dec_bits === 11'b0_110_0110011;
         $is_and = $dec_bits === 11'b0_111_0110011;
         
         
         
         // immediate load
         $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
         
         // jalr return jump
         $is_jalr = $dec_bits ==? 11'bx_000_1100111;
         
         // load all types of load
         $is_load = $dec_bits ==? 11'bx_xxx_0000011;
         
         // store
         $is_store = $dec_bits ==? 11'bx_xxx_0100011;
         //$is_sb = $dec_bits ==? 11'bx_000_0100011;;
         //$is_sh = $dec_bits ==? 11'bx_001_0100011;
         //$is_sw = $dec_bits ==? 11'bx_010_0100011;
         
         // logical operations
         $is_slti = $dec_bits ==? 11'bx_010_0010011; // set if less than
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011;    
         
         // logical immediate
         $is_xori = $dec_bits ==? 11'bx_100_0010011;
         $is_ori = $dec_bits ==? 11'bx_110_0010011;
         $is_andi = $dec_bits ==? 11'bx_111_0010011;
         
         // shift operations
         $is_slli = $dec_bits === 11'b0_001_0010011;
         $is_srli = $dec_bits === 11'b0_101_0010011;
         $is_srai = $dec_bits === 11'b1_101_0010011;
         
         // jump
         $is_jump = $is_jal || $is_jalr;         
      
      @2
         // Register file read
         
         $rf_rd_en2 = $rs2_valid;
         ?$rs2_valid
            $rf_rd_index2[4:0] = $rs2[4:0];
            
         //$src2_value[31:0] = $rf_rd_data2[31:0];
         
         $src2_value[31:0] = ((>>1$rd == $rs2) && (>>1$rf_wr_en) ) ? >>1$result : $rf_rd_data2[31:0];
            
         $rf_rd_en1 = $rs1_valid;
         ?$rs2_valid
            $rf_rd_index1[4:0] = $rs1[4:0];
            
         //$src1_value[31:0] = $rf_rd_data1[31:0];
         
         $src1_value[31:0] = ((>>1$rd == $rs1) && (>>1$rf_wr_en) ) ? >>1$result : $rf_rd_data1[31:0];
            
         $br_tgt_pc[31:0] = $pc + $imm; // this one line wasted 2 hours for me!   
         
      @3        
         
                     
         // check conditions for branch instructions
         
         
         $taken_br = $is_beq ? ( $src1_value == $src2_value ) :
                     $is_bne ? ( $src1_value != $src2_value ) :
                     $is_blt ? ( ( $src1_value < $src2_value ) ^ ( $src1_value[31] != $src2_value[31] ) ) :
                     $is_bge ? ( ( $src1_value >= $src2_value ) ^ ( $src1_value[31] != $src2_value[31] ) ) :
                     $is_bltu ? ( $src1_value < $src2_value ) :
                     $is_bgeu ? ( $src1_value >= $src2_value ) : 1'b0;
         
         $valid_taken_br = $valid && $taken_br; // branch taker unit
         
         // ALU Decoder
         
         
         /*$result[31:0] = $is_addi ? $src1_value + $imm :
                         $is_add ? $src1_value + $src2_value :
                         32'bx;
         */
         
         $sltu_rslt = ($src1_value < $src2_value) ? 1 : 0;
         $sltiu_rslt = ($src1_value < $imm) ? 1 : 0;
         
         $result[31:0] = $is_andi ? $src1_value & $imm :
                         $is_ori ? $src1_value | $imm :
                         $is_xori ? $src1_value ^ $imm :
                         $is_addi ? $src1_value + $imm :
                         $is_slli ? $src1_value << $imm :
                         $is_srli ? $src1_value >> $imm :
                         $is_and ? $src1_value & $src2_value :
                         $is_or ? $src1_value | $src2_value :
                         $is_xor ? $src1_value ^ $src2_value :
                         $is_add ? $src1_value + $src2_value :
                         $is_sub ? $src1_value - $src2_value :
                         $is_sll ? $src1_value << $src2_value :
                         $is_srl ? $src1_value >> $src2_value :
                         $is_sltu ? $sltu_rslt :
                         $is_sltiu ? $sltiu_rslt :
                         $is_srai ? ({ {32{$src1_value[31]}}, $src1_value } >> $imm[4:0]) :
                         $is_sra ? ( { {32{$src1_value[31]} }, $src1_value} >> $src2_value[4:0] ) :
                         $is_slt ? ( ( $src1_value[31] == $src2_value[31] ) ? $sltu_rslt : {31'b0, $src1_value[31]} ) :
                         $is_slti ? ( ($src1_value[31] == $imm[31]) ? $sltiu_rslt : {31'b0, $src1_value[31]} ) :
                         $is_lui ? { $imm[31:12], 12'b0 } :
                         $is_auipc ? $pc + $imm :
                         $is_jal ? $pc + 4 :
                         $is_jalr ? $pc + 4 : 32'bx;
                         
         // Register file write
         // should not write to r0 register
         // write only during valid time
         // enable when there was a valid load two cycles ago
         
         $rf_wr_en = (!($rd[4:0] == 5'b0) && $rd_valid && $valid) || (>>2$valid_load);
         
         //$rf_wr_index[4:0] = $rd[4:0];
         
         // for load
         $rf_wr_index[4:0] = (>>2$valid_load) ? >>2$rd : $rd;
         
         //$rf_wr_data[31:0] = $result;
         
         // for load from memory
         // if there is a valid_load two cycles ago, load the data
         $rf_wr_data[31:0] = (>>2$valid_load) ? >>2$ld_data : $result;
         
         //NAND == NOT(OR)
         //Whenever branch is taken do not allow the next two instructions to write to register file
         //Whenver there is a load instruction, next two instructions are invalid
         
         
         //$valid = $is_load ? 1'b0 : ~( (>>1$valid_taken_br) && (>>1$valid_taken_br) ) ;
         //$valid = ~( >>1$valid_taken_br || >>2$valid_taken_br || >>1$valid_load || >>2$valid_load);
         
         // also we wait till 2 cycles before loading
         $valid_load = $is_load && $valid;
         
         // Jump validity
                  
         $valid_jump = $is_jump && $valid;
         
         $valid = ~( >>1$valid_taken_br || >>2$valid_taken_br || >>1$valid_load ||
                     >>2$valid_load || >>1$$valid_jump || >>2$valid_jump);
         // Jump Address
                  
         $jalr_tgt_pc[31:0] = $src1_value + $imm;
         
         
      @4
         
         
         // store D[addr] <= rs2
         // load rd <= dmem[addr]
         // addr <= rs1 + imm
         
         $dmem_addr[3:0] = $result[5:2]; // rs1 + imm
         
         $dmem_wr_en = $is_s_instr && $valid; // store data
         $dmem_wr_data[31:0] = $src2_value;
         
         
         $dmem_rd_en = $valid_load; // load instruction
         
      @5
         $ld_data[31:0] = $dmem_rd_data; // load data
         
