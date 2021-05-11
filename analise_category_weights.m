clear

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

if isfile('category_weights.mat')
    load('category_weights.mat')
else
    get_category_weights
end

figure('Position', [500,0,500,1200]), imagesc(category_weights), colorbar, colormap('hot'), xlabel('Categories'), ylabel('Dimensions')

rep_strengths = sum(category_weights(:,1:end-1),1);
figure, bar(sort(rep_strengths,'descend')), hold on
plot(0:size(category_weights,2), repmat(sum(category_weights(:,end)),[size(category_weights,2)+1,1]), 'LineWidth', 3), xlabel('Categories'), ylabel('Representation Strength')

% Exclude random category for next analysis 
category_weights = category_weights(:,1:end-1);

dims = [2,6,45];

cat_names = ["math", "animal", "tools"];
cat_inds = find(ismember(category_names, 'math'));

figure('Position', [500,200,1200,600]), 

subplot(3,2,1),
bar(category_weights(dims(1),:)), xlabel('Categories'), ylabel('Weight'), title(sprintf('Categorical decomposition of $%d^{th}$ dimension',dims(1)))
subplot(3,2,3),
bar(category_weights(dims(2),:)), xlabel('Categories'), ylabel('Weight'), title(sprintf('Categorical decomposition of $%d^{th}$ dimension',dims(2)))
subplot(3,2,5),
bar(category_weights(dims(3),:)), xlabel('Categories'), ylabel('Weight'), title(sprintf('Categorical decomposition of $%d^{th}$ dimension',dims(3)))

subplot(3,2,2),
bar(category_weights(:,find(ismember(category_names, cat_names(1))))), xlabel('Dimensions'), ylabel('Weight'), title(sprintf('Categorical decomposition of the %s category',cat_names{1}))
subplot(3,2,4),
bar(category_weights(:,find(ismember(category_names, cat_names(2))))), xlabel('Dimensions'), ylabel('Weight'), title(sprintf('Categorical decomposition of the %s category',cat_names{2}))
subplot(3,2,6),
bar(category_weights(:,find(ismember(category_names, cat_names(3))))), xlabel('Dimensions'), ylabel('Weight'), title(sprintf('Categorical decomposition of the %s category',cat_names{3}))




