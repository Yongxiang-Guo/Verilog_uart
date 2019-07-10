`timescale 1ns / 1ps
/**
 * @brief : 三输入的数据发生器，根据mode和isHigh决定一帧数据发几个字节，状态字是什么
 * 
 * 数据帧解释：
 * 		
 * when mode = 2'b10 or 2'b01 : 	
 *   	byte 1 : 'P' 
 * 		byte 2 : '1' or '2' : '1' high_fre '2' low_fre
 * 		byte 3-6 : 32 bit (frequency) inf
 * 		byte 7 : 'd' 
 * 		byte 8 : 'a' 
 *
 * when mode = 2'b11 : 
 *   	byte 1 'P'
 * 		byte 2 '3' or '4' : '3' high_fre '4' low_fre
 * 		byte 3-14 3*32bit info
 * 		byte 15 : 'd'
 * 		byte 16 : 'a'
 *
 *
 */
module uarttx_frame(clk, rst_n, mode,datain,extra_data,one_more_data,dataout, wrsig, isHigh);
	input clk;
	input rst_n;
	input isHigh;
	input[1:0] mode;
	input[31:0] datain,one_more_data,extra_data;
	output[7:0] dataout;
	output wrsig;
	reg [7:0] dataout;
	reg wrsig;
	reg [7:0] cnt;
	reg[4:0] state;

	
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    cnt<=8'd0;
		wrsig<=1'b0;
  end
  
  else begin
	  if(cnt 
	  == 254) begin
		if((mode[0] & ~mode[1])|(mode[1] & ~mode[0]))
			case(state)
				5'd0 : dataout <= 8'd80;	//<'P'
				5'd1 : dataout <= isHigh ? 8'd49 : 8'd50;		//Mode 1\2
				5'd2 : dataout <= datain[31:24];//datain[31:24];
				5'd3 : dataout <= datain[23:16];//datain[23:16];
				5'd4 : dataout <= datain[15:8];
				5'd5 : dataout <= datain[7:0];
				5'd6 : dataout <= 8'd13;	//<'d'
				5'd7 : dataout <= 8'd10;	//<'a'
			endcase
		else if(mode[0] & mode[1])
			case(state)
				5'd0 :  dataout <= 8'd80;	//<'P'
				5'd1 :  dataout <= isHigh ? 8'd51 : 8'd52;		//Mode 3\4
				5'd2 :  dataout <= datain[31:24];//datain[31:24];
				5'd3 :  dataout <= datain[23:16];//datain[23:16];
				5'd4 :  dataout <= datain[15:8];
				5'd5 :  dataout <= datain[7:0];
				5'd6 :  dataout <= extra_data[31:24];	
				5'd7 :  dataout <= extra_data[23:16];
				5'd8 :  dataout <= extra_data[15:8];
				5'd9 :  dataout <= extra_data[7:0];
				5'd10 :  dataout <= one_more_data[31:24];	
				5'd11 :  dataout <= one_more_data[23:16];
				5'd12 :  dataout <= one_more_data[15:8];
				5'd13 :  dataout <= one_more_data[7:0];
				5'd14 : dataout <= 8'd13;	//<'d'
				5'd15 : dataout <= 8'd10;	//<'a'
			endcase
		 wrsig <= 1'b1;              //产生发送命令
		 cnt <= 8'd0;
		 if(mode[0] & mode[1])	state <= (state == 5'd15) ? 5'd0 :  state + 1'b1;
		 else if((mode[0] & ~mode[1])|(mode[1] & ~mode[0])) state <= (state == 5'd7) ? 5'd0 :  state + 1'b1;
		end
		
		else begin
		 wrsig <= 1'b0;
		 cnt <= cnt + 8'd1;
		end
	end	  
end
endmodule


module uarttx_frame_test(clk, rst_n,datain,dataout, wrsig);
	input clk;
	input rst_n;
	input[31:0] datain;
	output[7:0] dataout;
	output wrsig;
	reg [7:0] dataout;
	reg wrsig;
	reg [7:0] cnt;
	reg[2:0] state;

	
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    cnt<=8'd0;
		wrsig<=1'b0;
  end
  
  else begin
	  if(cnt == 254) begin
			case(state)
				3'd0 : dataout <= 8'd80;	//<'P'
				3'd1 : dataout <= 8'd49;		//Mode
				3'd2 : dataout <= datain[31:24];//datain[31:24];
				3'd3 : dataout <= datain[23:16];//datain[23:16];
				3'd4 : dataout <= datain[15:8];
				3'd5 : dataout <= datain[7:0];
				3'd6 : dataout <= 8'd13;	//<'d'
				3'd7 : dataout <= 8'd10;	//<'a'
			endcase
		 wrsig <= 1'b1;              //产生发送命令
		 cnt <= 8'd0;
		 state <= state + 1'b1;
		end
		
		else begin
		 wrsig <= 1'b0;
		 cnt <= cnt + 8'd1;
		end
	end	  
end
endmodule
