

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AI allocation decisions
% Wilcoxon rank-sum tests
% Holm-Bonferroni and Benjamini-Hochberg corrections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;

% Significance level
alpha = 0.05;

%% =========================================================
%1. Load data
% ==========================================================

alldata = readtable('Ambiguous_case_base.xlsx');

% Remove observations with missing self_amount
alldata = alldata(~isnan(alldata.self_amount), :);

%% =========================================================
%2. Extract observations by condition
% ==========================================================

% Female
female_keep = alldata.self_amount( ...
    strcmp(alldata.condition, 'female-keep'));

female_give = alldata.self_amount( ...
    strcmp(alldata.condition, 'female-give'));

% Male
male_keep = alldata.self_amount( ...
    strcmp(alldata.condition, 'male-keep'));

male_give = alldata.self_amount( ...
    strcmp(alldata.condition, 'male-give'));

% Unspecified
unspecified_keep = alldata.self_amount( ...
    strcmp(alldata.condition, 'unspecified-keep'));

unspecified_give = alldata.self_amount( ...
    strcmp(alldata.condition, 'unspecified-give'));




%% =========================================================
% 3. Raw Wilcoxon rank-sum tests
% ==========================================================

p_raw = zeros(9,1);


% ----------------------------------------------------------
% Family 1: Gender comparisons
% Six tests
% ----------------------------------------------------------

% Give framing
p_raw(1) = ranksum(female_give, male_give);
p_raw(2) = ranksum(female_give, unspecified_give);
p_raw(3) = ranksum(male_give, unspecified_give);

% Keep framing
p_raw(4) = ranksum(female_keep, male_keep);
p_raw(5) = ranksum(female_keep, unspecified_keep);
p_raw(6) = ranksum(male_keep, unspecified_keep);


% ----------------------------------------------------------
% Family 2: Framing comparisons
% Three tests
% ----------------------------------------------------------

p_raw(7) = ranksum(female_give, female_keep);
p_raw(8) = ranksum(male_give, male_keep);
p_raw(9) = ranksum(unspecified_give, unspecified_keep);


%% =========================================================
% 4. Multiple-testing corrections
% ==========================================================

p_holm = nan(9,1);
p_bh   = nan(9,1);

significant_holm = false(9,1);
significant_bh   = false(9,1);


% ----------------------------------------------------------
% Family 1: six gender comparisons
% ----------------------------------------------------------

[p_holm(1:6), significant_holm(1:6)] = ...
    holm_adjust(p_raw(1:6), alpha);

[p_bh(1:6), significant_bh(1:6)] = ...
    bh_adjust(p_raw(1:6), alpha);


% ----------------------------------------------------------
% Family 2: three framing comparisons
% ----------------------------------------------------------

[p_holm(7:9), significant_holm(7:9)] = ...
    holm_adjust(p_raw(7:9), alpha);

[p_bh(7:9), significant_bh(7:9)] = ...
    bh_adjust(p_raw(7:9), alpha);


%% =========================================================
% 5. Create labels
% ==========================================================

comparison = [
    "Female vs male, give"
    "Female vs unspecified, give"
    "Male vs unspecified, give"
    "Female vs male, keep"
    "Female vs unspecified, keep"
    "Male vs unspecified, keep"
    "Give vs keep, female"
    "Give vs keep, male"
    "Give vs keep, unspecified"
];

family = [
    repmat("Gender comparisons", 6, 1)
    repmat("Framing comparisons", 3, 1)
];


%% =========================================================
% 6. Create results table
% ==========================================================

results_table = table( ...
    family, ...
    comparison, ...
    p_raw, ...
    p_holm, ...
    p_bh, ...
    significant_holm, ...
    significant_bh, ...
    'VariableNames', { ...
        'TestFamily', ...
        'Comparison', ...
        'RawP', ...
        'HolmAdjustedP', ...
        'BHAdjustedP', ...
        'SignificantAfterHolm', ...
        'SignificantAfterBH' ...
    } ...
);

disp(results_table);


