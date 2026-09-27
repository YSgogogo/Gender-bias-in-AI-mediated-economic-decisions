# Gender-bias-in-AI-mediated-economic-decisions
Data and Code
We are using Python to get the data and MATLAB to analyze the data.

For the folders Baseline, Fair, Self_interested, Socially_appropriate. They have the similar structure.

In each folder, it contains two sub-folders: Obtain_the_data and Analysis_of_the_data.

<Obtain_the_data> contain py. files to obtain the data from (Chat)GPT and record their responses and to transfer (Chat)GPT’s responses to the data and the data is saved in the <Analysis_of_the_data> folder for our analysis purpose.

In <Analysis_of_the_data> folder:

1.The file 'ChatGPT_4o_distribution_give' generates the figure of distribution of AI’s decision in the give framing.

2.The file 'ChatGPT_4o_overall_give' generates the figure of the mean amount kept by AI in the give framing.

3.The file 'ChatGPT_4o_distribution_keep' generates the figure of distribution of AI’s decision in the keep framing.

4.The file 'ChatGPT_4o_overall_keep' generates the figure of the mean amount kept by AI in the keep framing.

5.'Wilcoxon_rank_Holm_correction' related files generate all Willcoxon_rank_sum tests and corrections in the paper.

6.‘Descriptive_statistics’ related files generate all Descriptive_statistics for the paper
