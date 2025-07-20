clc;
clear;

threshold = 0.1;  % 절대 오차 기준 0.01, 퍼센트 기준이면 1% → threshold = 0.01 (1%)
epsilon = 1e-12;   % 0 나누기 방지용 아주 작은 수

steps = {
    '0_0', '0_1', '0_2', ...
    '1_0', '1_1', '1_2', ...
    '2_0', '2_1', '2_2'
};

fprintf('=== FFT 단계별 비교 시작 ===\n');
fprintf('허용 오차(threshold) = %.1e (절대값 기준)\n\n', threshold);

for i = 1:length(steps)
    tag = steps{i};
    golden_file = sprintf('float_step%s.txt', tag);
    test_file   = sprintf('fixed_step%s.txt', tag);

    fprintf('--- Step %s ---\n', tag);

    try
        golden = load_step(golden_file);
    catch
        fprintf('❌ 참값 파일 없음: %s\n', golden_file);
        continue;
    end

    try
        test = load_step(test_file);
    catch
        fprintf('❌ 테스트 파일 없음: %s\n', test_file);
        continue;
    end

    if length(golden) ~= length(test)
        fprintf('⚠️ 데이터 길이 불일치: %d vs %d\n', length(golden), length(test));
        continue;
    end

    % 절대값 차이 계산
    diff_abs = abs(golden - test);

    % 상대 오차(%) 계산
    diff_rel = diff_abs ./ (abs(golden) + epsilon) * 100;  % % 단위

    % 절대값 차이 통계 출력
    fprintf('Max absolute diff : %.2e\n', max(diff_abs));
    fprintf('Mean absolute diff: %.2e\n', mean(diff_abs));

    % 상대 오차 통계 출력
    fprintf('Max relative diff : %.2f %%\n', max(diff_rel));
    fprintf('Mean relative diff: %.2f %%\n', mean(diff_rel));

    % 상대 오차 임계값 초과 인덱스
    bad_idx = find(diff_rel > threshold * 100); % threshold를 % 단위로 변환해서 비교
    if isempty(bad_idx)
        disp('✅ 상대 차이 없음 (threshold 이하)');
    else
        fprintf('⚠️ 상대 차이 큰 인덱스 (>%g%%): %d 개\n', threshold*100, numel(bad_idx));
        fprintf('   예시 인덱스: ');
        disp(bad_idx(1:min(10,end))');
    end

    fprintf('\n');
end

fprintf('=== 비교 완료 ===\n');

%% 파일 로드 함수
function data = load_step(filename)
    fid = fopen(filename);
    if fid == -1
        error('파일 열기 실패: %s', filename);
    end
    C = textscan(fid, 'idx=%d, val=%f+j%f');
    fclose(fid);

    data = C{2} + 1j*C{3};
end