%% =========================================================
% 7. Print results
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('Wilcoxon rank-sum tests with multiple-testing correction\n');
fprintf('alpha = %.2f\n', alpha);
fprintf('====================================================\n\n');


for i = 1:height(results_table)

    fprintf('%s\n', results_table.Comparison(i));

    fprintf('  Raw p-value:             %.8f\n', ...
        results_table.RawP(i));

    fprintf('  Holm-adjusted p-value:   %.8f\n', ...
        results_table.HolmAdjustedP(i));

    fprintf('  BH-adjusted p-value:     %.8f\n', ...
        results_table.BHAdjustedP(i));


    % Holm result
    if results_table.SignificantAfterHolm(i)

        fprintf('  Holm result: significant at alpha = %.2f\n', ...
            alpha);

    else

        fprintf('  Holm result: not significant at alpha = %.2f\n', ...
            alpha);

    end


    % BH result
    if results_table.SignificantAfterBH(i)

        fprintf('  BH result:   significant at alpha = %.2f\n', ...
            alpha);

    else

        fprintf('  BH result:   not significant at alpha = %.2f\n', ...
            alpha);

    end

    fprintf('\n');

end


%% =========================================================
% 8. Save results
% ==========================================================

writetable( ...
    results_table, ...
    'baseline_wilcoxon_multiple_testing_results_ambiguous.xlsx' ...
);

fprintf('Results saved to:\n');
fprintf('baseline_wilcoxon_multiple_testing_results_ambiguous.xlsx\n');


%% =========================================================
% Local function 1:
% Holm-Bonferroni adjustment
% ==========================================================

function [p_adjusted, significant] = holm_adjust(p_raw, alpha)

    % Convert to column vector
    p_raw = p_raw(:);

    % Check input
    if any(isnan(p_raw))
        error('The p-value vector contains missing values.');
    end

    if any(p_raw < 0 | p_raw > 1)
        error('All p-values must be between 0 and 1.');
    end


    % Sort p-values from smallest to largest
    [p_sorted, sort_index] = sort(p_raw);

    m = numel(p_sorted);


    % Holm adjustment:
    %
    % smallest p * m
    % second smallest p * (m-1)
    % ...
    % largest p * 1

    multipliers = (m:-1:1)';

    p_adjusted_sorted = multipliers .* p_sorted;


    % Enforce monotonicity
    p_adjusted_sorted = cummax(p_adjusted_sorted);


    % Adjusted p-values cannot exceed 1
    p_adjusted_sorted = min(p_adjusted_sorted, 1);


    % Return to original order
    p_adjusted = zeros(m,1);

    p_adjusted(sort_index) = p_adjusted_sorted;


    % Significance based on adjusted p-values
    significant = p_adjusted < alpha;

end


%% =========================================================
% Local function 2:
% Benjamini-Hochberg adjustment
% ==========================================================

function [p_adjusted, significant] = bh_adjust(p_raw, alpha)

    % Convert to column vector
    p_raw = p_raw(:);

    % Check input
    if any(isnan(p_raw))
        error('The p-value vector contains missing values.');
    end

    if any(p_raw < 0 | p_raw > 1)
        error('All p-values must be between 0 and 1.');
    end


    % Sort p-values from smallest to largest
    [p_sorted, sort_index] = sort(p_raw);

    m = numel(p_sorted);

    ranks = (1:m)';


    % Initial Benjamini-Hochberg adjusted p-values
    %
    % p(i) * m / rank(i)

    p_adjusted_sorted = p_sorted .* m ./ ranks;


    % Enforce monotonicity
    % Work backwards from largest p-value

    for i = m-1:-1:1

        p_adjusted_sorted(i) = min( ...
            p_adjusted_sorted(i), ...
            p_adjusted_sorted(i+1) ...
        );

    end


    % Adjusted p-values cannot exceed 1
    p_adjusted_sorted = min(p_adjusted_sorted, 1);


    % Return adjusted p-values to original order
    p_adjusted = zeros(m,1);

    p_adjusted(sort_index) = p_adjusted_sorted;


    % Significance based on adjusted p-values
    significant = p_adjusted < alpha;

end