

%%%%%%%%%%%%%%%%%%
% This section contains all Willcoxon Rank-Sum tests in the paper
%%%%%%%%%%%%%%%%%%

clear all
clc

alldata_baseline = table();   

for i = 1:14
    filename = ['baseline_output_chatgpt_session', num2str(i), '.xlsx'];
    temp = readtable(filename);
    alldata_baseline = [alldata_baseline; temp];   
end


alldata_sa = table();   

for i = 1:6
    filename = ['output_appropriate_', num2str(i), '.xlsx'];
    temp = readtable(filename);
    alldata_sa = [alldata_sa; temp];   
end


%%

alldata_baseline = alldata_baseline(~isnan(alldata_baseline.self_amount), :);

% ---------- female ----------
female_keep_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'female-keep'));

female_give_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'female-give'));

% ---------- male ----------

male_keep_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'male-keep'));

male_give_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'male-give'));

% ---------- unspecified ----------

unspecified_keep_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'unspecified-keep'));

unspecified_give_baseline = alldata_baseline.self_amount( ...
    strcmp(alldata_baseline.question_id,'unspecified-give'));


alldata_sa = alldata_sa(~isnan(alldata_sa.self_amount), :);

% ---------- female ----------
female_keep_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'female-keep'));

female_give_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'female-give'));

% ---------- male ----------

male_keep_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'male-keep'));

male_give_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'male-give'));

% ---------- unspecified ----------

unspecified_keep_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'unspecified-keep'));

unspecified_give_sa = alldata_sa.self_amount( ...
    strcmp(alldata_sa.question_id,'unspecified-give'));



%%

p1 = ranksum(female_give_baseline, female_give_sa);
p2 = ranksum(male_give_baseline, male_give_sa);
p3 = ranksum(unspecified_give_baseline, unspecified_give_sa);
p4 = ranksum(female_keep_baseline, female_keep_sa);
p5 = ranksum(male_keep_baseline, male_keep_sa);
p6 = ranksum(unspecified_keep_baseline, unspecified_keep_sa);



fprintf('female_give_baseline vs female_give_sa: p = %.4f\n', p1);
fprintf('male_give_baseline vs male_give_sa: p = %.4f\n', p2);
fprintf('unspecified_give_baseline vs unspecified_give_sa: p = %.4f\n', p3);
fprintf('female_keep_baseline vs female_keep_sa: p = %.4f\n', p4);
fprintf('male_keep_baseline vs male_keep_sa: p = %.4f\n', p5);
fprintf('unspecified_keep_baseline vs unspecified_keep_sa: p = %.4f\n', p6);

