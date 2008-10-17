/**
 * jGlycy
 * (c) 2008 Semooh (http://semooh.jp/)
 * 
 */
(function($j, prefix, jg){
  jQuery[jg] = $({});
  jQuery[jg].extend({
    invoke: function(nodes) {
      nodes.each(function(){
        var node = this;
        var funcs = jQuery(node).attr(prefix).split(',');
        jQuery(funcs).each(function(){
          var arg = jQuery(node).attr(prefix + ":" + this);
          if(arg) {
            eval('var options = {' + arg + '}');
          } else {
            var options = {};
          }
          if(jQuery.fn[this]) {
            jQuery(node)[this](options);
          }
        });
      });
    },
    invokeElement: function(node) {
      jQuery[jg].invoke(jQuery("*[" + prefix + "]", node));
    }
  });
  jQuery(document).ready(function(){
    jQuery[jg].invokeElement(document);
  });
})(jQuery, "jg", "jg");