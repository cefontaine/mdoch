use Time;
use BlockDist, CyclicDist, BlockCycDist, ReplicatedDist;

record elapsedTimer {
	var t: Timer;
	var u: TimeUnits = TimeUnits.microseconds;
	proc start() {
		t.clear();
		t.start();
	}
	proc stop() {
		t.stop();
		return t.elapsed(u);
	}
	proc stop(s: string) {
		writeln(s, ": ", t.elapsed(u));
		stdout.flush();
	}
}

config const n = 1000;
var t: elapsedTimer;
var res: real;
var myLocale = Locales(here.id);

proc dist_prim_types_r() {
	var space = [1..n, 1..n];
	var asg, add, sub, mul, div: real;
	var resReal: real;
	
	writeln("Evaluation of Array with Types (Read Only)");
	writeln("# of ops: ", n, ", time unit: usec");

	var blockSpace = space dmapped Block(boundingBox=space);
	var arrBlock: [blockSpace] real;
	t.start();
	for d in arrBlock.domain do on myLocale do 
		arrBlock(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrBlock.domain do on myLocale do 
		resReal = resReal + arrBlock(d); 
	add = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do 
		resReal = resReal - arrBlock(d);
	sub = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do 
		resReal = resReal * arrBlock(d);
	mul = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do 
		resReal = resReal /  arrBlock(d);
	div = t.stop();
	res = resReal;
	writeln("Block\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	const cyclicSpace = space dmapped Cyclic(startIdx=space.low);
	var arrCyclic: [cyclicSpace] real;
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		arrCyclic(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrCyclic.domain do on myLocale do 
		resReal = resReal + arrCyclic(d); 
	add = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		resReal = resReal - arrCyclic(d);
	sub = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		resReal = resReal * arrCyclic(d);
	mul = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		resReal = resReal /  arrCyclic(d);
	div = t.stop();
	res = resReal;
	writeln("Cyclic\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	const blkCycSpace = space dmapped BlockCyclic(startIdx=space.low, 
												  blocksize=(1, 2));
	var arrBlkCyc: [blkCycSpace] real;
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		arrBlkCyc(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		resReal = resReal + arrBlkCyc(d); 
	add = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		resReal = resReal - arrBlkCyc(d);
	sub = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		resReal = resReal * arrBlkCyc(d);
	mul = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		resReal = resReal /  arrBlkCyc(d);
	div = t.stop();
	res = resReal;
	writeln("BlockCyc\t\t",asg,"\t",add,"\t",sub,"\t",mul,"\t",div);

	const replicatedSpace = space dmapped ReplicatedDist();
	var arrRep: [replicatedSpace] real;
	
	t.start();
	for d in arrRep.domain do on myLocale do 
		arrRep(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrRep.domain do on myLocale do 
		resReal = resReal + arrRep(d); 
	add = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do 
		resReal = resReal - arrRep(d);
	sub = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do 
		resReal = resReal * arrRep(d);
	mul = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do 
		resReal = resReal / arrRep(d);
	div = t.stop();
	res = resReal;
	writeln("Replica\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
}

proc dist_prim_types_rw() {
	var space = [1..n, 1..n];
	var asg, add, sub, mul, div: real;
	var resReal: real;
	
	writeln("Evaluation of Array with Types (Read & Write)");
	writeln("# of ops: ", n, ", time unit: usec");

	var blockSpace = space dmapped Block(boundingBox=space);
	var arrBlock: [blockSpace] real;
	t.start();
	for d in arrBlock.domain do on myLocale do
		arrBlock(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrBlock.domain do on myLocale do 
		arrBlock(d) = arrBlock(d) + d(1); 
	add = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do
		arrBlock(d) = arrBlock(d) - d(2);
	sub = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do
		arrBlock(d) = arrBlock(d) * d(1);
	mul = t.stop();
	
	t.start();
	for d in arrBlock.domain do on myLocale do 
		arrBlock(d) = arrBlock(d) / d(2);
	div = t.stop();
	res = resReal;
	writeln("Block\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);

	const cyclicSpace = space dmapped Cyclic(startIdx=space.low);
	var arrCyclic: [cyclicSpace] real;
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		arrCyclic(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrCyclic.domain do on myLocale do 
		arrCyclic(d) = arrCyclic(d) + d(1); 
	add = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		arrCyclic(d) = arrCyclic(d) - d(2);
	sub = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do 
		arrCyclic(d) = arrCyclic(d) * d(1);
	mul = t.stop();
	
	t.start();
	for d in arrCyclic.domain do on myLocale do
		arrCyclic(d) = arrCyclic(d) / d(2);
	div = t.stop();
	res = resReal;
	writeln("Cyclic\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
	
	const blkCycSpace = space dmapped BlockCyclic(startIdx=space.low, 
												  blocksize=(1, 2));
	var arrBlkCyc: [blkCycSpace] real;
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		arrBlkCyc(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrBlkCyc.domain do on myLocale do 
		arrBlkCyc(d) = arrBlkCyc(d) + d(1); 
	add = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do
		arrBlkCyc(d) = arrBlkCyc(d) - d(2); 
	sub = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do
		arrBlkCyc(d) = arrBlkCyc(d) * d(1); 
	mul = t.stop();
	
	t.start();
	for d in arrBlkCyc.domain do on myLocale do
		arrBlkCyc(d) = arrBlkCyc(d) / d(2); 
	div = t.stop();
	res = resReal;
	writeln("BlockCyc\t\t",asg,"\t",add,"\t",sub,"\t",mul,"\t",div);

	const replicatedSpace = space dmapped ReplicatedDist();
	var arrRep: [replicatedSpace] real;
	
	t.start();
	for d in arrRep.domain do on myLocale do
		arrRep(d) = (d(1) - 1) * n + d(2);
	asg = t.stop();

	t.start();
	for d in arrRep.domain do on myLocale do
		arrRep(d) = arrRep(d) + d(1); 
	add = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do
		arrRep(d) = arrRep(d) - d(2); 
	sub = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do
		arrRep(d) = arrRep(d) * d(1); 
	mul = t.stop();
	
	t.start();
	for d in arrRep.domain do on myLocale do
		arrRep(d) = arrRep(d) / d(2); 
	div = t.stop();
	res = resReal;
	writeln("Replica\t\t\t",asg,"\t\t",add,"\t\t",sub,"\t\t",mul,"\t\t",div);
}

proc main() {
	dist_prim_types_r();
	dist_prim_types_rw();
}
