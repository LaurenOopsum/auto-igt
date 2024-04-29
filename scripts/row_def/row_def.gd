## Template for creating preview rows

class_name RowDef
extends HBoxContainer

## Setup used for presets
func setup_row(row_num : int, line_array : Array) :
	$RowNum.text = str(row_num)
	if row_num == 1 && line_array[0] == C.TYPE.PHRASE : 
		$Italic.pressed = true
	if row_num == V.line_count : $Quotes.pressed = true
	$Level.text = $Level.get_popup().get_item_text(line_array[0])

	$Type._on_level_changed(line_array[0])
	$Type.set_default_value(line_array[1])
	
## Rows created when row count is changed
## or when generated with custom preset
func setup_blank_row(row_num : int) :
	$RowNum.text = str(row_num)

## Array of template settings
func get_settings() -> Array :
	return [$Level.text, $Type.text, $Italic.pressed, $Bold.pressed, $Quotes.pressed]
