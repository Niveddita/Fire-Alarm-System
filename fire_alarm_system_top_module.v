`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2021 16:11:32
// Design Name: 
// Module Name: fire_alarm_system_top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fire_alarm_system_top_module(
input clk,reset,
output [3:0] an,
output [6:0] seg,
output buzzer_out
);
parameter zero = 4'b0000;
wire clk_out;
wire newclk_out;
wire [1:0] sig;
wire [3:0] out;
wire [7:0] count;
wire [11:0] bcd;
wire ioport;
wire [7:0] tempV;
wire [1:0] dout;
wire led;


temperature_sensor a10(clk,reset,ioport,tempV);
fsm a11(tempV,clk,reset,sig);
countdown_10s a7 (newclk_out,reset,sig,count);
slowclock_1s a8(clk,newclk_out);
binarytobcd a1 (count,bcd[11:0]);
//binarytobcd a1 (count,bcd[11:8],bcd[7:4],bcd[3:0]); old
slowclock a3 (clk,sig,led,buzzer_out);
two_bit_counter a4(led,reset,dout);
mux4to1 a2(bcd[11:8],bcd[7:4],bcd[3:0],4'b0000,dout,out);
segment7 a6(out,seg);
//slowclock a3 (clk,clk_out);
//two_bit_counter a4(dout,clk_out,reset); old

decoder_2_4 a5(dout,an);

//bcd_7_segment a6(bcd,seg);

//countdown_10s a7 (newclk_out,reset,sig,count);
//slowclock_1s a8(clk,newclk_out);
//tone_generator a9(clk,counter,sound);

//temperature_sensor a10(clk,reset,ioport);
//fsm a11(tempV,clk,reset,sig);
endmodule


module binarytobcd(
count,
     bcd
);
input [7:0] count;
    output [11:0] bcd;
reg [11 : 0] bcd;  
  reg [3:0] i;    
     
  always @(count)
    begin
            bcd = 0; //initialize bcd to zero.
        for (i = 0; i < 8; i = i+1)  
        begin
                bcd = {bcd[10:0],count[7-i]};  
                     
         
            if(i < 7 && bcd[3:0] > 4)  
                    bcd[3:0] = bcd[3:0] + 3;
            if(i < 7 && bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
            if(i < 7 && bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;  
        end
    end      
                 
endmodule
 
module mux4to1 ( input [3:0] a,
input [3:0] b,
input [3:0] c,
input [3:0] d,  
input [1:0] dout,
output reg [3:0]out
);  
always @ (a or b or c or d or dout[0] or dout[1])
begin
case (dout[0] | dout[1])
2'b00: out = a;
2'b01: out = b;
2'b10: out = c;
2'b11: out = 4'b0000;
endcase
end  
endmodule
// LED BLINKING AND BUZZER (ALARM)
module slowclock(
input clk_in, input [1:0]sig,
output led,
output reg buzzer_out
    );
   
    reg [25:0]count=0;
    reg [25:0] count1 = 0;
    reg clk_out;
    assign led=0;
    always@ (posedge clk_in)
    begin
    if(sig == 2'b10)
    begin
    count<=count+1;
    if (count==50_000_000)
    begin
    count<=0;
    clk_out=-clk_out;
    //clk_out=-clk_out; old
    end
    if (count1 <= 50_000_000)
    begin
    buzzer_out <= 1;
    end
    else if (count1 >= 50_000_000 && count1<= 100_000_000)
    begin
    buzzer_out <=0;
    end
    else
    begin
    buzzer_out <=0;
    end
    end
    end
    assign led=clk_out;
endmodule

module two_bit_counter(led ,reset ,dout );

output [1:0] dout ;
reg [1:0] dout ;

input led ;
wire clk ;
input reset ;
wire reset ;

initial dout = 0;
 
always @ (posedge led)
begin
 if (reset)
  dout <= 0;
 else
  dout <= dout + 1;
end  

endmodule

module decoder_2_4(
input [1:0] dout,
output reg [3:0]an

);
always@(dout)
begin
case(dout)
2'b00: an = 4'b0001;
2'b01: an = 4'b0010;
2'b10: an = 4'b0100;
2'b11: an = 4'b1000;
endcase
end
endmodule

module segment7(
     out,
     seg
    );
     
     //Declare inputs,outputs and internal variables.
     input [3:0] out;
     output [6:0] seg;
     reg [6:0] seg;
 
//always block for converting bcd digit into 7 segment format
    always @(out)
    begin
        case (out) //case statement
            0 : seg = 7'b0000001;
            1 : seg = 7'b1001111;
            2 : seg = 7'b0010010;
            3 : seg = 7'b0000110;
            4 : seg = 7'b1001100;
            5 : seg = 7'b0100100;
            6 : seg = 7'b0100000;
            7 : seg = 7'b0001111;
            8 : seg = 7'b0000000;
            9 : seg = 7'b0000100;
            //switch off 7 segment character when the bcd digit is not a decimal number.
            default : seg = 7'b1111111;
        endcase
    end
   
endmodule
 
module countdown_10s
(
input newclk_out,
input reset,
input [1:0] sig,
output [7:0]count
);
reg [7:0]current_count=0;
always @(posedge newclk_out)
begin
if(reset)
current_count<=10;

else if(sig==2'b00)
current_count<=10;
else if ((sig==2'b10)&&(current_count!=0))
//else if ((sig==2'b10)&(current_count!=0)) old
current_count<=current_count-1;
else
current_count<=current_count;
end
assign count=current_count;
endmodule

module slowclock_1s(
input clk_in,
output reg newclk_out);
reg[26:0] period_count=0;
always @(posedge clk_in)
begin
if (period_count != 100_000_000-1)
begin
period_count<=period_count+1;
newclk_out<=0;
end
else
begin
period_count<=0;
newclk_out<=1;
end
end
endmodule



module temperature_sensor(
input wire clk,
input wire reset,
inout ioport,
output reg [7:0] tempV
   );
always @(posedge clk)
begin
    tempV <= ioport;    
end
endmodule


module fsm (
input clk, reset,
input [7:0] tempV,
output [1:0] sig,
output reg flag_in
);
localparam s00=0,s01=1,s10=2,s11=3;
reg [1:0] current_state = 2'b00;
reg [1:0] next_state = 2'b00;
reg setsig = 2'b00;
always @(posedge clk)
begin
if (reset)
current_state <= s00;
else
current_state <= next_state;
end

//Next State Combinational Logic
always@(current_state)
begin
case(current_state)
s00:
begin
if(tempV != 8'b00000000)
next_state = s01;
end
s01:
begin
if(tempV >= 8'b00110010)
next_state =s10;
else
next_state = s11;
end
s10:
begin
//countdown_10s a7(newclk_out,reset,sig,count);
//slowclock a9 (clk,newclk_out);
end
s11:
begin
next_state=s00;
end
endcase
end
// Combinational Output Logic for each state
always@(posedge clk)
begin
case(current_state)
s00: begin
setsig = 2'b00;
end
s01: begin
setsig = 2'b01;
end
s10: begin
setsig = 2'b10;
end
s11: begin
setsig = 2'b11;
end
endcase
end
assign sig = setsig;
endmodule

