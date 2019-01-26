# {
# 	inst_id_or_path1:{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	},
# 	inst_id_or_path2:{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	}
# }
var returns = {}
var _gut = null
var _utils = load('res://addons/gut/utils.gd').new()

func _is_instance(obj):
	return typeof(obj) == TYPE_OBJECT and !obj.has_method('new')

func _get_path_from_variant(obj):
	var to_return = null

	match typeof(obj):
		TYPE_STRING:
			to_return = obj
		TYPE_OBJECT:
			if(_is_instance(obj)):
				# these next two lines would work if godot allowed us to call
				# inst2dict on an instance that didn't come from res://
				# but since we can't do that, there doesn't appear to be a way
				# to get the subpath from an instance so we cannot stub at the
				# class level for inner classes, only at the instance level.
				#		var d = inst2dict(obj)
				#		to_return = d['@path']
				to_return = obj.get_script().get_path()
			else:
				to_return = obj.resource_path
	return to_return

func _add_obj_method(obj, method):
	var key = _get_path_from_variant(obj)
	if(_is_instance(obj)):
		key = obj

	if(!returns.has(key)):
		returns[key] = {}
	if(!returns[key].has(method)):
		returns[key][method] = []

	return key

# ##############
# Public
# ##############
func set_return(obj, method, value, parameters = null):
	var key = _add_obj_method(obj, method)
	var sp = _utils.StubParams.new(key, method)
	sp.parameters = parameters
	sp.return_val = value
	returns[key][method].append(sp)

func add_stub(stub_params):
	var key = _add_obj_method(stub_params.stub_target, stub_params.stub_method)
	returns[key][stub_params.stub_method].append(stub_params)

func get_return(obj, method, parameters = null):
	var key = _get_path_from_variant(obj)
	var to_return = null

	if(_is_instance(obj)):
		if(returns.has(obj) and returns[obj].has(method)):
			key = obj
		elif(obj.get('__gut_metadata_')):
			key = obj.__gut_metadata_.path

	if(returns.has(key) and returns[key].has(method)):
		var param_idx = -1
		var null_idx = -1

		for i in range(returns[key][method].size()):
			if(returns[key][method][i].parameters == parameters):
				param_idx = i
			if(returns[key][method][i].parameters == null):
				null_idx = i

		if(param_idx != -1):
			to_return = returns[key][method][param_idx].return_val
		elif(null_idx != -1):
			to_return = returns[key][method][null_idx].return_val

	return to_return

func get_gut():
	return _gut

func set_gut(gut):
	_gut = gut

func clear():
	returns.clear()
