# FPGA Whack-a-Mole Game 

A hardware implementation of the classic Whack-a-Mole game on the Digilent Nexys 4 FPGA board.

## Tech Stack
- **Language:** VHDL
- **Hardware:** Digilent Nexys 4 (Artix-7)
- **Tools:** Xilinx Vivado

## Key Features
- **Game Logic:** Implemented using Finite State Machines (FSM).
- **Randomization:** Uses LFSR (Linear-Feedback Shift Register) for random LED target generation.
- **Input Handling:** Includes switch debouncing logic for reliable user inputs.

## How to Run
1. Open the project in Xilinx Vivado.
2. Import the VHDL source files and the Nexys 4 `.xdc` constraint file.
3. Run Synthesis, Implementation, and Generate Bitstream.
4. Program the FPGA board.
