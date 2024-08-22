//base human language
/decl/language/human
	name = "proto-sapien"
	desc = "This is the human root language. If you have this, please tell a developer."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = "solcom"
	flags = LANG_FLAG_WHITELISTED | LANG_FLAG_RESTRICTED
	shorthand = "???"
	space_chance = 40
	abstract_type = /decl/language/human

/decl/language/human/get_spoken_verb(mob/living/speaker, msg_end)
	switch(msg_end)
		if("!")
			return pick("exclaims","shouts","yells")
		if("?")
			return ask_verb
	return speech_verb

/decl/language/human/get_random_name(var/gender)
	if (prob(80))
		if(gender==FEMALE)
			return capitalize(pick(global.using_map.first_names_female)) + " " + capitalize(pick(global.using_map.last_names))
		else
			return capitalize(pick(global.using_map.first_names_male)) + " " + capitalize(pick(global.using_map.last_names))
	else
		return ..()

/*//////////////////////////////////////////////////////////////////////////////////////////////////////
	Syllable list compiled in this file based on work by Stefan Trost, available at the following URLs
						https://www.sttmedia.com/syllablefrequency-english
						https://www.sttmedia.com/syllablefrequency-french
						https://www.sttmedia.com/syllablefrequency-spanish
						http://www.sttmedia.com/syllablefrequency-russian

	Additional Mandarin syllables originally sourced from:
						http://www.chinahighlights.com/
*///////////////////////////////////////////////////////////////////////////////////////////////////////

/decl/language/human/common
	name = "Galactic Common"
	desc = "Galactic Common, or GalCom is by far the most commonly spoken language in human space, Galactic Common was \
	deliberately engineered over long years by dedicated teams of linguists from 2360 onwards as a hybrid of the earlier \
	Sol Common and Common Skrellian in order to facilitate interspecies communication with the skrell. The language has \
	been adopted as the official language of the Solar Confederate Government, and some degree of fluency is often a \
	requirement for employment by major Trans-Stellar Corporations to ensure that all of their employees are capable of \
	at least basic communication. "
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = ""
	key = "0"
	flags = LANG_FLAG_WHITELISTED
	shorthand = "C"
	partial_understanding = list()
	syllables = list(
	"vol", "zum", "coo","zoo","bi","do","ooz","ite","og","re","si","ite","ish",
	"ar","at","on","ee","east","ma","da", "rim")


