
%%%%%%%%%%%%%%%%%%
% This section contains all Descriptive statistics
%%%%%%%%%%%%%%%%%%
clear;
clc;

%1. Load data
% ==========================================================

alldata = readtable('data_fair.xlsx');

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




%% ---------------------------------------------------------
% Descriptive statistics for baseline treatment
% ----------------------------------------------------------

groups = {
    female_give
    male_give
    unspecified_give
    female_keep
    male_keep
    unspecified_keep
};

Framing = {
    'Give'
    'Give'
    'Give'
    'Keep'
    'Keep'
    'Keep'
};

Recipient = {
    'Female'
    'Male'
    'Unspecified'
    'Female'
    'Male'
    'Unspecified'
};

nGroup = length(groups);

N = zeros(nGroup,1);
Mean = zeros(nGroup,1);
SD = zeros(nGroup,1);

EqualSplit = zeros(nGroup,1);
NearTotalKeep = zeros(nGroup,1);
Other = zeros(nGroup,1);

for i = 1:nGroup
    
    x = groups{i};

    % Basic descriptive statistics
    N(i) = length(x);
    Mean(i) = mean(x);
    SD(i) = std(x);

    % Equal split: AI keeps exactly $50
    EqualSplit(i) = 100 * mean(x == 50);

    % Near-total keep: AI keeps $90-$100
    NearTotalKeep(i) = 100 * mean(x >= 90 & x <= 100);

    % All remaining allocations
    Other(i) = 100 * mean((x ~= 50) & ~(x >= 90 & x <= 100));

end

%% Create Table

Table1 = table( ...
    string(Framing), ...
    string(Recipient), ...
    N, ...
    Mean, ...
    SD, ...
    EqualSplit, ...
    NearTotalKeep, ...
    Other, ...
    'VariableNames', { ...
        'Framing', ...
        'Recipient', ...
        'N', ...
        'Mean', ...
        'SD', ...
        'EqualSplitPercent', ...
        'NearTotalKeepPercent', ...
        'OtherPercent' ...
    } ...
);

% Round results
Table1.Mean = round(Table1.Mean, 2);
Table1.SD = round(Table1.SD, 2);
Table1.EqualSplitPercent = round(Table1.EqualSplitPercent, 2);
Table1.NearTotalKeepPercent = round(Table1.NearTotalKeepPercent, 2);
Table1.OtherPercent = round(Table1.OtherPercent, 2);

disp(Table1);
