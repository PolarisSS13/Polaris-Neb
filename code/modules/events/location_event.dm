/datum/event/loreplace_event
	endWhen = 10

/datum/event/loreplace_event/proc/get_possible_events(var/decl/cultural_info/loreplace/affected_dest)
	. = affected_dest.viable_mundane_events

/datum/event/loreplace_event/announce()
	var/decl/cultural_info/loreplace/affected_dest = GET_DECL(pick(global.using_map.available_cultural_info[TAG_HOMECULTURE]))
	if(istype(affected_dest))
		var/list/possible_events = get_possible_events(affected_dest)
		if(length(possible_events))
			var/event_type = pick(possible_events)
			if(ispath(event_type, /decl/loreplace_event))
				var/decl/loreplace_event/event = GET_DECL(event_type)
				news_network.SubmitArticle(event.announce(affected_dest), "News Daily", "News Daily", null, 1)

/datum/event/loreplace_event/mundane_news
	endWhen = 50
	announceWhen = 15

/datum/event/loreplace_event/mundane_news/start()
	endWhen = rand(60,300)

/datum/event/loreplace_event/mundane_news/get_possible_events(var/decl/cultural_info/loreplace/affected_dest)
	. = affected_dest.viable_random_events
