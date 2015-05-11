function = fuzzycluster(source_data, output_file_path, lamda_setting)
   % all input and output files
   raw_data_file = source_data;  % raw data file, contains only sample data, one sample per line
   normalized_data_file = output_file_path + '\step1_normalized_data.txt';  % the normalized data file
   similarity_data_file = output_file_path + '\step2_similarity_data.txt';  % the similarity data file
   output_transitive_closure = output_file_path + '\step3_transitive_closure.txt';  % the output transitive closure matrix file
   lamda = lamda_setting;
   transformed_path = strrep(output_file_path, '\', '\\');
   cut_matrix_file = sprintf('%s\\step4_cut_matrix_lamda_%4.2f.txt', transformed_path, lamda);
   final_group_result = sprintf('%s\\step5_final_group_result_lamda_%4.2f.txt', transformed_path, lamda);

   % read raw data into matrix
   [raw_data] = load('-ascii', raw_data_file);

   % normalization
   num_attrs = length(raw_data(1, :));
   num_samples = length(raw_data(:, 1));
   normalized_data = [];
   for i = 1 : num_attrs,
      [per_attr] = raw_data(:, i);
      per_attr = (per_attr - mean(per_attr)) / std(per_attr);
      normalized_data = [normalized_data, per_attr];
   end;
   save(normalized_data_file, 'normalized_data', '-ascii');
   disp('calculate normalized data ... done.');
    
   % calculate similarity relations between different samples
   distance_data = zeros(num_samples);
   for i = 1 : (num_samples-1),
      for j = (i + 1) : num_samples,
         distance_data(i, j) = sqrt(sum(power(normalized_data(i, :) - normalized_data(j, :), 2)));
         distance_data(j, i) = distance_data(i, j);
      end;
   end; 
   similarity_data = ones(num_samples );
   max_distance = max(max(distance_data));
   for i = 1 : (num_samples-1),
      for j = (i + 1) : num_samples,
         similarity_data(i, j) = 1 - distance_data(i, j) / max_distance;
         similarity_data(j, i) = similarity_data(i, j);
      end;
   end; 
   save(similarity_data_file, 'similarity_data', '-ascii');
   disp('calculate similarity data ... done.');

   % calculate transitive closure
   base_data = similarity_data;
   step_result = [];
   isEqual = 0;
   num_rows = num_cols = num_samples;
   while isEqual == 0
      for i = 1 : num_rows
         for j = 1 : num_cols
            step_result(i, j) = max(min(base_data(i, :), base_data(:, j)'));
         end
      end
      if step_result == base_data
         isEqual = 1;
      else
         base_data = step_result;
      end
   end
            
   % write transitive closure to output_transitive_closure
   save(output_transitive_closure, 'base_data', '-ascii');
   disp('calculate transitive closure ... done.');

   % calculate cut matrix
   cut_matrix = base_data > lamda;
   save(cut_matrix_file, 'cut_matrix', '-ascii');
   disp('calculate cut matrix  ... done.');

   % calculate the final group result
   final_group_map = struct;
   for i = 1 : num_samples,
      lineData = sprintf("%d", cut_matrix(i, :));
      if isfield(final_group_map, sprintf("%s", lineData)),
         final_group_map.(sprintf("%s", lineData)) = [final_group_map.(sprintf("%s", lineData)), i];
      else
         final_group_map.(sprintf("%s", lineData)) = i;
      end;
   end;
   file_id = fopen(final_group_result, 'w');
   for [val, key] = final_group_map,
      fprintf(file_id, "%d ", val)
      fprintf(file_id, "\n");
   end
   fclose(file_id);
   disp('calculate final group result ... done.');
   clear all;
end;