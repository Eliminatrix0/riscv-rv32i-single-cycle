# RISC-V RV32I Single-Cycle Processor

A fully functional single-cycle RISC-V processor implementing the RV32I base integer ISA, designed in Verilog. Supports R, I, S, B, and J-type instructions with a clean separation between datapath and control path.

---

## Architecture Overview

The processor follows a classic Harvard-style single-cycle architecture with two top-level components:

- **Datapath** — Handles all data flow: PC, instruction memory, register file, ALU, data memory, and the mux network connecting them.
- **Control Path (CU)** — Decodes the instruction opcode and function fields to generate all control signals for the datapath.

```
         ┌─────────────────────────────────────────────┐
         │                  top_module                  │
         │                                              │
         │   ┌──────────┐       ┌──────────────────┐   │
         │   │ datapath │◄─────►│   controlpath    │   │
         │   │          │       │  (control unit)  │   │
         │   └──────────┘       └──────────────────┘   │
         └─────────────────────────────────────────────┘
```

---

## Module Breakdown

| Module | File | Description |
|---|---|---|
| `top_module` | `top_module.v` | Integrates datapath and control path |
| `datapath` | `datapath.v` | PC, mux network, sub-module instantiations |
| `controlpath` | `controlpath.v` | Instruction decoder, control signal generation |
| `ALU` | `ALU.v` | Arithmetic, shift, and logical execution unit |
| `Imm_Sign_Extend` | `Imm_Sign_Extend.v` | Immediate field extraction and sign extension |
| `Reg_file` | `Reg_file.v` | 32×32 general purpose register file |
| `IM` | `IM.v` | Instruction memory |
| `DM` | `DM.v` | Data memory |

---

## Datapath Design

The datapath wires all components together through a mux network driven by control signals:

- **PC Logic**: On each clock edge, PC updates to either `PC+4` (sequential) or `PC+imm` (branch/jump target), selected by `br_taken`.
- **srcB Mux**: Selects between `rf_rd2` (register) and sign-extended immediate — controlled by `sel_srcB`.
- **RF Write-back Mux** (`sel_ld`): Selects what gets written to the register file:
  - `00` → ALU output (R/I-type)
  - `10` → Data memory read (load)
  - `01` → `PC+4` (JAL return address)

---

## Control Path Design

The control unit decodes using three instruction fields:

```
op       = instr[6:0]    // Opcode
func3    = instr[14:12]  // Function (type disambiguation)
func7_5  = instr[30]     // Differentiates ADD/SUB, SRL/SRA
```

| Instruction Type | Opcode | Key Control Actions |
|---|---|---|
| R-type | `0110011` | `RF_WEN=1`, `sel_srcB=0` (register) |
| I-type (ALU) | `0010011` | `RF_WEN=1`, `sel_srcB=1` (immediate) |
| Load | `0000011` | `RF_WEN=1`, `sel_ld=10`, reads from DM |
| Store | `0100011` | `DM_WEN=1`, no RF write |
| Branch (B) | `1100011` | `br_taken` driven by ALU zero flag |
| Jump (J / JAL) | `1101111` | `br_taken=1` (unconditional), saves `PC+4` to RF |

---

## ALU

The execution unit is composed of three sub-units:

- **Adder/Subtractor**: Handles ADD, SUB, and flag generation (Zero `z`, Carry `c`, Negative `n`)
- **Barrel Shifter**: Handles SLL, SRL, SRA — takes lower 5 bits of srcB as shift amount
- **Logical Unit**: Handles AND, OR, XOR

Final output selected by `sel_exec_out` mux:
- `00` → Adder/Subtractor result
- `01` → SLT/SLTU comparison result
- `10` → Logical result
- `11` → Shift result

---

## Immediate Sign Extension

The `Imm_Sign_Extend` module handles all four immediate formats of RV32I:

| `sel_imm` | Type | Bit Extraction |
|---|---|---|
| `00` | I-type | `instr[31:20]` sign-extended |
| `01` | S-type | `instr[31:25]`, `instr[11:7]` concatenated |
| `10` | B-type | Bits rearranged with LSB = 0 (byte alignment) |
| `11` | J-type | 20-bit offset rearranged with LSB = 0 |

---

## Supported Instructions

**R-type**: `ADD`, `SUB`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`, `AND`, `OR`, `XOR`

**I-type**: `ADDI`, `SLLI`, `SRLI`, `SRAI`, `SLTI`, `SLTIU`, `ANDI`, `ORI`, `XORI`, `LW`

**S-type**: `SW`

**B-type**: `BEQ`

**J-type**: `JAL`

---

## Repository Structure

```
├── Design files/
│   ├── top_module.v        # Top-level integration
│   ├── datapath.v          # Datapath with mux network
│   ├── controlpath.v       # Control unit / instruction decoder
│   ├── ALU.v               # Execution unit (arith + shift + logical)
│   ├── Imm_Sign_Extend.v   # Immediate extraction and sign extension
│   ├── Reg_file.v          # 32×32 register file
│   ├── IM.v                # Instruction memory
│   └── DM.v                # Data memory
│
└── Simulation files/
    ├── top_tb.v            # Top-level testbench
    ├── Reg_file_tb.v       # Register file testbench
    ├── exec_ALU_tb.v       # ALU testbench
    └── IM_tb.v             # Instruction memory testbench
```

---

## Tools

- **HDL**: Verilog (IEEE 1364)
- **Simulator**: Xilinx Vivado (Behavioral Simulation)
- **Target**: Simulation only (not synthesized to FPGA)

---

## Key Design Notes

- Instruction and data memories are separate (Harvard architecture).
- The `controlpath` is purely combinational — all registers live in the datapath.
- The `func7_5` trick for distinguishing ADD/SUB and SRL/SRA keeps decode logic minimal and clean, consistent with the RV32I ISA design philosophy.
- Branch resolution is combinational — `br_taken` is directly driven by ALU flags, so no branch delay slots are needed.
