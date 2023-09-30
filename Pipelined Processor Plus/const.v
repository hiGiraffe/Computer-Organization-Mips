//D_grf
`define regWriteAddrIsRd 			2'd0
`define regWriteAddrIsRt 			2'd1
`define regWriteAddrIs31			2'd2

`define regWriteIsMemReadData 	3'd0
`define regWriteIsAluResult		3'd1
`define regWriteIsImmLUI			3'd2
`define regWriteIsPCJal				3'd3
`define regWriteIsHILO				3'd5

//EXT
`define immUnsignedExt				2'd0
`define immSignedExt					2'd1
`define immLUI							2'd3

//ALU
`define aluSrcBIsImmExt			2'd0
`define aluSrcBIsRtData			2'd1

`define	aluResultIsAdd				3'd0
`define	aluResultIsSub				3'd1
`define	aluResultIsAnd				3'd2
`define	aluResultIsOr				3'd3
`define 	aluResultIsSlt				3'd4
`define  aluResultIsSltu			3'd5

//HILO
`define mult 	4'd9
`define multu 	4'd1
`define div 	4'd2
`define divu 	4'd3
`define mfhi 	4'd4
`define mflo 	4'd5
`define mthi 	4'd6
`define mtlo	4'd7

