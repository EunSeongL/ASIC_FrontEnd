#------------------------------------------------------------------
# Copyright (c) 2013 by Ando Ki.
# All right reserved.
#
# This code is distributed in the hope that it will
# be useful to understand Ando Ki's work,
# but WITHOUT ANY WARRANTY.
#------------------------------------------------------------------
SHELL		= /bin/sh
MAKEFILE	= Makefile
#------------------------------------------------------------------
ARCH	= $(shell uname)
ifeq ($(ARCH), CYGWIN_NT-5.1)
else
ifeq ($(ARCH), MINGW32_NT-5.1)
else
endif
endif
#--------------------------------------------------------
VLIB	= $(shell which vlib)
VLOG	= $(shell which vlog)
VSIM	= $(shell which vsim)
WORK	= simv
#--------------------------------------------------------
TOP	= top
#--------------------------------------------------------
all: vcs

irun:
	irun 

vcs:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	vcs -f run.f -full64 -kdb -sverilog  -debug_acc+all

rev:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	vcs -f run.f -full64 -kdb -sverilog -debug_acc+all+reverse -lca
	./simv -verdi -sv -f run.f &

test:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	vcs -sverilog -full64 -kdb -debug_acc+all test*
	./simv

save:
	./simv -r test.chk

cov:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	vcs -full64 -kdb -debug_acc+all -f run.f  -lca -cm line+tgl+fsm+branch+cond
	./simv -Xdprof=timeline+trace:all -cm line+tgl+fsm+branch+cond
	verdi -cov -covdir ./simv.vdb &

xrun:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	xrun -64bit -access +rwc -f run.f

verdi:
	verdi -sv -f run.f &

replay:
	cp verdiLog/verdi.cmd .
	verdi -play verdi.cmd
	
vlib:
	if [ -d $(WORK) ]; then /bin/rm -rf $(WORK); fi
	($(VLIB) $(WORK) || exit -1) 2>&1 | tee compile.log

compile:
	($(VLOG) -lint -work $(WORK)\
		-f run.f || exit -1) 2>&1 | tee compile.log

simulate: compile
	$(VSIM) -novopt -c -do "add wave *; run -all; quit"\
		$(WORK).$(TOP)

#--------------------------------------------------------
clean:
	-@/bin/rm -rf $(WORK)
	-@/bin/rm -f  transcript
	-@/bin/rm -f  wave.vcd dump.vcd
	-@/bin/rm -f  vsim.wlf
	-@/bin/rm -f  vish_stacktrace.vstf
	-@/bin/rm -f  wlft*
	-@/bin/rm -f  compile.log
	-@/bin/rm -f  xrun.history
	-@/bin/rm -f  xrun.log
	-@/bin/rm -f  novas*
	-@/bin/rm -rf  Verdi*
	-@/bin/rm -f  wave.fsdb
	-@/bin/rm -rf  verdiLog *.vpd
	-@/bin/rm -rf  verdi.cmd
	-@/bin/rm -rf  Verdi*
	-@/bin/rm -rf  *.log
	-@/bin/rm -rf  simv.vdb
	-@/bin/rm -rf  dprof*
	-@/bin/rm -rf  vdCov*
	-@/bin/rm -rf  test.chk*
	-@/bin/rm -rf  inter*
	-@/bin/rm -rf  simv csrc simv.daidir ucli.key

cleanup: clean

clobber: cleanup
#--------------------------------------------------------
