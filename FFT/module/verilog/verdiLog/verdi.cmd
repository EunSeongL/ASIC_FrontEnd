simSetSimulator "-vcssv" -exec "./simv" -args " " -uvmDebug on
debImport "-i" "-simflow" "-dbdir" "./simv.daidir"
srcTBInvokeSim
verdiSetActWin -dock widgetDock_<Member>
verdiWindowResize -win $_Verdi_1 "8" "31" "2560" "1369"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvCreateWindow
verdiSetActWin -win $_nWave3
srcHBSelect "tb_fft_gate.dut" -win $_nTrace1
srcSetScope "tb_fft_gate.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_gate.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 459305 -pos 2 -win $_nTrace1
wvDumpScope "tb_fft_gate.dut"
wvSetPosition -win $_nWave3 {("dut" 0)}
wvRenameGroup -win $_nWave3 {G1} {dut}
wvAddSignal -win $_nWave3 "/tb_fft_gate/dut/clk" "/tb_fft_gate/dut/rstn" \
           "/tb_fft_gate/dut/valid_in" "/tb_fft_gate/dut/din_i\[143:0\]" \
           "/tb_fft_gate/dut/din_q\[143:0\]" "/tb_fft_gate/dut/valid_out" \
           "/tb_fft_gate/dut/dout_i\[207:0\]" \
           "/tb_fft_gate/dut/dout_q\[207:0\]"
wvSetPosition -win $_nWave3 {("dut" 0)}
wvSetPosition -win $_nWave3 {("dut" 8)}
wvSetPosition -win $_nWave3 {("dut" 8)}
srcTBRunSim
srcHBSelect "tb_fft_gate.dut" -win $_nTrace1
srcSetScope "tb_fft_gate.dut" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_gate.dut" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
wvSetCursor -win $_nWave3 1774999236.464088 -snap {("G2" 0)}
verdiSetActWin -win $_nWave3
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 1327229281.767956 1711036256.906077
wvSelectSignal -win $_nWave3 {( "dut" 7 )} 
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcSelect -win $_nTrace1 -range {459306 459320 1 1 1 1} -backward
srcHBSelect "tb_fft_gate.dut.U_MODULE0" -win $_nTrace1
srcSetScope "tb_fft_gate.dut.U_MODULE0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_gate.dut.U_MODULE0" -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "tb_fft_gate.dut.U_MODULE0.U_CBFP0" -win $_nTrace1
srcHBSelect "tb_fft_gate.dut.U_MODULE0.U_CBFP0" -win $_nTrace1
srcSetScope "tb_fft_gate.dut.U_MODULE0.U_CBFP0" -delim "." -win $_nTrace1
srcHBSelect "tb_fft_gate.dut.U_MODULE0.U_CBFP0" -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvSetPosition -win $_nWave3 {("dut" 3)}
wvSetPosition -win $_nWave3 {("dut" 6)}
wvSetPosition -win $_nWave3 {("dut" 7)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("dut" 0)}
wvSetPosition -win $_nWave3 {("G2" 0)}
wvDumpScope "tb_fft_gate.dut.U_MODULE0.U_CBFP0"
wvSetPosition -win $_nWave3 {("U_CBFP0" 0)}
wvRenameGroup -win $_nWave3 {G2} {U_CBFP0}
wvAddSignal -win $_nWave3 "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/clk" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/rstn" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/real_in\[367:0\]" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/imag_in\[367:0\]" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/in_valid" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/real_out\[175:0\]" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/imag_out\[175:0\]" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/index_out\[79:0\]" \
           "/tb_fft_gate/dut/U_MODULE0/U_CBFP0/valid_out"
wvSetPosition -win $_nWave3 {("U_CBFP0" 0)}
wvSetPosition -win $_nWave3 {("U_CBFP0" 9)}
wvSetPosition -win $_nWave3 {("U_CBFP0" 9)}
srcTBRebuild -fromVCSScript -reloadKDB -restartSim -simOpt "-sml=verdi "
verdiDockWidgetSetCurTab -dock windowDock_InteractiveConsole_2
verdiSetActWin -win $_InteractiveConsole_2
verdiDockWidgetSetCurTab -dock windowDock_nWave_3
verdiSetActWin -win $_nWave3
srcTBRunSim
wvSetCursor -win $_nWave3 1774992046.961326 -snap {("U_CBFP0" 3)}
wvZoomAll -win $_nWave3
wvZoom -win $_nWave3 463044544.198895 859232389.502762
debExit
