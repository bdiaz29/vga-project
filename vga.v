module vgaNumProject(clk,VS,HS,red,green,blue,r,g,b,vFree,hFree,inc,JA);
output [3:0] JA;

assign JA[0]=VS;
assign JA[1]=HS;
assign JA[2]=hFree&&vFree;
assign JA[3]=hFree&&vFree&&numfree;
reg[11:0] count;
reg[4:0] testR,testG,testB;

always@(posedge tst)
begin
count=count+1;
end

always
begin
testR=count[4:0];
testG=count[7:5];
testB=count[11:8];
end




input [0:0] clk;
input inc;
input [3:0] r,g,b;
output  VS,HS,hFree,vFree;
output reg [3:0] red,green,blue;
reg [3:0] free;
reg [3:0] number;
wire numfree;
wire numfreeA,numfreeB;
wire [10:0] x,y;
wire tst;

assign numfree=numfreeA||numfreeB;
always
begin

free[0]=hFree&&vFree&&numfree;
free[1]=hFree&&vFree&&numfree;
free[2]=hFree&&vFree&&numfree;
free[3]=hFree&&vFree&&numfree;

red=r&free;
green=g&free;
blue=b&free;
end
vgaPulse H(pixelClk,21'd96,21'd144,21'd784,21'd800,HS,hFree,x);
vgaPulse V(HS,21'd2,21'd35,21'd515,21'd525,VS,vFree,y);
clockDiv pixelClock(clk,32'd4,pixelClk);
clockDiv testClock(pixelClk,32'd10,tst);

//calling multiples blocks to display multiple numbers
//with a modified number blocks that takes parameters
//(num,x,y,out,xOffset,yOffset,xScale,yScale);
//num is the number you want displayed
//the x and y offset is where you want on the screen
// and the x and y scale is how you want them scaled
//block A is the  number 5
//block B is the  number  9 but offset to a diffrent positon and twice as large
//each block must have its own unqie numfree wire that will have to be ORd
//with the main numfree
numberBlock blockA(5,x,y,numfreeA,300,380,15,15);
numberBlock blockB(9,x,y,numfreeB,200,280,30,30);

//numberBlock blockB(num,x,y,numfree,300,380,15,15);

always@(posedge inc)
begin

number=number+1;
end

endmodule

module vgaPulse(clk,stage1,stage2,stage3,endStage,syncPulse,free,position);
reg [12:0] count;
reg inc;
reg[10:0] posCount;
output [10:0] position;
assign position=posCount;
input [21:0] stage1,stage2,stage3,endStage;
input clk;
//whether the count is in each stage
reg S0,S1,S2,S3;
output  syncPulse,free;
//free if and only if in stage 0
assign free=fr;
//sync is high if in stage 0 1 or 3
assign syncPulse=sp;
reg fr,sp;
always
begin
inc=(count>endStage);
//stage0
S0<=(((count>21'd0)||(count==21'd0))&&(count<stage1)||(count==endStage));
//stage1
S1<=(((count>stage1)||(count==stage1))&&(count<stage2));
//stage2
S2<=(((count>stage2)||(count==stage2))&&(count<stage3));
//stage3
S3<=(((count>stage3)||(count==stage3))&&(count<endStage));
//free if and only if in stage 0
end

always@(negedge clk)
begin
//free if and only if in stage 0
fr<=S2;
//sync is high if in stage 0 1 or 3
sp<=S1||S2||S3;
end
//at the clock edge
always@(posedge clk)
begin
case(free)
0:posCount=0;
1:posCount=posCount+1;
endcase
case(inc)
1:count=0;
0:count=count+1;
endcase
end
endmodule

module clockDiv(clk,div,out);
output reg out;
input clk;
input [31:0] div;
reg [31:0] count;
reg inc;
reg outhold;
reg max;
//assign out=outhold;
always begin inc=(count>max); max=div>>1;end
always@(posedge clk)
begin
case(inc)
1:begin count=0; out=~out; end
0:begin count=count+1; end
endcase
end
endmodule

module numberBlock(num,x,y,out,xOffset,yOffset,xScale,yScale);
input  [3:0] num;
input  [10:0] x,y;
//positioning offset
input [10:0] xOffset,yOffset,xScale,yScale;
output out;
reg blockout;

reg blockC1,blockC2,blockC3,blockC4,blockC5;
reg blockB1,blockB2,blockB3,blockB4,blockB5;
reg blockA1,blockA2,blockA3,blockA4,blockA5;
reg allblock;

reg [10:0] column1,column2,column3;
reg [10:0] row1,row2,row3,row4,row5;

always
begin
 column1=xOffset+xScale+1;
 column2=xOffset+xScale+xScale+1;
 column3=xOffset+xScale+xScale+xScale+1;

 row1=yOffset+yScale+1;
 row2=yOffset+yScale+yScale+1;
 row3=yOffset+yScale+yScale+yScale+1;
 row4=yOffset+yScale+yScale+yScale+yScale+1;
 row5=yOffset+yScale+yScale+yScale+yScale+yScale+1;
end

assign out=blockout;
//the blocks
always 
begin
//first column 
blockA1=(x>xOffset)&&(x<=column1)&&(y>yOffset)&&(y<=row1);
blockA2=(x>xOffset)&&(x<=column1)&&(y>row1)&&(y<=row2);
blockA3=(x>xOffset)&&(x<=column1)&&(y>row2)&&(y<=row3);
blockA4=(x>xOffset)&&(x<=column1)&&(y>row3)&&(y<=row4);
blockA5=(x>xOffset)&&(x<=column1)&&(y>row4)&&(y<=row5);
//second column
blockB1=(x>column1)&&(x<=column2)&&(y>yOffset)&&(y<=row1);
blockB2=(x>column1)&&(x<=column2)&&(y>row1)&&(y<=row2);
blockB3=(x>column1)&&(x<=column2)&&(y>row2)&&(y<=row3);
blockB4=(x>column1)&&(x<=column2)&&(y>row3)&&(y<=row4);
blockB5=(x>column1)&&(x<=column2)&&(y>row4)&&(y<=row5);
//third column
blockC1=(x>column2)&&(x<=column3)&&(y>yOffset)&&(y<=row1);
blockC2=(x>column2)&&(x<=column3)&&(y>row1)&&(y<=row2);
blockC3=(x>column2)&&(x<=column3)&&(y>row2)&&(y<=row3);
blockC4=(x>column2)&&(x<=column3)&&(y>row3)&&(y<=row4);
blockC5=(x>column2)&&(x<=column3)&&(y>row4)&&(y<=row5);
//the entire area
allblock=(x>xOffset)&&(x<=column3)&&(y>yOffset)&&(y<=row5);
end

always 
begin
case (num) 
    0:blockout=allblock&&(~(blockB2||blockB3||blockB4));
    1:blockout=blockB1||blockB2||blockB3||blockB4||blockB5;
    2:blockout=allblock&&(~(blockA2||blockB2||blockB4||blockC4));
    3:blockout=allblock&&(~(blockA2||blockB2||blockA4||blockB4));
	4:blockout=allblock&&(~(blockB1||blockB2||blockA4||blockA5||blockB4||blockB5));
	5:blockout=allblock&&(~(blockB2||blockC2||blockA4||blockB4));
	6:blockout=allblock&&(~(blockB1||blockC1||blockB2||blockC2||blockB4));
	7:blockout=blockA1||blockB1||blockC1||blockC2||blockC3||blockC4||blockC5;
	8:blockout=allblock&&(~(blockB2||blockB4));
	9:blockout=allblock&&(~(blockB2||blockA4||blockB4||blockA5||blockB5));
    10:blockout=blockB1;
    11:blockout=blockB1||blockA1;
    12:blockout=blockB1||blockA2;
    13:blockout=blockB1||blockA3;
    14:blockout=blockA1||blockA4;
    15:blockout=blockA1||blockA5;
endcase 

end

endmodule
