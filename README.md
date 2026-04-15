# Gender-bias-in-AI-mediated-economic-decisions
The repository contains data and code for the project

We are using Python to get the data and MATLAB to analyze the data.

For the folders <Baseline>, <Fair>, <Self-interested>, <Socially appropriate>. They have the same structure.

In each folder, itcontains two sub-folders: <Obtain_the_data> and <Analysis_of_the _data>.

<Obtain_the_data> contain two py. files, one is to obtain the date from ChatGPT and record their responses. Another py file called <Extraction> is transfer ChatGPT’s responses to the data and the data is saved in the <Analysis_of_the _data> foleder for our analysis purpose.

In <Analysis_of_the _data> folder:

1.The file 'ChatGPT_4o_distribution_give' generates the figure of distribution of AI’s decision in the give framing.

2.The file 'ChatGPT_4o_overall_give' generates the figure of the mean amount kept by AI in the give framing.

3.The file 'ChatGPT_4o_distribution_keep' generates the figure of distribution of AI’s decision in the keep framing.

4.The file 'ChatGPT_4o_overall_keep' generates the figure of the mean amount kept by AI in the keep framing.

5.The file 'Willcoxon_rank_sum' generates all Willcoxon_rank_sum tests in the paper.


For the folders <Comparison>, it contains data from baseline and socially appropriate treatments and compare them. 
