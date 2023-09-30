//D_grf
`define regWriteAddrIsRd 			2'd0
`define regWriteAddrIsRt 			2'd1
`define regWriteAddrIs31			2'd2

`define regWriteIsMemReadData 	3'd0
`define regWriteIsAluResult		3'd1
`define regWriteIsImmLUI			3'd2
`define regWriteIsPCJal				3'd3


//EXT
`define immUnsignedExt				2'd0
`define immSignedExt					2'd1
`define immLUI							2'd3

//ALU
`define aluSrcBIsImmExt			2'd0
`define aluSrcBIsRtData			2'd1

`define	aluResultIsAdd				2'd0
`define	aluResultIsSub				2'd1
`define	aluResultIsAnd				2'd2
`define	aluResultIsOr				2'd3

