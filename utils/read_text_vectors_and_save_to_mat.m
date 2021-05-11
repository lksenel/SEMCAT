function [ vectors, vocab ] = read_text_vectors_and_save_to_mat( vector_file, dim, vocab_lim )

    formatspec = '%s';
    for i = 1:dim
        formatspec = [formatspec '%f'];
    end

    f = fopen(vector_file,'r','n','UTF-8');
    content = textscan(f, formatspec);

    vocab = content{1};
    vectors = zeros(length(vocab), dim);
    for i = 1:dim
        vectors(:,i) = content{i+1};
    end

    if nargin > 2
        vocab = vocab(1:vocab_lim);
        vectors = vectors(1:vocab_lim,:); 
    end
    save('vectors.mat','vectors','vocab')

end
