# 📌 DSP Radix-2 FFT Filter Design 프로젝트

- [📌 DSP Radix-2 FFT Filter Design 프로젝트](#-dsp-radix-2-fft-filter-design-프로젝트)
    - [🎯 프로젝트 개요](#-프로젝트-개요)
    - [🙋‍♂️ 역할 분담](#️-역할-분담)
    - [💻 개발 환경](#-개발-환경)
    - [📂 프로젝트 구조](#-프로젝트-구조)
    - [🏗️ FFT 구조](#️-fft-구조)
    - [🔎 알고리즘 검증](#-알고리즘-검증)
    - [🔎 검증 및 시뮬레이션](#-검증-및-시뮬레이션)
    - [🛠️ Trouble Shooting](#️-trouble-shooting)
    - [🧠 고찰](#-고찰)

---

### 🎯 프로젝트 개요

---

### 🙋‍♂️ 역할 분담

---

### 💻 개발 환경

- **EDA Tools**: Xilinx Vivado HLx Editions, Synopsys VCS, Synopsys Verdi  
- **Languages**: SystemVerilog, MATLAB  
- **IDE / Tools**: Visual Studio Code, MobaXterm  

---

### 📂 프로젝트 구조

```
FFT-Design/
├── docs/           # 설계 보고서, 참고 자료
├── software/        # 알고리즘 검증
├── hardware/   
│    ├── rtl/        # SystemVerilog 설계 소스
│    ├── sim/        # 시뮬레이션 스크립트
│    ├── syn/        # 합성 스크립트 및 리포트
│    └── testbench/  # 시뮬레이션 테스트벤치
└── README.md
```

---

### 🏗️ FFT 구조


### 🔎 알고리즘 검증

📂 [참고문헌](./FFT-Design/Docs/A new approach to pipeline FFT processor.pdf)
📂 [MATLAB 알고리즘 검증 코드](./FFT-Design/Software)

---

### 🔎 검증 및 시뮬레이션

🔎 RTL Level 검증 (Synopsys 시뮬레이션)

- 주요 모듈: Butterfly 단위 연산, 파이프라인 레지스터, Twiddle ROM, 제어 로직, BFP/CBFP 모듈 등  
- 데이터 흐름, 제어 신호, 모듈 인터페이스 및 역할 설명  

---

🔎 Gate Level 검증 (Synopsys 시뮬레이션)
- 합성 도구 (예: Synopsys Design Compiler) 사용  
- 면적(area), 타이밍(timing), 파워 및 클록 제약 등 분석 

---

🔎 FPGA 검증 (Vivado 시뮬레이션)
- FPGA에서의 실제 동작 시험, 리소스(utilization)

---

### 🛠️ Trouble Shooting

---

### 🧠 고찰

---