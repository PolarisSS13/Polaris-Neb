/decl/hierarchy
	abstract_type = /decl/hierarchy
	decl_flags = DECL_FLAG_ALLOW_ABSTRACT_INIT // for the children list
	var/name = "Hierarchy"
	var/decl/hierarchy/parent
	var/list/decl/hierarchy/children
	/// The cached result of get_descendants(). Should not be mutated.
	VAR_PRIVATE/list/decl/hierarchy/_descendants
	var/expected_type

/decl/hierarchy/Initialize()
	children = list()
	if(ispath(expected_type))
		for(var/subtype in subtypesof(type))
			var/decl/hierarchy/child = GET_DECL(subtype) // Might be a grandchild, which has already been handled.
			if(child.parent_type == type && istype(child, expected_type))
				dd_insertObjectList(children, child)
				child.parent = src
	. = ..()

/decl/hierarchy/proc/is_category()
	return length(children)

/decl/hierarchy/proc/get_descendants()
	if(!children)
		return
	if(_descendants)
		return _descendants
	_descendants = children.Copy()
	for(var/decl/hierarchy/child in children)
		if(child.children)
			_descendants |= child.get_descendants()
	return _descendants

/decl/hierarchy/dd_SortValue()
	return name
