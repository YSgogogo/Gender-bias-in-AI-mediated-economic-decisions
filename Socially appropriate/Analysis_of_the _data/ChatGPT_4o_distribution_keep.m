
%%%%%%%%%%%%%%%%%%
% Where we get Figure 5c (Distribution of AI’s decision in the keep framing)
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


%% 

% Step 1. get the proportion
bins = 0:10:100;

female_counts = histcounts(female_keep, bins);
male_counts = histcounts(male_keep, bins);
unspecified_counts = histcounts(unspecified_keep, bins);

female_prop = 100 * female_counts / length(female_keep);
male_prop = 100 * male_counts / length(male_keep);
unspecified_prop = 100 * unspecified_counts / length(unspecified_keep);

group_data = [female_prop'  male_prop'  unspecified_prop'];  
group_data(group_data == 0) = NaN;


% Step 2. draw the graph and color etc. 
colors = [
    0.75 0.75 0.75;    % female
    0.55 0.55 0.55;    % male
    0.35 0.35 0.35     % unspecified
];

figure; hold on;

b = bar(group_data, 1, 'grouped');

for i = 1:3
    b(i).FaceColor = colors(i,:);
end

legend({'Female','Male','Unspecified'}, 'Location','northwest');

x = nan(size(group_data));
for i = 1:3
    x(:,i) = b(i).XEndPoints;
end

 
% Step 3. add numbers to the bar
%for i = 1:size(group_data,1)       
%    for j = 1:3                   
%        val = group_data(i,j);
%
%        if isnan(val)
%            continue;   
%        end

%        label = sprintf('%g', val);

%        ypos = val + 2;
%        text(x(i,j), ypos, label, ...
%            'HorizontalAlignment','center','FontSize',8);
%    end
%end


% Step 4. design the graph
xticks([]);
ylim([-2 100]);
yticks(0:10:100);
%ylabel('Percentage of the proposal assigned to AI');

xlimits = xlim();
for y = 0:10:100
    h = line(xlimits, [y y], 'Color', [0.85 0.85 0.85], ...
             'LineStyle','-', 'LineWidth', 0.8);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    uistack(h,'bottom');
end

xticks(1:10);
xticklabels({'0-10','10-20','20-30','30-40','40-50','50-60','60-70','70-80','80-90','90-100'});
set(gca, 'TickLength', [0 0]);   
%xlabel('Proposal assigned to AI');

set(gca,'Layer','bottom');
set(gcf,'Color',[0.98 0.98 0.98]);
set(gcf,'Position',[250 300 600 350]);

saveas(gcf, 'ChatGPT-4o-keep-distribution_sa.png');


