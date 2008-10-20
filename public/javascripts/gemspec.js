/* 
 * Initialize code
 */
var $j = jQuery.noConflict();
$j(document).ready( function() 
{
  // for search
  $j('.niceforms').jForms({listSize:20, imagePath:'/images/niceforms/default/'});
  //$j('div.niceforms').jForms({listSize:20, imagePath:'/images/niceforms/default/'});
  $j('input.coolinput').coolinput({blurClass: 'pre-input'});

  // for title
  $j('.part-of-title').corner();

  // for search panel detail 
  $j('#search-detail-toggle').click(function () {
    $j('#search-detail-panel').slideToggle();
    if('none' == $j('#search-detail-panel').css("display")){
      $j('#search-detail-panel+input').val("");
      $j('#license').val("");
    }
    target = $j('#search-detail-toggle');
    if('▽' == target.val()){
      target.val("△");
    }else{
      target.val("▽");
    }
  });
	
  // for licensers
  $j('#licenser-toggle').click(function (e) {
    e.preventDefault();
    $j('#licenserPanel').modal();
  });

  // lastupdate slider
  $j("#search-detail-toggle").one("click", function(){
    // lastupdate slider
    $j('#last-update-slider').makeSlider(2, 170, false);
    // jForm enable for select
    $j('#niceforms-select').jForms({listSize:20, imagePath:'./images/niceforms/default/'});
  });
} );
/*
enhancedDomReady(function(){
	$('#last-update-slider').makeSlider(2, 380); // enable time slider
});
*/
function emuJsonP(){
	eval('LPOCallback([ { "message" : "今日のオススメは×××です。興味ある方はクリックしてください", "url" : "gem.html" },  { "message" : "今日のオススメは○○○です。興味ある方はクリックしてください", "url" : "mypage.html" }, { "message" : "今日のオススメは無いので天気予報です。晴れです。", "url" : "" }, { "message" : "今日のオススメは無いので天気予報です。曇りです。", "url" : "" } ])');
}


