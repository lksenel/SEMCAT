clear

load('vectors.mat')
load('category_weights.mat')

vocab_size = size(vectors,1);

category_weights = category_weights(:,1:end-1);
category_signs = category_signs(:,1:end-1);
category_means = category_means(:,1:end-1);
category_names = category_names(1:end-1);
category_words = category_words(1:end-1);

% ---------- Generate I ----------
% normalize category weights using l1 norm
W_NB = category_weights./repmat(sum(category_weights,1),300,1); 
W_NSB = W_NB.*category_signs;

% Standardize word vectors
standard_vectors = ((vectors - repmat(mean(vectors,1),vocab_size,1)) ./ repmat(std(vectors),vocab_size,1));

I = standard_vectors * W_NSB;

% ---------- Generate I* ----------
I_star = vectors * category_means;


disp_cat_count = 20;
words = ["window","bus","soldier","article"];


% word category decomposition from I
figure('Position',[100,100,650,900])
for word_no = 1:length(words)
    word = words(word_no);
    [word_vec, ~, ~] = get_vectors(cellstr(word), vocab, I);

    [sorted_word_category_weights,ind] = sort(word_vec,'descend');
    ind = ind(1:disp_cat_count);
    sorted_word_category_weights = sorted_word_category_weights(1:disp_cat_count);

    c = category_names(ind);
          
    including_weights = zeros(disp_cat_count,1);
    not_including_weights = zeros(disp_cat_count,1);

    for i = 1:disp_cat_count
        c{i} = strrep(c{i}, '_', ' ');
        if isempty(find(strcmp(word, category_words{ind(i)}),1))
            not_including_weights(i) = sorted_word_category_weights(i);
        else
            including_weights(i) = sorted_word_category_weights(i);  
        end      
    end
        
    subplot(2,2,word_no),
    p1 = barh(not_including_weights);
    set(p1, 'FaceColor', 'blue');
    hold on
    p2 = barh(including_weights);
    set(p2, 'FaceColor', 'red');
    yticklabels(c), yticks((1:length(c))-0.4), ylim([0, disp_cat_count+1]),   
    title({sprintf('%s',word)})
end



% word category decomposition from I*
figure('Position',[1000,100,650,900])
for word_no = 1:length(words)
    word = words(word_no);
    [word_vec, ~, ~] = get_vectors(cellstr(word), vocab, I_star);
    
    [sorted_word_category_weights,ind] = sort(word_vec,'descend');
    ind = ind(1:disp_cat_count);
    sorted_word_category_weights = sorted_word_category_weights(1:disp_cat_count);

    c = category_names(ind);
          
    including_weights = zeros(disp_cat_count,1);
    not_including_weights = zeros(disp_cat_count,1);

    for i = 1:disp_cat_count
        c{i} = strrep(c{i}, '_', ' ');
        if isempty(find(strcmp(word, category_words{ind(i)}),1))
            not_including_weights(i) = sorted_word_category_weights(i);
        else
            including_weights(i) = sorted_word_category_weights(i);  
        end      
    end
        
    subplot(2,2,word_no),
    p1 = barh(not_including_weights);
    set(p1, 'FaceColor', 'blue');
    hold on
    p2 = barh(including_weights);
    set(p2, 'FaceColor', 'red');
    yticklabels(c), yticks((1:length(c))-0.4), ylim([0, disp_cat_count+1]),   
    title({sprintf('%s',word)})
end



