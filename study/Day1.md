# Day 1

## Setup/Hold Time

### Switching이 일어난 후 상태의 변화가 정확히 인식되도록 필요한 최소 시간

![alt text](../img/Day1/image3.png)

## Critical Path (임계 경로)
- 입력에서 출력까지 모든 경로 중에서 propagation delay(지연 시간)이 가장 긴 경로
- Critical Path는 회로의 **최대 동작 주파수**를 결정

![alt text](../img/Day1/image4.png)

- 가장 큰 propagation delay를 갖는 path (Setup violation에 영향)
- Scenario2 가 Scenario 1보다 큰 딜레이를 가지고 있으므로 

### 왜 중요한가?
- Setup Time Violation은 

## for vs generate

```sv
genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : bfly_mul
        assign out_re[i] = (bfly_re[i] * tw_re) - (bfly_im[i] * tw_im);
        assign out_im[i] = (bfly_im[i] * tw_re) + (bfly_re[i] * tw_im);
    end
endgenerate
```
### 특징
    - Combinational logic (조합 논리)
    - 클럭에 의존하지 않음, 입력 바뀌면 바로 출력이 바뀜
    - 지연 없음 (곱셈기 + 덧셈기의 연산 지연만 존재)
    - 하드웨어 자원 = N개의 곱셈기 + 덧셈기

### 장점
    - 구조가 단순함 (배선 + 연산기)
    - 파이프라인 딜레이 없이 바로 결과 나옴

### 단점
    - 타이밍 여유가 부족할 수 있음 (곱셈+덧셈이 한 클럭에 모두 끝나야 함)
    - 레지스터가 없어서 파이프라인 최적화가 어려움 → 고속 클럭 설계에서 불리


```sv
integer i;
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for (i = 0; i < N; i = i + 1) begin
            out_re[i] <= 0;
            out_im[i] <= 0;
        end
    end else begin
        for (i = 0; i < N; i = i + 1) begin
            out_re[i] <= (bfly_re[i] * tw_re) - (bfly_im[i] * tw_im);
            out_im[i] <= (bfly_im[i] * tw_re) + (bfly_re[i] * tw_im);
        end
    end
end
```

### 특징
    - Sequential logic (순차 논리)
    - 클럭 동기화 → 한 클럭 뒤에 결과가 나옴
    - 레지스터에 저장 → 출력이 안정적

### 장점
    - 타이밍 여유가 커짐 (연산 결과를 레지스터로 받음)
    - 파이프라인 설계 가능 → 고속 설계에 유리
    - 동기화 쉬움 (파이프라인 단계별 동작 제어)

### 단점
    - 한 클럭 딜레이 생김
    - 레지스터 자원 추가 필요