/decl/language/human/solcom
	name = "Solar Common"
	desc = "An early standardized hybrid of many languages, including  elements of English, French, Standard \
	Chinese, Hindi, Spanish, Arabic, and Russian, while eliminating phonemes that would prove difficult for any \
	particular existing cultural group to pronounce. It is the common language of the Sol system, but has been \
	phased out of official usage and is beginning to fade like so many of Earth's ancient languages did in \
	centuries prior."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = ""
	key = "1"
	flags = LANG_FLAG_WHITELISTED
	shorthand = "Sol"
	partial_understanding = list()
	syllables = list(
"a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao",
"bie", "bin", "bing", "bo", "bu", "ca", "cai", "can", "cang", "cao", "ce", "cei", "cen", "ceng", "cha", "chai",
"chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chua", "chuai", "chuan", "chuang", "chui", "chun",
"chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei",
"den", "deng", "di", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e",
"ei", "en", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu", "ga", "gai", "gan", "gang",
"gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha",
"hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hm", "hng", "hong", "hou", "hu", "hua", "huai", "huan",
"huang", "hui", "hun", "huo", "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan",
"jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "kei", "ken", "keng", "kong", "kou", "ku", "kua", "kuai",
"kuan", "kuang", "kui", "kun", "kuo", "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian",
"liang", "liao", "lie", "lin", "ling", "liu", "long", "lou", "lu", "luan", "lun", "luo", "ma", "mai", "man", "mang",
"mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu", "na",
"nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ng", "ni", "nian", "niang", "niao", "nie", "nin", "ning",
"niu", "nong", "nou", "nu", "nuan", "nuo", "o", "ou", "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng",
"pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin",
"qing", "qiong", "qiu", "qu", "quan", "que", "qun", "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou",
"ru", "rua", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sei", "sen", "seng", "sha",
"shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui",
"shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo", "ta", "tai", "tan", "tang", "tao", "te",
"teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan",
"wang", "wei", "wen", "weng", "wo", "wu", "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu",
"xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yong", "you", "yu", "yuan",
"yue", "yun", "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao",
"zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi",
"zong", "zou", "zuan", "zui", "zun", "zuo", "zu",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
"ah", "be", "bo", "eh", "ep", "et", "ka", "ko", "ha", "he", "ho", "ob", "oh", "op", "oc", "ot", "pa", "pe", "ct", "ta", "te", "to",
"vse", "tak", "nak", "no", "epo", "pre", "kan", "dly", "ime", "sha", "kur", "yey", "khi", "yeg", "ne",
"ion", "ne", "nas", "v",
"ah", "be", "bo", "eh", "ep", "et", "ka", "ko", "ha", "he", "ho", "ob", "oh", "op", "oc", "ot", "pa", "pe", "ct", "ta", "te", "to",
"vse", "tak", "nak", "no", "epo", "pre", "kan", "dly", "ime", "sha", "kur", "yey", "khi", "yeg", "ne",
"ion", "ne", "nas", "v",
"ah", "be", "bo", "eh", "ep", "et", "ka", "ko", "ha", "he", "ho", "ob", "oh", "op", "oc", "ot", "pa", "pe", "ct", "ta", "te", "to",
"vse", "tak", "nak", "no", "epo", "pre", "kan", "dly", "ime", "sha", "kur", "yey", "khi", "yeg", "ne",
"ion", "ne", "nas", "v",
"ai", "an", "ar", "au", "ce", "ch", "co", "de", "em", "en", "er", "es", "et", "eu", "il", "in", "is", "la", "le",
"ma", "me", "ne", "ns", "nt", "on", "ou", "pa", "qu", "ra", "re", "se", "te", "ti", "tr", "ue", "ur", "us", "ve",
"tou", "e", "eve", "hen", "son", "non", "not", "le",
"ai", "an", "ar", "au", "ce", "ch", "co", "de", "em", "en", "er", "es", "et", "eu", "il", "in", "is", "la", "le",
"ma", "me", "ne", "ns", "nt", "on", "ou", "pa", "qu", "ra", "re", "se", "te", "ti", "tr", "ue", "ur", "us", "ve",
"tou", "e", "eve", "hen", "son", "non", "not", "le",
"ai", "an", "ar", "au", "ce", "ch", "co", "de", "em", "en", "er", "es", "et", "eu", "il", "in", "is", "la", "le",
"ma", "me", "ne", "ns", "nt", "on", "ou", "pa", "qu", "ra", "re", "se", "te", "ti", "tr", "ue", "ur", "us", "ve",
"tou", "e", "eve", "hen", "son", "non", "not", "le",
"ad", "al", "an", "ar", "as", "ci", "co", "de", "do", "el", "en", "er", "es", "ie", "in", "la", "lo", "me", "na",
"no", "nt", "or", "os", "pa", "qu", "ra", "re", "ro", "se", "st", "ta", "te", "to", "ue", "un",
"tod", "ser", "su", "no", "nue", "el",
"ad", "al", "an", "ar", "as", "ci", "co", "de", "do", "el", "en", "er", "es", "ie", "in", "la", "lo", "me", "na",
"no", "nt", "or", "os", "pa", "qu", "ra", "re", "ro", "se", "st", "ta", "te", "to", "ue", "un",
"tod", "ser", "su", "no", "nue", "el",
"ad", "al", "an", "ar", "as", "ci", "co", "de", "do", "el", "en", "er", "es", "ie", "in", "la", "lo", "me", "na",
"no", "nt", "or", "os", "pa", "qu", "ra", "re", "ro", "se", "st", "ta", "te", "to", "ue", "un",
"tod", "ser", "su", "no", "nue", "el")

/decl/language/human/sivian
	name = "Sivian Creole"
	desc = "A hybrid language local to the Vir system, heavily incorporating elements from the local languages of early Scandinavian colonists into a form of Galactic Common."
	speech_verb = "says"
	whisper_verb = "whispers"
	colour = ""
	key = "7"
	flags = LANG_FLAG_WHITELISTED
	shorthand = "Sif"
	space_chance = 45
	partial_understanding = list()
	syllables = list (
	"all", "are", "det", "enn", "ere", "hen", "kan", "lig", "men", "ren", "som", "ver", "vir", "var", "vis", "ikk", "ter", "ork",
	"den", "ing", "jeg", "jag", "han", "hir", "hil", "ans", "kan", "kir", "bor", "bir", "um", "om", "ve", "ur", "ha", "he", "hyu",
	"er", "ad", "ath", "bjo,", "gun", "gur", "gir", "fyr", "thar", "thir", "thad", "thei", "ayr", "for", "fjo", "jor", "jik", "jar",
	"yor", "yar", "yik", "rik", "os", "olm", "erm", "ferk", "borg", "bork", "smorg", // Scandi
	"meng", "tao", "bu", "qu", "ai", "xin", "pin", "wa", "cang", "chun", "ding", "gang", "ling", "gao", "jian", "sun", "tong",
	"xie", "zu", "miao", "po", "nu", // Chinese (galcom)
	"our", "oul", "tou", "eve", "ome", "ion", "ais", // Romance (galcom)
	"zaoo", "zix", "vol") //Skrell (galcom)
