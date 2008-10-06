// JavaScript Document
/* 
 * !!DO NOT DELETE THIS COMMENT!!
 *
 * Launding Page Optimize(LPO) Message library
 * (c)2008 Yusuke Ohmichi(Maimuzo)
 * MIT and GPL license
 * - Website: http://fromnorth.blogspot.com/
 */


var LPOLastMessage;

function LPOCallback(json){
	for(var index in json){
		showLPOMessage(json[index]["message"], json[index]["url"]);
	}
	$j('#LPOToggle').css('display', 'block');
	LPOLastMessage = json;
}

function LPOShowAgain(){
	LPOCallback(LPOLastMessage);
}

function showLPOMessage(text, url){
	if(url){
		var message = '<a href="' + url + '">' + text + '</a>';
	}else{
		var message = text;
	}
	$j('#LPOPanel').jGrowl(message, {
		header: 'ググってきた方へのオススメ',
		theme: 'LPOMessagePanel',
		life: 15000, 
		glue: 'before',
		speed: 2000,
		easing: 'easeInOutElastic',
		animateOpen: { 
			height: "show",
			width: "show"
		},
		animateClose: { 
			height: "hide",
			width: "show"
		}
	});
}
