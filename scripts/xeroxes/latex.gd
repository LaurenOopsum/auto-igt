
class_name LatexXerox
extends Xerox



func clipboard_copy() :
	var latext : String = C.OPEN_CLOSE[C.MARKUP.LATEX][0]
	
	var row_node_arrays := get_row_node_arrays()
	
	var col_count := get_col_count(row_node_arrays)
	
	latext += define_columns(col_count)
	
	latext += print_markup_rows(row_node_arrays, col_count) 
	
	latext += C.OPEN_CLOSE[C.MARKUP.LATEX][1]
	
	print(latext)


func get_row_node_arrays() -> Array :
	var row_node_arrays := []
	
	for template in rows_data :
		if template[0] == C.TYPE.PHRASE : 
			row_node_arrays.append([phrase])
		else :
			var type_array := phrase.get_type_array(template[0])
			type_array = _trim_type_array(type_array, template[1].split("-"))
			row_node_arrays.append(type_array)
	
	return row_node_arrays


func _trim_type_array(type_array : Array, match_array : PoolStringArray) :
	var to_delete := []
	
	for type_node in type_array :
		var t_items : Array = type_node.get_matching_items(match_array)
		if t_items.empty() : to_delete.append(type_node)
	
	for x in to_delete :
		type_array.erase(x)
	
	return type_array


func get_col_count(row_node_arrays : Array) -> int :
	var cols := 1
	for row in row_node_arrays :
		if row.size() > cols : cols = row.size()
	return cols


func define_columns(col_count : int) -> String :
	var latext := ""
	for x in col_count :
		latext += "l "
	return latext + "}\n"


func print_markup_rows(row_node_arrays : Array, col_count : int) -> String :
	var latext := ""
	
	var match_patterns = rows_data.duplicate()
	
	for row in row_node_arrays :
		var match_pattern : PoolStringArray = match_patterns.pop_front()[1].split("-")
		match row[0].node_type :
			C.TYPE.PHRASE : latext += _mu_phrase_row(row, col_count, match_pattern)
			C.TYPE.WORD : latext += _mu_word_row(row, row_node_arrays, match_pattern)
			C.TYPE.MORPH : latext += _mu_morph_row(row, match_pattern)
		latext += " \\\\\n"
	
	return latext 
	

func _mu_phrase_row(row : Array, col_count : int, match_pattern : PoolStringArray) -> String : 
	return "\t" + add_multicol_val(row[0], match_pattern, col_count)

func _mu_word_row(row : Array, row_node_arrays : Array, match_pattern : PoolStringArray) -> String : 
	var latext := "\t"
	
	var morph_locs := _get_morph_locations(row_node_arrays)
	
	if morph_locs.size() > 0 : 
		var morph_row : Array = row_node_arrays[morph_locs[0]]
		latext += _set_words_yes_morphs(row, morph_row, match_pattern)
	else : latext += _set_words_no_morphs(row, match_pattern)
	
	return latext


func _get_morph_locations(row_node_arrays : Array) -> PoolIntArray :
	var locations : PoolIntArray = []
	var index := 0
	for row in row_node_arrays :
		if row[0].node_type == C.TYPE.MORPH :
			locations.append(index)
		index += 1
	return locations


func _set_words_yes_morphs(row : Array, morph_row : Array, match_pattern : PoolStringArray) -> String :
	var latext := ""
	for word in row :
		var morph_count := 0
		for morph in morph_row :
			if morph.get_parent() == word : morph_count += 1
		if morph_count > 1 : 
			latext += add_multicol_val(word, match_pattern, morph_count)
			latext += " & "
		else : latext += add_single_val(word, match_pattern)
	latext = latext.rstrip(" & ")
	return latext


func _set_words_no_morphs(row : Array, match_pattern : PoolStringArray) -> String:
	var latext := ""
	for word in row : latext += add_single_val(word, match_pattern)
	latext = latext.rstrip(" & ")
	return latext


func add_single_val(val : GlossNode, match_pattern : PoolStringArray) -> String :
	var latext := ""
	var match_items : Array = val.get_matching_items(match_pattern)
	for item in match_items :
		latext += item.node_value + " & "
	return latext
	
func add_multicol_val(word : GlossNode, match_pattern : PoolStringArray, col_count : int) -> String :
	var latext := "\\multicolumn{" + str(col_count) + "}{ l }{"
	var item : Array = word.get_matching_items(match_pattern)
	latext += item[0].node_value
	
	return latext + "}"


func _mu_morph_row(row : Array, match_pattern : PoolStringArray) -> String : 
	var latext := "\t"
	for morph in row :
		latext += add_single_val(morph, match_pattern)
	latext = latext.rstrip(" & ")
	return latext