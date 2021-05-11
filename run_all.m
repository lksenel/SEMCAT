clear
clc
close all

% Note: One can run these scripts individually as well since it takes a long time for all of them to complete. 

% This script reads vectors from the txt file (you should specify the path in the script) 
% and saves (if not already saved) to a mat file after limiting the vocabulary.
% Then it calculates and saves category weights using SEMCAT and Bhattacharya distance.
% Estimated run time: 1 minute (if vectors are already saved as a mat file)
calculate_category_weights 

% This script displays the obtained category weights for dimensions (W_B),
% plots the total representations strengths of the categories,
% plots the categorical decompositions od 3 different dimensions, along
% with dimensional decompositions of 3 different categories
analise_category_weights

% This script maps the original vectors to category weights (from Bhattacharya and category centers)
% to obtain interpretable semantic spaces I and I*. Then it plots the
% semantic decompositions of 4 different words using dimensions of I and I*.
map_word_vectors_to_categories


% This script maps the original vectors to category weights (from Bhattacharya and category centers)
% to obtain interpretable semantic spaces I and I*. Then it measures the
% interpretability of the 4 embedding spaces (Random, GloVe, I*, I) based on the categories in SEMCAT for different lambda
% values (i.e. lambda = 1:10) This script may take around 20 minutes
measure_interpretability_from_category_words


% This script maps the original vectors to category weights (from Bhattacharya and category centers)
% to obtain interpretable semantic spaces I and I*. Then it measures the
% interpretability of the 4 embedding spaces (Random, GloVe, I*, I) based on the categories in SEMCAT
% for lambda = 5 and n_min = 5:20. Its difference from the previous script is that
% it considers the possible subcategories within the categories of SEMCAT. This script may take around 4 hours with
% these parameters
measure_interpretability_from_subcategory_words
