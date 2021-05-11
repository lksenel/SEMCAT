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


% Measure interpretability of from category words
% This may take a while (~20 minutes for lambda = 1:10)
lambdas = 1:10;
figure,
vector_types = ["Random","GloVe","I*","I"];
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

    cat_positive_interpretability_scores = zeros(dim, category_count, length(lambdas));
    cat_negative_interpretability_scores = zeros(dim, category_count, length(lambdas));

    tic           
    for cat_no = 1:category_count
        for dim_no = 1:dim    
            for lambda_no = 1:length(lambdas)
                lambda = lambdas(lambda_no);
                cat_positive_interpretability_scores(dim_no, cat_no, lambda_no) = nnz(ismember(category_words{cat_no}, sorted_vocabs(end-round(lambda*length(category_words{cat_no}))+1:end, dim_no)))/length(category_words{cat_no})*100;
                cat_negative_interpretability_scores(dim_no, cat_no, lambda_no) = nnz(ismember(category_words{cat_no}, sorted_vocabs(1:round(lambda*length(category_words{cat_no})), dim_no)))/length(category_words{cat_no})*100;       
            end
        end
        if rem(cat_no,10) == 0
            fprintf('Cat No: %d, Elapsed %d Hours %d minutes %d seconds\n', cat_no, floor(toc/3600), floor(rem(toc,3600)/60), round(rem(toc,60)))
        end
    end

    cat_interpretability_scores_for_each_dim = max(cat_positive_interpretability_scores, cat_negative_interpretability_scores);
    interpretability_scores_for_dimensions = squeeze(max(cat_interpretability_scores_for_each_dim, [], 2));
    average_interpretability_scores = squeeze(mean(interpretability_scores_for_dimensions,1));
    
    plot(lambdas, average_interpretability_scores,'linewidth',1.5), hold on 
end

title('Interpretability scores from category words'), xlabel('$\lambda$'), ylabel('Interpretability score (\%)'), grid, legend(vector_types)






