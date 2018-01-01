//IDģ��
//��ָ�������
//�õ��������������͡������͡�Դ������1��Դ������2��Ҫд��Ŀ�ļĴ����ĵ�ַ
`include "defines.v"
module id(
    input wire                  rst,
    input wire[`InstAddrBus]    pc_i,
    input wire[`InstBus]        inst_i,

    //��ȡ��Regfile��ֵ
    input wire[`RegBus]         reg1_data_i,
    input wire[`RegBus]         reg2_data_i,

    //�����Regfile����Ϣ
    output reg                     reg1_read_o,
    output reg                     reg2_read_o,
    output reg[`RegAddrBus]        reg1_addr_o,
    output reg[`RegAddrBus]        reg2_addr_o,

    //�����ִ�н׶�
    output reg[`AluOpBus]          aluop_o,
    output reg[`AluSelBus]         alusel_o,
    output reg[`RegBus]            reg1_o,
    output reg[`RegBus]            reg2_o,
    output reg[`RegAddrBus]        wd_o,
    output reg                     wreg_o
);
//ȡ�õ�ָ���빦����
wire[5:0] op = inst_i[31:26];
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op3 = inst_i[5:0];
wire[4:0] op4 = inst_i[20:16];

//����ָ��ִ����Ҫ��������
reg[`RegBus]   imm;

//ָʾָ���Ƿ���Ч
reg instvalid;

//��ָ���������
always @ (*) begin
    if(rst == `RstEnable) begin
        aluop_o <=  `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o    <=  `NOPRegAddr;
        wreg_o  <=  `WriteDisable;
        instvalid   <=  `InstInvalid;
        reg1_read_o <=  1'b0;
        reg2_read_o <=  1'b0;
        reg1_addr_o <=  `NOPRegAddr;
        reg2_addr_o <=  `NOPRegAddr;
        imm         <=  32'h0;
    end else begin
        aluop_o <=  `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o    <=  inst_i[15:11];
        wreg_o  <=  `WriteDisable;
        instvalid   <=  `InstInvalid;
        reg1_read_o <=  1'b0;
        reg2_read_o <=  1'b0;
        reg1_addr_o <=  inst_i[25:21];  //Ĭ�ϵ�һ���������Ĵ���Ϊ�˿�1��ȡ�ļĴ���
        reg2_addr_o <=  inst_i[20:16];  //Ĭ�ϵڶ��������Ĵ���Ϊ�˿�2��ȡ�ļĴ���
        imm         <=  `ZeroWord;    

        case(op)
            `EXE_SPECIAL_INST:  begin //SPECIAL
              case(op2)
                5'b00000: begin
                  case(op3)
                    `EXE_OR:begin       //or
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_OR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_AND:begin      //and
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_AND_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;
                            end
                            `EXE_XOR:begin     //xor
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_XOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_NOR:begin     //nor
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_NOR_OP;
                                alusel_o <= `EXE_RES_LOGIC;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SLLV:begin     //sllv
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SLL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SRLV:begin     //srlv
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SRAV:begin     //srav
                                wreg_o <= `WriteEnable;
                                aluop_o <= `EXE_SRA_OP;
                                alusel_o <= `EXE_RES_SHIFT;
                                reg1_read_o <= 1'b1;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            `EXE_SYNC:begin     //sync
                                wreg_o <= `WriteDisable;
                                aluop_o <= `EXE_SRL_OP;
                                alusel_o <= `EXE_RES_NOP;
                                reg1_read_o <= 1'b0;
                                reg2_read_o <= 1'b1;
                                instvalid <= `InstValid;  
                            end
                            default: begin
                            end
                        endcase //op3
                    end
                    default: begin
                    end
                endcase //op2
            end //SPECIAL
            `EXE_ORI:   begin   //�ж���ori��ָ����
            //oriָ����Ҫ�����д��Ŀ�ļĴ����������д���ź�ʹ��
            wreg_o  <=  `WriteEnable;
            //��������������߼���������
            aluop_o <=  `EXE_OR_OP;
            //�����������߼�����   
            alusel_o<=  `EXE_RES_LOGIC;
            //��Ҫͨ��Regfile�Ķ��˿�1���Ĵ���
            reg1_read_o <= 1'b1;
            //��Ҫͨ��Regfile�Ķ��˿�2���Ĵ���
            reg2_read_o <= 1'b0;
            //ָ��ִ����Ҫ��������
            imm <=  {16'h0,inst_i[15:0]};
            //ָ��ִ��Ҫд��Ŀ�ļĴ���
            wd_o <= inst_i[20:16];
            //oriָ����Ч
            instvalid   <=  `InstValid;
            end
            
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_AND_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {16'h0,inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;
            end
            `EXE_XORI:begin         //xori
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_XOR_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {16'h0,inst_i[15:0]};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;
            end
            `EXE_LUI:begin          //lui
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_OR_OP;
                alusel_o<=  `EXE_RES_LOGIC;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                imm <=  {inst_i[15:0],16'h0};
                wd_o <= inst_i[20:16];
                instvalid   <=  `InstValid;    
            end
            `EXE_PREF:begin        //pref
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_NOP_OP;
                alusel_o<=  `EXE_RES_NOP;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                instvalid   <=  `InstValid;   
            end 
            default:begin
            end
        endcase //case op
        
            if(op3 == `EXE_SLL) begin       //sll
                wreg_o  <=  `WriteEnable;
                aluop_o <=  `EXE_SLL_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid; 
            end else if(op3 == `EXE_SRL)begin        //srl
                wreg_o <= `WriteEnable;
                aluop_o <=  `EXE_SRL_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid;
            end else if (op3 == `EXE_SRA) begin //sra
                wreg_o <= `WriteEnable;
                aluop_o <=  `EXE_SRA_OP;
                alusel_o<=  `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <=  inst_i[10:6];
                wd_o <= inst_i[15:11];
                instvalid   <=  `InstValid;
            end
        end
    end //if
end //always

//ȷ������Դ������1
always @ (*) begin
    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if(reg1_read_o == 1'b1) begin
        reg1_o <= reg1_data_i;  //Regfile���˿�1�����ֵ
    end else if(reg1_read_o == 1'b0) begin
        reg1_o <= imm;          //������
    end else begin
        reg1_o <= `ZeroWord;
    end
end

//ȷ������Դ������2
always @ (*) begin
    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if(reg2_read_o == 1'b1) begin
        reg2_o <= reg2_data_i;  //Regfile���˿�1�����ֵ
    end else if(reg2_read_o == 1'b0) begin
        reg2_o <= imm;          //������
    end else begin
        reg2_o <= `ZeroWord;
    end
end

endmodule