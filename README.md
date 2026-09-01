# 💻 CmpE 344 - Computer Organization & RISC-V CoreMark Suite

![Assembly](https://img.shields.io/badge/Language-RISC--V_Assembly-002244?style=for-the-badge&logo=riscv&logoColor=white)
![Course](https://img.shields.io/badge/Course-CmpE_344_Computer_Organization-blue?style=for-the-badge)
![Benchmark](https://img.shields.io/badge/Benchmark-EEMBC_CoreMark-orange?style=for-the-badge)
![Tool](https://img.shields.io/badge/Tools-GTKWave_%7C_Linker_Scripts-darkgreen?style=for-the-badge)
![Report](https://img.shields.io/badge/Report-LaTeX_Academic_Paper-008080?style=for-the-badge&logo=latex&logoColor=white)

---

## 📌 Executive Summary

This repository contains the complete practical assembly implementations, hardware memory linker configurations, GTKWave waveform signal traces, and EEMBC CoreMark CPU benchmarking studies for **CmpE 344 (Computer Architecture & Microprocessors)** at **Boğaziçi University**.

The repository brings together low-level hardware control, algorithm implementation in **RISC-V Assembly**, linker script memory layout design (`.ld`), waveform signal debugging (`.gtkw`), and empirical evaluation of compiler optimization levels (`-O0` to `-march=native`) on modern CPU architectures and RISC-V ISAs (`RV32I`, `RV32IM`, `RV32IMC`, `RV32GC`, `RV64I`).

Full academic paper source code is available in [`cpu-coremark-benchmarking/benchmark_report.tex`](cpu-coremark-benchmarking/benchmark_report.tex).

---

## 🚀 RISC-V Assembly Algorithms & Hardware Control

### 1. Flight Navigation & Refueling Router (`assembly-programming/riscv_flight_navigation.s`)
- Implements an automated flight router over a 10-airport matrix (Tokyo, Hong Kong, Singapore, Dubai, Istanbul, Brussels, Reykjavik, New York, Los Angeles, Honolulu).
- **Key Subroutines:**
  - `flight_navigation`: Evaluates distance/direction matrices to select reachable westward destinations.
  - `refuel`: Calculates fuel differential against tank capacity (`20,000` units) and updates airport supply.
  - `execute_flight`: Computes consumption rate, updates odometer, and state registers.

### 2. Hardware Memory Linker & GTKWave Waveforms (`hardware-linking-gtkwave/`)
- **Linker Script (`linker.ld`):** Maps `.text`, `.rodata`, `.data`, and `.bss` sections to physical memory addresses.
- **Waveform Trace (`signals.gtkw`):** Signal definitions for GTKWave digital logic timing diagram verification.

---

## 📈 EEMBC CoreMark CPU Benchmarking & Optimization Study

CoreMark exercises four primary computational workloads: **Linked List Operations, Matrix Multiplication, Finite State Machine parsing, and CRC Checksum verification**.

### Compiler Optimization Level Performance Comparison

| Optimization Level | Compiler Flags | Average Performance (Iter/Sec) | Speedup vs -O0 | Key Technical Characteristics |
| :--- | :--- | :--- | :--- | :--- |
| **Unoptimized** | `-O0` | **8,932.59** | **1.00$\times$** | Baseline unoptimized code generated for step debugging. |
| **Basic** | `-O1` | **22,740.23** | **2.55$\times$** | Applies fundamental register allocation & dead-code elimination. |
| **Moderate (Default)** | `-O2` | **28,196.89** | **3.16$\times$** | Industry standard balance of execution speed and code size. |
| **Aggressive** | `-O3` | **28,883.94** | **3.23$\times$** | Enables loop unrolling and aggressive function inlining. |
| **Fast Math** | `-Ofast` | **28,923.08** | **3.24$\times$** | Relaxed IEEE floating-point compliance rules. |
| **Architecture-Native**| **`-march=native`** | **36,818.41** | **4.12$\times$** | **Unlocks SIMD AVX2 and SSE4.2 hardware instruction sets.** |

---

## 🏛️ RISC-V Instruction Set Extension Architectures (ISAs)

| ISA Extension | Name & Description | Primary Embedded / System Use Case |
| :--- | :--- | :--- |
| **`RV32I`** | Base 32-Bit Integer (32 Registers $x_0..x_{31}$) | Microcontrollers & minimal viable embedded cores |
| **`RV32IM`** | Base Integer + Hardware Multiply & Divide | DSP & math-heavy embedded systems |
| **`RV32IMC`** | IM + Compressed 16-bit Instructions | Memory-constrained systems (25-30% code density savings) |
| **`RV32GC`** | General Purpose (I + M + A + F + D + C) | High-performance application processors (Linux OS ready) |
| **`RV64I`** | Base 64-Bit Integer (64-bit Addressing) | Datacenter servers and 64-bit desktop architectures |

---

## 📂 Repository Structure

```
CmpE344-Computer-Architecture-RISCV-CoreMark/
├── assembly-programming/
│   ├── riscv_flight_navigation.s      # Complete 10-Airport Flight Router & Refueling Assembly Algorithm
│   ├── riscv_assembly_basics.s        # Fundamental RISC-V Assembly Subroutines & Register Manipulation
│   └── problem_spec.txt               # Algorithm Problem Specification Document
├── hardware-linking-gtkwave/
│   ├── riscv_hardware_control.s       # Low-level RISC-V Assembly Hardware Execution Control
│   ├── linker.ld                      # Memory Layout Linker Script (.text, .data, .bss mapping)
│   └── signals.gtkw                   # GTKWave Waveform Logic Signal Configuration File
├── cpu-coremark-benchmarking/
│   ├── benchmark_report.tex           # Full LaTeX Academic Report Source (Benchmarking & RISC-V ISAs)
│   └── coremark/                      # EEMBC CoreMark C Source Suite & Makefiles
├── .gitattributes                     # LF line ending configuration
└── .gitignore                         # Excludes compiled binaries (*.exe, *.o) & build log dumps
```

---

## 👨‍💻 Author

**Ahmet Meriç Kızıltaş**  
*Department of Computer Engineering, Boğaziçi University*  
[Student ID: 2022400225]
