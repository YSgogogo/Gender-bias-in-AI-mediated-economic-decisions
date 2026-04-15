
%%%%%%%%%%%%%%%%%%
% Where we get Figure 3b (Amount kept by AI in the give framing (out of
% $100))
%%%%%%%%%%%%%%%%%%

clear all
clc

alldata = table();   

for i = 1:4
    filename = ['output_fair_', num2str(i), '.xlsx'];
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

means = [mean(female_give), mean(male_give), mean(unspecified_give)];

%95% CI
alpha = 0.05; 
n_f = length(female_give);
n_m = length(male_give);
n_u = length(unspecified_give);

se_f = std(female_give)/sqrt(n_f);
se_m = std(male_give)/sqrt(n_m);
se_u = std(unspecified_give)/sqrt(n_u);

t_f = tinv(1-alpha/2, n_f-1);
t_m = tinv(1-alpha/2, n_m-1);
t_u = tinv(1-alpha/2, n_u-1);

ci_f = t_f * se_f;
ci_m = t_m * se_m;
ci_u = t_u * se_u;

ci = [ci_f, ci_m, ci_u];

% get bar
figure;
b = bar(means, 'FaceColor', [0.8 0.8 0.8]);  
hold on;

x = b.XEndPoints; 
errorbar(x, means, ci, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

for i = 1:length(means)
    text(x(i), means(i)+ci(i)+1, sprintf('%.2f', means(i)), ...
        'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);
end

set(gca, 'XTick', x, 'XTickLabel', {'Female', 'Male', 'Unspecified'});




ylim([-2 100]);
yticks(0:10:100);

xlimits = xlim();
for y = 0:10:100
    h = line(xlimits, [y y], 'Color', [0.85 0.85 0.85], ...
             'LineStyle','-', 'LineWidth', 0.8);
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    uistack(h,'bottom');
end

%ylabel('Average proposal assigned to AI');
%xlabel('ChatGPT-4o-give');

set(gca,'Layer','bottom');
box off
set(gcf,'Color',[0.98 0.98 0.98]);
set(gcf,'Position',[250 300 600 350]);

hold off;

saveas(gcf, 'ChatGPT-4o-overall-give_fair.png');