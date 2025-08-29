# 📌 512 Point Radix-2 FFT Filter Design

### 🎯 프로젝트 개요
- MATLAB을 활용해 Radix-2 FFT의 Butterfly 구조를 구현하고 Floating-Point와 Fixed-Point 차이를 분석하였으며, BFP와 CBFP를 적용한 알고리즘을 검증했습니다. 이후 소프트웨어 모델링을 기반으로 하드웨어 모듈을 설계하고, Synopsys EDA Tool을 이용해 RTL 및 Gate Level 검증을 수행하였으며, Vivado를 활용해 FPGA 검증과 비트스트림 생성을 포함한 전반적인 Front-End 과정을 진행했습니다.
---

### 🙋‍♂️ 역할 분담

#### 🐲윤종민
- 역할
#### 🦖이현수
- 역할 
#### 🐉이은성
- 역할
#### 🥊장환
- 역할

---

### 💻 개발 환경

| 구분        | 사용 도구 / 언어 |
|------------|----------------|
| **EDA Tools** | Xilinx Vivado HLx Editions, Synopsys VCS, Synopsys Verdi |
| **Languages** | SystemVerilog, MATLAB |
| **IDE / Tools** | Visual Studio Code, MobaXterm |

---

### 📂 프로젝트 구조

```
FFT-Design/
├── docs/            # 설계 보고서, 참고 자료
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

---

### 🔎 알고리즘 검증

📂 [참고문헌](./Docs) <br>
📂 [MATLAB 알고리즘 검증 코드](./Software)

---

### 🔎 검증 및 시뮬레이션

🔎 **RTL Level 검증 (Synopsys 시뮬레이션)**

- 주요 모듈: Butterfly 단위 연산, 파이프라인 레지스터, Twiddle ROM, 제어 로직, BFP/CBFP 모듈 등  
- 데이터 흐름, 제어 신호, 모듈 인터페이스 및 역할 설명  

---

🔎 **Gate Level 검증 (Synopsys 시뮬레이션)**
- 합성 도구 (예: Synopsys Design Compiler) 사용  
- 면적(area), 타이밍(timing), 파워 및 클록 제약 등 분석 

---

🔎 **FPGA 검증 (Vivado 시뮬레이션)**
- FPGA에서의 실제 동작 시험, 리소스(utilization)

---

### 🛠️ Trouble Shooting

---

### 🧠 고찰 및 개선 점

```
Area 개선
Clock 줄이기
Code 최적화
```


---



