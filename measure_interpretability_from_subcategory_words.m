clear

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

load("vectors.mat")
load("category_weights.mat")

vocab_size = size(vectors,1);
dim = 300;

category_weights = category_weights(:,1:end-1);
category_signs = category_signs(:,1:end-1);
category_means = category_means(:,1:end-1);
category_names = category_names(1:end-1);
category_words = category_words(1:end-1);
category_count = length(category_names);

% ---------- Generate I ----------
% normalize category weights using l1 norm
W_NB = category_weights./repmat(sum(category_weights,1),dim,1); 
W_NSB = W_NB.*category_signs;

% Standardize word vectors
standard_vectors = ((vectors - repmat(mean(vectors,1),vocab_size,1)) ./ repmat(std(vectors),vocab_size,1));

I = standard_vectors * W_NSB;

% ---------- Generate I* ----------
I_star = vectors * category_means;


% Measure interpretability of from subcategory words 
% (method from paper "Interpretability Analysis for Turkish Word Embeddings" )
% This may take a couple of hours for min_cat_word_counts = 5:20; 

%Parameters
lambda = 5;
min_cat_word_counts = 5:20; 

tic
vector_types = ["Random","GloVe","I","I*"];
for vector_type_no = 1:4
    
    if vector_type_no == 1
       dim = 300;
       vec = randn(vocab_size,dim);       
    elseif vector_type_no == 2 
        dim = 300;
        vec = vectors;
    elseif vector_type_no == 3
        dim = category_count;
        vec = I_star;
    elseif vector_type_no == 4
        dim = category_count;
        vec = I;
    end
    vector_type = vector_types(vector_type_no);
    fprintf("******** Measuring interpretability for %s vectors ********\n", vector_type);
    
    [~, ind] = sort(vec);
    sorted_vocabs = vocab(ind);

    cat_positive_interpretability_scores = zeros(dim, category_count, length(min_cat_word_counts));
    cat_negative_interpretability_scores = zeros(dim, category_count, length(min_cat_word_counts));

    for min_cat_word_count_no = 1:length(min_cat_word_counts)   
        min_cat_word_count = min_cat_word_counts(min_cat_word_count_no);

        for cat_no = 1:category_count
            words = category_words{cat_no};

            max_range = lambda*length(words);
            for dim_no = 1:dim    
                Match=cellfun(@(x) ismember(x,words),sorted_vocabs(end-max_range+1:end, dim_no),'UniformOutput',0);
                positive_indices = find(cell2mat(Match))+length(vocab)-max_range;

                Match=cellfun(@(x) ismember(x,words),sorted_vocabs(1:max_range, dim_no),'UniformOutput',0);
                negative_indices = find(cell2mat(Match));

                if length(positive_indices) >= min_cat_word_count
                    for i = length(category_words):-1:min_cat_word_count
                        edge_word_count = sum(positive_indices >= (length(vocab)-lambda*i)+1);

                        if edge_word_count >= min_cat_word_count
                            score = edge_word_count/i*100;
                            if score > cat_positive_interpretability_scores(dim_no, cat_no, min_cat_word_count_no)
                                cat_positive_interpretability_scores(dim_no, cat_no, min_cat_word_count_no) = min(score,100);
                            end
                        end
                    end
                end

                if length(negative_indices) >= min_cat_word_count
                    for i = length(category_words):-1:min_cat_word_count
                        edge_word_count = sum(negative_indices <= lambda*i);

                        if edge_word_count >= min_cat_word_count
                            score = edge_word_count/i*100;
                            if score > cat_negative_interpretability_scores(dim_no, cat_no, min_cat_word_count_no)
                                cat_negative_interpretability_scores(dim_no, cat_no, min_cat_word_count_no) = min(score,100);
                            end
                        end
                    end
                end          
            end
        end
        fprintf('n_min: %d , Elapsed %d Hours %d minutes %d seconds\n', min_cat_word_count, floor(toc/3600), floor(rem(toc,3600)/60), round(rem(toc,60)))
    end

    cat_interpretability_scores_for_each_dim = max(cat_positive_interpretability_scores, cat_negative_interpretability_scores);
    interpretability_scores_for_dimensions = squeeze(max(cat_interpretability_scores_for_each_dim, [], 2));
    average_interpretability_scores = squeeze(mean(interpretability_scores_for_dimensions,1));

    plot(min_cat_word_counts, average_interpretability_scores,'linewidth',1.5), hold on 
end

title(sprintf('Interpretability scores from subcategory words for $\lambda = %d$',lambda)), xlabel('$n_{min}$'), ylabel('Interpretability score (\%)'), grid, legend(vector_types)












