

%%%%%%%%%%%%%%%%%%
% This section contains all Willcoxon Rank-Sum tests in the paper
%%%%%%%%%%%%%%%%%%

clear all
clc

alldata = table();   

for i = 1:6
    filename = ['output_appropriate_', num2str(i), '.xlsx'];
    temp = readtable(filename);
    alldata = [alldata; temp];   
end


alldata = alldata(~isnan(alldata.self_amount), :);

% ---------- female ----------
female_keep = alldata.self_amount( ...
    strcmp(alldata.question_id,'female-keep'));

female_give = alldata.self_amount( ...
    strcmp(alldata.question_id,'female-give'));

% ---------- male ----------

male_keep = alldata.self_amount( ...
    strcmp(alldata.question_id,'male-keep'));

male_give = alldata.self_amount( ...
    strcmp(alldata.question_id,'male-give'));

% ---------- unspecified ----------

unspecified_keep = alldata.self_amount( ...
    strcmp(alldata.question_id,'unspecified-keep'));

unspecified_give = alldata.self_amount( ...
    strcmp(alldata.question_id,'unspecified-give'));




p1 = ranksum(female_give, male_give);
p2 = ranksum(female_give, unspecified_give);
p3 = ranksum(male_give, unspecified_give);
p4 = ranksum(female_keep, male_keep);
p5 = ranksum(female_keep, unspecified_keep);
p6 = ranksum(male_keep, unspecified_keep);
p7 = ranksum(female_give, female_keep);
p8 = ranksum(male_give, male_keep);
p9 = ranksum(unspecified_give, unspecified_keep);


fprintf('female_give vs male_give: p = %.4f\n', p1);
fprintf('female_give vs unspecified_give: p = %.4f\n', p2);
fprintf('male_give vs unspecified_give: p = %.4f\n', p3);

fprintf('female_keep vs male_keep: p = %.4f\n', p4);
fprintf('female_keep vs unspecified_keep: p = %.4f\n', p5);
fprintf('male_keep vs unspecified_keep: p = %.4f\n', p6);

fprintf('female_give vs female_keep: p = %.4f\n', p7);
fprintf('male_give vs male_keep: p = %.4f\n', p8);
fprintf('unspecified_give vs unspecified_keep: p = %.4f\n', p9);
