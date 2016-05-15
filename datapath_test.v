module datapath_test;
	datapath d(clr, clk);

	reg clk, clr;

	wire wMarEn, wMdrEn, wMdrMuxSel, mfc, wInstEn, regEn, regEnint;
	wire[1:0] wordSel;
	wire[3:0] wRc;
	wire[7:0] states;
	wire[11:0] wShifter_operand;
	wire[15:0] decoderOutput;
	wire[31:0] wRegY1, wRegY0, wAluMuxOut, wAluOut, wMar, wMdr, wMdrMuxOut, wRamOut, wInst, Reg0, Reg1, Reg5, Reg10, wRotOut, ram;
	wire[4:0] op;

	assign{wAluMuxOut} = d.wAluMuxOut;
	assign{wRamOut} = d.wRamOut;
	assign{wAluOut} = d.wAluOut;
	assign{op} = d.wOp;
	assign{ram} = {d.ram.Mem[8], d.ram.Mem[9], d.ram.Mem[10], d.ram.Mem[11]};
	assign{wRegY0} = d.wRegY0;
	assign{wMarEn} = d.wMarEn;
	assign{wMar} = d.wMar;
	assign{wMdrEn} = d.wMdrEn;
	assign{wMdr} = d.wMdr;
	assign{states} = d.cu.state;
	assign{wMdrMuxOut} = d.wMdrMuxOut;
	assign{wMdrMuxSel} = d.wMdrMuxSel;
	assign{mfc} = d.ram.MFC;
	assign{wInst} = d.cu.instruction;
	assign{wInstEn} = d.wInstEn;
	assign{Reg0} = d.registers.Register0.Out;
	assign{Reg1} = d.registers.Register1.Out;
	assign{Reg5} = d.registers.Register5.Out;
	assign{Reg10} = d.registers.Register10.Out;
	assign{regEn} = d.wRegEn;
	assign{wRc} = d.wRc;
	assign{wordSel} = d.cu.wordSel;
	assign{wRotOut} = d.wRotOut;

	assign{wShifter_operand} = d.wShifter_operand;
	assign{regEnint} = d.registers.D_Enable;
	assign{decoderOutput} = d.registers.D_Out;

	integer fd, code, i; reg[31:0] data;
 
	initial begin
		//initializing clock and clear
		clk = 1'b1;
		clr = 1'b0;
		i= 0;
		fd = $fopenr("testarm.dat");

		//populating memory with instructions in file
		#2 begin
		while(!($feof(fd))) begin
			code = $fscanf(fd, "%b\n", data);		
			d.ram.Mem[4*i] = data[31:24];
			d.ram.Mem[4*i + 1] = data[23:16];
			d.ram.Mem[4*i + 2] = data[15:8];
			d.ram.Mem[4*i + 3] = data[7:0];
			i = i + 1;
			$display("memory[4]: %b", d.ram.Mem[4]);
		end
		$fclose(fd);		
		end
		//#10 begin d.ram.Mem[0] = 8'hE0; d.ram.Mem[1] = 8'h90; d.ram.Mem[2] = 8'h10; d.ram.Mem[3] = 8'h01; d.registers.Register0.Out = 32'h1; d.registers.Register1.Out = 32'h5;  end
		//#10 begin d.ram.Mem[0] = 8'hE2; d.ram.Mem[1] = 8'h90; d.ram.Mem[2] = 8'h12; d.ram.Mem[3] = 8'h0C; d.registers.Register0.Out = 32'h2; d.registers.Register1.Out = 32'h5;  end
		//#10 begin d.ram.Mem[0] = 8'hE5; d.ram.Mem[1] = 8'h91; d.ram.Mem[2] = 8'h00; d.ram.Mem[3] = 8'h04; d.ram.Mem[8] = 8'hA6; d.ram.Mem[9] = 8'h11; d.ram.Mem[10] = 8'hFF; d.ram.Mem[11] = 8'h00;d.registers.Register0.Out = 32'h2; d.registers.Register1.Out = 32'h4;  end
		//#10 begin d.ram.Mem[0] = 8'hE5; d.ram.Mem[1] = 8'hB1; d.ram.Mem[2] = 8'h00; d.ram.Mem[3] = 8'h04; d.ram.Mem[8] = 8'hA6; d.ram.Mem[9] = 8'h11; d.ram.Mem[10] = 8'hFF; d.ram.Mem[11] = 8'h00; d.registers.Register0.Out = 32'h1FF42FD1; d.registers.Register1.Out = 32'h4;  end
		//#10 begin d.ram.Mem[0] = 8'hE7; d.ram.Mem[1] = 8'hDA; d.ram.Mem[2] = 8'h00; d.ram.Mem[3] = 8'h05; d.ram.Mem[8] = 8'hBF; d.ram.Mem[9] = 8'h11; d.ram.Mem[10] = 8'hFF; d.ram.Mem[11] = 8'h00; d.registers.Register10.Out = 32'h1; d.registers.Register0.Out = 32'h1A150FF4;
		//d.registers.Register5.Out = 32'h7;  end
		//#10 begin d.ram.Mem[0] = 8'hE7; d.ram.Mem[1] = 8'h91; d.ram.Mem[2] = 8'h00; d.ram.Mem[3] = 8'h04; d.ram.Mem[8] = 8'hA6; d.ram.Mem[9] = 8'h11; d.ram.Mem[10] = 8'hFF; d.ram.Mem[11] = 8'h00;d.registers.Register0.Out = 32'h2; d.registers.Register1.Out = 32'h4;  end

		//E290110C
		//E5910004
		//E5810004
		repeat(400)
		begin
			#5 begin clk = ~clk;clr = 1'b1; end
		end
	end

	initial begin
		//$monitor("regEnint: %b, decoderOutput: %h, currentState: %d", regEnint, decoderOutput, states);
		$monitor("ram[8]: %h, wRamOut: %b, clr : %b, wMar: %data, wMarEn: %b, currentState: %d, ", ram, wRamOut, clr, wMar, wMarEn, states);
		//$monitor("instruction: %b, wAluOut: %h, wAluMuxOut: %h, wShifter_operand: %h, wRegY1: %h, wReg0: %h, regEn: %b, wRc: %h, op: %b, currentState: %d\n memory[4]: %b", wInst, wAluOut, wAluMuxOut, wShifter_operand, Reg1, Reg0, regEn, wRc, op, states, d.ram.Mem[4]);
		// $monitor("instruction: %b, wAluOut: %h, wAluMuxOut: %h, wRegY1: %h, wReg0: %h, ram[8]: %h, regEn: %b, wRc: %h, wMar: %h, wMarEn: %b, wMdr: %h, op: %b, currentState: %d", wInst, wAluOut, wAluMuxOut, Reg1, Reg0, ram, regEn, wRc, wMar, wMarEn, wMdr, op, states);
		//$monitor("instruction: %b, wAluOut: %h, wAluMuxOut: %h, wRegY0: %h, wRegY5: %h, wRegY10: %h, ram[11:8]: %h,\nregEn: %b, wRc: %h, wMar: %h, wMarEn: %b, wMdr: %h, wordSel: %h, op: %b, currentState: %d, address: %h, r1: %h\n", wInst, wAluOut, wAluMuxOut, Reg0, Reg5, Reg10, ram, regEn, wRc, wMar, wMarEn, wMdr, wordSel, op, states, d.ram.Address, Reg1);
		//$monitor(" wMar: %b, wMarEn: %b, wMdr: %b, wMdrEn: %b, wMdrMuxOut: %b, wMdrMuxSel: %b, currentState: %d, mfc: %b", wMar, wMarEn, wMdr, wMdrEn, wMdrMuxOut, wMdrMuxSel, states, mfc);
		//$monitor("mfc: %b", mfc);
		//$monitor("instruction: %h, RamOut: %h, IRenabled? : %b, MdrMuxOut : %h, Mdr: %h, MdrEn: %b, opCode: %b, state: %d", wInst, wRamOut, wInstEn, wMdrMuxOut, wMdr, wMdrEn, op, states );
	end

endmodule