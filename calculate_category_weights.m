Semcat_path = 'SEMCAT/';
vocab_lim = 5e4;
dim = 300;

tic
if isfile('vectors.mat')
    load('vectors.mat')
    fprintf('Vocabulary and vectors are loaded in %d seconds\n', round(toc));
else
    [vectors, vocab] = read_text_vectors_and_save_to_mat("English_vectors.txt" ,dim, vocab_lim);    
    fprintf('Vocabulary and vectors are read, vocabulary is limited to %d in %d seconds\n', vocab_lim, round(toc));
end 
% vectors = bsxfun(@rdivide,vectors,sqrt(sum(vectors.*vectors,2)));

category_files = dir(Semcat_path);
category_files = category_files(3:end); % remove additional files ('.' and '..')
category_count = length(category_files)+1;
category_names = cell(category_count,1);
cat_file_names = cell(category_count,1);
category_words = cell(category_count,1);

category_word_counts = zeros(category_count+1,1);
for category_no = 1:category_count
     %Include a category of randomly selected words
    if category_no == category_count
        category_word_counts(category_no) = round(mean(category_word_counts(1:end-1)));
        category_names{category_no} = 'random';        
    else
        name = category_files(category_no).name;
        cat_file_names{category_no} = name;
        split = strsplit(name,'-');
        count = split{end};
        count = str2double(count(1:end-4)); 
        category_names{category_no} = split{1};
        category_word_counts(category_no) = count;
    end
end

category_weights = zeros(dim,category_count);
category_signs = zeros(dim,category_count);
category_means = zeros(dim,category_count);
category_stds = zeros(dim,category_count);

tic
for category_no = 1:category_count
    
    if category_no == category_count
        % Randomly sample words from vocabulary generate random category
        words = vocab(randsample(vocab_lim,category_word_counts(category_no)));  
        category_words{category_no} = words;
    else
        f = fopen(sprintf('%s%s',Semcat_path,cat_file_names{category_no}),'r','n','UTF-8');
        words = textscan(f,'%s');
        words = words{1};
        category_words{category_no} = words;
        fclose(f);
    end
    
    [cat_word_vecs, ~, cat_word_inds] = get_vectors(words, vocab, vectors);

    for dim_no = 1:dim       
        rest = vectors(~ismember(1:length(vocab), cat_word_inds),dim_no);                                 
        cat = cat_word_vecs(:,dim_no);

        category_signs(dim_no,category_no) = sign(mean(cat) - mean(rest));

        %Bhattacharya distance between cathegory word vectors and rest is used as weight
        category_weights(dim_no,category_no) = 1/4*log(1/4*((var(rest)/var(cat))+(var(cat)/var(rest))+2)) + 1/4*((mean(cat)-mean(rest))^2/(var(cat) + var(rest)));
        category_means(dim_no,category_no) = mean(cat);
        category_stds(dim_no,category_no) = std(cat);
    end
end
save('category_weights.mat','category_weights','category_signs','category_means','category_stds','category_names','category_word_counts','category_words')
fprintf('Category weights are obtained and saved in %d seconds\n', round(toc));

