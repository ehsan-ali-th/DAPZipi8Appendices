

Appendix A
Authors: - Ehsan Ali:		ehssan.aali@gmail.com
	   - Wanchalerm Pora	wanchalerm.p@chula.ac.th
Last modfied: 23-Feb-2022

-------------------------------------------------------------------------------

Folder content:

- DAP-Zipi8_Vivado_project: Contains DAP-zipi8 Vivado 2020.1 project. 
- DAP-Zipi8_Vivado_project/zipi8_1ipc.srcs/sources_1/new : Contains the VHDL source code of DAP-Zipi8 modules - top.vhd is the main wrapper and any attempt to understand the project should start from there.


DAP-Zipi8 is a PicoBlaze compatible soft-core processors developed in Electrical Engineering Department of Chulalongkorn University of Thailand. It improves the raw performance of original Xilinx PicoBlaze by 25.31%. After considering the NOPs the observed performance improved is 18.28–19.49% depending on the instruction sequence used in rge assembly language of an algorithm. 


In order to use Zipi8 in your project just import all VHDL files in 
 - DAP-Zipi8_Vivado_project/zipi8_1ipc.srcs/sources_1/new
 - DAP-Zipi8_Vivado_project/zipi8_1ipc.srcs/sources_1/imports/new/ 

to your project.

Three IPs that must be instantiated are as follows:
1. clk_wiz_0 		: Clocking Wizard version 6.0 (Rev. 5)
2. proc_sys_reset_0	: Processor System Reset (5.0)
3. program_memory		: Block Memory Generator (8.4)	

The setting of the following IPs can be seen by opening the Vivado project and double clicking on each IP. That brings the customization window which shows the current IP setting.