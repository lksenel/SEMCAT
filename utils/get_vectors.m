function [ selected_vectors, missing_word_indices, word_indices ] = get_vectors( selected_vocab, full_vocab, full_vectors )
% get_vectors: takes list of selected vocabulary words, full vocabulary
% words as cell array, and full vectors as integer matrix where rows
% correspond to words in full vocabulary and colums correspond to
% dimensions.
    
    selected_vectors = zeros(length(selected_vocab),size(full_vectors,2));
    missing_word_indices = zeros(length(selected_vocab),1);
    word_indices = zeros(length(selected_vocab),1);
    missing_word_count = 0;
    valid_word_count = 0;
    for i = 1:length(selected_vocab) 
        if ~strcmp(selected_vocab{i},'')
            loc = find(strcmp(full_vocab, selected_vocab{i}));
            if isempty(loc)
                missing_word_count = missing_word_count + 1;
                missing_word_indices(missing_word_count) = i;
%                 fprintf('%s\n',selected_vocab{i})
            else
                valid_word_count = valid_word_count + 1;
                selected_vectors(valid_word_count,:) = full_vectors(loc,:);
                word_indices(valid_word_count) = loc;
            end
        end
    end
    selected_vectors = selected_vectors(1:valid_word_count,:);
    word_indices = word_indices(1:valid_word_count);
    missing_word_indices = missing_word_indices(1:missing_word_count);
end

